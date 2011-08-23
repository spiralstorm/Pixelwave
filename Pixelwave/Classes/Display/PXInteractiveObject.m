/*
 *  _____                       ___                                            
 * /\  _ `\  __                /\_ \                                           
 * \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
 *  \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
 *   \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
 *    \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
 *     \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
 *       
 *           www.pixelwave.org + www.spiralstormgames.com
 *                            ~;   
 *                           ,/|\.           
 *                         ,/  |\ \.                 Core Team: Oz Michaeli
 *                       ,/    | |  \                           John Lattin
 *                     ,/      | |   |
 *                   ,/        |/    |
 *                 ./__________|----'  .
 *            ,(   ___.....-,~-''-----/   ,(            ,~            ,(        
 * _.-~-.,.-'`  `_.\,.',.-'`  )_.-~-./.-'`  `_._,.',.-'`  )_.-~-.,.-'`  `_._._,.
 * 
 * Copyright (c) 2011 Spiralstorm Games http://www.spiralstormgames.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#import "PXInteractiveObject.h"

#include "PXPrivateUtils.h"

#import "PXStage.h"

// TODO Later: Remove these and their tap interaction - It should be a gesture.
#import "PXTouchEvent.h"
#import "PXEvent.h"
#import "PXPoint.h"
#import "PXLinkedList.h"

/**
 * A PXInteractiveObject is the abstract base class for all PXDisplayObjects
 * that can recieve user interaction events.
 */
@implementation PXInteractiveObject

@synthesize touchEnabled = _touchEnabled;
@synthesize captureTouches = _captureTouches;

- (id) init
{
	self = [super init];

	if (self)
	{
		PX_ENABLE_BIT(_flags, _PXDisplayObjectFlags_isInteractive);
		_touchEnabled = YES;

		_captureTouches = [PXStage mainStage].defaultCaptureTouchesValue;

		// Lists to track information for the tap events.
		pxInteractiveObjectTouchList = [[PXLinkedList alloc] init];
		pxInteractiveObjectTouchUpHistoryList = [[PXLinkedList alloc] init];
	}

	return self;
}

- (void) dealloc
{
	// Release the lists holding that kept track of the touch information.
	[pxInteractiveObjectTouchList release];
	pxInteractiveObjectTouchList = nil;

	[pxInteractiveObjectTouchUpHistoryList release];
	pxInteractiveObjectTouchUpHistoryList = nil;

	[super dealloc];
}

- (BOOL) dispatchEvent:(PXEvent *)event
{
	// Why do we make these variables here? Well, these variables keep track of
	// information required for us to know wether a tap event has occured. If we
	// create them within the 'if' statement, then it will not be possible for
	// us to contain all of the event dispatching code within a singular place.
	BOOL sendTap = NO;
	unsigned int tapCount = 1;
	PXPoint *touchPosition = nil;

	// We override this method to check for tap events, so if this is not a
	// touch event of any type then we just don't care about it.
	if ([event isKindOfClass:[PXTouchEvent class]])
	{
		PXTouchEvent *touchEvent = (PXTouchEvent *)event;
		NSString *eventType = touchEvent.type;

		// We store the fact that it is an up event so we only have to do this
		// check once. We need to know in two places if it is an up event, and
		// hence this test should only be done once.
		BOOL isUpEvent = [eventType isEqualToString:PXTouchEvent_TouchUp];

		if (isUpEvent == NO && [eventType isEqualToString:PXTouchEvent_TouchDown])
		{
			[pxInteractiveObjectTouchList addObject:touchEvent.nativeTouch];
		}
		else if (isUpEvent == YES || [eventType isEqualToString:PXTouchEvent_TouchCancel])
		{
			// Remove the touch from our storage list.
			[pxInteractiveObjectTouchList removeObject:touchEvent.nativeTouch];

			touchEvent->_tapCount = 0;

			// Only handle the up event if it was within our bounds. If we are
			// the main stage, then the touch is always within our bounds (even
			// though the position test will actually fail).
			if (isUpEvent == YES && (self == [PXStage mainStage] || touchEvent.insideTarget == YES))
			{
				// We guarantee at least one tap at this point, so we can set
				// the variable. We are going to manually update this because we
				// are manually handeling taps.
				sendTap = YES;

				PXPoint *oldPosition;
				float distance;

				touchPosition = touchEvent.stagePosition;

				// Go through each of the previous taps and compare our distance
				// to them. If we are within the epsilon value then we have
				// tapped more than once!
				for (PXTouchEvent *checkEvent in pxInteractiveObjectTouchUpHistoryList)
				{
					oldPosition = checkEvent.stagePosition;
					distance = [PXPoint distanceBetweenPointA:oldPosition pointB:touchPosition];

					// Compare the distance to the epsilon value
					if (distance < PXEngineTouchRadius)
					{
						// Incrase the tap count.
						tapCount = checkEvent.tapCount + 1;

						// We no longer need this tap in our history, so we can
						// just remove it.
						[pxInteractiveObjectTouchUpHistoryList removeObject:checkEvent];

						break;
					}
				}

				// Manually update the tap count for the event.
				touchEvent->_tapCount = tapCount;

				// Add it to the history list, then remove it if more than the
				// appropriate quantity of time has passed.
				[pxInteractiveObjectTouchUpHistoryList addObject:touchEvent];
				[pxInteractiveObjectTouchUpHistoryList performSelector:@selector(removeObject:) withObject:touchEvent afterDelay:PXEngineTapDuration];
			}
		}
	}

	// Retain ourselves prior to dispatching an event.
	[self retain];

	BOOL didDispatch = [super dispatchEvent:event];

	// Only send a tap event if our main event has been dispatched properly, and
	// if we actually want to send one.
	if (didDispatch == YES && sendTap == YES)
	{
		UITouch *touch = ((PXTouchEvent *)event).nativeTouch;

		// Make the tap event
		PXTouchEvent *tapEvent = [[PXTouchEvent alloc] initWithType:PXTouchEvent_Tap
														 nativeTouch:touch
															  stageX:touchPosition.x
															  stageY:touchPosition.y
															tapCount:tapCount];

		// Target of course is ourself
		tapEvent->_target = self;
		[self dispatchEvent:tapEvent];
		[tapEvent release];
	}

	// Release ourselves after dispatching the event
	[self release];

	return didDispatch;
}

@end
