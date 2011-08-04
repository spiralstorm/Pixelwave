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

/// @cond DX_IGNORE
// We give these methods names that hopefully won't be used by the user. If the
// user defines these and overrides them then we will not get proper interaction
// of events and tap will fail.
@interface PXInteractiveObject(Private)
- (BOOL) pxInteractiveObjectAddListeners;
- (void) pxInteractiveObjectRemoveListeners;
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
		pxIOOnTouchDown   = [PXListener(pxInteractiveObjectOnTouchDown:)   retain];
		pxIOOnTouchUp     = [PXListener(pxInteractiveObjectOnTouchUp:)     retain];
		pxIOOnTouchCancel = [PXListener(pxInteractiveObjectOnTouchCancel:) retain];

		// We have not added the listeners yet, just gotten pointers to them.
		addedListeners = NO;
	}

	return self;
}

- (void) dealloc
{
	[self pxInteractiveObjectRemoveListeners];

	[pxIOOnTouchDown release];
	pxIOOnTouchDown = nil;
	[pxIOOnTouchUp release];
	pxIOOnTouchUp = nil;
	[pxIOOnTouchCancel release];
	pxIOOnTouchCancel = nil;

	[super dealloc];
}

- (BOOL) pxInteractiveObjectAddListeners
{
	// If the listeners were already added, we don't need to add them again.
	// Return YES because the check for this is actaully just wondering if they
	// were added ever, not just now.
	if (addedListeners == YES)
		return YES;

	addedListeners = YES;

	// add the listeners
	BOOL addedDown   = [super addEventListenerOfType:PXTouchEvent_TouchDown   listener:pxIOOnTouchDown];
	BOOL addedUp     = [super addEventListenerOfType:PXTouchEvent_TouchUp     listener:pxIOOnTouchUp];
	BOOL addedCancel = [super addEventListenerOfType:PXTouchEvent_TouchCancel listener:pxIOOnTouchCancel];
	BOOL addedAll = addedDown && addedUp && addedCancel;

	// If any of them failed to add, then we will have to remove any we added
	// and inform them that it failed.
	if (addedAll == NO)
	{
		addedListeners = NO;

		if (addedDown)
			[super removeEventListenerOfType:PXTouchEvent_TouchDown   listener:pxIOOnTouchDown];
		if (addedUp)
			[super removeEventListenerOfType:PXTouchEvent_TouchUp     listener:pxIOOnTouchUp];
		if (addedCancel)
			[super removeEventListenerOfType:PXTouchEvent_TouchCancel listener:pxIOOnTouchCancel];
	}

	// If they added correctly, we need to make our lists that store information
	// required to keep track of the taps.
	if (addedAll == YES)
	{
		if (touchList == NULL)
		{
			touchList = [[PXLinkedList alloc] init];
		}
		if (touchUpHistoryList == NULL)
		{
			touchUpHistoryList = [[PXLinkedList alloc] init];
		}
	}

	return addedAll;
}
- (void) pxInteractiveObjectRemoveListeners
{
	// Do not need to remove the listeners if they weren't added.
	if (addedListeners == NO)
		return;

	addedListeners = NO;

	// Remove the listeners
	[super removeEventListenerOfType:PXTouchEvent_TouchDown   listener:pxIOOnTouchDown];
	[super removeEventListenerOfType:PXTouchEvent_TouchUp     listener:pxIOOnTouchUp];
	[super removeEventListenerOfType:PXTouchEvent_TouchCancel listener:pxIOOnTouchCancel];

	// Release the lists that keep track of the events to check for taps.
	[touchList release];
	touchList = nil;
	[touchUpHistoryList release];
	touchUpHistoryList = nil;
}

- (BOOL) addEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener useCapture:(BOOL)useCapture priority:(int)priority
{
	BOOL properlyAdded = [super addEventListenerOfType:type listener:listener useCapture:useCapture priority:priority];

	// If the event wasn't properly added, then give up, there is nothing we can
	// do.
	if (properlyAdded == NO)
		return NO;

	// We only care about tap events.
	BOOL isTapEvent = isTapEvent = [type isEqualToString:PXTouchEvent_Tap];

	if (isTapEvent == NO)
		return YES;

	// If it is a double tap or tap event, then we need to add our own listeners
	// so we can convert up events into tap events if needed.
	
	// If we have not added the listeners, add them!
	properlyAdded = [self pxInteractiveObjectAddListeners];
	if (properlyAdded == NO)
	{
		[super removeEventListenerOfType:type listener:listener useCapture:useCapture];
	}

	// If we added the listeners, and everything was properly added then we
	// can confirm the users want to listen to a tap or double tap event.
	// Note:	addedListeners is rechecked, as the previous if-statement
	//			could have reset it back to NO
	if (addedListeners == YES && properlyAdded == YES)
	{
		if (isTapEvent == YES)
			listenToTap = YES;
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
	BOOL isTapEvent = [type isEqualToString:PXTouchEvent_Tap];

	if (isTapEvent == NO)
		return YES;

	// We do not want to remove our own listeners unless NO one is listening to
	// any form of tap event. This if-statement is the first test for that.
	// NOTE:	This is why we remove the real event first.
	if ([self hasEventListenerOfType:PXTouchEvent_Tap] == NO)
	{
		listenToTap = NO;

		[self pxInteractiveObjectRemoveListeners];
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
