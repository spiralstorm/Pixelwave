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

#import "PXInteractiveObject.h"

@class PXDisplayObject;

@interface PXDisplayObjectContainer : PXInteractiveObject<NSFastEnumeration>
{
@public
	BOOL _touchChildren;
	unsigned short _numChildren;

	// Linked List
	PXDisplayObject *_childrenHead; // Linked List Head
	PXDisplayObject *_childrenTail; // Tail

	void (*_impPreChildRenderGL)(id, SEL);
	void (*_impPostChildRenderGL)(id, SEL);
@private
	// Optimization, adding/removing a child
	void (*_impAddChildBefore)(id, SEL, PXDisplayObject *, PXDisplayObject *, BOOL);
	void (*_impRemoveChild)(id, SEL, PXDisplayObject *, BOOL);
}

/**
 * Determines whether or not the children of this object can be sent touch
 * events.
 *
 * @warning This unfortunately-named property is the result of trying
 * to faithfully reproduce ActionScript's naming convention. The
 * original was named `mouseChildren`.
 */
@property (nonatomic, assign) BOOL touchChildren;
/**
 * The number of display objects within this container.
 */
@property (readonly) unsigned short numChildren;

// From the Flash API

// Increases the retain count, O(1)
//-- ScriptName: addChild
- (PXDisplayObject *)addChild:(PXDisplayObject *)child;
// O(n)
//-- ScriptName: addChildAt
- (PXDisplayObject *)addChild:(PXDisplayObject *)child atIndex:(int) index;

// O(n)
//-- ScriptName: contains
- (BOOL) containsChild:(PXDisplayObject *)child;

// O(n)
//-- ScriptName: getChildAt
- (PXDisplayObject *)childAtIndex:(int)index;
// O(n)
//-- ScriptName: getChildByName
- (PXDisplayObject *)childByName:(NSString *)name;
// O(n)
//-- ScriptName: getChildIndex
- (int) indexOfChild:(PXDisplayObject *)child;

// child isn't returned in remove functions, unlike flash API, since we don't
// want the child to get autoreleased (for performance reasons)
// O(1)
//-- ScriptName: removeChild
- (void) removeChild:(PXDisplayObject *)child;
// O(n)
//-- ScriptName: removeChildAt
- (void) removeChildAtIndex:(int)index;

//-- ScriptName: setChildIndex
- (void) setIndex:(int)index ofChild:(PXDisplayObject *)child;
// O(1)
//-- ScriptName: swapChildren
- (void) swapChild:(PXDisplayObject *)child1 withChild:(PXDisplayObject *)child2;
// O(n + 1)
//-- ScriptName: swapChildrenAt
- (void) swapChildAtIndex:(int)index1 withChildAtIndex:(int)index2;

// Custom Functions

// O(n)
//-- ScriptName: removeAllChildren
- (void) removeAllChildren;
// O(n)
//-- ScriptName: getObjectsUnderPoint
- (NSArray *)objectsUnderPoint:(PXPoint *)point;
@end

@interface PXDisplayObjectContainer (Override)
- (void) _preChildRenderGL;
- (void) _postChildRenderGL;
@end
/// @endcond
