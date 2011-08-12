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

#import "PXTouchEvent.h"
#import "PXDisplayObject.h"
#import "PXPoint.h"
#import "PXEngine.h"
#import "PXTouchEngine.h"
#import "PXTouchEngine.h"

#include "PXPrivateUtils.h"

NSString * const PXTouchEvent_Tap = @"tap";
NSString * const PXTouchEvent_TouchDown = @"touchDown";
NSString * const PXTouchEvent_TouchMove = @"touchMove";
NSString * const PXTouchEvent_TouchUp = @"touchUp";
NSString * const PXTouchEvent_TouchCancel = @"touchCancel";

@interface PXTouchEvent(Private)
- (void) setNativeTouch:(UITouch *)touch;
@end

/**
 * Dispatched by subclasses of #PXInteractiveObject an associated touch
 * begins, ends, moves, or cancels. The event has information needed by the user to
 * handle the touch correctly.
 */
@implementation PXTouchEvent

@synthesize stageX = _stageX;
@synthesize stageY = _stageY;
@synthesize nativeTouch = _nativeTouch;
@synthesize tapCount = _tapCount;

/**
 * Creates a touch event.
 *
 * @param type A string representing the type of the event.
 * @param nativeTouch The touch object used for keeping track of what finger started the
 * touch.
 * @param stageX The horizontal location in global (stage) coordinates where the touch
 * occured.
 * @param stageY The vertical location in global (stage) coordinates where the touch
 * occured.
 * @param tapCount The number of touches that have been repeated in the same place without
 * moving.
 */
- (id) initWithType:(NSString *)type
		nativeTouch:(UITouch *)touch
			 stageX:(float)stageX
			 stageY:(float)stageY
		   tapCount:(unsigned)tapCount
{
	self = [super initWithType:type bubbles:YES cancelable:NO];

	if (self)
	{
		[self setNativeTouch:touch];

		_stageX = stageX;
		_stageY = stageY;
		_tapCount = tapCount;
	}

	return self;
}

- (void) dealloc
{
	[self setNativeTouch:nil];

	[super dealloc];
}

#pragma mark NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	PXEvent *event = [[[self class] allocWithZone:zone] initWithType:_type nativeTouch:_nativeTouch stageX:_stageX stageY:_stageY tapCount:_tapCount];
	event->_currentTarget = _currentTarget;
	event->_target = _target;
	event->_eventPhase = _eventPhase;

	event->_defaultPrevented = _defaultPrevented;
	event->_stopPropegationLevel = _stopPropegationLevel;

	event->_bubbles = _bubbles;
	event->_cancelable = _cancelable;

	return event;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"[Event type=\"%@\" bubbles=%@ cancelable=%@ stageX=%f stageY=%f]",
			_type,
			PX_BOOL_TO_STRING(_bubbles),
			PX_BOOL_TO_STRING(_cancelable),
			_stageX,
			_stageY];
}

#pragma mark Pooled Reset

- (void) reset
{
	[super reset];

	[self setNativeTouch:nil];

	_bubbles = YES;
	_cancelable = NO;

	_tapCount = 0;
	_stageX = 0.0f;
	_stageY = 0.0f;
}

- (void) setNativeTouch:(UITouch *)touch
{
	touch = [touch retain];
	[_nativeTouch release];
	_nativeTouch = touch;
}

- (BOOL) captured
{
	id<PXEventDispatcher> capturingObject = PXTouchEngineGetTouchCapturingObject(_nativeTouch);
	return (capturingObject == _target);
}

- (BOOL) insideTarget
{
	if (_target && [_target isKindOfClass:[PXDisplayObject class]])
	{
		return [((PXDisplayObject *)_target) _hitTestPointWithoutRecursionWithGlobalX:_stageX globalY:_stageY shapeFlag:YES];
	}

	return NO;
}

- (PXPoint *)localPosition
{
	if (_target && [_target isKindOfClass:[PXDisplayObject class]])
	{
		return [((PXDisplayObject *)_target) positionOfTouch:_nativeTouch];
	}
	
	return nil;
}

- (PXPoint *)stagePosition
{
	return [PXPoint pointWithX:_stageX y:_stageY];
}

- (float) localX
{
	if (_target && [_target isKindOfClass:[PXDisplayObject class]])
	{
		return [((PXDisplayObject *)_target) positionOfTouch:_nativeTouch].x;
	}

	return 0.0f;
}

- (float) localY
{
	if (_target && [_target isKindOfClass:[PXDisplayObject class]])
	{
		return [((PXDisplayObject *)_target) positionOfTouch:_nativeTouch].y;
	}

	return 0.0f;
}

@end
