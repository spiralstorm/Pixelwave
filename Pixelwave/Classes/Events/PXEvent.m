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

#import "PXEvent.h"

#import "PXExceptionUtils.h"
#import "PXPrivateUtils.h"

#import "PXDebugUtils.h"

NSString * const PXEvent_EnterFrame = @"enterFrame";
NSString * const PXEvent_Added = @"added";
NSString * const PXEvent_Removed = @"removed";
NSString * const PXEvent_AddedToStage = @"addedToStage";
NSString * const PXEvent_RemovedFromStage = @"removedFromStage";
NSString * const PXEvent_Render = @"render";
NSString * const PXEvent_SoundComplete = @"soundComplete";

@interface PXEvent(Private)
- (void) setType:(NSString *)type;
@end

/**
 * The base class for all events dispatched through the #PXEventDispatcher
 * class.
 * 
 * A PXEvent holds all of the information related to the given event, and is
 * always passed in as the first argument of every event listener invocation by
 * an event listener.
 *
 * While the PXEvent class is the base for all other event classes, it's not
 * abstract, meaning that it can be used on its own for several common events.
 *
 * @see PXTouchEvent
 */
@implementation PXEvent

@synthesize bubbles = _bubbles;
@synthesize cancelable = _cancelable;
@synthesize currentTarget = _currentTarget;
@synthesize eventPhase = _eventPhase;
@synthesize target = _target;
@synthesize type = _type;

// Should never be used.
- (id) init
{
	PXDebugLog(@"PXEvent must be intialized with a type");
	[self release];
	return nil;
}

/**
 * Makes a new event with the given properties. These properties may not change
 * after the event object is created.
 *
 * Uses default values `bubbling = NO` and
 * `cancelable = NO`.
 *
 * @param type A string representing the type of the event
 */
- (id) initWithType:(NSString *)type
{
	return [self initWithType:type bubbles:NO cancelable:NO];
}

/**
 * Makes a new event with the given properties. These properties may not change
 * after the event object is created.
 *
 * @param type A string representing the type of the event
 * @param bubbles Whether the event should participate in the bubbling phase of the event
 * flow.
 * @param cancelable Whether the behavior described by the event can be canceled by the user.
 */
- (id) initWithType:(NSString *)type bubbles:(BOOL)bubbles cancelable:(BOOL)cancelable
{
	if (!type)
	{
		PXThrowNilParam(type);
		[self release];
		return nil;
	}

	self = [super init];

	if (self)
	{
		//PXPrecParamNotNil(type);

		[self setType:type];

		_bubbles = bubbles;
		_cancelable = cancelable;

		//Default values
		_eventPhase = PXEventPhase_Target;
		_target = nil;
		_currentTarget = nil;

		_defaultPrevented = NO;
		_stopPropegationLevel = _PXStopPropegationLevel_KeepGoing;

		_isBeingDispatched = NO;
		//_isBroadcastEvent = NO;
	}

	return self;
}

- (void) dealloc
{
	[self setType:nil];

	[super dealloc];
}

#pragma mark NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	PXEvent *e = [[[self class] allocWithZone:zone] initWithType:_type bubbles:_bubbles cancelable:_cancelable];
	e->_currentTarget = _currentTarget;
	e->_target = _target;
	e->_eventPhase = _eventPhase;

	e->_defaultPrevented = _defaultPrevented;
	e->_stopPropegationLevel = _stopPropegationLevel;

	return e;
}

// toString()
// [Event type=value bubbles=value cancelable=value]
- (NSString *)description
{
	return [NSString stringWithFormat:@"[Event type=\"%@\" bubbles=%@ cancelable=%@]",
			_type,
			PX_BOOL_TO_STRING(_bubbles),
			PX_BOOL_TO_STRING(_cancelable)];
}

#pragma mark Pooled Reset

- (void) reset
{
	[self setType:nil];

	_bubbles = NO;
	_cancelable = NO;

	_eventPhase = PXEventPhase_Target;
	_target = nil;
	_currentTarget = nil;

	_defaultPrevented = NO;
	_stopPropegationLevel = _PXStopPropegationLevel_KeepGoing;

	_isBeingDispatched = NO;
}

- (void) setType:(NSString *)type
{
	NSString *copy = [type copy];
	[_type release];
	_type = copy;
}

/**
 * Causes the behavior represented by this event to be canceled.
 * Not all events may be canceled. Use the #cancelable property to
 * check if this event's behavior can be canceled.
 */
- (void) preventDefault
{
	if (!_cancelable)
		return;

	_defaultPrevented = YES;
}

/**
 * Prevents the event from being dispatched any further in the event flow.
 * @see stopImmediatePropegation
 */
// Only relevant for the display list flow
- (void) stopPropagation
{
	// If stopImmediatePropegation was called, this will have no effect
	if (_stopPropegationLevel == _PXStopPropegationLevel_KeepGoing)
	{
		_stopPropegationLevel = _PXStopPropegationLevel_StopAfter;
	}
}

/**
 * Stops the event from being dispatched any further, and cancels event
 * dispatching for all remaining event listeners registered to listen for this
 * event.
 *
 * @see stopPropegation
 */
// Always relevant
- (void) stopImmediatePropagation
{
	_stopPropegationLevel = _PXStopPropegationLevel_StopNow;
}

/**
 * Whether the preventDefault method has been called on this event.
 */
- (BOOL) isDefaultPrevented
{
	return _defaultPrevented;
}

/**
 * Makes a event with the given properties. These properties may not change
 * after the event object is created.
 *
 * Uses default values `bubbling = NO` and
 * `cancelable = NO`.
 *
 * @param type A string representing the type of the event
 */
- (PXEvent *)eventWithType:(NSString *)type
{
	return [[[PXEvent alloc] initWithType:type] autorelease];
}

/**
 * Makes a event with the given properties. These properties may not change
 * after the event object is created.
 *
 * @param type A string representing the type of the event
 * @param bubbles Whether the event should participate in the bubbling phase of the event
 * flow.
 * @param cancelable Whether the behavior described by the event can be canceled by the user.
 */
- (PXEvent *)eventWithType:(NSString *)type bubbles:(BOOL) bubbles cancelable:(BOOL) cancelable
{
	return [[[PXEvent alloc] initWithType:type bubbles:bubbles cancelable:cancelable] autorelease];
}

@end
