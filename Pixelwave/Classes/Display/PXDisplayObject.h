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

#import <UIKit/UIKit.h>
#include "PXGL.h"

#import "PXEventDispatcher.h"

@class PXDisplayObjectContainer;
@class PXStage;
@class PXTransform;
@class PXRectangle;
@class PXPoint;

typedef enum
{
	//@ The initial state of _renderMode for PXDisplayObject. You must use PXGL
	//@ calls in your _renderGL method for this mode to work properly. It will
	//@ batch your gl draw calls together, so that less actual gl calls are
	//@ made. It will also manage the state of gl so when you use PXGL calls
	//@ such as PXGLEnable, it will enable intenral variables that will sync
	//@ with GL only when needed.
	PXRenderMode_BatchAndManageStates = 0,

	//@ You still can only use PXGL calls in _renderGL, however after each draw
	//@ it will flush the buffer immediately to GL rather then batch.
	PXRenderMode_ManageStates,

	//@ For custom you use normal gl calls. The matrix and color transform will
	//@ be set in gl so that your _renderGL method begins in the correct place.
	PXRenderMode_Custom,

	//@ The initial state of _renderGL for PXDisplayObjectContainers. No
	//@ _renderGL calls will be made for this display object.
	PXRenderMode_Off,
} PXRenderMode;

typedef enum
{
	_PXDisplayObjectFlags_shouldRenderAABB			= 0x01,
	_PXDisplayObjectFlags_visible					= 0x02,
	_PXDisplayObjectFlags_isContainer				= 0x04,
	_PXDisplayObjectFlags_isInteractive				= 0x08,
	_PXDisplayObjectFlags_useCustomHitArea			= 0x10,
} _PXDisplayObjectFlags;

@interface PXDisplayObject : PXEventDispatcher
{
@public
	// Linked List
	PXDisplayObject *_next;
	PXDisplayObject *_prev;

	PXRenderMode _renderMode;
	// NEVER set this variable directly, always use _PXGLState... to change it!
	PXGLState _glState;

	NSString *_name;
	PXDisplayObjectContainer *_parent;

	// Optimization, low level c functions
	void (*_impRenderGL)(id, SEL);

	// Transform properties
	float _rotation;
	float _scaleX;
	float _scaleY;

	PXGLMatrix _matrix;
	PXGLColorTransform _colorTransform;

	// This is the viewable size of the display object on the screen. This is
	// used for the first round of touch coordinate tests.
	PXGLAABB _aabb;

	_PXDisplayObjectFlags _flags;
@protected
	void *userData;
}

/**
 * A value defined and kept by the user. This is a useful pointer for anyone
 * who wants to associate a display object with something else.
 *
 * **Default:** `NULL`
 * 
 * @warning If you free/delete/release the object pointed to by userData,
 * remember to set userData to `NULL` to avoid
 * memory access bugs, headaches, frustration, and possibly suicidal
 * thoughts. Don't say we didn't warn you.
 */
@property (nonatomic) void *userData;

/**
 * A value between 0 and 1 representing the display object's transparency.
 * an `alpha` value of `1` will make the object
 * fully opaque while a value of `0` will make the object completely
 * transparent.
 *
 * **Default:** 1.0f
 */
@property (nonatomic) float alpha;
/**
 * The angle of rotation of the display object in degrees. Positive rotation
 * values result in clock-wise rotation.
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float rotation;
/**
 * A scaling value along the horizontal axis.
 * A value between 0 and 1 will squeeze the display object, while a value
 * greater than 1 will stretch it out.
 * 
 * A negative value flips the object.
 *
 * Note that modifying the #scaleX property may change the value of
 * the #width and #height properties and vice-versa
 *
 * **Default:** 1.0f
 */
@property (nonatomic) float scaleX;
/**
 * A scaling value along the vertical axis.
 * A value between 0 and 1 will squeeze the display object, while a value
 * greater than 1 will stretch it out.
 * 
 * A negative value flips the object.
 *
 * Note that modifying the #scaleY property may change the value of
 * the #width and #height properties and vice-versa
 *
 * **Default:** 1.0f
 */
@property (nonatomic) float scaleY;
/**
 * The offset of the display object's position across the horizontal axis.
 * Translation in Pixelwave is always measured in points, within the parent's
 * local coordinate space.
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float x;
/**
 * The offset of the display object's position across the vertical axis.
 * Translation in Pixelwave is always measured in points, within the parent's
 * local coordinate space.
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float y;
/**
 * The width, in points of the object's axis-aligned bounding box, within its
 * parent's coordinate space.
 *
 * Note that modifying the #width property affects the value of
 * the #scaleX and #scaleY properties and vice-versa
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float width;
/**
 * The height, in points of the object's axis-aligned bounding box, within its
 * parent's coordinate space.
 *
 * Note that modifying the #height property affects the value of
 * the #scaleX and #scaleY properties and vice-versa
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float height;
/**
 * A boolean representing the display object's visibility.
 * If set to `YES`, the display object is rendered as usual.
 * If set to `NO`, the display object is ignored during the render
 * phase, and will not recieve any touch interaction events.
 *
 * **Default:** `YES`
 */
@property (nonatomic) BOOL visible;

/**
 * Represents the display object's local space and color transformation.
 *
 * @see PXTransform
 */
@property (nonatomic, assign) PXTransform *transform;

/**
 * A non-unique name.
 * #name may never be `nil`. If a name isn't assigned,
 * one will be automatically generated.
 *
 * @throws #PXArgumentException if a nil value is set.
 *
 * @see [PXDisplayObjectContainer childByName:]
 */
@property (nonatomic, copy) NSString *name;

/**
 * The display object's container, or `nil` if the display object is
 * not on a display list.
 */
@property (nonatomic, readonly) PXDisplayObjectContainer *parent;

/**
 * The global root display object.
 * Will equal `nil` if the display object isn't part of a
 * display list descending from the root display object.
 */
@property (nonatomic, readonly) PXDisplayObject *root;

/**
 * The global stage display object.
 * Will equal `nil` if the display object isn't part of the main
 * display list.
 *
 * If a display object isn't on the main display list it can't	be rendered to
 * the screen.
 */
@property (nonatomic, readonly) PXStage *stage;

/**
 * Represents both the #scaleX and #scaleY properties.
 * Setting this property will set the values of #scaleX and
 * #scaleY to the given value.
 *
 * If the #scaleX</code> and #scaleY properties are equal,
 * this property will be equal to their value. If their values differ, this
 * property will be equal to `1.0`.
 *
 * @see scaleX
 * @see scaleY
 *
 * **Default:** 1.0f
 */
//Derived properties
@property (nonatomic) float scale;

/**
 * The horizontal position of the first touch on the screen in this
 * PXDisplayObject's coordinate space.  If there are no fingers (touches) on the
 * screen, then 0.0f is returned.
 */
@property (nonatomic, readonly) float touchX;
/**
 * The vertical position of the first touch on the screen in this
 * PXDisplayObject's coordinate space.  If there are no fingers (touches) on the
 * screen, then 0.0f is returned.
 */
@property (nonatomic, readonly) float touchY;
/**
 * The position of the first touch on the screen in this PXDisplayObject's
 * coordinate space.  If there are no fingers (touches) on the screen, then
 * `nil` is returned.
 */
@property (nonatomic, readonly) PXPoint *touchPosition;
/**
 * A list of #PXPoint s that represent the positions of every touch
 * on the screen in this PXDisplayObject's coordinate space.  If there are no
 * current touches on the screen, `nil` is returned.
 */
@property (nonatomic, readonly) NSArray *touchPositions;

//-- ScriptName: positionOfTouch
- (PXPoint *)positionOfTouch:(UITouch *)nativeTouch;

// Flash methods
//-- ScriptName: getBounds
- (PXRectangle *)boundsWithCoordinateSpace:(PXDisplayObject *)targetCoordinateSpace;
//-- ScriptName: getRect
- (PXRectangle *)rectWithCoordinateSpace:(PXDisplayObject *)targetCoordinateSpace;
//-- ScriptName: globalToLocal
- (PXPoint *)globalToLocal:(PXPoint *)point;
//-- ScriptName: localToGlobal
- (PXPoint *)localToGlobal:(PXPoint *)point;
//-- ScriptName: hitTestObject
- (BOOL) hitTestObject:(PXDisplayObject *)obj;
//-- ScriptIgnore
- (BOOL) hitTestPointWithX:(float)x y:(float)y;
//-- ScriptName: hitTestPoint
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: NO
- (BOOL) hitTestPointWithX:(float)x y:(float)y shapeFlag:(BOOL)shapeFlag;
@end

@interface PXDisplayObject (PrivateButPublic)
- (BOOL) _dispatchEventNoFlow:(PXEvent *)event;
- (void) _measureGlobalBounds:(CGRect *)retBounds;

- (BOOL) _hitTestPointWithoutRecursionWithGlobalX:(float)x globalY:(float)y shapeFlag:(BOOL)shapeFlag;
- (BOOL) _hitTestPointWithParentX:(float)x parentY:(float)y shapeFlag:(BOOL)shapeFlag;
- (BOOL) _hitTestPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag;

// Used by the transform property
- (void) _setMatrix:(PXGLMatrix *)matrix;
- (void) _setColorTransform:(PXGLColorTransform *)colorTransform;

// Propegate the event to the children if there are any
- (void) _dispatchAndPropegateEvent:(PXEvent *)event;
@end

@interface PXDisplayObject (Override)
- (void) _renderGL;
- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag;
- (void) _measureLocalBounds:(CGRect *)retBounds;
@end
