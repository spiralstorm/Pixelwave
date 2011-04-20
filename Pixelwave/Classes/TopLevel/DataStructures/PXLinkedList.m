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

/// @cond DX_IGNORE
#define PX_LL_START_CHILD_LOOP {_PXLLNode *node = _head; for (unsigned i = 0; i < _numNodes; ++i){
#define PX_LL_END_CHILD_LOOP node = node->next; }}
#define PX_LL_CONTINUE_CHILD_LOOP node = node->next; continue

// Pooled nodes
static _PXLLNode **pxLLPooledNodesStack = 0; // C-array
static unsigned pxLLPooledNodesCount = 0; // Items in stack
static unsigned pxLLPooledNodesSize = 0; // Size of the array

_PXLLNode *PXLinkedListGetPooledNode();
void PXLinkedListReturnPooledNode(_PXLLNode *node);
void PXLinkedListShrinkPoolNodes(int newSize);

@interface PXLinkedList(Private)
- (void) addObject:(PXGenericObject)object beforeNode:(_PXLLNode *)nodeToAddBefore;
- (void) removeNode:(_PXLLNode *)node;
- (_PXLLNode *)getNodeByIndex:(int)index;
- (_PXLLNode *)getNodeByObject:(PXGenericObject)object;
- (void) swapNodes:(_PXLLNode *)node1:(_PXLLNode *)node2;
@end
/// @endcond

/**
 *	@ingroup TopLevel
 *
 *	A PXLinkedList represents a data structure which can hold any number of
 *	Objective-C objects. Like all collection classes, the PXLinkedList class
 *	increases an object's retain count when it is added, and decreases the
 *	object's retain count when it is removed. This behavior can be disabled,
 *	however it is not recommended.
 *
 *	On the surface the PXLinkedList class is structured very similarly to the
 *	native <code>NSArray</code>	class, but under the hood it uses a linked list
 *	structure.
 *	<br>
 *	The PXLinkedList class is designed to be fast and efficient. It has been
 *	tested and found to be considerably faster than <code>NSArray<code> when
 *	performing the following tasks:
 *	- Adding and removing objects to and from the ends of the list
 *	- Adding and removing objects to and from the middle of the list
 *	- Looping through the list <i>(And much more so when using
 *		<code>#PXLinkedListForEach</code> or its counterpart
 *		<code>#PXLinkedListForEachReverse</code>)</i>
 *
 *	<br/>
 *	<b>Iterating through a linked list</b>
 *	<br/><br/>
 *	There are 3 (count 'em) ways to loop through a linked list:
 *	<br/>
 *	
 *	1. <b>(Recommended)</b> Using Objective-C's fast enumeration. This method
 *	is both cleaner and (much) faster than the previous one. It is the
 *	@b encouraged way to loop through linked lists. Here's a code example:
 *
 *	@code
 * PXLinkedList *list = ...
 *
 * for (NSObject *item in list)
 * {
 *	NSLog("Item = %@", item);
 * }
 *	@endcode
 *
 *	2. <b>(For optimization only)</b> This is the @b fastest way to loop through
 *	linked lists. (According to tests it could be as fast as looping through
 *	a plain C array). The downside is that it's not as clean as the recommended
 *	fast enumeration method and requires you to write a bit more code.
 *	Here's a code example:
 *
 *	@code
 * PXLinkedList *list = ...
 * 
 * // It's essential that this variable be declared before the loop
 * NSObject *item = nil;
 *
 * PXLinkedListForEach(list, item)
 * {
 *	NSLog("Item = %@", item);
 * }
 *	@endcode
 *
 *	We recommend only using this method of iteration for <b>very large lists</b>
 *	and/or lists that require one or more iterations <i>every frame</i> (such
 *	as a list of all the entities in the world). For short lists, or one-time
 *	operations you should stick to the fast enumeration method (#2 above).
 *
 *	@see #PXLinkedListForEach
 *	@see #PXLinkedListForEachReverse
 *
 *	3. (Not recommended) The n00bish way. It's the most obvious way to go
 *	but also the slowest. It's strongly @b discouraged to loop through a list
 *	this way. Here's an example to show you what <b>not to do</b>:
 *
 *	@code
 * PXLinkedList *list = ...
 *
 * NSObject *item = nil;
 *
 * for(int i = 0; i < list.count; ++i)
 * {
 *	item = [list objectAtIndex:i];
 *	NSLog("Item %i = %@", i, item);
 * }
 *	@endcode
 */
@implementation PXLinkedList

@synthesize count = _numNodes;

- (id) init
{
	return [self initWithWeakReferences:NO
						 usePooledNodes:PX_LINKED_LISTS_USE_POOLED_NODES];
}

/**
 *	Creates a linked list that uses pooled nodes if specified.
 *
 *	Equivalent to calling:
 *	@code
 *	[linkedList initWithWeakReferences:NO usePooledNodes:pooledNodes]
 *	@endcode
 *
 *	@param pooledNodes
 *		Whether or not too use pooled nodes internally. <b>It's	recommended that
 *		this value always be set to	<code>YES</code></b>.
 *
 *	@b Example:
 *	@code
 *	PXLinkedList *list = [[PXLinkedList alloc] initWithPooledNodes:YES];
 *	// list will use pooled nodes.
 *	@endcode
 */
- (id) initWithPooledNodes:(BOOL)pooledNodes
{
	return [self initWithWeakReferences:NO
						 usePooledNodes:pooledNodes];
}

/**
 *	Creates a new linked list that uses pooled nodes and only retains added
 *	objects if <code>weakReferences</code> is set to NO.
 *	
 *	Equivalent to calling:
 *	@code
 *	[linkedList initWithWeakReferences:weakReferences usePooledNodes:YES]
 *	@endcode
 *
 *	@param weakReferences
 *		<code>YES</code> if the list should not retain added elements;
 *		<code>NO</code> if it should. Setting this to <code>YES</code> is only
 *		useful in very rare circumstances and should be used with caution. The
 *		default value is <code>NO</code>.
 *
 *	@b Example:
 *	@code
 *	PXLinkedList *list = [[PXLinkedList alloc] initWithWeakReferences:NO];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	@endcode
 */
- (id) initWithWeakReferences:(BOOL)weakReferences
{
	return [self initWithWeakReferences:weakReferences
						 usePooledNodes:PX_LINKED_LISTS_USE_POOLED_NODES];
}

/**
 *	Creates a new linked list that uses pooled nodes if specified and only
 *	retains added objects if <code>weakReferences</code> is set to NO.
 *
 *	@param weakReferences
 *		<code>YES</code> if the list should not retain added elements;
 *		<code>NO</code> if it should. Setting this to <code>YES</code> is only
 *		useful in very rare circumstances and should be used with caution. The
 *		default value is <code>NO</code>.
 *	@param pooledNodes
 *		Whether or not too use pooled nodes internally. <b>It's	recommended that
 *		this value always be set to	<code>YES</code></b>.
 *
 *	@b Example:
 *	@code
 *	PXLinkedList *list = [[PXLinkedList alloc] initWithWeakReferences:NO usePooledNodes:YES];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	@endcode
 */
- (id) initWithWeakReferences:(BOOL)weakReferences
			   usePooledNodes:(BOOL)pooledNodes;
{
	self = [super init];
	if (self)
	{
		_head = nil;
		_tail = nil;
		_numNodes = 0;

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
		_numNodes = 0;

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

- (void) reset
{
	[self removeAllObjects];

	_keepStrongReference = YES;
	_pooledNodes = PX_LINKED_LISTS_USE_POOLED_NODES;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeBool:_pooledNodes forKey:@"pooledNodes"];
	[aCoder encodeBool:_keepStrongReference forKey:@"keepStrongReference"];

	// Encode all the objects

	id object = nil;

	NSString *str = nil;
	// Loop through all the objects
	PX_LL_START_CHILD_LOOP
	{
		object = node->data;
		NSAssert(object, @"PXLinkedList: Every node's data must be non-nil");

		str = [[NSString alloc] initWithFormat:@"PX.object.%u", i];
		[aCoder encodeObject:object forKey:str];
		[str release];
	}
	PX_LL_END_CHILD_LOOP
}

/////

#pragma mark Querying

//Private
- (_PXLLNode *)getNodeByIndex:(int)index
{
	PX_LL_START_CHILD_LOOP
	{
		if (i == index)
		{
			return node;
		}
	}
	PX_LL_END_CHILD_LOOP

	return 0;
}

- (_PXLLNode *)getNodeByObject:(PXGenericObject)object
{
	PX_LL_START_CHILD_LOOP
	{
		if (node->data == object)
		{
			return node;
		}
	}
	PX_LL_END_CHILD_LOOP

	return 0;
}

/**
 *	Finds and returns the object at the specified position in the list.  If the
 *	index is out of bounds, a PXArgumentException is thrown.
 *
 *	<i><b>Complexity:</b> O(n)</i>
 *
 *	@param index
 *		The index from which to look up the return object. Must be a value
 *		between <code>0</code> and <code>count - 1</code>
 *
 *	@return
 *		The object at the specified index.
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 */
- (PXGenericObject)objectAtIndex:(int)index
{
	if (index < 0 || index >= _numNodes)
	{
		PXThrowIndexOutOfBounds;
		return nil;
	}

	PX_LL_START_CHILD_LOOP
	{
		if (i == index)
		{
			return node->data;
		}
	}
	PX_LL_END_CHILD_LOOP

	NSAssert(NO, @"Linked List: Weird error... objectAtIndex:%i");

	PXDebugLog (@"Linked List: Weird error... objectAtIndex:%i", index);

	return nil;
}

/**
 *	Determines if an object is contained in the list.
 *
 *	<i><b>Complexity:</b> O(n)</i>
 *
 *	@param object
 *		The object for which to check existence in the list.
 *
 *	@return
 *		<code>YES</code> If the object exists in the list; otherwise
 *		<code>NO</code>.
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	// add1 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	// add1 has a retain count of 2, and an index of 0
 *	BOOL doesContain = [list containsObject:add1];
 *	// doesContain == YES
 *	@endcode
 */
- (BOOL) containsObject:(PXGenericObject)object
{
	if (!object)
	{
		PXThrowNilParam(object);
		return NO;
	}
	
	PX_LL_START_CHILD_LOOP
	{
		if (node->data == object)
			return YES;
	}
	PX_LL_END_CHILD_LOOP

	return NO;
}

/**
 *	Finds the position in the list of the specified object.
 *
 *	<i><b>Complexity:</b> O(n)</i>
 *
 *	@param object
 *		The object for which to check existence in the list.
 *
 *	@return
 *		If the object is contained in the list, its index; otherwise
 *		<code>-1</code>.
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	// add1 has a retain count of 1, and no index
 *
 *	PXLinkedList *list = [PXLinkedList new];
 *	// list will use pooled nodes, and keeps a retain on added objects.
 *	[list addObject:add1];
 *	// add1 has a retain count of 2, and an index of 0
 *	int index = [list indexOfObject:add1];
 *	// index == 0
 *	@endcode
 */
- (int) indexOfObject:(PXGenericObject)object
{
	if (!object)
	{
		PXThrowNilParam(object);
		return -1;
	}
	
	PX_LL_START_CHILD_LOOP
	{
		if (node->data == object)
			return i;
	}
	PX_LL_END_CHILD_LOOP

	return -1;
}

- (PXGenericObject) firstObject
{
	if (!_head)
		return nil;

	return _head->data;
}

- (PXGenericObject) lastObject
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

#pragma mark Debugging
- (NSString *)description
{
	NSMutableString *str = [[NSMutableString alloc] initWithString:@""];

	[str appendString:@"(PXLinkedList: [ "];

	PX_LL_START_CHILD_LOOP
	{
		if (i > 0)
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
	PX_LL_END_CHILD_LOOP

	[str appendString : @" ]"];

	return [str autorelease];
}

#pragma mark Adding

/**
 *	Adds the specified object to the end of list.  If
 *	<code>weakReferences</code> is set to <code>NO</code> (default), the
 *	object's retain count is incremented; otherwise the object's retain count
 *	stays the same.
 *
 *	<i><b>Complexity:</b> O(1)</i>
 *	
 *	@param object
 *		The object to add to the end of the list.
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
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
 *	@endcode
 *
 *	@see PXPoint
 */
- (void) addObject:(PXGenericObject)object
{
	if (!object)
	{
		PXThrowNilParam(object);
	}

	if (object == self)
	{
		PXThrow(PXArgumentException, @"A list cannot add itself to itself.. silly.");
		return;
	}

	[self addObject:object beforeNode:nil];
}

/**
 *	Adds the specified object to the front of list, shifting all subsequent
 *	object up by one.
 *
 *	If <code>weakReferences</code> is set to <code>NO</code> (default), the
 *	object's retain count is incremented; otherwise the object's retain count
 *	stays the same.
 *
 *	<i><b>Complexity:</b> O(1)</i>
 *
 *	@param object
 *		The object to add to the front of the list. Must be a descendant of the
 *		<code>NSObject</code> class.
 *	<br><br>
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 */

/*
- (void) insertObjectAtFront:(PXGenericObject)object
{
	[self addObject:object beforeNode:_head];
}
*/

/*- (void) insertObject:(PXGenericObject)object beforeObject:(PXGenericObject)objectToAddBefore
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

        PXDebugLog( @"Linked List: Did not contain the objectToAddBefore, thus did not add the object\n" );
   }*/

/**
 *	Adds the specified object to the list at the specified index.
 *
 *	If <code>weakReferences</code> is set to <code>NO</code> (default), the
 *	object's retain count is incremented; otherwise the object's retain count
 *	stays the same.
 *
 *	If an object already exists at the specified index, all of the objects whose
 *	indices are greater then the specified, are shifted up by one position.
 *
 *	<i><b>Complexity:</b> O(n)</i>
 *
 *	@param object
 *		The object to add to the front of the. Must be a descendant of the
 *		<code>NSObject</code> class.
 *	@param index
 *		The index to add the object to. Must be a value between 0 and count.
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 */
- (void) insertObject:(PXGenericObject)object atIndex:(int)index
{
	if (!object)
	{
		PXThrowNilParam(object);
		return;
	}
		
	// A slight optimization for edge cases
	if (index == 0)
	{
		// Add to the head
		[self addObject:object beforeNode:_head];
	}
	else if (index == _numNodes)
	{
		// Add to the tail
		[self addObject:object beforeNode:nil];
	}
	else if (index < 0 || index > _numNodes)
	{
		PXThrowIndexOutOfBounds;
		return;
	}
	else
	{
		// Find the node at the provided index, then add the object before it
		PX_LL_START_CHILD_LOOP
		{
			if (i == index)
			{
				[self addObject:object beforeNode:node];
				return;
			}
		}
		PX_LL_END_CHILD_LOOP

		PXDebugLog(@"Linked List: Weird error... addChildAt:%i", index);
	}
}

/*
 *	Internal
 */
- (void) addObject:(PXGenericObject)object beforeNode:(_PXLLNode *)nodeToAddBefore
{
	//head and tail must both be null or both be non-null
	NSAssert((_head && _tail) || (!_head && !_tail), @"");

	if (_keepStrongReference)
	{
		[object retain];
	}

	_PXLLNode *newNode = 0;
	if (_pooledNodes)
	{
		newNode = PXLinkedListGetPooledNode();
	}
	else
	{
		newNode = malloc(sizeof(_PXLLNode));
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
		NSAssert(_numNodes > 0, @"Assuming there's at least one node in the list");

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
	++_numNodes;
}

/**
 *	Adds all of the objects from the provided list to this list.
 *	<br>If <code>weakReferences</code> is set to <code>NO</code> (default), the
 *	objects' retain counts are incremented; otherwise the object's retain count
 *	stays the same.
 *
 *	<i><b>Complexity:</b> O(n)</i>
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 *
 *	@see PXPoint
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

#pragma mark Removing

/**
 *	Removes the specified object from the list.
 *
 *	If the object isn't contained in the list the call is simply ignored.
 *	otherwise all of the objects after the index of the specified object are
 *	shifted down by one to fill the gap.
 *
 *	<br>If <code>weakReferences</code> is set to <code>NO</code> (default), the
 *	object's retain count is decremented; otherwise the object's retain count
 *	stays the same.
 *
 *	<i><b>Complexity:</b> O(n)</i>
 *
 *	@param object
 *		The object to remove from the list.
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 *
 *	@see PXLinkedList::containsObject:
 */
- (void) removeObject:(PXGenericObject)object
{
	//Find the object and remove it
	if (!object)
	{
		PXThrowNilParam(object);
		return;
	}

	//find this object
	PX_LL_START_CHILD_LOOP
	{
		if (node->data == object)
		{
			//Succesful
			[self removeNode:node];
			return;
		}
	}
	PX_LL_END_CHILD_LOOP

	//Unsuccessful
	//PXDebugLog(@"The object provided must be contained in the list in order to be removed");
	return;
}

/**
 *	Removes the object at the specified index from the list.
 *
 *	If the object isn't contained in the list the call is simply ignored;
 *	otherwise all of the objects following the oject at <code>index</code> are
 *	shifted down by one.
 *
 *	If <code>weakReferences</code> is set to <code>NO</code> (default), the
 *	object's retain count is decremented; otherwise the object's retain count
 *	stays the same.
 *	
 *	<i><b>Complexity:</b> O(n)</i>
 *	
 *	@param index
 *		The index from which to remove the object. <code>index</code> must be
 *		be a value between 0 and count - 1
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 *
 *	@see PXPoint
 */
- (void) removeObjectAtIndex:(int)index
{
	if (index < 0 || index >= _numNodes)
	{
		PXThrowIndexOutOfBounds;
		return;
	}

	PX_LL_START_CHILD_LOOP
	{
		if (i == index)
		{
			//Succesful
			[self removeNode:node];
			return;
		}
	}
	PX_LL_END_CHILD_LOOP
}

/**
 *	Removes the last object in the list (object at index
 *	<code>count - 1</code>).  If the list is empty the call is ignored.
 *
 *	If <code>weakReferences</code> is set to <code>NO</code> (default), the
 *	object's retain count is decremented; otherwise the object's retain count
 *	stays the same.
 *
 *	<i><b>Complexity:</b> O(1)</i>
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 *
 *	@see PXPoint
 */
- (void) removeLastObject
{
	if (_tail)
	{
		[self removeNode:_tail];
	}
}

/**
 *	Removes the first object in the list (object at index <code>0</code>).  If
 *	the list is empty the call is ignored.
 *
 *	If <code>weakReferences</code> is set to <code>NO</code> (default), the
 *	object's retain count is decremented; otherwise the object's retain count
 *	stays the same. 
 *	
 *	<i><b>Complexity:</b> O(1)</i>
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 *
 *	@see PXPoint
 */

- (void) removeFirstObject
{
	if (_head)
	{
		[self removeNode:_head];
	}
}

/**
 *	Removes all of the objects in the list, restoring it to its initial state.
 *	<br>If <code>weakReferences</code> is set to <code>NO</code> (default), the
 *	objects' retain counts are decremented; otherwise the object's retain count
 *	stays the same.
 *
 *	<i><b>Complexity:</b> O(n)</i>
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 *
 *	@see PXPoint
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
	_numNodes = 0;
}

/**
 *	Removes all of the objects in the list that are also in the provided list.
 *	<br>If <code>weakReferences</code> is set to <code>NO</code> (default), the
 *	objects' retain counts are decremented; otherwise the object's retain count
 *	stays the same.
 *
 *	<i><b>Complexity:</b> O(n * m)</i>
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 *
 *	@see PXPoint
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

	--_numNodes;
}

#pragma mark Swapping

/**
 *	Swaps the location of two objects in the list.  If either of the parameters
 *	aren't contained in the list, a PXArgumentException is thrown.
 *	
 *	@param object1
 *		The object to swap with <code>object2</code>
 *	@param object2
 *		The object to swap with <code>object1</code>
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 */
- (void) swapObject:(PXGenericObject)object1 withObject:(PXGenericObject)object2
{
	_PXLLNode *node1 = [self getNodeByObject:object1];
	_PXLLNode *node2 = [self getNodeByObject:object2];

	if (!node1 || !node2)
	{
		PXThrow(PXArgumentException, @"Parameter object must be contained in list");
	}

	[self swapNodes:node1:node2];
}

/**
 *	Swaps the location of two objects specified their indices in the list.  If
 *	either of the parameters aren't contained in the list, or are out of bounds,
 *	a PXArgumentException is thrown.
 *	
 *	@param index1
 *		The index of the object to swap with the object at <code>index2</code>.
 *		Must be a value between <code>0</code> and <code>count - 1</code>.
 *	@param index2
 *		The index of the object to swap with the object at <code>index1</code>.
 *		Must be a value between <code>0</code> and <code>count - 1</code>.
 *
 *	@b Example:
 *	@code
 *	PXPoint *add1 = [[PXPoint alloc] initWithX:3 andY:4];
 *	PXPoint *add2 = [[PXPoint alloc] initWithX:2 andY:5];
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
 *	@endcode
 *
 *	@see PXLinkedList::swapObject:withObject:
 */
- (void) swapObjectAtIndex:(int)index1 withObjectAtIndex:(int)index2
{
	_PXLLNode *node1 = [self getNodeByIndex:index1];
	_PXLLNode *node2 = [self getNodeByIndex:index2];

	if (!node1 || !node2)
	{
		PXThrow(PXArgumentException, @"Parameter object must be contained in list");
	}

	[self swapNodes:node1:node2];
}

- (void) swapNodes:(_PXLLNode *)node1:(_PXLLNode *)node2
{
	_PXLLNode *next1 = node1->next;
	_PXLLNode *prev1 = node1->prev;

	_PXLLNode *next2 = node2->next;
	_PXLLNode *prev2 = node2->prev;
	
	// - If the other node's next/prev points at me, point my next/prev back at
	// him.
	// - Otherwise do a regular switch. Make his next/prev my new next/prev.
	// Change the neighbor's link as well (next/prev neighbor's prev/next
	// becomes me)
	
	// _a_ = the 'me' node.
	// _b_ = the 'other' node.
	// _n_ = next/prev
	// _p_ = prev/next
#define PX_LL_LINK_SWITCH(_a_,_b_,_n_,_p_) \
	if (_n_ ## _b_ == node ## _a_)\
	{ \
		node ## _a_->_n_ = node ## _b_; \
	} \
	else \
	{ \
		node ## _a_->_n_ = _n_ ## _b_; \
		if (_n_ ## _b_) \
		{ \
			_n_ ## _b_->_p_ = node ## _a_; \
		} \
	}

	// Modify Node0's next & prev
	PX_LL_LINK_SWITCH(1,2,next,prev);
	PX_LL_LINK_SWITCH(1,2,prev,next);

	// Modify Node1's next & prev
	PX_LL_LINK_SWITCH(2,1,next,prev);
	PX_LL_LINK_SWITCH(2,1,prev,next);

	// Modify the head/tail
	if (_head == node1)
		_head = node2;
	else if (_head == node2)
		_head = node1;

	if (_tail == node1)
		_tail = node2;
	else if (_tail == node2)
		_tail = node1;
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

	int i = 0;
	for (; i < len; ++i)
	{
		if (currentNode)
		{
			stackbuf[i] = currentNode->data;
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

	return i;
}

#pragma mark Exporting

/**
 *	Creates and returns a C array containing pointers to all the objects
 *	in the list.  The array's length is equal to the <code>count</code>
 *	property's value.
 *
 *	It is the caller's responsibility to call <code>free()</code>
 *	on the returned array.
 *
 *	Notice that the objects contained in the returned array aren't retained
 *	<i>again</i> and as such this method should be used with caution.
 *
 *	<i><b>Complexity:</b> O(n)</i>
 *
 *	@return
 *		A C array containing pointers to all of the objects in the list.
 *		returns 0 if the list is empty.
 *
 *	Example:
 *	@code
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
 *	@endcode
 *
 *	@see PXLinkedList::count
 */
- (id *)cArray
{
	int len = self.count;
	if (len <= 0)
		return 0;

	id *cArray = malloc(sizeof(id) * len);

	PX_LL_START_CHILD_LOOP
	{
		cArray[i] = node->data;
	}
	PX_LL_END_CHILD_LOOP

	return cArray;
}

/**
 *	Returns a new list containing the same objects as this list, and in the same
 *	order.
 *	The individual items in the list aren't duplicated, only their reference is.
 *	
 *	Note that the new list also retains each of the objects as long as
 *	<code>weakReferences</code> is set to <code>NO</code> (default).
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
 *	Resets the node pool. Applies to all instances of PXLinkedList and should be
 *	used with caution.
 */
+ (void) cleanNodesPool
{
	PXLinkedListShrinkPoolNodes(0);
}

+ (PXLinkedList *)linkedListWithPooledNodes:(BOOL)pooledNodes
{
	return [[[PXLinkedList alloc] initWithPooledNodes:pooledNodes] autorelease];
}

+ (PXLinkedList *)linkedWithWeakReferences:(BOOL)weakReferences
{
	return [[[PXLinkedList alloc] initWithWeakReferences:weakReferences] autorelease];
}

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
		//Grab one out of the stack
		--pxLLPooledNodesCount;
		newNode = pxLLPooledNodesStack[pxLLPooledNodesCount];

		//If the stack is too big, shrink it down
		if (pxLLPooledNodesCount < pxLLPooledNodesSize / 4)
		{
			int newSize = pxLLPooledNodesSize / 4;
			PXLinkedListShrinkPoolNodes(newSize);
		}
	}

	return newNode;
}

void PXLinkedListReturnPooledNode(_PXLLNode *node)
{
	if (pxLLPooledNodesSize == pxLLPooledNodesCount)
	{
		//Make it bigger
		if (pxLLPooledNodesSize == 0)
			pxLLPooledNodesSize = 1;

		pxLLPooledNodesSize *= 2;

		//Size up
		pxLLPooledNodesStack = realloc(pxLLPooledNodesStack, sizeof(_PXLLNode *) * pxLLPooledNodesSize );
	}

	pxLLPooledNodesStack[pxLLPooledNodesCount] = node;
	++pxLLPooledNodesCount;
}

void PXLinkedListShrinkPoolNodes(int newSize)
{
	if (newSize >= pxLLPooledNodesSize)
		return;

	//Clear the pool nodes
	for (int i = newSize; i < pxLLPooledNodesCount; ++i)
	{
		//Deallocate the node
		free(pxLLPooledNodesStack[i]);
		//Zero that array cell
		pxLLPooledNodesStack[i] = 0;
	}

	//Size down
	pxLLPooledNodesStack = realloc(pxLLPooledNodesStack, sizeof(_PXLLNode *) * newSize);

	pxLLPooledNodesSize = newSize;

	if (pxLLPooledNodesCount > newSize)
		pxLLPooledNodesCount = newSize;
}
