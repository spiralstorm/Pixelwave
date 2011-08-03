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

		pxInteractiveObjectOnTouchDown   = [PXListener(pxInteractiveObjectOnTouchDown:)   retain];
		pxInteractiveObjectOnTouchUp     = [PXListener(pxInteractiveObjectOnTouchUp:)     retain];
		pxInteractiveObjectOnTouchCancel = [PXListener(pxInteractiveObjectOnTouchCancel:) retain];

		pxInteractiveObjectAddedListeners = NO;
		pxInteractiveObjectTouchDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	}

	return self;
}

- (void) dealloc
{
	if (pxInteractiveObjectAddedListeners == YES)
	{
		[super removeEventListenerOfType:PXTouchEvent_TouchDown   listener:pxInteractiveObjectOnTouchDown];
		[super removeEventListenerOfType:PXTouchEvent_TouchUp     listener:pxInteractiveObjectOnTouchUp];
		[super removeEventListenerOfType:PXTouchEvent_TouchCancel listener:pxInteractiveObjectOnTouchCancel];
	}

	if (pxInteractiveObjectTouchDictionary != NULL)
	{
		CFRelease(pxInteractiveObjectTouchDictionary);
		pxInteractiveObjectTouchDictionary = NULL;
	}

	[pxInteractiveObjectOnTouchDown   release];
	[pxInteractiveObjectOnTouchUp     release];
	[pxInteractiveObjectOnTouchCancel release];

	[super dealloc];
}

- (BOOL) addEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener useCapture:(BOOL)useCapture priority:(int)priority
{
	BOOL properlyAdded = [super addEventListenerOfType:type listener:listener useCapture:useCapture priority:priority];

	BOOL isTapEvent = [type isEqualToString:PXTouchEvent_Tap];
	BOOL isDoubleTapEvent = [type isEqualToString:PXTouchEvent_DoubleTap];

	if (properlyAdded && (isTapEvent || isDoubleTapEvent))
	{
		if (pxInteractiveObjectAddedListeners == NO)
		{
			pxInteractiveObjectAddedListeners = YES;

			BOOL properlyAddedDown   = [super addEventListenerOfType:PXTouchEvent_TouchDown   listener:pxInteractiveObjectOnTouchDown   useCapture:useCapture priority:priority];
			BOOL properlyAddedUp     = [super addEventListenerOfType:PXTouchEvent_TouchUp     listener:pxInteractiveObjectOnTouchUp     useCapture:useCapture priority:priority];
			BOOL properlyAddedCancel = [super addEventListenerOfType:PXTouchEvent_TouchCancel listener:pxInteractiveObjectOnTouchCancel useCapture:useCapture priority:priority];

			properlyAdded = properlyAddedDown && properlyAddedUp && properlyAddedCancel;

			if (properlyAdded == NO)
			{
				[super removeEventListenerOfType:type listener:listener useCapture:useCapture];

				if (properlyAddedDown)
					[super removeEventListenerOfType:PXTouchEvent_TouchDown   listener:pxInteractiveObjectOnTouchDown   useCapture:useCapture];
				if (properlyAddedUp)
					[super removeEventListenerOfType:PXTouchEvent_TouchUp     listener:pxInteractiveObjectOnTouchUp     useCapture:useCapture];
				if (properlyAddedCancel)
					[super removeEventListenerOfType:PXTouchEvent_TouchCancel listener:pxInteractiveObjectOnTouchCancel useCapture:useCapture];

				pxInteractiveObjectAddedListeners = NO;
			}
		}

		if (pxInteractiveObjectAddedListeners == YES && properlyAdded == YES)
		{
			if (isTapEvent == YES)
				pxInteractiveObjectListenToTap = YES;
			else if (isDoubleTapEvent == YES)
				pxInteractiveObjectListenToDoubleTap = YES;
		}
	}

	return properlyAdded;
}

- (BOOL) removeEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener useCapture:(BOOL)useCapture
{
	BOOL properlyRemoved = [super removeEventListenerOfType:type listener:listener useCapture:useCapture];

	BOOL isTapEvent = [type isEqualToString:PXTouchEvent_Tap];
	BOOL isDoubleTapEvent = [type isEqualToString:PXTouchEvent_DoubleTap];

	BOOL stillHas = [self hasEventListenerOfType:type];

	if (stillHas == NO)
	{
		if (isTapEvent)
			pxInteractiveObjectListenToTap = NO;
		else if (isDoubleTapEvent)
			pxInteractiveObjectListenToDoubleTap = NO;

		if (pxInteractiveObjectAddedListeners == YES && pxInteractiveObjectListenToTap == NO && pxInteractiveObjectListenToDoubleTap == NO)
		{
			pxInteractiveObjectAddedListeners = NO;

			[super removeEventListenerOfType:PXTouchEvent_TouchDown   listener:pxInteractiveObjectOnTouchDown   useCapture:useCapture];
			[super removeEventListenerOfType:PXTouchEvent_TouchUp     listener:pxInteractiveObjectOnTouchUp     useCapture:useCapture];
			[super removeEventListenerOfType:PXTouchEvent_TouchCancel listener:pxInteractiveObjectOnTouchCancel useCapture:useCapture];

			CFDictionaryRemoveAllValues(pxInteractiveObjectTouchDictionary);
		}
	}

	return properlyRemoved;
}

- (void) pxInteractiveObjectOnTouchDown:(PXTouchEvent *)event
{
	// Do not check if the event phase is equal to target. Why? Because they may
	// also have a touch down listener that will interfere with this.

	CFDictionarySetValue(pxInteractiveObjectTouchDictionary, event.nativeTouch, event);
}
- (void) pxInteractiveObjectOnTouchUp:(PXTouchEvent *)event
{
	PXTouchEvent *oldEvent = (PXTouchEvent *)CFDictionaryGetValue(pxInteractiveObjectTouchDictionary, event.nativeTouch);

	if (oldEvent != nil)
	{
		[self pxInteractiveObjectOnTouchCancel:event];

		PXPoint *oldPosition = oldEvent.stagePosition;
		PXPoint *newPosition = event.stagePosition;

		float distance = [PXPoint distanceBetweenPointA:oldPosition pointB:newPosition];

		if (distance < PXEngineTouchRadius)
		{
			UITouch *touch = event.nativeTouch;
			unsigned tapCount = touch.tapCount;

			PXTouchEvent *event;

			if (pxInteractiveObjectListenToTap == YES)
			{
				event = [[PXTouchEvent alloc] initWithType:PXTouchEvent_Tap
											   nativeTouch:touch
													stageX:newPosition.x
													stageY:newPosition.y
												  tapCount:tapCount];

				event->_target = self;
				[self dispatchEvent:event];
				[event release];
			}

			if (pxInteractiveObjectListenToDoubleTap == YES && self.doubleTapEnabled == YES && tapCount == 2)
			{
				event = [[PXTouchEvent alloc] initWithType:PXTouchEvent_DoubleTap
											   nativeTouch:touch
													stageX:newPosition.x
													stageY:newPosition.y
												  tapCount:tapCount];

				event->_target = self;
				[self dispatchEvent:event];
				[event release];
			}
		}
	}
}
- (void) pxInteractiveObjectOnTouchCancel:(PXTouchEvent *)event
{
	CFDictionaryRemoveValue(pxInteractiveObjectTouchDictionary, event.nativeTouch);
}

@end
