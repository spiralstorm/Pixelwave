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

// TODO: Remove this
#import "PXTouchEvent.h"
#import "PXEvent.h"
#import "PXPoint.h"
#import "PXLinkedList.h"

/// @cond DX_IGNORE
@interface PXInteractiveObject(Private)
- (void) pxInteractiveObjectOnTouchDown:(PXTouchEvent *)event;
- (void) pxInteractiveObjectOnTouchUp:(PXTouchEvent *)event;
- (void) pxInteractiveObjectOnTouchCancel:(PXTouchEvent *)event;
@end
/// @endcond

/**
 *	@ingroup Display
 *
 *	A PXInteractiveObject is the abstract base class for all PXDisplayObjects
 *	that can recieve user interaction events.
 */
@implementation PXInteractiveObject

@synthesize doubleTapEnabled = _doubleTapEnabled;
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

		// So, what is all of this for? We manually add tap and double tap
		// events rather then the engine handeling them.

		// Grab the listener and retain it. They are autoreleased, thus at the
		// end of this function w/o a retain they would evaporate.
		onTouchDown   = [PXListener(pxInteractiveObjectOnTouchDown:)   retain];
		onTouchUp     = [PXListener(pxInteractiveObjectOnTouchUp:)     retain];
		onTouchCancel = [PXListener(pxInteractiveObjectOnTouchCancel:) retain];

		// We have not added the listeners yet, just gotten pointers to them.
		addedListeners = NO;
	}

	return self;
}

- (void) dealloc
{
	if (addedListeners == YES)
	{
		[super removeEventListenerOfType:PXTouchEvent_TouchDown   listener:onTouchDown];
		[super removeEventListenerOfType:PXTouchEvent_TouchUp     listener:onTouchUp];
		[super removeEventListenerOfType:PXTouchEvent_TouchCancel listener:onTouchCancel];
	}

	[touchList release];
	touchList = nil;

	[touchUpHistoryList release];
	touchUpHistoryList = nil;

	[onTouchDown release];
	onTouchDown = nil;
	[onTouchUp release];
	onTouchUp = nil;
	[onTouchCancel release];
	onTouchCancel = nil;

	[super dealloc];
}

- (BOOL) addEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener useCapture:(BOOL)useCapture priority:(int)priority
{
	BOOL properlyAdded = [super addEventListenerOfType:type listener:listener useCapture:useCapture priority:priority];

	// If the event wasn't properly added, then give up, there is nothing we can
	// do.
	if (properlyAdded == NO)
		return NO;

	// We only care about tap and double tap events.
	BOOL isTapEvent = NO;
	BOOL isDoubleTapEvent = NO;

	// Compare the type in an efficient way.
	isTapEvent = [type isEqualToString:PXTouchEvent_Tap];
	if (isTapEvent == NO)
		isDoubleTapEvent = [type isEqualToString:PXTouchEvent_DoubleTap];

	// If it is a double tap or tap event, then we need to add our own listeners
	// so we can convert up events into tap events if needed.
	if (isTapEvent || isDoubleTapEvent)
	{
		// If we have not added the listeners, add them!
		if (addedListeners == NO)
		{
			addedListeners = YES;

			// Ensure that each of these listeners was added properly
			BOOL properlyAddedDown   = [super addEventListenerOfType:PXTouchEvent_TouchDown   listener:onTouchDown   useCapture:useCapture priority:priority];
			BOOL properlyAddedUp     = [super addEventListenerOfType:PXTouchEvent_TouchUp     listener:onTouchUp     useCapture:useCapture priority:priority];
			BOOL properlyAddedCancel = [super addEventListenerOfType:PXTouchEvent_TouchCancel listener:onTouchCancel useCapture:useCapture priority:priority];

			// A generic value to see if everything was added properly
			properlyAdded = (properlyAddedDown == YES) && (properlyAddedUp == YES) && (properlyAddedCancel == YES);

			// If something failed adding, then we must remove everything and
			// inform the user of failure!
			if (properlyAdded == NO)
			{
				[super removeEventListenerOfType:type listener:listener useCapture:useCapture];

				if (properlyAddedDown == YES)
					[super removeEventListenerOfType:PXTouchEvent_TouchDown   listener:onTouchDown   useCapture:useCapture];
				if (properlyAddedUp == YES)
					[super removeEventListenerOfType:PXTouchEvent_TouchUp     listener:onTouchUp     useCapture:useCapture];
				if (properlyAddedCancel == YES)
					[super removeEventListenerOfType:PXTouchEvent_TouchCancel listener:onTouchCancel useCapture:useCapture];

				// The listeners are no longer added
				addedListeners = NO;
			}
			else
			{
				// Everything was added properly, we need to create our lists.
				if (touchList == NULL)
				{
					touchList = [[PXLinkedList alloc] init];
				}
				if (touchUpHistoryList == NULL)
				{
					touchUpHistoryList = [[PXLinkedList alloc] init];
				}
			}
		}

		// If we added the listeners, and everything was properly added then we
		// can confirm the users want to listen to a tap or double tap event.
		// Note:	addedListeners is rechecked, as the previous if-statement
		//			could have reset it back to NO
		if (addedListeners == YES && properlyAdded == YES)
		{
			if (isTapEvent == YES)
				listenToTap = YES;
			else if (isDoubleTapEvent == YES)
				listenToDoubleTap = YES;
		}
	}

	// Return to them the overall result
	return properlyAdded;
}

- (BOOL) removeEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener useCapture:(BOOL)useCapture
{
	BOOL properlyRemoved = [super removeEventListenerOfType:type listener:listener useCapture:useCapture];

	// If the event wasn't properly removed, then give up, there is nothing we
	// can do.
	if (properlyRemoved == NO)
		return NO;

	// We only care about tap and double tap events.
	BOOL isTapEvent = NO;
	BOOL isDoubleTapEvent = NO;

	// Compare the type in an efficient way.
	isTapEvent = [type isEqualToString:PXTouchEvent_Tap];
	if (isTapEvent == NO)
		isDoubleTapEvent = [type isEqualToString:PXTouchEvent_DoubleTap];

	// We do not want to remove our own listeners unless NO one is listening to
	// any form of tap event. This if-statement is the first test for that.
	if ([self hasEventListenerOfType:type] == NO)
	{
		// Turn off the correct variable
		if (isTapEvent)
			listenToTap = NO;
		else if (isDoubleTapEvent)
			listenToDoubleTap = NO;

		// They both need to be off for us to remove our listeners. This is the
		// second step of the test.
		if (addedListeners == YES && listenToTap == NO && listenToDoubleTap == NO)
		{
			addedListeners = NO;

			// Remove the listeners
			[super removeEventListenerOfType:PXTouchEvent_TouchDown   listener:onTouchDown   useCapture:useCapture];
			[super removeEventListenerOfType:PXTouchEvent_TouchUp     listener:onTouchUp     useCapture:useCapture];
			[super removeEventListenerOfType:PXTouchEvent_TouchCancel listener:onTouchCancel useCapture:useCapture];

			// Free the lists
			[touchList release];
			touchList = nil;

			[touchUpHistoryList release];
			touchUpHistoryList = nil;
		}
	}

	// Return to them the overall result
	return properlyRemoved;
}

- (void) pxInteractiveObjectOnTouchDown:(PXTouchEvent *)event
{
	// Only add the touch if we are the target of it, this way we do not add it
	// on weird phases.
	if (event.eventPhase == PXEventPhase_Target)
	{
		[touchList addObject:event.nativeTouch];
	}
}
- (void) pxInteractiveObjectOnTouchUp:(PXTouchEvent *)event
{
	// If we do not have the touch in our list, then we don't care about it, nor
	// do we know how we recieved it anyway.
	if ([touchList containsObject:event.nativeTouch] == NO)
		return;

	// Cancel the touch, this will remove it from our list.
	[self pxInteractiveObjectOnTouchCancel:event];

	// Only handle the up event if it was within our bounds. If we are the main
	// stage, then the touch is always within our bounds (even though the
	// position test will actually fail).
	if (self != [PXStage mainStage] && event.insideTarget == NO)
		return;

	// We guarantee at least one tap at this point, so we can set the variable.
	// We are going to manually update this because we are manually handeling
	// taps.
	UITouch *touch = event.nativeTouch;
	unsigned tapCount = 1;

	PXPoint *oldPosition;
	float distance;

	PXPoint *touchPosition = event.stagePosition;

	// Go through each of the previous taps and compare our distance to them. If
	// we are within the epsilon value then we have tapped more than once!
	for (PXTouchEvent *checkEvent in touchUpHistoryList)
	{
		oldPosition = checkEvent.stagePosition;
		distance = [PXPoint distanceBetweenPointA:oldPosition pointB:touchPosition];

		// Compare the distance to the epsilon value
		if (distance < PXEngineTouchRadius)
		{
			// Incrase the tap count.
			tapCount = checkEvent.tapCount + 1;

			// We no longer need this tap in our history, so we can just remove
			// it.
			[touchUpHistoryList removeObject:checkEvent];

			break;
		}
	}

	PXTouchEvent *sendEvent;

	// Send a tap event out if we are listening to it.
	if (listenToTap == YES)
	{
		sendEvent = [[PXTouchEvent alloc] initWithType:PXTouchEvent_Tap
										   nativeTouch:touch
												stageX:touchPosition.x
												stageY:touchPosition.y
											  tapCount:tapCount];

		sendEvent->_target = self;
		[self dispatchEvent:sendEvent];
		[sendEvent release];
	}

	// Send a double tap event out if we are listening to it, we can send them,
	// and if the tap count is equal to two (aka. double).
	if (listenToDoubleTap == YES && self.doubleTapEnabled == YES && tapCount == 2)
	{
		sendEvent = [[PXTouchEvent alloc] initWithType:PXTouchEvent_DoubleTap
										   nativeTouch:touch
												stageX:touchPosition.x
												stageY:touchPosition.y
											  tapCount:tapCount];

		sendEvent->_target = self;
		[self dispatchEvent:sendEvent];
		[sendEvent release];
	}

	// Manually update the tap count for the event.
	event->_tapCount = tapCount;

	// Add it to the history list, then remove it if more than the t
	[touchUpHistoryList addObject:event];
	[touchUpHistoryList performSelector:@selector(removeObject:) withObject:event afterDelay:PXEngineTapDuration];
}
- (void) pxInteractiveObjectOnTouchCancel:(PXTouchEvent *)event
{
	// Remove the touch from the list -> if this is a real cancel event, then it
	// will never get added to the history.
	[touchList removeObject:event.nativeTouch];
}

@end
