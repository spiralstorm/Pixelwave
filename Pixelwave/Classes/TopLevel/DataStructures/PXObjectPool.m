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

#import "PXObjectPool.h"
#import "PXLinkedList.h"
#import "PXPooledObject.h"

static PXObjectPool *pxSharedObjectPool = nil;

/**
 * An abstract object pool, capable of pooling multiple types of objects.
 * You should use an object pool in situations where the same type of class
 * must be allocated and deallocated many times over a period of time. The
 * object pool holds on to unused objects instead of deallocating them, to
 * avoid the overhead involved in allocating and releasing memory
 *
 * You may create and keep track of your own instance of PXObjectPool, but you
 * can also use the global shared object pool to quickly access pooled object
 * across the entire application.
 *
 * @see sharedObjectPool
 */
@implementation PXObjectPool

@synthesize delegate;

- (id) init
{
	self = [super init];

	if (self)
	{
		pools = nil;
		delegate = nil;
	}

	return self;
}

- (void) dealloc
{
	[self purgeCachedData];
	self.delegate = nil;
	[super dealloc];
}

/**
 * Clears all cached data in the pool from memory. As a pool is used it can
 * potentially collect many unused objects. Call this method to get rid of all
 * objects currently sitting in the pool without being used. Useful in low
 * system memory situations.
 */
- (void) purgeCachedData
{
	// Get rid of everything
	if (pools)
	{
		[pools removeAllObjects];
		[pools release];
		pools = nil;
	}
}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

#pragma mark Grabbing objects from pool

/**
 * Returns a pooled object of the given type. The returned object will have a
 * `retainCount` of 1, and must be released by the user at a later
 * time. When the returned object is no longer needed it should be
 * returned to the pool. To return an object to the pool, pass it to the
 * #releaseObject: method instead of calling `[NSObject release]` on
 * it directly.
 *
 * @param typeClass The class from which an instance should be created
 * @return A pooled instantiated object of the given class.
 *
 * @see releaseObject:
 */
- (PXGenericObject) newObjectUsingClass:(Class)typeClass
{
	if (!pools)
	{
		pools = [NSMutableDictionary new];
	}

	PXLinkedList *list = [pools objectForKey:typeClass];
	if (!list)
	{
		list = [[PXLinkedList alloc] init];
		[pools setObject:list forKey:typeClass];
		[list release];
	}

	PXGenericObject retObject = nil;

	if (list.count > 0)
	{
		retObject = list.lastObject;
		[retObject retain];
		[list removeLastObject];
	}
	else
	{
		if (delegate)
		{
			//[delegate poolDelegateCreateObjectForClass:typeClass retObject:&retObject];
			retObject = [delegate objectPool:self newObjectForType:typeClass];
		}

		if (!retObject && typeClass)
		{
			retObject = [typeClass new];
		}
	}

	return retObject;
}

#pragma mark Returning Objects to pool

/**
 * Returns an object to the pool and takes control of its ownership.
 * Passing an object to this method is
 * equivalent to calling `release` on it, and so you must follow
 * the usual rules of object ownership. You should **never** return an object to
 * a pool if you don't have ownership of it (a retain on it) for the same reason
 * you shouldn't release it if you don't have a retain on it.
 *
 * Another important part of returning an object to a pool is resetting its
 * state. An object that is returned to the pool with a state that hasn't been
 * reset may be given to the user at a different time, causing confusion as
 * the user expects an object with a fresh state. This can lead to memory
 * leaks and crashes which can be difficult to debug.
 *
 * To avoid this confusion, have your pooled objects implement the
 * PXPooledObject protocol, which requires a `reset` method to be
 * implemented. This `reset` method is autuamatically invoked
 * when the object is returned to a PXObjectPool, and should take care of
 * resetting its internal state.
 *
 * If you need to pool objects which you didn't design (and hence can't conform
 * to the PXPooledObject protocol) you must reset their states manually before
 * returning them to the pool.
 * 
 */
// Releases the object
- (void) releaseObject:(PXGenericObject)object
{
	if (!pools)
		return;

	Class typeClass = [object class];

	PXLinkedList *list = (PXLinkedList *)[pools objectForKey:typeClass];
	if (!list)
	{
		list = [[PXLinkedList alloc] init];
		[pools setObject:list forKey:typeClass];
		[list release];
	}
	
	[list addObject:object];

	[object release];
	
	if ([object conformsToProtocol:@protocol(PXPooledObject)])
	{
		if ([object respondsToSelector:@selector(reset)])
		{
			[((id<PXPooledObject>)object) reset];
		}
	}
}

#pragma mark Static Methods

/**
 * A global object pool which can be shared accross the entire application.
 * You're welcome!
 */
+ (PXObjectPool *)sharedObjectPool
{
	@synchronized(self)
	{
		if (pxSharedObjectPool == nil)
			pxSharedObjectPool = [[PXObjectPool alloc] init];
	}
	return pxSharedObjectPool;	
}

#pragma mark Debugging

- (NSString *)description
{
	NSMutableString *str = [NSMutableString new];

	[str appendFormat:@"[ObjectPool numTypes = %i]"];

	return [str autorelease];
}

@end
