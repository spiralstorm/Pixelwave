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

@class PXObjectPool;

/**
 * An optional protocol, used to customize the behaviour of a PXObjectPool.
 */
@protocol PXObjectPoolDelegate<NSObject>
/**
 * A PXObjectPool will automatically call this method when it needs to allocate
 * a new object. You should return the object you'd like to pass back to the
 * user, or `nil` if you'd like the pool to instantiate the object
 * with the default consructor.
 */
//-- ScriptIgnore
- (PXGenericObject) objectPool:(PXObjectPool *)objectPool newObjectForType:(Class)type;
@end

@interface PXObjectPool : NSObject
{
@private
	id<PXObjectPoolDelegate> delegate;

	NSMutableDictionary *pools;
}

/**
 * An optional delegate of type PXObjectPoolDelegate. Can be used to customize
 * what objects will be returned to the user for any given class type.
 */
@property(nonatomic, retain) id<PXObjectPoolDelegate> delegate;

//-- ScriptName: newObject
- (PXGenericObject) newObjectUsingClass:(Class)typeClass;
//-- ScriptName: releaseObject
- (void) releaseObject:(PXGenericObject)object;

//-- ScriptName: clean
- (void) purgeCachedData;

// TODO Later: Have the shared object pool be created in _PXTopLevelInitialize
// and released in _PXTopLevelDealloc? This way we do not have floating memory.
//-- ScriptName: sharedPool
+ (PXObjectPool *)sharedObjectPool;

@end
