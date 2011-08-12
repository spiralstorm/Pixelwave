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

#import "PXDisplayObjectContainer.h"
#import "PXEvent.h"

#import "PXEngine.h"
#import "PXTouchEngine.h"
#import "PXStage.h"

#import "PXPrivateUtils.h"
#import "PXExceptionUtils.h"
#import "PXDebugUtils.h"

#import "PXPoint.h"

/*
 * DEFINEs for looping the linked list.
 * If needed, make sure to use PX_CONTINUE_CHILD_LOOP and not just 'continue'.
 * Variables 'i' and 'child' are available within the START and END tags
 */

#define PXThrowDispNotChild PXThrow(PXArgumentException, @"The supplied DisplayObject must be a child of the caller.");

@interface PXDisplayObjectContainer (Private)
- (void) addChild:(PXDisplayObject *)child beforeChild:(PXDisplayObject *)childToAddBefore dispatchEvents:(BOOL)dispatchEvents;
- (void) removeChild:(PXDisplayObject *)child dispatchEvents:(BOOL)dispatchEvents;
@end

/**
 * A PXDisplayObjectContainer is the abstract base class for setting up the
 * display list.  A PXDisplayObjectContainer is a display object that can hold
 * children.  A PXDisplayObjectContainer should never be made directly, if you
 * wish to have a display object that holds children, then use a PXSprite or
 * PXSimpleSprite instead.
 *
 * When a PXDisplayObjectContainer is deallocated it removes all of its
 * children, which invokes the `remove` event on each one. This
 * behavior differs from that of Flash because all containers in Objective-C
 * must remove their contents once deallocated (to avoid
 * `child.parent` pointing to a zombie).
 *
 * @see PXDisplayObject
 * @see PXSimpleSprite
 */
@implementation PXDisplayObjectContainer

@synthesize touchChildren = _touchChildren;
@synthesize numChildren = _numChildren;

- (id) init
{
	self = [super init];

	if (self)
	{
		_childrenHead = nil; _childrenTail = nil;
		_numChildren = 0;
		PX_ENABLE_BIT(_flags, _PXDisplayObjectFlags_isContainer);

		_renderMode = PXRenderMode_Off;
		_touchChildren = YES;

		// Optimization:
		_impPreChildRenderGL = (void (*)(id, SEL))[self methodForSelector:@selector(_preChildRenderGL)];
		_impPostChildRenderGL = (void (*)(id, SEL))[self methodForSelector:@selector(_postChildRenderGL)];

		_impAddChildBefore = (void (*)(id, SEL, PXDisplayObject *, PXDisplayObject *, BOOL))[self methodForSelector:@selector(addChild:beforeChild:dispatchEvents:)];
		_impRemoveChild = (void (*)(id, SEL, PXDisplayObject *, BOOL))[self methodForSelector:@selector(removeChild:dispatchEvents:)];
	}

	return self;
}

// Removes all the children
- (void) dealloc
{
	// Remove all of my children
	[self removeAllChildren];

	_impPreChildRenderGL = 0;
	_impPostChildRenderGL = 0;

	_impAddChildBefore = 0;
	_impRemoveChild = 0;

	[super dealloc];
}

/////

//////////////////////
// Helper functions //
//////////////////////

#pragma mark Adding children

// Private function. This one actually does the adding
- (void) addChild:(PXDisplayObject *)child beforeChild:(PXDisplayObject *)childToAddBefore dispatchEvents:(BOOL)dispatchEvents
{
	// This increases the retain count, this is done here so that in the next if
	// statement the child does not lose all of it's retains. This is needed
	// anyway, as we need to hold onto a retain of the child anyway.
	[child retain];

	// In Flash, 
	if (child->_parent)  //If the child is already contained in a parent, remove it from that parent
	{
		[child->_parent removeChild:child];
	}

	/////////////////
	// Linked List //
	/////////////////

	//_children and _childrenTail must both be null or both be non-null
	NSAssert((_childrenHead && _childrenTail) || (!_childrenHead && !_childrenTail), @"Head and Tail must both be either null or non-null");

	if (!childToAddBefore)  //The last index was picked, add it to the tail
	{
		if (_childrenTail)  //The list isn't empty
		{
			_childrenTail->_next = child;
			child->_prev = _childrenTail;
			child->_next = nil;

			_childrenTail = child;
		}
		else   //The list is empty
		{
			_childrenHead = child;
			_childrenTail = child;

			child->_next = nil;
			child->_prev = nil;
		}
	}
	else   //Insert 'child' into the list

	{       //Assume that the list isn't empty at this point
		NSAssert(_numChildren > 0, @"The list must have at least one item at this point");

		/*
		                                Inserted here
		   \/
		   [prevChild] <----> [child] <----> [childToAddBefore]
		        ^
		   (may be null,
		   making child
		   the new head)

		 */

		//Add child right before 'childToAddBefore' (on the left)
		PXDisplayObject *prevChild = childToAddBefore->_prev; //The node to be on the left of 'child'

		//Create the right hand link
		childToAddBefore->_prev = child;
		child->_next = childToAddBefore;

		//Create the left hand link
		if (prevChild)
		{
			//Add me after the prev child
			prevChild->_next = child;
			child->_prev = prevChild;
		}
		else   //This is the new head
		{
			NSAssert(childToAddBefore == _childrenHead, @"Assuming that childToAddBefore is the head of the list");

			child->_prev = nil;
			_childrenHead = child;
		}
	}

	++_numChildren;

	///////////
	// Child //
	///////////

	child->_parent = self;
	
	// According to the API docs added events come after the child's been added	
	if (dispatchEvents)
	{
		// Keep a hold of child
		[child retain];
		
		PXEvent *e = nil;
		
		// ADDED event
		e = [[PXEvent alloc] initWithType:PXEvent_Added
							   bubbles:YES
							 cancelable:NO];
		[child dispatchEvent:e];
		[e release];
		
		// If the child is still on the display list
		if (child.stage)
		{
			// ADDED_TO_STAGE event
			
			// Yay this new child is going to be on the on stage display list!			
			// dispatch ADDED_TO_STAGE event
			
			e = [[PXEvent alloc] initWithType:PXEvent_AddedToStage
											bubbles:NO
										  cancelable:NO];
			
			[child _dispatchAndPropegateEvent:e];
			// Note child is not guaranteed to be in the display list, or even
			// exist at this point
			
			[e release];
		}
		
		// Release the child
		[child release];
	}
}

/**
 * Adds a child to the display list, increasing its retain count by 1.
 *
 * @param child The object to be added.
 *
 * @return The display object passed by the child parameter.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	// add1 has a retain count of 1
 *	[simpleSprite addChild:add1];
 *	// add1 has a retain count of 2
 */
- (PXDisplayObject *)addChild:(PXDisplayObject *)child
{
	if (!child)
	{
		PXThrowNilParam(child);
		return child;
	}
	
	if (child == self)
	{
		PXThrow(PXArgumentException, @"An object cannot be added as a child of itself.");
		return child;
	}
	
	_impAddChildBefore(self, nil, child, nil, PXEngineGetStage().dispatchesDisplayListEvents);

	return child;
}

/**
 * Adds a child to the display list at the specified index, increasing its
 * retain count by 1.
 *
 * @param child The object to be added.
 * @param index The index at which to add the display object. An index
 * of 0 represents the very back of the screen, while higher indecies
 * are closer to the top.
 *
 * @return The display object passed by the child parameter.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	// add1 has a retain count of 1
 *	[simpleSprite addChild:add1 atIndex:0];
 *	// add1 has a retain count of 2
 */
- (PXDisplayObject *)addChild:(PXDisplayObject *)child atIndex:(int)index
{
	if (!child)
	{
		PXThrowNilParam(child);
		return child;
	}
	
	if (child == self)
	{
		PXThrow(PXArgumentException, @"An object cannot be added as a child of itself.");
		return child;
	}
	
	if (index < 0 || index > _numChildren)
	{
		PXThrowIndexOutOfBounds;
		return child;
	}

	//Find which child lives at this index

	PXDisplayObject *childToAddBefore = nil;

	if (index < _numChildren)
	{
		PXDisplayObject *loopChild;
		unsigned loopIndex;
		for (loopIndex = 0, loopChild = _childrenHead; loopIndex < _numChildren; ++loopIndex, loopChild = loopChild->_next)
		{
			if (loopIndex == index)
			{
				childToAddBefore = loopChild;
				break;
			}
		}

		NSAssert(child != nil, @"Assuming that the child was found and there are no holes in the linked list chain");
	}

	_impAddChildBefore(self, nil, child, childToAddBefore, PXEngineGetStage().dispatchesDisplayListEvents);

	return child;
}

#pragma mark Removing Children

// As an optimization, there is no containment check to see if the child is
// actually on the list. Only the parent is checked to see if it matches.

- (void) removeChild:(PXDisplayObject *)child dispatchEvents:(BOOL)dispatchEvents
{	
	// I don't have any children, so none can be removed
	if (!_childrenHead || !child)
	{
		return;
	}

	/////////////////
	// Linked List //
	/////////////////

	//_childrenHead and _childrenTail must both be null or both be non-null
	NSAssert((_childrenHead && _childrenTail) || (!_childrenHead && !_childrenTail), @"_childrenHead and _childrenTail must both be null or both be non-null");

	////////////
	// Events //
	////////////

	// Removes all touch captures that may be associating with this child.
	PXTouchEngineRemoveAllTouchCapturesFromObject(child);

	// Removed events come before things get romoved
	if (dispatchEvents)
	{
		// Get an extra hold on the child, in case all of its owners release it
		// on the listeners
		[child retain];

		PXEvent *event = nil;

		// REMOVED event
		event = [[PXEvent alloc] initWithType:PXEvent_Removed
								   bubbles:YES
								 cancelable:NO];

		[child dispatchEvent:event];
		[event release];

		// If the child hasn't been removed while we dispatched the remove event
		// on it, dispatch the next event
		if (child.stage != nil)
		{
			// REMOVED_FROM_STAGE event

			event = [[PXEvent alloc] initWithType:PXEvent_RemovedFromStage
									   bubbles:NO
									 cancelable:NO];

			[child _dispatchAndPropegateEvent:event];

			[event release];
		}

		// Is the child still MY child?
		if (child->_parent != self)
		{
			// Oops, looks like one of the event listeners removed the child
			// before I even got to.
			[child release];
			return;
		}

		// Get rid of my extra hold
		[child release];
	}

	/////////////////
	// Linked List //
	/////////////////

	//Remove me from the list
	if (child == _childrenHead && child == _childrenTail)
	{
		//I'm the only one...
		_childrenHead = nil;
		_childrenTail = nil;
	}
	else if (child == _childrenTail) //I'm the tail, and there's a (different) head
	{
		_childrenTail = _childrenTail->_prev;
		_childrenTail->_next = nil;
	}
	else if (child == _childrenHead) //I'm the head, and there's a (different) tail
	{
		_childrenHead = _childrenHead->_next;
		_childrenHead->_prev = nil;
	}
	else
	{
		//I'm somewhere in the middle, there's a (different) head and tail
		//I must have a next and a prev
		NSAssert(child->_next && child->_prev, @"Assuming that this node has children");

		PXDisplayObject *childPrev = child->_prev;
		PXDisplayObject *childNext = child->_next;

		childPrev->_next = childNext;
		childNext->_prev = childPrev;

		//child->_prev->_next = child->_next;
		//child->_next->_prev = child->_prev;
	}

	child->_next = nil;
	child->_prev = nil;

	--_numChildren;

	///////////
	// Child //
	///////////

	child->_parent = nil;

	[child release]; //release my real hold
}

/**
 * Removes the child from the container, and decreases its retain count by 1.
 * If the specified object is not a child of this container, then a
 * #PXArgumentException is thrown. All of the other children move
 * down a position to fill the gap left by the removed child.
 *
 * @param child The child to be removed.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	PXSimpleSprite *add2 = [PXSimpleSprite new];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *	[simpleSprite addChild:add1];
 *	[simpleSprite addChild:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 2, and an index of 1
 *	[simpleSprite removeChild:add1];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 2, and an index of 0
 */
- (void) removeChild:(PXDisplayObject *)child
{
	if (!child)
	{
		PXThrowNilParam(child);
		return;
	}

	if (child->_parent != self)
	{
		PXThrowDispNotChild;
		return;
	}

	_impRemoveChild(self, nil, child, PXEngineGetStage().dispatchesDisplayListEvents);
}

/**
 * Removes the child from the container, and decreases its retain count by 1.
 * If the object is not a child of this container, then a
 * #PXRangeException is thrown. All of the other children move
 * down a position to fill the gap left by the removed child.
 *
 * @param index The index of the child to be removed.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	PXSimpleSprite *add2 = [PXSimpleSprite new];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *	[simpleSprite addChild:add1];
 *	[simpleSprite addChild:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 2, and an index of 1
 *	[simpleSprite removeChildAtIndex:0];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 2, and an index of 0
 */
- (void) removeChildAtIndex:(int)index
{
	if (index < 0 || index >= _numChildren)
	{
		PXThrowIndexOutOfBounds;
		return;
	}

	PXDisplayObject *child = [self childAtIndex:index];
	[self removeChild:child];
}

#pragma mark Querying

/**
 * Determines whether the specified object is a child of this container or any
 * of its children.
 *
 * @param child The child to be checked.
 *
 * @return YES if the specified child is a decendant of this container.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	[simpleSprite addChild:add1];
 *	BOOL containsChild = [simpleSprite containsChild:add1];
 *	// containsChild is YES
 *	[simpleSprite removeChild:add1];
 *	containsChild = [simpleSprite containsChild:add1];
 *	// containsChild is NO
 */
- (BOOL) containsChild:(PXDisplayObject *)childToCheck
{
	if (!childToCheck)
	{
		PXThrowNilParam(child);
	}

	PXDisplayObject *loopChild;
	unsigned loopIndex;
	for (loopIndex = 0, loopChild = _childrenHead; loopIndex < _numChildren; ++loopIndex, loopChild = loopChild->_next)
	{
		if (loopChild == childToCheck)
			return YES;

		if (PX_IS_BIT_ENABLED(loopChild->_flags, _PXDisplayObjectFlags_isContainer))
		{
			if ([(PXDisplayObjectContainer *)loopChild containsChild:childToCheck])
				return YES;
		}
	}

	return NO;

}

/**
 * Retrieves the index of the specified child.  If the specified child is not
 * part of this container, then `-1` is returned instead and a
 * #PXArgumentException is thrown.
 *
 * @param child The child in question.
 *
 * @return index
 * The index of the child.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	PXSimpleSprite *add2 = [PXSimpleSprite new];
 *	[simpleSprite addChild:add1];
 *	[simpleSprite addChild:add2];
 *
 *	int index = [simpleSprite getIndexOfChild:add1];
 *	// index == 0
 *	index = [simpleSprite getIndexOfChild:add2];
 *	// index == 1
 *	[simpleSprite removeChild:add1];
 *	index = [simpleSprite getIndexOfChild:add1];
 *	//index == -1
 */
- (int) indexOfChild:(PXDisplayObject *)childToCheck
{
	if (!childToCheck)
	{
		PXThrowNilParam(child);
		return -1;
	}
	
	if (childToCheck->_parent != self)
	{
		PXThrowDispNotChild;
		return -1;
	}

	PXDisplayObject *loopChild;
	unsigned loopIndex;
	for (loopIndex = 0, loopChild = _childrenHead; loopIndex < _numChildren; ++loopIndex, loopChild = loopChild->_next)
	{
		if (loopChild == childToCheck)
			return loopIndex;
	}

	// The code should never get here.. if the parent of childToCheck is self,
	// it should be found in the above loop

	PXDebugLog (@"There was a weird error in getChildIndex");

	return -1;
}

#pragma mark Retrieving Children

/**
 * Retrieves the child at the specified index.  If no child was found at the
 * index, then `nil` is returned instead.  If the index is out of
 * bounds then a #PXRangeException is thrown.
 *
 * @param index The index.
 *
 * @return The child at the specified index.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	[simpleSprite addChild:add1];
 *	PXSimpleSprite *retrievedChild = (PXSimpleSprite *)[simpleSprite getChildAtIndex:0];
 *	// retrievedChild == add1
 */
- (PXDisplayObject *)childAtIndex:(int)index
{
	if (index < 0 || index >= _numChildren)
	{
		PXThrowIndexOutOfBounds;
		return nil;
	}

	PXDisplayObject *loopChild;
	unsigned loopIndex;
	for (loopIndex = 0, loopChild = _childrenHead; loopIndex < _numChildren; ++loopIndex, loopChild = loopChild->_next)
	{
		if (loopIndex == index)
			return loopChild;
	}

	// The code should never get here.. if the parent of childToCheck is self,
	// it should be found in the above loop

	PXDebugLog (@"There was a weird error in getChildAt");

	return nil;

	/* //NSArray method
	   if ([_children count] <= 0) return nil;
	   return [_children objectAtIndex:index];
	 */
}

/**
 * Retrieves the child with the specified name.  If no child was found with the
 * specified name, then `nil` is returned instead.
 *
 * @param name The case sensitive name of the child.
 *
 * @return The child with the specified name.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	add1.name = @"Orange";
 *	[simpleSprite addChild:add1];
 *	PXSimpleSprite *retrievedChild = (PXSimpleSprite *)[simpleSprite getChildByName:@"Orange"];
 *	// retrievedChild == add1
 */
- (PXDisplayObject *)childByName:(NSString *)name
{
	if (!name)
	{
		PXThrowNilParam(name);
		return nil;
	}

	PXDisplayObject *loopChild;
	unsigned loopIndex;
	for (loopIndex = 0, loopChild = _childrenHead; loopIndex < _numChildren; ++loopIndex, loopChild = loopChild->_next)
	{
		if ([loopChild.name isEqualToString:name])
		{
			return loopChild;
		}
	}

	return nil;
}

#pragma mark Moving Children

/**
 * Changes the position of the child to the specified index.  This will
 * decrease the position all of the children that are between the original
 * index and the new index.
 *
 * If the index provided is less than 0, then the object is moved to index 0.
 * If the index is higher than the number of children, then the object is moved
 * to the last index.
 *
 * @param index New index of the child.
 * @param child Child to be repositioned.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	PXSimpleSprite *add2 = [PXSimpleSprite new];
 *	PXSimpleSprite *add3 = [PXSimpleSprite new];
 *	[simpleSprite addChild:add1];
 *	[simpleSprite addChild:add2];
 *	[simpleSprite addChild:add3];
 *	// add1 has an index of 0, add2 has an index of 1, add3 has an index of 2.
 *	[simpleSprite setIndex:2 ofChild:add1];
 *	// add1 has an index of 2, add2 has an index of 0, add3 has an index of 1.
 *	[simpleSprite setIndex:2 ofChild:add3];
 *	// add1 has an index of 1, add2 has an index of 0, add3 has an index of 2.
 */
- (void) setIndex:(int)index ofChild:(PXDisplayObject *)child
{
	// Check preconditions
	
	if (!child)
	{
		PXThrowNilParam(child);
		return;
	}
	
	if (index < 0 || index >= _numChildren)
	{
		PXThrowIndexOutOfBounds;
		return;
	}
	
	if (child->_parent != self)
	{
		PXThrowDispNotChild;
		return;
	}
	
	// Make the switch //
	
	// First remove the child from the list, but without dispatching events
	_impRemoveChild(self, nil, child, NO);
	
	if (index == _numChildren)
	{
		// An optimization: Add it back at the end of the list
		_impAddChildBefore(self, nil, child, nil, NO);
	}
	else
	{
		// Add it before the child at 'index' to take its place
		PXDisplayObject *childAtIndex = nil;

		PXDisplayObject *loopChild;
		unsigned loopIndex;
		for (loopIndex = 0, loopChild = _childrenHead; loopIndex < _numChildren; ++loopIndex, loopChild = loopChild->_next)
		{
			if (loopIndex == index)
			{
				childAtIndex = loopChild;
				break;
			}
		}

		// Now add it back at the right index
		_impAddChildBefore(self, nil, child, childAtIndex, NO);
	}
}

/**
 * Swaps the two children's position, all other children remain in the position
 * they were at prior to the swap taking place.
 *
 * @param child1 The first child.
 * @param child2 The second child.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	PXSimpleSprite *add2 = [PXSimpleSprite new];
 *	[simpleSprite addChild:add1];
 *	[simpleSprite addChild:add2];
 *	// add1 has an index of 0, add2 has an index of 1
 *	[simpleSprite swapChild:add1 withChild:add2];
 *	// add1 has an index of 1, add2 has an index of 0
 */
- (void) swapChild:(PXDisplayObject *)child1 withChild:(PXDisplayObject *)child2
{
	//Just swap, no adding or removing

	if (!child1 || !child2)
	{
		PXThrowNilParam(child);
		return;
	}

	if (child1->_parent != self || child2->_parent != self)
	{
		PXThrowDispNotChild;
		return;
	}

	if (child1 == child2)
		return;

	// Grab the next and previous of the children
	PXDisplayObject *next1 = child1->_next;
	PXDisplayObject *prev1 = child1->_prev;

	PXDisplayObject *next2 = child2->_next;
	PXDisplayObject *prev2 = child2->_prev;

	// Set their next and previous to the other child's next and previous (this
	// does the initial swap).
	child1->_next = next2;
	child1->_prev = prev2;
	child2->_next = next1;
	child2->_prev = prev1;

	// Special Case:	If the children are next to eachother, then they would
	//					be pointing back at themselves from the previous swap.
	//					This must be corrected, or it would cause an infinite
	//					loop when looping through the children.
	if (next1 == child2)
	{
		// Case 1:		The RIGHT side swap. This is when the first child's next
		//				is equal to the second child. The other case is when the
		//				second child's next is equal to the first child, this
		//				would be called the LEFT swap.

		// If the next of the first child is equal to the second, then they are
		// next to eachother and we must set their next and previous to the
		// other child rather then themselves (which they would be currently
		// set to).
		child2->_next = child1;
		child1->_prev = child2;
	}
	else
	{
		// If they are not next to eachother on the RIGHT side, then we can set
		// the next's previous and the previous's next normally.
		if (next1)
			next1->_prev = child2;
		if (prev2)
			prev2->_next = child1;
	}
	if (next2 == child1)
	{
		// Case 2:		The LEFT side swap. This is when the second child's next
		//				is equal to the first child. The other case is when the
		//				first child's next is equal to the second child, this
		//				would be called the RIGHT swap.

		// If the next of the second child is equal to the first, then they are
		// next to eachother and we must set their next and previous to the
		// other child rather then themselves (which they would be currently
		// set to).
		child2->_prev = child1;
		child1->_next = child2;
	}
	else
	{
		// If they are not next to eachother on the LEFT side, then we can set
		// the next's previous and the previous's next normally.
		if (prev1)
			prev1->_next = child2;
		if (next2)
			next2->_prev = child1;
	}

	// Special Case:	If our head or tail pointer points to either of the
	//					children, we must update it to point to the other now.
	if (_childrenHead == child1)
		_childrenHead = child2;
	else if (_childrenHead == child2)
		_childrenHead = child1;

	if (_childrenTail == child1)
		_childrenTail = child2;
	else if (_childrenTail == child2)
		_childrenTail = child1;
}

/**
 * Swaps the two children's position, all other children remain in the position
 * they were at prior to the swap taking place.
 *
 * It is more efficent not to reference a child by index.  If at all possible
 * you should avoid using this method, and use #swapChild:withChild: instead.
 *
 * @param index1 Index of the first child.
 * @param index2 Index of the second child.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	PXSimpleSprite *add2 = [PXSimpleSprite new];
 *	[simpleSprite addChild:add1];
 *	[simpleSprite addChild:add2];
 *	// add1 has an index of 0, add2 has an index of 1
 *	[simpleSprite swapChildAtIndex:0 withChildAtIndex:1];
 *	// add1 has an index of 1, add2 has an index of 0
 *
 * @exception
 * PXArgumentException Throws if either child parameter is not a child of
 * this object.
 */
- (void) swapChildAtIndex:(int)index1 withChildAtIndex:(int)index2
{
	if (index1 >= _numChildren || index2 >= _numChildren ||
	    index1 < 0 || index2 < 0)
	{
		PXThrowIndexOutOfBounds;
		return;
	}

	PXDisplayObject *child1 = [self childAtIndex:index1];
	PXDisplayObject *child2 = [self childAtIndex:index2];

	NSAssert(child1 && child2, @"child1 and child2 must be non-nil");

	[self swapChild:child1 withChild:child2];
}

/**
 * Removes all of the children from the container, reducing each of the
 * object's retain counts by 1.
 *
 * **Example:**
 *	PXSimpleSprite *simpleSprite = [PXSimpleSprite new];
 *	PXSimpleSprite *add1 = [PXSimpleSprite new];
 *	PXSimpleSprite *add2 = [PXSimpleSprite new];
 *	// add1 and add2 have a retain count of 1
 *	[simpleSprite addChild:add1];
 *	[simpleSprite addChild:add2];
 *	// simpleSprite contains two children now
 *	// add1 and add2 have a retain count of 2
 *	[add1 release];
 *	[add2 release];
 *	// add1 and add2 have a retain count of 1
 *	[simpleSprite removeAllChildren];
 *	// simpleSprite has no children now
 *	// add1 and add2 have a retain count of 0
 */
- (void) removeAllChildren
{
	unsigned short len = _numChildren;
	for (unsigned short i = 0; i < len; ++i)
	{
		[self removeChild:_childrenHead];
	}

	_childrenHead = nil;
	_childrenTail = nil;
	_numChildren = 0;
}

/**
 * Makes a list of objects that are under the given point.  These objects can
 * be any child, grandchild, etc. of this container, as long as they are under
 * the point.
 *
 * @param point The point to check for objects under in global coordinates.
 *
 * **Example:**
 *	PXSprite *container = [[PXSprite alloc] init];
 *
 *	PXSprite *square1 = [[PXSprite alloc] init];
 *	[square1.graphics beginFill:0xFFCC00 alpha:1.0f];
 *	[square1.graphics drawRectWithX:0 y:0 width:40 height:40];
 *
 *	PXSprite *square2 = [[PXSprite alloc] init];
 *	[square2.graphics beginFill:0x00CCFF alpha:1.0f];
 *	[square2.graphics drawRectWithX:20 y:0 width:30 height:40];
 *
 *	[container addChild:square1];
 *	[container addChild:square2];
 *
 *	PXPoint *pt;
 *	NSArray *objects;
 *
 *	pt = [PXPoint pointWithX:10 y:20];
 *	objects = [container objectsUnderPoint:pt];
 *	NSLog (@"list count = %d\n", [objects count]); // 1
 *
 *	pt = [PXPoint pointWithX:35 y:20];
 *	objects = [container objectsUnderPoint:pt];
 *	NSLog (@"list count = %d\n", [objects count]); // 2
 *
 *	[square1 release];
 *	[square2 release];
 *
 *	[container release];
 */
- (NSArray *)objectsUnderPoint:(PXPoint *)point
{
	if (!point)
	{
		return nil;
	}

	NSMutableArray *list = [[NSMutableArray alloc] init];
	NSArray *addList = nil;
	PXDisplayObjectContainer *container;

	PXDisplayObject *loopChild;
	unsigned loopIndex;
	for (loopIndex = 0, loopChild = _childrenHead; loopIndex < _numChildren; ++loopIndex, loopChild = loopChild->_next)
	{
		// If the point is within the child, then add the child.  This also adds
		// the child if it is a display object container when the point is
		// within the container itself and not it's children.  This is extremly
		// useful for the example of using a sprite that has a grahpics object,
		// and the point lies within the graphics object.
		if ([loopChild _hitTestPointWithoutRecursionWithGlobalX:point.x globalY:point.y shapeFlag:YES])
		{
			[list addObject:loopChild];
		}

		// If it is a display object container, then add each child that is also
		// under the point.
		if ([loopChild isKindOfClass:[PXDisplayObjectContainer class]])
		{
			container = (PXDisplayObjectContainer *)(loopChild);
			addList = [container objectsUnderPoint:point];
			
			[list addObjectsFromArray:addList];
		}
	}

	return [list autorelease];
}

#pragma mark Event Dispatching

// Tell all of my children they were added to the stage
// Overriden
//- (void) _dispatchAddedToStage
- (void) _dispatchAndPropegateEvent:(PXEvent *)event
{
	// Dispatch my event
	//[super _dispatchAddedToStage];
	[super _dispatchAndPropegateEvent:event];
	
	// If I have no children, don't bother
	if (_numChildren <= 0)
		return;
	
	// Loop through the children.
	// In the flash player when doing this the children aren't cached in a list
	// so care must be taken when looping through them because any event
	// listener may remove one of the children
	
	PXDisplayObject *child = nil;
	
	// The following behavior was reverse-engineered by fiddling with the flash
	// player to the best of my ability.	
	int childIndex;
	
	PXEvent *eCopy = nil;
	
	child = [self childAtIndex:0];
	
	for (; child;)
	{
		//[child _dispatchAddedToStage];
		// Propegate the event down to the child
		eCopy = [event copy];
		[child _dispatchAndPropegateEvent:eCopy];
		[eCopy release];
		eCopy = nil;
		
		// If the listener removed the child from me, stop here
		if (child->_parent != self)
			break;
		
		// Grab the next child on the list.
		
		// This has to be queried every loop because the order of the children
		// may have changed
		childIndex = [self indexOfChild:child];
		
		// If that was the last child, you're done
		if (childIndex >= _numChildren - 1)
			break;
		
		child = [self childAtIndex:childIndex + 1];
	}
}

#pragma mark Misc

- (void) _measureGlobalBounds:(CGRect *)retBounds
{
	if (_numChildren == 0)
	{
		[self _measureLocalBounds:retBounds];
		return;
	}

	CGRect _bounds = CGRectZero;
	[self _measureLocalBounds:&_bounds];

//	float xMin = _bounds.origin.x;
//	float xMax = abs(xMin) + _bounds.size.width;
//	float yMin = _bounds.origin.y;
//	float yMax = abs(yMin) + _bounds.size.height;

	float xMin = _bounds.origin.x;
	float xMax = xMin + _bounds.size.width;
	float yMin = _bounds.origin.y;
	float yMax = yMin + _bounds.size.height;

#define _PX_DISPLAY_OBJECT_UPDATE_AABB_BOUNDS(_xMin_, _xMax_, _yMin_, _yMax_, _x_, _y_) \
	{ \
		(_xMin_) = MIN((_x_), (_xMin_)); \
		(_xMax_) = MAX((_x_), (_xMax_)); \
		(_yMin_) = MIN((_y_), (_yMin_)); \
		(_yMax_) = MAX((_y_), (_yMax_)); \
	}
	//	if ((_xMin) > (_x)) (_xMin) = (_x); \
		if ((_xMax) < (_x)) (_xMax) = (_x); \
		if ((_yMin) > (_y)) (_yMin) = (_y); \
		if ((_yMax) < (_y)) (_yMax) = (_y); \
	}

	float rectX = 0.0f;
	float rectY = 0.0f;
	float rectW = 0.0f;
	float rectH = 0.0f;

	float x1; float y1;
	float x2; float y2;
	float x3; float y3;
	float x4; float y4;

	PXDisplayObject *loopChild;
	unsigned loopIndex;

	for (loopIndex = 0, loopChild = _childrenHead; loopIndex < _numChildren; ++loopIndex, loopChild = loopChild->_next)
	{
		_bounds = CGRectZero;
		[loopChild _measureGlobalBounds:&_bounds];

		if (CGRectIsEmpty(_bounds))
		{
			continue;
		}

		rectX = _bounds.origin.x;
		rectY = _bounds.origin.y;
		rectW = _bounds.size.width;
		rectH = _bounds.size.height;

		x1 = rectX;			y1 = rectY;
		x2 = rectX;			y2 = rectY + rectH;
		x3 = rectX + rectW;	y3 = rectY;
		x4 = rectX + rectW;	y4 = rectY + rectH;

		PXGLMatrixConvert4Pointsv(&(loopChild->_matrix),
								  &x1, &y1,
								  &x2, &y2,
								  &x3, &y3,
								  &x4, &y4);

		_PX_DISPLAY_OBJECT_UPDATE_AABB_BOUNDS(xMin, xMax, yMin, yMax, x1, y1);
		_PX_DISPLAY_OBJECT_UPDATE_AABB_BOUNDS(xMin, xMax, yMin, yMax, x2, y2);
		_PX_DISPLAY_OBJECT_UPDATE_AABB_BOUNDS(xMin, xMax, yMin, yMax, x3, y3);
		_PX_DISPLAY_OBJECT_UPDATE_AABB_BOUNDS(xMin, xMax, yMin, yMax, x4, y4);
	}

	retBounds->origin.x = xMin;
	retBounds->origin.y = yMin;
	retBounds->size.width  = xMax - xMin;
	retBounds->size.height = yMax - yMin;
}

- (BOOL) _hitTestPointWithLocalX:(float)x
						  localY:(float)y
					   shapeFlag:(BOOL)shapeFlag
{
	PXDisplayObject *loopChild;
	unsigned loopIndex;
	for (loopIndex = 0, loopChild = _childrenHead; loopIndex < _numChildren; ++loopIndex, loopChild = loopChild->_next)
	{
		if ([loopChild _hitTestPointWithParentX:x parentY:y shapeFlag:shapeFlag])
			return YES;
	}

	return [self _containsPointWithLocalX:x localY:y shapeFlag:shapeFlag];
}

#pragma mark Fast Enumeration

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)count
{
	PXDisplayObject *current;
	if (state->state == 0)
	{
		// Set the starting point. _startOfListNode is assumed to be our
		// object's instance variable that points to the start of the list.
		current = _childrenHead;
	}
	else if (state->state == 1) //No more items left
	{
		return 0;
	}
	else
	{
		// Subsequent iterations, get the current progress out of state->state
		current = (PXDisplayObject *)state->state;
	}

	unsigned index;
	for (index = 0; index < count; ++index)
	{
		if (current)
		{
			stackbuf[index] = current;
			current = current->_next;
		}
		else
		{
			break;
		}
	}

	if (current)
	{
		state->state = (unsigned long)current;
	}
	else
	{
		state->state = 1;
	}

	state->itemsPtr = stackbuf;
	state->mutationsPtr = (unsigned long *)self;

	return index;
}

- (void) _preChildRenderGL
{
}
- (void) _postChildRenderGL
{
}

@end
