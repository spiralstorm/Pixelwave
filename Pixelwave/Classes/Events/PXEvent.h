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

#include "PXSettings.h"
#include "PXHeaderUtils.h"

#import "PXPooledObject.h"

// EVENT CONSTANTS
PXExtern NSString * const PXEvent_EnterFrame;
PXExtern NSString * const PXEvent_Added;
PXExtern NSString * const PXEvent_Removed;
PXExtern NSString * const PXEvent_AddedToStage;
PXExtern NSString * const PXEvent_RemovedFromStage;
PXExtern NSString * const PXEvent_Render;
PXExtern NSString * const PXEvent_SoundComplete;

//@ Event Phases
typedef enum
{
	//@ The capture phase happens when the event travels downwards toward's the
	//@ target.
	PXEventPhase_Capture = 1,
	//@ The target phase is when the event is on the target.
	PXEventPhase_Target,
	//@ The bubbling phase is when the event is 'bubbling' back up the hierarchy.
	PXEventPhase_Bubbling
} PXEventPhase;

typedef enum
{
	//@ Keeps the propegation going (it's default value).
	_PXStopPropegationLevel_KeepGoing = 0,
	//@ stopPropegation after the current node (only relevant when using the
	//@ displaylist event flow).
	_PXStopPropegationLevel_StopAfter,
	//@ stopPropegation now (like calling break; in the middle of the
	//@ dispatch loop for the current node)
	_PXStopPropegationLevel_StopNow
} _PXStopPropegationLevel;

@interface PXEvent : NSObject <NSCopying, PXPooledObject>
{
@public
	// The object on which dispatchEvent() was called.
	PXGenericObject _target;
	NSString *_type;

	// These 2 change throughout the event flow, depending on who the event is
	// dispatched on
	// If not using display event flow, currentTarget = target. If using, then
	// currentTarget is the current displayObject (ancestor of the target)
	// processing the event
	PXGenericObject _currentTarget;
	PXEventPhase _eventPhase;

	_PXStopPropegationLevel _stopPropegationLevel;

	// These get re-set before the event gets dispatched
	BOOL _defaultPrevented;

	// If the event is currently being dispatched, a copy of it is made and used
	// instead (Done automatically in the EventDispatcher.dispatchEvent method)
	BOOL _isBeingDispatched;

	// These 3 remain constant for the lifetime of the event
	BOOL _bubbles;
	BOOL _cancelable;
}

/**
 * Describes whether the event participates in the bubbling phase of the event
 * flow.
 */
@property (nonatomic, readonly) BOOL bubbles;
/**
 * Describes whether the behavior represented by the event may be canceled. If
 * `YES`, #preventDefault may be used.
 * @see [PXEvent preventDefault]
 */
@property (nonatomic, readonly) BOOL cancelable;
/**
 * The node in the event flow currently processing the event.
 */
@property (nonatomic, readonly) PXGenericObject currentTarget;
/**
 * The node representing the ultimate target of the event.
 */
@property (nonatomic, readonly) PXGenericObject target;
/**
 * A string representing the type of the event
 */
@property (nonatomic, readonly) NSString *type;
/**
 * The event in which the event is currently participating
 * @see PXEventPhase
 */
@property (nonatomic, readonly) PXEventPhase eventPhase;

//-- ScriptIgnore
- (id) initWithType:(NSString *)type;
//-- ScriptName: Event
//-- ScriptArg[0]: required
//-- ScriptArg[1]: NO
//-- ScriptArg[2]: NO
- (id) initWithType:(NSString *)type bubbles:(BOOL)bubbles cancelable:(BOOL)cancelable;

//-- ScriptName: preventDefault
- (void) preventDefault;
//-- ScriptName: stopPropagation
- (void) stopPropagation;
//-- ScriptName: stopImmediatePropagation
- (void) stopImmediatePropagation;
//-- ScriptName: isDefaultPrevented
- (BOOL) isDefaultPrevented;

//-- ScriptIgnore
- (PXEvent *)eventWithType:(NSString *)type;
//-- ScriptName: make
//-- ScriptArg[0]: required
//-- ScriptArg[1]: NO
//-- ScriptArg[2]: NO
- (PXEvent *)eventWithType:(NSString *)type bubbles:(BOOL)bubbles cancelable:(BOOL)cancelable;

@end
