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

// My header
#import "PXEventDispatcher.h"
#import "PXLinkedList.h"
#import "PXSettings.h"
#import "PXEngine.h"
#import "PXObjectPool.h"

#import "PXExceptionUtils.h"

// DELETE
#import "PXTouchEvent.h"

// More info about the Event Flow:
// http://livedocs.adobe.com/flex/3/html/help.html?content=events_08.html#203937

// This string gets tagged at the end of capture event dictionary keys
#define PX_CAPTURE_STRING @"_CAP_"
#define PX_GET_EVENT_CAPTURE_KEY(_type_) [NSString stringWithFormat:@"%@%@", (_type_), PX_CAPTURE_STRING]

PXEventListener *PXGetSimilarListener(PXEventListener *listener, PXLinkedList *list);

//
// Event Dispatcher
//

/*
   DONE: (from AS3 docs for EventDispatcher)

   If the event listener is being registered on a node while an event is being processed on this node,
   the event listener is not triggered during the current phase but can be triggered during a later phase
   in the event flow, such as the bubbling phase.

   If an event listener is removed from a node while an event is being processed on the node, it is still triggered
   by the current actions. After it is removed, the event listener is never invoked again (unless registered again for future processing).

 */

/**
 * The base class for all classes that dispatch events.
 * The event dispatcher allows individual methods to be associated with any
 * event.
 *
 * Event types are represented as NSString objects and methods are
 * wrapped in PXEventListener objects, while information about events is passed
 * along in PXEvent objects.
 *
 * The PXEventDispatcher is the base class for all display objects.
 *
 * the PXEventDispatcher class maybe subclassed by any user class in order to
 * provide event dispatching behavior for that class. If a user class is
 * unable to subclass PXEventDispatcher because it is already subclassing a
 * different class, it may implement the PXEventDispatcher protocol.
 * 
 * In order to implement the methods of the protocol, a private PXEventDispatcher
 * ivar should be created, to which all of the protocol method calls should be
 * forwarded.See the #PXEventDispatcher protocol for more information.
 *
 * @see PXEventDispatcher
 */
@implementation PXEventDispatcher

@synthesize dispatchEvents;

- (id) init
{
	return [self initWithTarget:self];
}

/**
 * Makes a new event disptacher with the given target.
 *
 * @param target The target.
 */
- (id) initWithTarget:(id<PXEventDispatcher>)_target
{
	self = [super init];

	if (self)
	{
		target = _target;
		eventListeners = nil;
		dispatchEvents = YES;
	}

	return self;
}

- (void) dealloc
{
	//Remove all my event listeners
	if (eventListeners)
	{
		[eventListeners release];
		eventListeners = nil;
	}

	[super dealloc];
}

#pragma mark Adding Listeners

/**
 * Adds an event listener.
 *
 * **Example:**
 * In this example the method `onTouch:` is assigned as a
 * listener to the stage's `touchDown` event.
 * 
 *	[self.stage addEventListenerForType:PXTouchEvent_TouchDown listener:PXListener(onTouchDown:)];
 *	//...
 *	- (void) onTouchDown:(PXTouchEvent *)event
 *	{
 *		// handle event
 *	}
 *
 * @param type The type
 * @param listener The listener
 */
- (BOOL) addEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener
{
	return [self addEventListenerOfType:type listener:listener useCapture:NO priority:0];
}

/**
 * Adds an event listener.
 *
 * **Example:**
 * In this example the method `onTouch:` is assigned as a
 * listener to the stage's `touchDown` event.
 * 
 *	[self.stage addEventListenerForType:PXTouchEvent_TouchDown listener:PXListener(onTouchDown:) useCapture:NO priority:0];
 *	//...
 *	- (void) onTouchDown:(PXTouchEvent *)event
 *	{
 *		// handle event
 *	}
 *
 * @param type The type
 * @param listener The listener
 * @param capture If it should use capture
 * @param priority The priority
 */
- (BOOL) addEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener useCapture:(BOOL)useCapture priority:(int)priority
{
	if (!type)
	{
		PXThrowNilParam(type);
		return NO;
	}
	if (!listener)
	{
		PXThrowNilParam(listener);
		return NO;
	}

	// Event priority must be >= zero... Could be negative in Flash player, but
	// decided against it here for optimization purposes (so the default zero
	// priority listeners can always be added to the end of the list)
	if (priority < 0)
	{
		PXThrow(PXArgumentException, @"Parameter priority must be >= 0");
		return NO;
	}

	if (!eventListeners)
	{
		//Initialize the dictionary
		eventListeners = [[NSMutableDictionary alloc] init];
	}

	//The capture phase events are stored in a different array
	if (useCapture)
	{
		type = PX_GET_EVENT_CAPTURE_KEY(type);
	}

	//Get the array of event listeners. If it doesn't exist, create it
	PXLinkedList *listenersArray = [eventListeners valueForKey:type];
	if (!listenersArray)
	{
		listenersArray = [[PXLinkedList alloc] initWithPooledNodes:PX_LINKED_LISTS_USE_POOLED_NODES];
		[eventListeners setValue:listenersArray forKey:type];
		[listenersArray release];
	}

	// If there is already an identical listener (ie with the exact same
	// function), don't do anything.  Similar behavior seen (but not officially
	// documented) in the Flash player
	// if ([self getSimilarListener:listener inArr:listenersArray] != nil)
	if (PXGetSimilarListener(listener, listenersArray))
	{
		return NO;
	}

	// Add this listener into the list given its priority
	if ([listenersArray count] == 0)
	{
		// Optimization, since the lowest priority is zero, these can always be
		// added to the end of the list
		[listenersArray addObject:listener];
	}
	else
	{
		//Loop on each listener and see if it has a higher priority

		int index = 0;
		int count = [listenersArray count];

		PXEventListener *cListener = nil;
		PXLinkedListForEach(listenersArray, cListener)
		{
			if (priority > cListener->_priority)
			{
				[listenersArray insertObject:listener atIndex:index];
				break;
			}

			++index;
		}

		// Looks like all the items have a higher or = priority, just add at the
		// end
		if (index == count)
		{
			[listenersArray addObject:listener];
		}
	}

	listener->_priority = priority;
	
	return YES;
}

#pragma mark Removing Listeners

/**
 * Removes an event listener.
 *
 * @param type The type
 * @param listener The listener
 */
- (BOOL) removeEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener
{
	return [self removeEventListenerOfType:type listener:listener useCapture:NO];
}

/**
 * Removes an event listener.
 *
 * @param type The type
 * @param listener The listener
 * @param capture If it should use capture
 */
- (BOOL) removeEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener useCapture:(BOOL)useCapture
{
	if (!type)
	{
		PXThrowNilParam(type);
		return NO;
	}
	if (!listener)
	{
		PXThrowNilParam(listener);
		return NO;
	}
	
	// Can't remove an event listeners if there aren't any
	if (!eventListeners)
		return NO;

	if (useCapture)
	{
		type = PX_GET_EVENT_CAPTURE_KEY(type);
	}

	PXLinkedList *listenersArray = [eventListeners valueForKey:type];

	// Can't remove an event listener if there aren't any for that type
	if (!listenersArray)
		return NO;

	// Remove the listener from the array
	//[self getSimilarListener:listener inArr:listenersArray];
	PXEventListener *realListener = PXGetSimilarListener(listener, listenersArray);

	//Can't remove a listener if it doesn't exist in my list
	if (!realListener)
		return NO;

	[listenersArray removeObject:realListener];

	// If the array is empty now, dispose of it
	if ([listenersArray count] <= 0)
	{
		[eventListeners removeObjectForKey:type];
	}

	// If the dictionary is empty, get rid of it
	if ([eventListeners count] <= 0)
	{
		[eventListeners release];
		eventListeners = nil;
	}
	
	return YES;
}

// TODO: Change this up so that individual removeEventListener methods are called.
// This way subclasses won't have to override this method to know when private event
// listeners are removed when this method is called.
/**
 * Removes all of the event listeners.
 */
- (void) removeAllEventListeners
{
	[eventListeners release];
	eventListeners = nil;

	/*if (!eventListeners)
	{
		return;
	}

	NSMutableDictionary *eventListenersCopy = [[NSMutableDictionary alloc] init];

	NSEnumerator *enumerator;
	NSString *key;
	PXGenericObject obj;

	enumerator = [eventListeners keyEnumerator];
	while (key = [enumerator nextObject])
	{
		obj = [eventListeners objectForKey:key];

		[eventListenersCopy setObject:obj forKey:key];
	}

	enumerator = [eventListenersCopy objectEnumerator];
	PXLinkedList *listenersArray;
	PXEventListener *realListener;
	PXEventListener *listener;
	PXEventListener *realListener;
	PXLinkedList *listenersRemoveList;

	while (obj = [enumerator nextObject])
	{
		listenersArray = (PXLinkedList *)(obj);

		// Can't remove an event listener if there aren't any for that type
		if (!listenersArray)
			continue;

		listenersRemoveList = [[PXLinkedList alloc] init];
		for (listener in listenersArray)
		{
			realListener = PXGetSimilarListener(listener, listenersArray);

			//Can't remove a listener if it doesn't exist in my list
			if (!realListener)
				continue;

			[listenersRemoveList addObject:realListener];
		}
		for (listener in listenersRemoveList)
		{
			[listenersRemoveList removeObject:listener];
		}
		[listenersRemoveList release];
	}*/
}

#pragma mark Querying

/**
 * Returns `YES` if this event dispatcher has a listener of the
 * type.
 *
 * @param type The type.
 *
 * @return Returns `YES` if this event dispatcher has a listener of the
 * type.
 */
- (BOOL) hasEventListenerOfType:(NSString *)type
{
	if (!type)
	{
		PXThrowNilParam(type);
		return NO;
	}

	if (!eventListeners)
		return NO;

	// Check the non-capture phase
	if ([eventListeners valueForKey:type] != nil)
		return YES;

	// Check the capture phase
	if ([eventListeners valueForKey:PX_GET_EVENT_CAPTURE_KEY(type)] != nil)
		return YES;

	return NO;
}

/**
 * This method returns `YES` if an event listener is triggered
 * during any phase of the event flow when an event of the specified type is
 * dispatched to this EventDispatcher object or any of its descendants.
 *
 * Essentially, checks the entire flow path of the event, were it to dispatch
 * right now, and sees if any node along the path has an event listener. This
 * really only applies to display object sinceonly they have event flow...
 *
 * @param type The type
 *
 * @return This method returns `YES` if an event listener is triggered
 * during any phase of the event flow when an event of the specified type
 * is dispatched to this EventDispatcher object or any of its descendants.
 */
- (BOOL) willTriggerEventOfType:(NSString *)type
{
	if (!type)
	{
		PXThrowNilParam(type);
		return NO;
	}

	return [self hasEventListenerOfType:type];
}

#pragma mark Dispatching

// Prepares an event for dispatching
//- (PXEvent *)_prepEvent:(PXEvent *)event
- (void)_prepEvent:(PXEvent *)event
{
	// Set the defaults for dispatching events without any flow (ie just one
	// phase).  PXDisplayObject takes care of display list event flow

	event->_target = target;
	event->_currentTarget = event->_target;
	event->_defaultPrevented = NO;
	event->_stopPropegationLevel = 0;
	event->_eventPhase = PXEventPhase_Target; //Default

	//return event;
}

/**
 * Invokes the event on all listeners of the same type as `event`.
 *
 * @param event The event
 *
 * @return `YES` if the event completed.
 */

/*
 * Take good care when calling this function (retain this object before/release
 * after).  The reason is that after object.dispatchEvent is called, there's no
 * guarantee that this object wasn't deleted by one of the event handlers
 */
- (BOOL) dispatchEvent:(PXEvent *)event
{
	if (!event)
	{
		PXThrowNilParam(event);
		return NO;
	}
	
	if (!dispatchEvents)
		return NO;
	
	if (!event)
		return NO;
	
	// Get a retain on the event
	// If the event is currently being dispatched, make a copy of it and
	// dispatch that.
	// This behavior is kind of documented in the Event.clone() Flash API
	// description.
	if (event->_isBeingDispatched)
		event = [event copy];
	else
		[event retain];
	
	////////////////////
	// Prep the event //
	////////////////////

	[self _prepEvent:event];
	//event = [self _prepEvent:event];
	//if (!event)
	//	return NO;

	////////////////////////
	// Dispatch the event //
	////////////////////////

	event->_isBeingDispatched = YES;

	// Keep a hold of me in case someone tries to deallocate me
	// Ex: Think about the case where this object gets released while looping
	// through its listeners.
	// It would be a hard to find the cause of the crash.
	[self retain];

	// This is the default behavior when not doing display list event flow
	[self _invokeEvent:event withCurrentTarget:target eventPhase:PXEventPhase_Target];

	// I can be deallocated now if needed
	[self release];

	event->_isBeingDispatched = NO;
	BOOL defaultPrevented = event->_defaultPrevented;
	
	// Release the event
	[event release];
	
	return !defaultPrevented;
}

#pragma mark Private functions

/*
 * This actually dispatches the event listeners
 * Loops through all of the listeners for the given type of event and invokes
 * them with the given event object. Assumes that the event has already been
 * re-set.
 */
- (void) _invokeEvent:(PXEvent *)event withCurrentTarget:(PXGenericObject)currentTarget eventPhase:(char)phase
{
	/* No reason to dispatch events if there are no event listeners */
	if (!eventListeners)
		return;            // YES;

	NSString *type = event.type;

	if (type == nil)
	{
		return;
	}

	// If in the capture phase, only invoke the capture phase listeners
	if (phase == PXEventPhase_Capture)
	{
		type = PX_GET_EVENT_CAPTURE_KEY(type);
	}

	PXLinkedList *listeners = [eventListeners valueForKey:type];

	// There's no reason to try to dispatch an event if no one is listening to
	// the event's type.
	if (!listeners)
		return;       // YES;

	if (listeners.count <= 0)
		return;                 // YES;

	/////////////////////////////////////////////////
	// Event is Kosher, let's actually dispatch it //
	/////////////////////////////////////////////////

	event->_currentTarget = currentTarget;
	event->_eventPhase = phase;

	// Dispatch all the listeners for this event
	PXEventListener *listener = 0;

	// Copy all the events.
	//  This is the magic: The copied event listeners won't deallocate while
	//   their functions are being called.
	//  Also since the copied list is being looped over, the main list (used by
	//   addEventListener and removeEventListener) can be mutated

	PXLinkedList *cachedListeners = (PXLinkedList *)[PXEngineGetSharedObjectPool() newObjectUsingClass:[PXLinkedList class]];
	[cachedListeners removeAllObjects];

	// Retain all the listener targets so they don't disappear mid-invocation
	PXLinkedListForEach(listeners, listener)
	{
		NSAssert(listener, @"PXEventDispatcher: One of my listeners is nil");

		[listener->_target retain];
		[cachedListeners addObject:listener];
	}

	// Invoke all the event functions
	PXLinkedListForEach(cachedListeners, listener)
	{
		_PXEventListenerInvoke(listener, event);

		// If user called event.stopPropegationNow()
		if (event->_stopPropegationLevel == 2)
		{
			break;
		}
	}

	// Release all the listener targets
	PXLinkedListForEach(cachedListeners, listener)
	{
		[listener->_target release];
	}

	// Clean up the temp list and put it back
	[cachedListeners removeAllObjects];
	[PXEngineGetSharedObjectPool() releaseObject:cachedListeners];

	return;
}

@end

//Private//
// Matches the passed listener object with each one in the array to see if their
// properties are equal
PXEventListener *PXGetSimilarListener(PXEventListener *listener, PXLinkedList *list)
{
	PXEventListener *cListener;

	PXLinkedListForEach(list, cListener)
	{
		if (_PXEventListenersAreEqual(listener, cListener))
		{
			return cListener;
		}
	}

	return nil;
}
