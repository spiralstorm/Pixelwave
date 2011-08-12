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

#import "PXEventListener.h"
#include "PXSettings.h"

@class PXEventListener;
@class PXEvent;
@class PXLinkedList;

///////////////////////////////
// Event Dispatcher Protocol //
///////////////////////////////

/**
 * The protocol from which the #PXEventDispatcher is derived.
 * You should implement this protocol when your class requires event
 * dispatching functionallity but cannot extend the #PXEventDispatcher class.
 * 
 * The implementing class should simply create a private #PXEventDispatcher object
 * and pass along all method invocations to it.
 *
 * **Example:**
 * We want to create a subclass of `SomeOtherClass` and we want it
 * to have event dispatching capabilities. The easy thing to do would be to
 * have our class extend #PXEventDispatcher. But since it already extends from
 * `SomeOtherClass` we need a different solution. The solution is
 * to implement the #PXEventDispatcher protocol, since one class can implement
 * any number of protocols but only inherit from a single class. Here's what
 * our class would need to do to support the #PXEventDispatcher protocol:
 *
 * _Header:_
 *	#import "SomeOtherClass.h"
 *	#import "PXEventDispatcher.h"
 *	
 *	@interface MyEventDispatchingClass : SomeOtherClass <PXEventDispatcher>
 *	{
 *	@private
 *		PXEventDispatcher *eventDispatcher;
 *	}
 *	
 *	@end 
 *
 * _Implementation:_
 *	#import "MyEventDispatchingClass.h"
 *	 
 *	@implementation MyEventDispatchingClass
 *	
 *	- (id) init
 *	{
 *		self = [super init];
 *		
 *		if (self)
 *		{
 *			eventDispatcher = [[PXEventDispatcher alloc] initWithTarget:self];
 *		}
 *
 *		return self;
 *	}
 *
 *	- (void) dealloc
 *	{
 *		[eventDispatcher release];
 *		eventDispatcher = nil;
 *		
 *		[super dealloc];
 *	}
 *
 *	// Implementation of protocol methods. They just pass the parameters to the
 *	// internal PXEventDispatcher object.
 *
 *	- (BOOL) addEventListenerOfType:(NSString *)type
 *	                       listener:(PXEventListener *)listener
 *	                     useCapture:(BOOL)useCapture
 *	                       priority:(int)priority
 *	{
 *		return [eventDispatcher addEventListenerOfType:type listener:listener useCapture:useCapture priority:priority];
 *	}
 *
 *	- (BOOL) removeEventListenerOfType:(NSString *)type
 *	                          listener:(PXEventListener *)listener
 *	                        useCapture:(BOOL)useCapture
 *	{
 *		return [eventDispatcher removeEventListenerOfType:type listener:listener useCapture:useCapture];
 *	}
 *
 *	- (BOOL) dispatchEvent:(PXEvent *)event
 *	{
 *	return [eventDispatcher dispatchEvent:event];
 *	}
 *
 *	- (BOOL) hasEventListenerOfType:(NSString *)type
 *	{
 *		return [eventDispatcher hasEventListenerOfType:type];
 *	}
 *	- (BOOL) willTriggerEventOfType:(NSString *)type
 *	{
 *		return [eventDispatcher willTriggerEventOfType:type];
 *	}
 *
 *	@end 
 *
 * @see PXEventDispatcher
 */
@protocol PXEventDispatcher<NSObject>
@required
//-- ScriptName: addEventListener
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: NO
//-- ScriptArg[3]: 0
/**
 * Adding an event listener.
 */
- (BOOL) addEventListenerOfType:(NSString *)type
					   listener:(PXEventListener *)listener
					 useCapture:(BOOL)useCapture
					   priority:(int)priority;
//-- ScriptName: removeEventListener
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: NO
/**
 * Removing an event listener.
 */
- (BOOL) removeEventListenerOfType:(NSString *)type
						  listener:(PXEventListener *)listener
						useCapture:(BOOL)useCapture;
//-- ScriptName: dispatchEvent
/**
 * Dispatching an event.
 */
- (BOOL) dispatchEvent:(PXEvent *)event;
//-- ScriptName: hasEventListener
/**
 * Querying registered events.
 */
- (BOOL) hasEventListenerOfType:(NSString *)type;
//-- ScriptName: willTrigger
/**
 * Querying registered events.
 */
- (BOOL) willTriggerEventOfType:(NSString *)type;
@end

//
// Event Dispatcher
//

// TODO Later: Keep all the capture phase listeners in a separate
// dictionary instead of doing string contcatenation with the keys
// of a single dictionary.

@interface PXEventDispatcher : NSObject <PXEventDispatcher>
{
@private
	id<PXEventDispatcher> target;

	NSMutableDictionary *eventListeners;
	
	BOOL dispatchEvents;
}

/**
 * Assign `YES` if this event dispatcher should dispatch events.
 *
 * **Default:** `YES`
 */
@property (nonatomic, assign) BOOL dispatchEvents;

//-- ScriptName: EventDispatcher
- (id) initWithTarget:(id<PXEventDispatcher>)target;

//-- ScriptIgnore
- (BOOL) addEventListenerOfType:(NSString *)type
					   listener:(PXEventListener *)listener;
//-- ScriptName: addEventListener
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: NO
//-- ScriptArg[3]: 0
- (BOOL) addEventListenerOfType:(NSString *)type
					   listener:(PXEventListener *)listener
					 useCapture:(BOOL) useCapture
					   priority:(int)priority;

//-- ScriptIgnore
- (BOOL) removeEventListenerOfType:(NSString *)type
						  listener:(PXEventListener *)listener;
//-- ScriptName: removeEventListener
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: NO
- (BOOL) removeEventListenerOfType:(NSString *)type
						  listener:(PXEventListener *)listener
						useCapture:(BOOL)useCapture;

//-- ScriptName: removeAllEventListeners
- (void) removeAllEventListeners;

//-- ScriptName: dispatchEvent
- (BOOL) dispatchEvent:(PXEvent *)event;
//-- ScriptName: hasEventListener
- (BOOL) hasEventListenerOfType:(NSString *)type;
//-- ScriptName: willTrigger
- (BOOL) willTriggerEventOfType:(NSString *)type;

@end

@interface PXEventDispatcher(Protected)
- (void) _prepEvent:(PXEvent *)event;

// Actually calls the listener functions for each registered listener.
- (void) _invokeEvent:(PXEvent *)event
	withCurrentTarget:(PXGenericObject)currentTarget
		   eventPhase:(char)phase;
@end
