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

#import "PXLinkedList.h"
#import "PXSettings.h"

#import "PXExceptionUtils.h"

#import "PXDebugUtils.h"

#include "PXPrivateUtils.h"

// Pooled nodes
static _PXLLNode **pxLLPooledNodesStack = 0; // C-array
static unsigned pxLLPooledNodesCount = 0; // Items in stack
static unsigned pxLLPooledNodesSize = 0; // Size of the array

_PXLLNode *PXLinkedListGetPooledNode();
void PXLinkedListReturnPooledNode(_PXLLNode *node);
void PXLinkedListShrinkPoolNodes(int newSize);

@interface PXLinkedList(Private)
- (void) addObject:(id)object beforeNode:(_PXLLNode *)nodeToAddBefore;
- (void) removeNode:(_PXLLNode *)node;
- (_PXLLNode *)getNodeByIndex:(int)index;
- (_PXLLNode *)getNodeByObject:(id)object;
- (void) swapNode:(_PXLLNode *)node1 withNode:(_PXLLNode *)node2;
@end

_PXLLNode pxLinkedListBadNode;

/**
 * A collection data structure which can hold any number of `NSObject` instances.
 * Like all collection classes, the PXLinkedList class
 * increases an object's retain count when it is added, and decreases the
 * object's retain count when it is removed. This behavior can be disabled,
 * however it is not recommended.
 *
 * On the surface the PXLinkedList class is structured very similarly to the
 * native `NSArray`	class, but under the hood it uses a linked list
 * structure.
 * 
 * The PXLinkedList class is designed to be fast and efficient. It has been
 * tested and found to be considerably faster than `NSArray` when
 * performing the following tasks:
 *
 * - Adding and removing objects to and from the ends of the list
 * - Adding and removing objects to and from the middle of the list
 * - Looping through the list _(And much more so when using
 * `PXLinkedListForEach` or its counterpart
 * `PXLinkedListForEachReverse`)_
 * 
 * <br/>
 * *Iterating through a linked list*
 * 
 * There are 3 (count 'em) ways to loop through a linked list:
 * 
 * 1) _(Recommended)_ Using Objective-C's fast enumeration. It is the
 * **encouraged** way to loop through linked lists. Here's a code example:
 *
 *	PXLinkedList *list = ...
 *	
 *	for (NSObject *item in list)
 *	{
 *		NSLog("Item = %@", item);
 *	}
 *
 * 2) _(For optimization only)_ This is the **fastest** way to loop through
 * linked lists. (According to tests it could be as fast as looping through
 * a plain C array). The downside is that it's not as clean as the recommended
 * fast enumeration method and requires you to write a bit more code.
 * Here's a code example:
 *
 *	PXLinkedList *list = ...
 *	
 *	// It's essential that this variable be declared before the loop
 *	NSObject *item = nil;
 *
 *	PXLinkedListForEach(list, item)
 *	{
 *		NSLog("Item = %@", item);
 *	}
 *
 * We recommend only using this method of iteration for **very large lists**
 * and/or lists that require one or more iterations _every frame_ (such
 * as a list of all the entities in the world). For short lists, or one-time
 * operations you should stick to the fast enumeration method (#2 above).
 *
 * 3) _(Not recommended)_ The n00bish way. It's the most obvious way to go
 * but also the slowest. It's strongly **discouraged** to loop through a list
 * this way. Here's an example to show you what **not to do**:
 *
 *	PXLinkedList *list = ...
 *
 *	NSObject *item = nil;
 *
 *	for (int i = 0; i < list.count; ++i)
 *	{
 *		item = [list objectAtIndex:i];
 *		NSLog("Item %i = %@", i, item);
 *	}
 */
@implementation PXLinkedList

@synthesize count = _nodeCount;

- (id) init
{
	return [self initWithWeakReferences:NO
						 usePooledNodes:PX_LINKED_LISTS_USE_POOLED_NODES];
}

/**
 * Creates a linked list that uses pooled nodes if specified.
 *
 * Equivalent to calling:
 *	[linkedList initWithWeakReferences:NO usePooledNodes:pooledNodes]
 *
 * @param pooledNodes Whether or not too use pooled nodes internally. **It's recommended that
 * this value always be set to `YES`**.
 *
 * **Example:**
 *	PXLinkedList *list = [[PXLinkedList alloc] initWithPooledNodes:YES];
 *	// list will use pooled nodes.
 */
- (id) initWithPooledNodes:(BOOL)pooledNodes
{
	return [self initWithWeakReferences:NO
						 usePooledNodes:pooledNodes];
}

/**
 * Creates a new linked list that uses pooled nodes and only retains added
 * objects if #weakReferences is set to NO.
 * 
 * Equivalent to calling:
 *	[linkedList initWithWeakReferences:weakReferences usePooledNodes:YES]
 *
 * @param weakReferences `YES` if the list should not retain added elements;
 * `NO` if it should. Setting this to `YES` is only
 * useful in very rare circumstances and should be used with caution. The
 * default value is `NO`.
 *
 * **Example:**
 *	PXLinkedList *list = [[PXLinkedList alloc] initWithWeakReferences:NO];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 */
- (id) initWithWeakReferences:(BOOL)weakReferences
{
	return [self initWithWeakReferences:weakReferences
						 usePooledNodes:PX_LINKED_LISTS_USE_POOLED_NODES];
}

/**
 * Creates a new linked list that uses pooled nodes if specified and only
 * retains added objects if #weakReferences is set to NO.
 *
 * @param weakReferences `YES` if the list should not retain added elements;
 * `NO` if it should. Setting this to `YES` is only
 * useful in very rare circumstances and should be used with caution. The
 * default value is `NO`.
 * @param pooledNodes Whether or not too use pooled nodes internally. **It's recommended that
 * this value always be set to `YES`**.
 *
 * **Example:**
 *	PXLinkedList *list = [[PXLinkedList alloc] initWithWeakReferences:NO usePooledNodes:YES];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 */
- (id) initWithWeakReferences:(BOOL)weakReferences
			   usePooledNodes:(BOOL)pooledNodes;
{
	self = [super init];

	if (self)
	{
		_head = nil;
		_tail = nil;
		_nodeCount = 0;

		_keepStrongReference = !weakReferences;
		_pooledNodes = pooledNodes;
	}

	return self;
}

- (void) dealloc
{
	[self removeAllObjects];

	[super dealloc];
}

//////////////
// NSCoding //
//////////////

// Supports keyed-archiving
// Accordind to Apple, non-keyed archiving is deprecated, so new code doesn't
// need to support it.

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];

	if (self)
	{
		_head = nil;
		_tail = nil;
		_nodeCount = 0;

		_pooledNodes = [aDecoder decodeBoolForKey:@"pooledNodes"];
		_keepStrongReference = [aDecoder decodeBoolForKey:@"keepStrongReference"];

		id object = nil;
		NSString *str = nil;
		unsigned i = 0;

		do
		{
			if (object)
			{
				[self addObject:object];
			}
			
			str = [[NSString alloc] initWithFormat:@"PX.object.%u", i];
			object = [aDecoder decodeObjectForKey:str];
			[str release];
			++i;
		}
		while (object != nil);
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeBool:_pooledNodes forKey:@"pooledNodes"];
	[aCoder encodeBool:_keepStrongReference forKey:@"keepStrongReference"];

	// Encode all the objects

	id object = nil;

	NSString *str = nil;
	// Loop through all the objects
	_PXLLNode *node;
	unsigned index;
	for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
	{
		object = node->data;
		NSAssert(object, @"PXLinkedList: Every node's data must be non-nil");

		str = [[NSString alloc] initWithFormat:@"PX.object.%u", index];
		[aCoder encodeObject:object forKey:str];
		[str release];
	}
}

- (void) reset
{
	[self removeAllObjects];

	_keepStrongReference = YES;
	_pooledNodes = PX_LINKED_LISTS_USE_POOLED_NODES;
}

- (NSString *)description
{
	NSMutableString *str = [[NSMutableString alloc] initWithString:@""];

	[str appendString:@"(PXLinkedList: [ "];

	_PXLLNode *node;
	unsigned index;
	for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
	{
		if (index != 0)
			[str appendString:@", "];

		if (node->data)
		{
			[str appendString:[node->data description]];
		}
		else
		{
			[str appendString:@"nil"];
		}
	}

	[str appendString : @" ]"];

	return [str autorelease];
}

#pragma mark Querying

// Private
- (_PXLLNode *)getNodeByIndex:(int)indexOfObject
{
	_PXLLNode *node;
	unsigned index;
	for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
	{
		if (index == indexOfObject)
		{
			return node;
		}
	}

	return 0;
}

- (_PXLLNode *)getNodeByObject:(id)object
{
	_PXLLNode *node;
	unsigned index;
	for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
	{
		if (node->data == object)
		{
			return node;
		}
	}

	return 0;
}

/**
 * Finds and returns the object at the specified position in the list.  If the
 * index is out of bounds, a PXArgumentException is thrown.
 *
 * _**Complexity:** O(n)_
 *
 * @param index The index from which to look up the return object. Must be a value
 * between `0` and #count `- 1`
 *
 * @return The object at the specified index.
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 2, and an index of 1
 *	PXPoint *foundObject = (PXPoint *)[list objectAtIndex:0];
 *	// foundObject == add1
 */
- (id) objectAtIndex:(int)indexOfObject
{
	if (indexOfObject < 0 || indexOfObject >= _nodeCount)
	{
		PXThrowIndexOutOfBounds;
		return nil;
	}

	_PXLLNode *node;
	unsigned index;
	for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
	{
		if (index == indexOfObject)
		{
			return node->data;
		}
	}

	NSAssert(NO, @"Linked List: Weird error... objectAtIndex:%i");

	PXDebugLog (@"Linked List: Weird error... objectAtIndex:%i", indexOfObject);

	return nil;
}

/**
 * Determines if an object is contained in the list.
 *
 * _**Complexity:** O(n)_
 *
 * @param object The object for which to check existence in the list.
 *
 * @return `YES` If the object exists in the list; otherwise
 * `NO`.
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	// add1 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	// add1 has a retain count of 2, and an index of 0
 *	BOOL doesContain = [list containsObject:add1];
 *	// doesContain == YES
 */
- (BOOL) containsObject:(id)object
{
	if (!object)
	{
		PXThrowNilParam(object);
		return NO;
	}
	
	_PXLLNode *node;
	unsigned index;
	for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
	{
		if (node->data == object)
			return YES;
	}

	return NO;
}

/**
 * Finds the position in the list of the specified object.
 *
 * _**Complexity:** O(n)_
 *
 * @param object The object for which to check existence in the list.
 *
 * @return If the object is contained in the list, its index; otherwise
 * `-1`.
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	// add1 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	// add1 has a retain count of 2, and an index of 0
 *	int index = [list indexOfObject:add1];
 *	// index == 0
 */
- (int) indexOfObject:(id)object
{
	if (!object)
	{
		PXThrowNilParam(object);
		return -1;
	}
	
	_PXLLNode *node;
	unsigned index;
	for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
	{
		if (node->data == object)
			return index;
	}

	return -1;
}

- (id) firstObject
{
	if (!_head)
		return nil;

	return _head->data;
}

- (id) lastObject
{
	if (!_tail)
		return nil;

	return _tail->data;
}

- (BOOL) weakReferences
{
	return !_keepStrongReference;
}

////

#pragma mark Adding

/**
 * Adds the specified object to the end of list.  If
 * #weakReferences is set to `NO` (default), the
 * object's retain count is incremented; otherwise the object's retain count
 * stays the same.
 *
 * _**Complexity:** O(1)_
 * 
 * @param object The object to add to the end of the list.
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	// add1's retain count is 1
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	// add1's retain count is 2
 *	[list release];
 *	// add1's retain count is 1
 *
 *	list = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	// list will use pooled nodes, and will not keep a retain on added objects.
 *	[list addObject:add1];
 *	// add1's retain count is 1
 *
 * @see PXPoint
 */
- (void) addObject:(id)object
{
	if (!object)
	{
		PXThrowNilParam(object);
	}

	if (object == self)
	{
		PXThrow(PXArgumentException, @"A list cannot add itself to itself... silly.");
		return;
	}

	[self addObject:object beforeNode:nil];
}

/**
 * Adds the specified object to the front of list, shifting all subsequent
 * object up by one.
 *
 * If #weakReferences is set to `NO` (default), the
 * object's retain count is incremented; otherwise the object's retain count
 * stays the same.
 *
 * _*Complexity:* O(1)_
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list insertObjectAtFront:add1];
 *	[list insertObjectAtFront:add2];
 *	// add1 has a retain count of 2, and an index of 1
 *	// add2 has a retain count of 2, and an index of 0
 *	[list release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	list = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	// list will use pooled nodes, and will not keep a retain on added objects.
 *	[list insertObjectAtFront:add1];
 *	[list insertObjectAtFront:add2];
 *	// add1 has a retain count of 1, and an index of 1
 *	// add2 has a retain count of 1, and an index of 0
 *
 * @param object The object to add to the front of the list. Must be a descendant of the
 * `NSObject` class.
 */

/*
- (void) insertObjectAtFront:(id)object
{
	[self addObject:object beforeNode:_head];
}
*/

/*- (void) insertObject:(id)object beforeObject:(id)objectToAddBefore
   {
        PX_LL_START_CHILD_LOOP
        {
                if (node.data == objectToAddBefore)
                {
                        [self addObject:object beforeNode:node];
                        return;
                }
        }
        PX_LL_END_CHILD_LOOP

        PXDebugLog(@"Linked List: Did not contain the objectToAddBefore, thus did not add the object\n");
   }*/

/**
 * Adds the specified object to the list at the specified index.
 *
 * If #weakReferences is set to `NO` (default), the
 * object's retain count is incremented; otherwise the object's retain count
 * stays the same.
 *
 * If an object already exists at the specified index, all of the objects whose
 * indices are greater then the specified, are shifted up by one position.
 *
 * _**Complexity:** O(n)_
 *
 * @param object The object to add to the front of the. Must be a descendant of the
 * `NSObject` class.
 * @param index The index to add the object to. Must be a value between 0 and count.
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list insertObject:add1 atIndex:0];
 *	[list insertObject:add2 atIndex:0];
 *	// add1 has a retain count of 2, and an index of 1
 *	// add2 has a retain count of 2, and an index of 0
 *	[list release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	list = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	// list will use pooled nodes, and will not keep a retain on added objects.
 *	[list insertObject:add1 atIndex:0];
 *	[list insertObject:add2 atIndex:0];
 *	// add1 has a retain count of 1, and an index of 1
 *	// add2 has a retain count of 1, and an index of 0
 */
- (void) insertObject:(id)object atIndex:(int)indexOfObject
{
	if (!object)
	{
		PXThrowNilParam(object);
		return;
	}
		
	// A slight optimization for edge cases
	if (indexOfObject == 0)
	{
		// Add to the head
		[self addObject:object beforeNode:_head];
	}
	else if (indexOfObject == _nodeCount)
	{
		// Add to the tail
		[self addObject:object beforeNode:nil];
	}
	else if (indexOfObject < 0 || indexOfObject > _nodeCount)
	{
		PXThrowIndexOutOfBounds;
		return;
	}
	else
	{
		// Find the node at the provided index, then add the object before it
		_PXLLNode *node;
		unsigned index;
		for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
		{
			if (index == indexOfObject)
			{
				[self addObject:object beforeNode:node];
				return;
			}
		}

		PXDebugLog(@"Linked List: Weird error... addChildAt:%i", indexOfObject);
	}
}

/*
 * Internal
 */
- (void) addObject:(id)object beforeNode:(_PXLLNode *)nodeToAddBefore
{
	//head and tail must both be null or both be non-null
	NSAssert((_head && _tail) || (!_head && !_tail), @"");

	_PXLLNode *newNode = 0;
	if (_pooledNodes)
	{
		newNode = PXLinkedListGetPooledNode();
	}
	else
	{
		newNode = malloc(sizeof(_PXLLNode));
	}

	if (!newNode)
		return;

	if (_keepStrongReference)
	{
		[object retain];
	}

	// If the last index was picked, add it to the tail.  Otherwise insert
	// 'child' into the list.
	if (!nodeToAddBefore)
	{
		//If the list isn't empty
		if (_tail)
		{
			//_childrenTail->_next = child;
			_tail->next = newNode;
			//child->_prev = _childrenTail;
			newNode->prev = _tail;

			//child->_next = nil;
			newNode->next = nil;

			//_childrenTail = child;
			_tail = newNode;
		}
		else
		{
			//_childrenHead = child;
			_head = newNode;

			//_childrenTail = child;
			_tail = newNode;

			//child->_next = nil;
			//child->_prev = nil;
			newNode->next = nil;
			newNode->prev = nil;
		}
	}
	else
	{
		//Assume that the list isn't empty at this point
		NSAssert(_nodeCount > 0, @"Assuming there's at least one node in the list");

		//
		//				   Inserted here
		//						 \/
		//	[prevChild] <----> [child] <----> [childToAddBefore]
		//		^
		//	(may be null,
		//	making child
		//	the new head)
		//

		// Add child right before 'childToAddBefore' (on the left)
		//PXDisplayObject *prevChild = childToAddBefore->_prev; //The node to be on the left of 'child'
		_PXLLNode *prevNode = nodeToAddBefore->prev;

		//Create the right hand link
		//childToAddBefore->_prev = child;
		nodeToAddBefore->prev = newNode;
		//child->_next = childToAddBefore;
		newNode->next = nodeToAddBefore;

		//Create the left hand link
		if (prevNode)
		{       //Add me after the prev child
			//prevChild->_next = child;
			prevNode->next = newNode;
			//child->_prev = prevChild;
			newNode->prev = prevNode;
		}
		else   //This is the new head
		{
			NSAssert(nodeToAddBefore == _head, @"Assuming nodeToAddBefore is the head node");

			//child->_prev = nil;
			newNode->prev = nil;
			//_childrenHead = child;
			_head = newNode;
		}
	}

	newNode->data = object;
	++_nodeCount;
}

/**
 * Adds all of the objects from the provided list to this list.
 * 
 * If #weakReferences is set to `NO` (default), the
 * objects' retain counts are incremented; otherwise the object's retain count
 * stays the same.
 *
 * _**Complexity:** O(n)_
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	PXLinkedList *otherList = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	[otherList addObject:add2];
 *	// add1 has a retain count of 2, and an index of 0 in list
 *	// add2 has a retain count of 2, and an index of 0 in otherList
 *	[list addObjectsFromList:otherList];
 *	// add1 has a retain count of 2, and an index of 0 in list
 *	// add2 has a retain count of 3, and an index of 1 in list, and 0 in other list
 *	[list release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 2, and an index of 0 in otherList
 *	[otherList release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	list = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	otherList = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	// list will use pooled nodes, and will not keep a retain on added objects.
 *	[list addObject:add1];
 *	[otherList addObject:add2];
 *	// add1 has a retain count of 1, and an index of 0 in list
 *	// add2 has a retain count of 1, and an index of 0 in otherList
 *	[list addObjectsFromList:otherList];
 *	// add1 has a retain count of 1, and an index of 0 in list
 *	// add2 has a retain count of 1, and an index of 1 in list, and 0 in other list
 *
 * @see PXPoint
 */
- (void) addObjectsFromList:(PXLinkedList *)otherList
{
	if (otherList == self)
		return;

	id obj;

	for (obj in otherList)
	{
		[self addObject:obj];
	}
}

/**
 * Sets the index of the object in the list, to the index provided. This shifts
 * the data over properly in the process.
 *
 * **Example:**
 *	PXPoint *point0 = [PXPoint pointWithX:3 y:4];
 *	PXPoint *point1 = [PXPoint pointWithX:2 y:5];
 *	PXPoint *point2 = [PXPoint pointWithX:1 y:6];
 *	PXPoint *point3 = [PXPoint pointWithX:0 y:7];
 *	// point0 has no index
 *	// point1 has no index
 *	// point2 has no index
 *	// point3 has no index
 *
 *	PXLinkedList *list = [[PXLinkedList alloc] init];
 *
 *	[list addObject:point0];
 *	[list addObject:point1];
 *	[list addObject:point2];
 *	[list addObject:point3];
 *	// point0 has an index of 0
 *	// point1 has an index of 1
 *	// point2 has an index of 2
 *	// point3 has an index of 3
 *
 *	[list setIndex:2 ofObject:point0];
 *	// point0 has an index of 2
 *	// point1 has an index of 0
 *	// point2 has an index of 1
 *	// point3 has an index of 3
 *
 *	[list release];
 *
 * @see PXPoint
 */
- (void) setIndex:(int)newIndexOfObject ofObject:(id)object
{
	if (!object)
		return;

	// We will remove it, and we may have the only retain on it.
	[object retain];

	_PXLLNode *node;
	unsigned index;
	for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
	{
		if (node->data == object)
		{
			//Succesful
			[self removeNode:node];

			[self insertObject:object atIndex:newIndexOfObject];
			break;
		}
	}

	// We retained it, so we must release it.
	[object release];
}

#pragma mark Removing

/**
 * Removes the specified object from the list.
 *
 * If the object isn't contained in the list the call is simply ignored.
 * otherwise all of the objects after the index of the specified object are
 * shifted down by one to fill the gap.
 *
 * If #weakReferences is set to `NO` (default), the
 * object's retain count is decremented; otherwise the object's retain count
 * stays the same.
 *
 * _**Complexity:** O(n)_
 *
 * @param object The object to remove from the list.
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list insertObject:add1 atIndex:0];
 *	[list insertObject:add2 atIndex:0];
 *	// add1 has a retain count of 2, and an index of 1
 *	// add2 has a retain count of 2, and an index of 0
 *	[list removeObject:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 1, and no index
 *	[list release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	list = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	// list will use pooled nodes, and will not keep a retain on added objects.
 *	[list insertObject:add1 atIndex:0];
 *	[list insertObject:add2 atIndex:0];
 *	// add1 has a retain count of 1, and an index of 1
 *	// add2 has a retain count of 1, and an index of 0
 *	[list removeObject:add2];
 *	// add1 has a retain count of 1, and an index of 0
 *	// add2 has a retain count of 1, and no index
 *
 * @see [PXLinkedList containsObject:]
 */
- (void) removeObject:(id)object
{
	//Find the object and remove it
	if (!object)
	{
		PXThrowNilParam(object);
		return;
	}

	//find this object
	_PXLLNode *node;
	unsigned index;
	for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
	{
		if (node->data == object)
		{
			//Succesful
			[self removeNode:node];
			return;
		}
	}

	//Unsuccessful
	//PXDebugLog(@"The object provided must be contained in the list in order to be removed");
	return;
}

/**
 * Removes the object at the specified index from the list.
 *
 * If the object isn't contained in the list the call is simply ignored;
 * otherwise all of the objects following the oject at `index` are
 * shifted down by one.
 *
 * If #weakReferences is set to `NO` (default), the
 * object's retain count is decremented; otherwise the object's retain count
 * stays the same.
 * 
 * _**Complexity:** O(n)_
 * 
 * @param index The index from which to remove the object. `index` must be
 * be a value between 0 and #count - 1
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 2, and an index of 1
 *	[list removeObjectAtIndex:0];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 2, and an index of 0
 *	[list release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	list = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	// list will use pooled nodes, and will not keep a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 1, and an index of 0
 *	// add2 has a retain count of 1, and an index of 1
 *	[list removeObjectAtIndex:0];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and an index of 0
 *
 * @see PXPoint
 */
- (void) removeObjectAtIndex:(int)indexOfObject
{
	if (indexOfObject < 0 || indexOfObject >= _nodeCount)
	{
		PXThrowIndexOutOfBounds;
		return;
	}

	_PXLLNode *node;
	unsigned index;
	for (index = 0, node = _head; index < _nodeCount; ++index, node = node->next)
	{
		if (index == indexOfObject)
		{
			//Succesful
			[self removeNode:node];
			return;
		}
	}
}

/**
 * Removes the last object in the list (object at index
 * #count `- 1`).  If the list is empty the call is ignored.
 *
 * If #weakReferences is set to `NO` (default), the
 * object's retain count is decremented; otherwise the object's retain count
 * stays the same.
 *
 * _**Complexity:** O(1)_
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 2, and an index of 1
 *	[list removeLastObject];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 1, and no index
 *	[list release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	list = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	// list will use pooled nodes, and will not keep a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 1, and an index of 0
 *	// add2 has a retain count of 1, and an index of 1
 *	[list removeLastObject];
 *	// add1 has a retain count of 1, and an index of 0
 *	// add2 has a retain count of 1, and no index
 *
 * @see PXPoint
 */
- (void) removeLastObject
{
	if (_tail)
	{
		[self removeNode:_tail];
	}
}

/**
 * Removes the first object in the list (object at index `0`).  If
 * the list is empty the call is ignored.
 *
 * If #weakReferences is set to `NO` (default), the
 * object's retain count is decremented; otherwise the object's retain count
 * stays the same. 
 * 
 * _**Complexity:** O(1)_
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 2, and an index of 1
 *	[list removeFirstObject];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 2, and an index of 0
 *	[list release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	list = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	// list will use pooled nodes, and will not keep a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 1, and an index of 0
 *	// add2 has a retain count of 1, and an index of 1
 *	[list removeFirstObject];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and an index of 0
 *
 * @see PXPoint
 */

- (void) removeFirstObject
{
	if (_head)
	{
		[self removeNode:_head];
	}
}

/**
 * Removes all of the objects in the list, restoring it to its initial state.
 * 
 * If #weakReferences is set to `NO` (default), the
 * objects' retain counts are decremented; otherwise the object's retain count
 * stays the same.
 *
 * _**Complexity:** O(n)_
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 2, and an index of 1
 *	[list removeAllObjects];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *	[list release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	list = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	// list will use pooled nodes, and will not keep a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 1, and an index of 0
 *	// add2 has a retain count of 1, and an index of 1
 *	[list removeAllObjects];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 * @see PXPoint
 */
- (void) removeAllObjects
{
	// Remove the tail until there's nothing left
	while (_tail)
	{
		[self removeLastObject];
	}

	_head = nil;
	_tail = nil;
	_nodeCount = 0;
}

/**
 * Removes all of the objects in the list that are also in the provided list.
 * 
 * If #weakReferences is set to `NO` (default), the
 * objects' retain counts are decremented; otherwise the object's retain count
 * stays the same.
 *
 * _**Complexity:** O(n * m)_
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	PXLinkedList *otherList = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 2, and an index of 1
 *	[otherList addObject:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 3, and an index of 1
 *	[list removeObjectsInList:otherList];
 *	// add1 has a retain count of 2, and no index
 *	// add2 has a retain count of 2, and no index
 *	[list release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *	[otherList release];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	list = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	otherList = [[PXLinkedList alloc] initWithWeakReferences:YES];
 *	// list will use pooled nodes, and will not keep a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	[otherList addObject:add2];
 *	// add1 has a retain count of 1, and an index of 0
 *	// add2 has a retain count of 1, and an index of 1
 *	[list removeObjectsInList:otherList];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 * @see PXPoint
 */
- (void) removeObjectsInList:(PXLinkedList *)otherList
{
	if (otherList == self)
	{
		[self removeAllObjects];
	}

	id object;
	PXLinkedListForEach(otherList, object)
	{
		[self removeObject:object];
	}
}

- (void) removeNode:(_PXLLNode *)node
{
	// _childrenHead and _childrenTail must both be null or both be non-null
	NSAssert((_head && _tail) || (!_head && !_tail), @"");

	// I don't have any children, so none can be removed
	if (!_head)
	{
		return;
	}

	// Remove me from the list
	if (node == _head && node == _tail)
	{
		// I'm the only one...
		_head = nil;
		_tail = nil;
	}
	else if (node == _tail) // I'm the tail, and there's a (different) head
	{
		_tail = _tail->prev;
		_tail->next = nil;
	}
	else if (node == _head) // I'm the head, and there's a (different) tail
	{
		_head = _head->next;
		_head->prev = nil;
	}
	else
	{
		// I'm somewhere in the middle, there's a (different) head and tail
		// I must have a next and a prev
		NSAssert(node->next && node->prev, @"");

		_PXLLNode *nodePrev = node->prev;
		_PXLLNode *nodeNext = node->next;

		nodePrev->next = nodeNext;
		nodeNext->prev = nodePrev;
	}

	node->next = nil;
	node->prev = nil;

	if (_keepStrongReference)
	{
		[node->data release];
	}

	if (_pooledNodes)
	{
		PXLinkedListReturnPooledNode(node);
	}
	else
	{
		free(node);
	}

	--_nodeCount;
}

#pragma mark Swapping

/**
 * Swaps the location of two objects in the list.  If either of the parameters
 * aren't contained in the list, a PXArgumentException is thrown.
 * 
 * @param object1 The object to swap with `object2`
 * @param object2 The object to swap with `object1`
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 2, and an index of 1
 *	[list swapObject:add1 withObject:add2];
 *	// add1 has a retain count of 2, and an index of 1
 *	// add2 has a retain count of 2, and an index of 0
 */
- (void) swapObject:(id)object1 withObject:(id)object2
{
	if (object1 == object2)
		return;

	_PXLLNode *node1 = [self getNodeByObject:object1];
	_PXLLNode *node2 = [self getNodeByObject:object2];

	if (!node1 || !node2)
	{
		PXThrow(PXArgumentException, @"Parameter object must be contained in list");
	}

	[self swapNode:node1 withNode:node2];
}

/**
 * Swaps the location of two objects specified their indices in the list.  If
 * either of the parameters aren't contained in the list, or are out of bounds,
 * a PXArgumentException is thrown.
 * 
 * @param index1 The index of the object to swap with the object at `index2`.
 * Must be a value between `0` and #count `- 1`.
 * @param index2 The index of the object to swap with the object at `index1`.
 * Must be a value between `0` and #count `- 1`.
 *
 * **Example:**
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 y:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 y:5];
 *	// add1 has a retain count of 1, and no index
 *	// add2 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	[list addObject:add2];
 *	// add1 has a retain count of 2, and an index of 0
 *	// add2 has a retain count of 2, and an index of 1
 *	[list swapObjectAtIndex:0 withObjectAtIndex:1];
 *	// add1 has a retain count of 2, and an index of 1
 *	// add2 has a retain count of 2, and an index of 0
 *
 * @see [PXLinkedList swapObject:]withObject:
 */
- (void) swapObjectAtIndex:(int)index1 withObjectAtIndex:(int)index2
{
	if (index1 == index2)
		return;

	_PXLLNode *node1 = [self getNodeByIndex:index1];
	_PXLLNode *node2 = [self getNodeByIndex:index2];

	if (!node1 || !node2)
	{
		PXThrow(PXArgumentException, @"Parameter object must be contained in list");
	}

	[self swapNode:node1 withNode:node2];
}

- (void) swapNode:(_PXLLNode *)node1 withNode:(_PXLLNode *)node2
{
	if (!node1 || !node2)
		return;

	if (node1 == node2)
		return;

	id data1 = node1->data;
	node1->data = node2->data;
	node2->data = data1;
}

#pragma mark Fast Enumeration

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	_PXLLNode *currentNode;
	if (state->state == 0)
	{
		// Set the starting point. _startOfListNode is assumed to be our
		// object's instance variable that points to the start of the list.
		currentNode = _head;
	}
	else if (state->state == 1) //No more items left
	{
		return 0;
	}
	else
	{
		// Subsequent iterations, get the current progress out of state->state
		currentNode = (_PXLLNode *)state->state;
	}

	unsigned index;
	id *curStackBuffer;
	for (index = 0, curStackBuffer = stackbuf; index < len; ++index, ++curStackBuffer)
	{
		if (currentNode)
		{
			*curStackBuffer = currentNode->data;
			currentNode = currentNode->next;
		}
		else
		{
			break;
		}
	}

	if (currentNode)
	{
		state->state = (unsigned long)currentNode;
	}
	else
	{
		state->state = 1;
	}

	state->itemsPtr = stackbuf;
	state->mutationsPtr = (unsigned long *)self;

	return index;
}

#pragma mark Exporting

/**
 * Creates and returns a C array containing pointers to all the objects
 * in the list.  The array's length is equal to the `count`
 * property's value.
 *
 * It is the caller's responsibility to call `free()`
 * on the returned array.
 *
 * Notice that the objects contained in the returned array aren't retained
 * _again_ and as such this method should be used with caution.
 *
 * _**Complexity:** O(n)_
 *
 * @return A C array containing pointers to all of the objects in the list.
 * returns 0 if the list is empty.
 *
 * Example:
 *	PXLinkedList *list = [PXLinkedList new];
 *	// [populate list with strings]
 *	NSObject **cArray = (NSString **)[list cArray];
 *	int len = list.count;
 *
 *	for (int i = 0; i < len; ++i)
 *	{
 *		NSLog(@"%W", cArray[i];
 *	}
 *
 *	free(cArray);
 *
 * @see [PXLinkedList count]
 */
- (id *)cArray
{
	if (_nodeCount == 0)
		return NULL;

	id *cArray = malloc(sizeof(id) * _nodeCount);

	_PXLLNode *node;
	unsigned index;
	id *currentObject;
	for (index = 0, node = _head, currentObject = cArray; index < _nodeCount; ++index, node = node->next, ++currentObject)
	{
		*currentObject = node->data;
	}

	return cArray;
}

/**
 * Returns a new list containing the same objects as this list, and in the same
 * order.
 * The individual items in the list aren't duplicated, only their reference is.
 * 
 * Note that the new list also retains each of the objects as long as
 * #weakReferences is set to `NO` (default).
 */
// Implemented so that we can comment it
- (id) copy
{
	return [super copy];
}
- (id) copyWithZone:(NSZone *)zone
{
	PXLinkedList *list = [[[self class] allocWithZone:zone] initWithWeakReferences:!_keepStrongReference
																	usePooledNodes:_pooledNodes];

	[list addObjectsFromList:self];

	return list;
}

#pragma mark Pooling

/**
 * Resets the node pool. Applies to all instances of PXLinkedList and should be
 * used with caution.
 */
+ (void) cleanNodesPool
{
	PXLinkedListShrinkPoolNodes(0);
}

/**
 * Creates a linked list with strong references.
 *
 * @param pooledNodes Whether or not too use pooled nodes internally. **It's recommended that
 * this value always be set to `YES`**.
 *
 * @return The created linked list.
 *
 * **Example:**
 *	PXLinkedList *list = [PXLinkedList linkedListWithPooledNodes:YES];
 *	// list will use pooled nodes
 *	list = [PXLinkedList linkedListWithPooledNodes:NO];
 *	// list will not use pooled nodes
 */
+ (PXLinkedList *)linkedListWithPooledNodes:(BOOL)pooledNodes
{
	return [[[PXLinkedList alloc] initWithPooledNodes:pooledNodes] autorelease];
}

/**
 * Creates a linked list without using pooled nodes.
 *
 * @param weakReferences `YES` if the list should not retain added elements;
 * `NO` if it should. Setting this to `YES` is only
 * useful in very rare circumstances and should be used with caution. The
 * default value is `NO`.
 *
 * @return The created linked list.
 *
 * **Example:**
 *	PXLinkedList *list = [PXLinkedList linkedWithWeakReferences:YES];
 *	// list will use weak references (will not retain objects added to it)
 */
+ (PXLinkedList *)linkedWithWeakReferences:(BOOL)weakReferences
{
	return [[[PXLinkedList alloc] initWithWeakReferences:weakReferences] autorelease];
}

/**
 * Creates a linked list.
 *
 * @param pooledNodes Whether or not too use pooled nodes internally. **It's	recommended that
 * this value always be set to `YES`**.
 * @param weakReferences `YES` if the list should not retain added elements;
 * `NO` if it should. Setting this to `YES` is only
 * useful in very rare circumstances and should be used with caution. The
 * default value is `NO`.
 *
 * @return The created linked list.
 *
 * **Example:**
 *	PXLinkedList *list = [PXLinkedList linkedWithWeakReferences:YES usePooledNodes:YES];
 *	// list will use weak references (will not retain objects added to it) and will use pooled nodes.
 */
+ (PXLinkedList *)linkedListWithWeakReferences:(BOOL)weakReferences usePooledNodes:(BOOL)pooledNodes
{
	return [[[PXLinkedList alloc] initWithWeakReferences:weakReferences usePooledNodes:pooledNodes] autorelease];
}

@end

#pragma mark Node Pooling

//////////////////
// Node Pooling //
//////////////////

_PXLLNode *PXLinkedListGetPooledNode()
{
	_PXLLNode *newNode = 0;

	if (pxLLPooledNodesCount == 0)
	{
		newNode = malloc(sizeof(_PXLLNode));
		return newNode;
	}
	else
	{
		// Grab one out of the stack
		--pxLLPooledNodesCount;

		_PXLLNode **nodePtr = pxLLPooledNodesStack + pxLLPooledNodesCount;
		newNode = *nodePtr;
		*nodePtr = &pxLinkedListBadNode;

		int newSize = pxLLPooledNodesSize >> 2; // division by 4

		// If the stack is too big, shrink it down
		if ((int)(pxLLPooledNodesCount) < newSize)
		{
			PXLinkedListShrinkPoolNodes(newSize);
		}
	}

	return newNode;
}

void PXLinkedListReturnPooledNode(_PXLLNode *node)
{
	if (pxLLPooledNodesSize == pxLLPooledNodesCount)
	{
		// Make it bigger
		if (pxLLPooledNodesSize == 0)
			pxLLPooledNodesSize = 1;

		pxLLPooledNodesSize <<= 1; // Multiply by 2

		// Size up
		pxLLPooledNodesStack = realloc(pxLLPooledNodesStack, sizeof(_PXLLNode *) * pxLLPooledNodesSize);
	}

	pxLLPooledNodesStack[pxLLPooledNodesCount] = node;
	++pxLLPooledNodesCount;
}

void PXLinkedListShrinkPoolNodes(int newSize)
{
	if (newSize >= pxLLPooledNodesSize)
		return;

	// Clear the pool nodes
	unsigned index;
	_PXLLNode **curNode;
	for (index = newSize, curNode = pxLLPooledNodesStack + index; index < pxLLPooledNodesCount; ++index, ++curNode)
	{
		// Deallocate the node
		free(*curNode);
		// Zero that array cell
		*curNode = NULL;
	}

	// Size down
	pxLLPooledNodesStack = realloc(pxLLPooledNodesStack, sizeof(_PXLLNode *) * newSize);

	pxLLPooledNodesSize = newSize;

	if (pxLLPooledNodesCount > newSize)
		pxLLPooledNodesCount = newSize;
}
