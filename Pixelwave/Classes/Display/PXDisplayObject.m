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

#import "PXDisplayObject.h"

#import "PXTransform.h"
#import "PXColorTransform.h"

#import "PXRectangle.h"
#import "PXPoint.h"

#import "PXLinkedList.h"

#import "PXDisplayObjectContainer.h"

#import "PXObjectPool.h"
#include "PXEngine.h"
#include "PXTouchEngine.h"
#include "PXMathUtils.h"
#import "PXEvent.h"

#include "PXPrivateUtils.h"
#include "PXEngineUtils.h"
#include "PXExceptionUtils.h"
#include "PXGLUtils.h"
#include "PXDebugUtils.h"

#import "PXStage.h"
#include "PXSettings.h"

// Used for naming instances
static unsigned _pxDisplayObjectCount = 0;

/**
 * The base class for all elements drawn to the stage.
 * PXDisplayObject is an abstract class that represent a single element in the
 * display list.
 *
 * Every display object has the following main components:
 * 
 * - A transformation matrix representing the translation, rotation, scaling,
 * and skewing of the display object in relation to its parent's (ie. local
 * coordinates).
 * - A color transform representing the display object's color offset in
 * relation to its parents' (ie. local color space).
 * - A reference to the display object's parent, as well as the global stage
 * and root objects.
 * - An optional non-unique name. (for easy dereferencing)
 * - A visibility toggle.
 *
 * To abstract away the details of setting transformation matrices and color
 * transforms, the following properties are available:
 * 
 * - #x, #y
 * - #scaleX, #scaleY
 * - #width, #height
 * - #rotation
 * - #alpha
 *
 * Helper methods are available for getting the bounding-box of a display
 * object and performing hit-tests:
 * 
 * - #boundsWithCoordinateSpace:
 * - #hitTestPointWithX:y:shapeFlag:
 *
 * @warning The PXDisplayObject class should never be instantiated directly. Instead
 * use one of its concrete subclasses or create your own.
 *
 * @see PXSprite
 * @see PXSimpleSprite
 * @see PXTexture
 * @see PXShape
 */
@implementation PXDisplayObject

@synthesize userData;

//@synthesize visible = _visible;
@synthesize name = _name;
@synthesize parent = _parent;

- (id) init
{
	self = [super init];

	if (self)
	{
		userData = NULL;

		_flags = 0;
		PX_ENABLE_BIT(_flags, _PXDisplayObjectFlags_shouldRenderAABB);
		PX_ENABLE_BIT(_flags, _PXDisplayObjectFlags_visible);

		_renderMode = PXRenderMode_BatchAndManageStates;
		_glState = _PXGLDefaultState();

		// Transform
		_scaleX = 1.0f;
		_scaleY = 1.0f;
		_rotation = 0.0f;
		
		PXGLMatrixIdentity(&_matrix);
		PXGLColorTransformIdentity(&_colorTransform);
		
		// Properties
		_parent = nil;

		_name = [[NSString alloc] initWithFormat:@"instance%u", _pxDisplayObjectCount];
		++_pxDisplayObjectCount;

		_next = nil;
		_prev = nil;

		_impRenderGL = (void (*)(id, SEL))[self methodForSelector : @selector(_renderGL)];

		_aabb.xMin = 0; _aabb.xMax = 0;
		_aabb.yMin = 0; _aabb.yMax = 0;
	}

	return self;
}

- (void) dealloc
{
	// Remove all frame listeners I registered with the engine
	if ([self hasEventListenerOfType:PXEvent_EnterFrame])
	{
		PXEngineRemoveFrameListener(self);
	}
	if ([self hasEventListenerOfType:PXEvent_Render])
	{
		PXEngineRemoveRenderListener(self);
	}

	[_name release];
	_name = nil;

	_impRenderGL = 0;

	[super dealloc];
}

- (void) setName:(NSString *)str
{
	if (!str)
	{
		PXThrowNilParam(name);
		return;
	}

	if (_name != str)
	{
		[_name release];
		_name = [str copy];
	}
}

- (void) setVisible:(BOOL)visible
{
	if (visible)
	{
		PX_ENABLE_BIT(_flags, _PXDisplayObjectFlags_visible);
	}
	else
	{
		PX_DISABLE_BIT(_flags, _PXDisplayObjectFlags_visible);
	}
}
- (BOOL) visible
{
	return PX_IS_BIT_ENABLED(_flags, _PXDisplayObjectFlags_visible);
}

#pragma mark Stage and Root

- (PXStage *)stage
{
	if (_parent)
		return _parent.stage;
	
	return nil;
}
- (PXDisplayObject *)root
{
	if (self == PXEngineGetRoot())
		return self;
	
	if (_parent)
		return _parent.root;
	
	return nil;
}

#pragma mark Transformations

- (void) setTransform:(PXTransform *)newTransform
{
	if (!newTransform)
	{
		PXThrowNilParam(transform);
	}

	// The nicest, but least efficient way (3 allocations autoreleased):
	//PXTransform *transform = self.transform;
	//transform.matrix = newTransform.matrix;
	//transform.colorTransform = newTransform.colorTransform;

	// The messiest, but most efficient way (0 allocations, 2 struct copies):
	[self _setMatrix:&newTransform->_displayObject->_matrix];
	[self _setColorTransform:&newTransform->_displayObject->_colorTransform];
}

- (PXTransform *)transform
{
	return [[[PXTransform alloc] _initWithDisplayObject:self] autorelease];
}

- (void) _setMatrix:(PXGLMatrix *)mat
{
	_matrix = *mat;
	
	float mult = (_matrix.a < 0.0f ? -1.0f : 1.0f);
	//	mult = 1.0f;
	_scaleX = sqrtf(_matrix.a * _matrix.a + _matrix.b * _matrix.b) * mult;
	_scaleY = sqrtf(_matrix.d * _matrix.d + _matrix.c * _matrix.c) * (_matrix.d < 0.0f ? -1.0f : 1.0f);
	
	//float det = _matrix.a * _matrix.d - _matrix.b * _matrix.c;
	//float sX = _scaleX * (det < 0.0f ? -1.0f : 1.0f);
	float angle = atan2f(_matrix.b, _matrix.a * mult);
	angle = PXMathToDeg(angle);
	_rotation = angle * mult;
}
- (void) _setColorTransform:(PXGLColorTransform *)ct
{
	_colorTransform = *ct;
}

- (void) setScale:(float)scale
{
	//[_transform setScale : scale];

	_scaleX = scale;
	_scaleY = scale;

	float radians = PXMathToRad(_rotation);

	float cosVal = scale * cosf(radians);
	float sinVal = scale * sinf(radians);

	_matrix.a = cosVal;
	_matrix.b = sinVal;
	_matrix.c = -sinVal;
	_matrix.d = cosVal;
}

- (float) scale
{
	if (_scaleX == _scaleY)
		return _scaleX;

	return 1.0f;
}

- (void) setAlpha:(float)alpha
{
	if (_colorTransform.alphaMultiplier == alpha)
		return;

	_colorTransform.alphaMultiplier = alpha;
}

- (float) alpha
{
	return _colorTransform.alphaMultiplier;
}

- (void) setX:(float)x
{
	_matrix.tx = x;
}

- (void) setY:(float)y
{
	_matrix.ty = y;
}

- (float) x
{
	return _matrix.tx;
}

- (float) y
{
	return _matrix.ty;
}

- (void) setScaleX:(float)scale
{
	_scaleX = scale;

	float radians = PXMathToRad(_rotation);

	_matrix.a = _scaleX * cosf(radians);
	_matrix.b = _scaleX * sinf(radians);
}

- (void) setScaleY:(float)scale
{
	_scaleY = scale;

	float radians = PXMathToRad(_rotation);

	_matrix.c = -_scaleY *sinf(radians);
	_matrix.d = _scaleY * cosf(radians);
}

- (float) scaleX
{
	return _scaleX;
}

- (float) scaleY
{
	return _scaleY;
}

- (void) setRotation:(float)rot
{
	if (rot == _rotation)
		return;

	while (rot > 180.0f)
		rot -= 360.0f;

	while (rot < -180.0f)
		rot += 360.0f;

	float radians = PXMathToRad(rot - _rotation);

	float sinVal = sinf(radians);
	float cosVal = cosf(radians);

	float a = _matrix.a;
	float b = _matrix.b;
	float c = _matrix.c;
	float d = _matrix.d;

	_matrix.a = a * cosVal - b * sinVal;
	_matrix.b = a * sinVal + b * cosVal;
	_matrix.c = c * cosVal - d * sinVal;
	_matrix.d = c * sinVal + d * cosVal;

	_rotation = rot;
}

- (float) rotation
{
	return _rotation;
}

- (void) setWidth:(float)width
{
	//width *= (width < 0 ? -1.0f : 1);
	width = fabsf(width);
	float neg = (_scaleX < 0.0f ? -1.0f : 1.0f);

	CGRect rect = CGRectMake(0, 0, 0, 0);
	[self _measureGlobalBounds:&rect];

	float a = 0;
	float c = _matrix.c;
	if (c < 0.0f)
		c = -c;

	if (rect.size.width != 0)
		a = (width - (c * rect.size.height)) / rect.size.width;

	float b = _matrix.b;

	_matrix.a = a;
	_scaleX = sqrtf(a * a + b * b) * neg;
}

- (void) setHeight:(float)height
{
	//height *= (height < 0 ? -1 : 1);
	height = fabsf(height);
	float neg = (_scaleY < 0.0f ? -1.0f : 1.0f);

	CGRect rect = CGRectMake(0, 0, 0, 0);
	[self _measureGlobalBounds:&rect];

	float d = 0;
	float b = _matrix.c;
	if (b < 0.0f)
		b = -b;

	if (rect.size.height != 0)
		d = (height - (b * rect.size.width)) / rect.size.height;

	float c = _matrix.c;

	_matrix.d = d;
	_scaleY = sqrtf(d * d + c * c) * neg;
}

- (float) width
{
	CGRect rect = CGRectZero;
	[self _measureGlobalBounds:&rect];

	float x = rect.size.width;
	float y = rect.size.height;
	float a = _matrix.a;
	a = a < 0 ? -a : a;
	float c = _matrix.c;
	c = c < 0 ? -c : c;
	rect.size.width = (x * a + y * c);
	return rect.size.width;
}

- (float) height
{
	CGRect rect = CGRectZero;
	[self _measureGlobalBounds:&rect];

	float x = rect.size.width;
	float y = rect.size.height;
	float b = _matrix.b;
	b = b < 0 ? -b : b;
	float d = _matrix.d;
	d = d < 0 ? -d : d;
	rect.size.height = (x * b + y * d);

	return rect.size.height;
}

- (float) touchX
{
	PXPoint *point = [self touchPosition];
	if (!point)
		return 0.0f;
	return point.x;
}
- (float) touchY
{
	PXPoint *point = [self touchPosition];
	if (!point)
		return 0.0f;
	return point.y;
}
- (PXPoint *)touchPosition
{
	return [self positionOfTouch:PXTouchEngineGetFirstTouch()];
}
/*
- (float) localX:(UITouch *)touch
{
	PXPoint *point = [self localTouch:touch];
	if (!point)
		return 0.0f;
	return point.x;
}
- (float) localY:(UITouch *)touch
{
	PXPoint *point = [self localTouch:touch];
	if (!point)
		return 0.0f;
	return point.y;
}
*/
- (NSArray *)touchPositions
{
	NSMutableArray *list = [[NSMutableArray alloc] init];

	PXPoint *addPoint;
	PXLinkedList *touchList = PXTouchEngineGetAllTouches();
	for (UITouch *touch in touchList)
	{
		addPoint = [self positionOfTouch:touch];

		if (addPoint)
		{
			[list addObject:addPoint];
		}
	}

	return [list autorelease];
}

/////////////////
/////////////////
/////////////////

/*- (BOOL) multiplyDown:(PXDisplayObject *)targetCoordinateSpace:(PXDisplayObject *)displayObject:(PXGLMatrix *)matrix
{
	if (displayObject == targetCoordinateSpace)
		return YES;

	if (displayObject->_parent)
	{
		if ([self multiplyDown:targetCoordinateSpace:displayObject->_parent:matrix])
		{
			PXGLMatrixMult(matrix, matrix, &displayObject->_matrix);
			return YES;
		}
	}

	return NO;
}

- (void) multDown:(PXGLMatrix *)matrix
{
	PXDisplayObject *root = _parent;
	while (root && root->_parent)
		root = root->_parent;

	[self multiplyDown:root:self:matrix];
}

- (void) multUp:(PXGLMatrix *)matrix
{
	PXGLMatrix matInv;
	PXGLMatrixIdentity(&matInv);
	PXGLMatrixMult(&matInv, &matInv, &_matrix);
	PXGLMatrixInvert(&matInv);
	PXGLMatrixMult(matrix, matrix, &matInv);

	PXDisplayObject *parent = _parent;
	while (parent && parent->_parent)
	{
		PXGLMatrixIdentity(&matInv);
		PXGLMatrixMult(&matInv, &matInv, &parent->_matrix);
		PXGLMatrixInvert(&matInv);
		PXGLMatrixMult(matrix, matrix, &matInv);

		parent = parent->_parent;
	}
}*/

- (void) _measureGlobalBounds:(CGRect *)retBounds
{
	[self _measureLocalBounds:retBounds];
}

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	*retBounds = CGRectZero;
}

/**
 * Finds the position of the touch in this display object's coordinate system.
 *
 * @param nativeTouch The touch to find the position of.
 *
 * @return The position of the touch in this display object's coordinate system.
 *
 * **Example:**
 *	- (void) onTouchDown:(PXTouchEvent *)event
 *	{
 *		PXPoint *touchPosition = [self positionOfTouch:event.nativeTouch];
 *	}
 */
- (PXPoint *)positionOfTouch:(UITouch *)nativeTouch
{
	if (!nativeTouch)
		return nil;

	CGPoint touchPoint = PXTouchEngineTouchToScreenCoordinates(nativeTouch);

	PXObjectPool *pool = PXEngineGetSharedObjectPool();
	PXPoint *point = (PXPoint *)[pool newObjectUsingClass:[PXPoint class]];

#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_HalveStage))
	{
		PXStage *theStage = PXEngineGetStage();
		float stageWidth  = theStage.stageWidth;
		float stageHeight = theStage.stageHeight;

		touchPoint.x = 2.0f * ((stageWidth  * 0.75f) + (touchPoint.x - stageWidth));
		touchPoint.y = 2.0f * ((stageHeight * 0.75f) + (touchPoint.y - stageHeight));
	}
#endif

	point.x = touchPoint.x;
	point.y = touchPoint.y;

	PXPoint *globalPoint = [self globalToLocal:point];
	[pool releaseObject:point];

	return globalPoint;
}

#pragma mark Flash Methods
/**
 * Finds the bounding box of this display object in the target coordinate
 * space.
 *
 * @param targetCoordinateSpace The coordinate space for the bounds
 *
 * @return The bounding box in the target coordinate system.
 *
 * **Example:**
 *	PXShape *shape1 = [[PXShape alloc] init];
 *	PXShape *shape2 = [[PXShape alloc] init];
 *
 *	[self addChild:shape1];
 *	[self addChild:shape2];
 *
 *	[shape1 release];
 *	[shape2 release];
 *
 *	shape1.x = 50.0f;
 *	shape1.y = 25.0f;
 *	shape2.x = 100.0f;
 *	shape2.y = 75.0f;
 *
 *	[shape1.graphics beginFill:0xFF0000 alpha:1.0f];
 *	[shape1.graphics drawRectWithX:0.0f y:0.0f width:100.0f height:200.0f];
 *	[shape1.graphics endFill];
 *
 *	[shape2.graphics beginFill:0x0000FF alpha:1.0f];
 *	[shape2.graphics drawRectWithX:0.0f y:0.0f width:200.0f height:100.0f];
 *	[shape2.graphics endFill];
 *
 *	PXRectangle *bounds;
 *
 *	bounds = [shape1 boundsWithCoordinateSpace:shape2];
 *	NSLog (@"shape1 in shape2 = %@\n", [bounds description]);
 *	// bounds = (x=-50.0f, y=-50.0f, w=100.0f, h=200.0f)
 *
 *	shape2.scale = 0.5f;
 *	bounds = [shape1 boundsWithCoordinateSpace:shape2];
 *	NSLog (@"shape1 in shape2 = %@\n", [bounds description]);
 *	// bounds = (x=-100.0f, y=-100.0f, w=200.0f, h=400.0f)
 *
 *	bounds = [shape1 boundsWithCoordinateSpace:shape1];
 *	NSLog (@"shape1 in shape1 = %@\n", [bounds description]);
 *	// bounds = (x=0.0f, y=0.0f, w=100.0f, h=200.0f)
 *
 *	bounds = [shape1 boundsWithCoordinateSpace:self];
 *	NSLog (@"shape1 in root = %@\n", [bounds description]);
 *	// bounds = (x=50.0f, y=-25.0f, w=100.0f, h=200.0f)
 */
- (PXRectangle *)boundsWithCoordinateSpace:(PXDisplayObject *)targetCoordinateSpace
{
	CGRect bounds;
	[self _measureGlobalBounds:&bounds];

	PXGLMatrix matrix;
	PXGLMatrixIdentity(&matrix);

	if (targetCoordinateSpace != self)
	{
		PXUtilsDisplayObjectMultiplyDown(self, &matrix);
		//[self multDown:&matrix];

		PXGLMatrix m2;
		PXGLMatrixIdentity(&m2);
		PXUtilsDisplayObjectMultiplyUp(targetCoordinateSpace, &m2);
		//[targetCoordinateSpace multUp:&m2];

		PXGLMatrixMult(&matrix, &m2, &matrix);
	}

	bounds = PXGLMatrixConvertRect(&matrix, bounds);
	//PX_GL_CONVERT_RECT_TO_MATRIX(matrix, bounds);

 	return [[[PXRectangle alloc] initWithX:bounds.origin.x y:bounds.origin.y width:bounds.size.width height:bounds.size.height] autorelease];
}

/**
 * For the time being, both rectWithCoordinateSpace and
 * boundsWithCoordinateSpace do the same thing.
 *
 * @see [PXDisplayObject boundsWithCoordinateSpace]
 */
- (PXRectangle *)rectWithCoordinateSpace:(PXDisplayObject *)targetCoordinateSpace
{
	return [self boundsWithCoordinateSpace:targetCoordinateSpace];
}

/**
 * Converts a stage coordinate point to the display object's coordinate system.
 *
 * @param point A point in the stage coordinate system.
 *
 * @return The converted point to this display object's coordinate system.
 *
 * **Example:**
 *	PXShape *shape = [[PXShape alloc] init];
 *	[self addChild:shape];
 *	[shape release];
 *
 *	shape.x = 50.0f;
 *	shape.y = 25.0f;
 *
 *	[shape.graphics beginFill:0xFF0000 alpha:1.0f];
 *	[shape.graphics drawRectWithX:0.0f y:0.0f width:100.0f height:200.0f];
 *	[shape.graphics endFill];
 *
 *	PXPoint *point = [PXPoint pointWithX:10.0f y:20.0f];
 *	PXPoint *localPoint = [shape globalToLocal:point];
 *	// Point will be at (x=10.0f, y=20.0f), localPoint = (x=-40.0f, y=-5.0f).
 */
- (PXPoint *)globalToLocal:(PXPoint *)point
{
	if (!point)
	{
		PXThrowNilParam(point);
		return nil;
	}

	CGPoint cgPoint = CGPointMake(point.x, point.y);
	cgPoint = PXUtilsGlobalToLocal(self, cgPoint);
	return [PXPoint pointWithX:cgPoint.x y:cgPoint.y];
}

/**
 * Converts a display object's coordinate system point to the stage's
 * coordinate system.
 *
 * @param point A point in this display object's coordinate system.
 *
 * @return The converted point to the stage's coordinate system.
 *
 * **Example:**
 *	PXShape *shape = [[PXShape alloc] init];
 *	[self addChild:shape];
 *	[shape release];
 *
 *	shape.x = 50.0f;
 *	shape.y = 25.0f;
 *
 *	[shape.graphics beginFill:0xFF0000 alpha:1.0f];
 *	[shape.graphics drawRectWithX:0.0f y:0.0f width:100.0f height:200.0f];
 *	[shape.graphics endFill];
 *
 *	PXPoint *point = [PXPoint pointWithX:10.0f y:20.0f];
 *	PXPoint *globalPoint = [shape localToGlobal:point];
 *	// Point will be at (x=10.0f, y=20.0f), localPoint = (x=-60.0f, y=45.0f).
 */
- (PXPoint *)localToGlobal:(PXPoint *)point
{
	if (!point)
	{
		PXThrowNilParam(point);
		return nil;
	}

	CGPoint cgPoint = CGPointMake(point.x, point.y);
	cgPoint = PXUtilsLocalToGlobal(self, cgPoint);
	return [PXPoint pointWithX:cgPoint.x y:cgPoint.y];
}

/**
 * Tests if the bounding box of the given object is within the bounding box of
 * this object.
 *
 * @param obj The object for testing.
 *
 * @return `YES` if the bounding box of the given object is within the
 * bounding box of this object.
 *
 * **Example:**
 *	PXTexture *tex1 = [PXTexture textureWithContentsOfFile:@"image.png"];
 *	PXTexture *tex2 = [PXTexture textureWithContentsOfFile:@"image.png"];
 *
 *	[self addChild:tex1];
 *	[self addChild:tex2];
 *
 *	BOOL collides;
 *
 *	tex2.x = 0.0f;
 *	collides = [tex1 hitTestObject:tex2];
 *	NSLog (@"collides = %@\n", (collides ? @"YES" : @"NO"));
 *	// collides = YES
 *
 *	tex2.x = (tex1.x + tex1.width) *	1.2f;
 *	collides = [tex1 hitTestObject:tex2];
 *	NSLog (@"collides = %@\n", (collides ? @"YES" : @"NO"));
 *	// collides = NO
 */
- (BOOL) hitTestObject:(PXDisplayObject *)obj
{
	if (!obj)
	{
		PXThrowNilParam(hitTestObject);
		return NO;
	}

	PXStage *stage = self.stage;
	PXRectangle *rect1 = [self boundsWithCoordinateSpace:stage];
	PXRectangle *rect2 = [obj boundsWithCoordinateSpace:stage];

	return [rect1 intersectsWithRect:rect2];
}

/**
 * Tests if the given horizontal and vertical coordinate are within the
 * bounding box of this display object.
 *
 * @param x The horizontal coordinate (in stage coordinates) for testing.
 * @param y The vertical coordinate (in stage coordinates) for testing.
 *
 * @return `YES` if point is contained within the bounding box of this
 * display object.
 *
 * **Example:**
 *	PXTexture *tex = [PXTexture textureWithContentsOfFile:@"image.png"];
 *	[self addChild:tex];
 *
 *	tex.width  = 100.0f;
 *	tex.height = 100.0f;
 *
 *	BOOL collides;
 *
 *	tex.x = 0.0f;
 *	tex.y = 0.0f;
 *	collides = [tex hitTestPointWithX:50.0f y:25.0f];
 *	// collides = YES
 *
 *	tex.x = 75.0f;
 *	tex.y = 75.0f;
 *	collides = [tex hitTestPointWithX:50.0f y:25.0f];
 *	// collides = NO
 */
- (BOOL) hitTestPointWithX:(float)x y:(float)y
{
	return [self hitTestPointWithX:x y:y shapeFlag:NO];
}

/**
 * Tests if the given horizontal and vertical coordinate are within the display
 * object.
 *
 * @param x The horizontal coordinate (in stage coordinates) for testing.
 * @param y The vertical coordinate (in stage coordinates) for testing.
 * @param shapeFlag If `YES` a detailed collision detection is done of the actual
 * object.  If `NO` just the bounding box is tested.
 *
 * @return `YES` if point is contained within the bounding box of this
 * display object.
 *
 * **Example:**
 *	PXShape *shape = [[PXShape alloc] init];
 *	[self addChild:shape];
 *	[shape release];
 *
 *	[shape.graphics beginFill:0xFF0000 alpha:1.0f];
 *	[shape.graphics drawCircleWithX:50.0f y:50.0f radius:50.0f];
 *	[shape.graphics endFill];
 *
 *	BOOL collides;
 *
 *	collides = [tex hitTestPointWithX:1.0f y:1.0f shapeFlag:NO];
 *	// collides = YES
 *
 *	collides = [tex hitTestPointWithX:1.0f y:1.0f shapeFlag:YES];
 *	// collides = NO
 */
- (BOOL) hitTestPointWithX:(float)x y:(float)y shapeFlag:(BOOL)shapeFlag
{
	// Convert from global to local
	CGPoint globalPoint = CGPointMake(x, y);
	globalPoint = PXUtilsGlobalToLocal(self, globalPoint);
	return [self _hitTestPointWithLocalX:globalPoint.x localY:globalPoint.y shapeFlag:shapeFlag];

	/*// This is where most of the magic happens.
	// The global position gets converted to local coords
	PXObjectPool *pool = PXEngineGetSharedObjectPool();
	PXPoint *point = (PXPoint *)[pool newObjectUsingClass:[PXPoint class]];
	point.x = x;
	point.y = y;
	PXPoint *globalPoint = [self globalToLocal:point];
	[pool releaseObject:point];

//	PXPoint *pt = [[PXPoint alloc] initWithX:x y:y];
//	PXPoint *pt2 = [self globalToLocal:pt];
//	[pt release];

	return [self _hitTestPointWithLocalX:globalPoint.x localY:globalPoint.y shapeFlag:shapeFlag];*/
}


// Goes through display object and all of its children (overridden by
// DisplayObjectContainer).
- (BOOL) _hitTestPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	return [self _containsPointWithLocalX:x localY:y shapeFlag:shapeFlag];
}

- (BOOL) _hitTestPointWithParentX:(float)x
						  parentY:(float)y
						shapeFlag:(BOOL)shapeFlag
{
	// Converts position from parent's coordinate system to self's
	PXGLMatrix matInv;
	PXGLMatrixIdentity(&matInv);
	PXGLMatrixMult(&matInv, &matInv, &_matrix);
	PXGLMatrixInvert(&matInv);

	PXGLMatrixConvertPointv(&matInv, &x, &y);
	//PX_GL_CONVERT_POINT_TO_MATRIX(matInv, x, y);

	return [self _hitTestPointWithLocalX:x localY:y shapeFlag:shapeFlag];
}

// The actual one the user should override
- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	return NO;
}

// Engine only function for testing hittest given stage coordinates,
// WITHOUT recursion. This is almost identical to the public hittest function
// just that there's no recursion.
- (BOOL) _hitTestPointWithoutRecursionWithGlobalX:(float)x globalY:(float)y shapeFlag:(BOOL)shapeFlag
{
	CGPoint globalPoint = CGPointMake(x, y);
	globalPoint = PXUtilsGlobalToLocal(self, globalPoint);
	return [self _containsPointWithLocalX:globalPoint.x localY:globalPoint.y shapeFlag:shapeFlag];
}

#pragma mark GL Rendering

- (void) _renderGL
{
}

#pragma mark Per frame event listeners
- (BOOL) addEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener useCapture:(BOOL)useCapture priority:(int)priority
{
	char engineListenerToAdd = 0;

	// 1 = enterFrame
	// 2 = render
	
	if (!useCapture)
	{
		// If this is an ENTER_FRAME event, and I'm not already listening
		// on the engine then add me
		if ([type isEqualToString:PXEvent_EnterFrame])
		{
			if (![self hasEventListenerOfType:type])
				engineListenerToAdd = 1;
		}
		else if ([type isEqualToString:PXEvent_Render])
		{
			if (![self hasEventListenerOfType:type])
				engineListenerToAdd = 2;
		}
	}
	
	BOOL added = [super addEventListenerOfType:type listener:listener useCapture:useCapture priority:priority];

	if (!added)
	{
		return NO;
	}

	if (engineListenerToAdd > 0)
	{
		if (!PXEngineIsInitialized())
		{
			PXThrow(PXException, @"Can't add a broadcast event listener before a PXView is created.");
			return NO;
		}

		switch (engineListenerToAdd)
		{
			case 1:
				PXEngineAddFrameListener(self);
				break;
			case 2:
				PXEngineAddRenderListener(self);
				break;
			default:
				break;
		}
		
	}

	return YES;
}

- (BOOL) removeEventListenerOfType:(NSString *)type listener:(PXEventListener *)listener useCapture:(BOOL)useCapture
{
	BOOL removed = [super removeEventListenerOfType:type listener:listener useCapture:useCapture];

	if (!removed)
	{
		return NO;
	}

	if (!useCapture)
	{
		if ([type isEqualToString:PXEvent_EnterFrame])
		{
			// If nothing else needs to recieve enter frame events from the engine
			// we can stop listening
			if (![self hasEventListenerOfType:type])
			{
				PXEngineRemoveFrameListener(self);
			}
		}
		else if ([type isEqualToString:PXEvent_Render])
		{
			if (![self hasEventListenerOfType:type])
			{
				PXEngineRemoveRenderListener(self);
			}
		}
	}

	return YES;
}

#pragma mark the Event Flow

/*
 * Since I'm overriding the dispatchEvent method, this one can be used to
 * dispatch events with no event flow. Used on the ENTER_FRAME event which has
 * no capture of bubble phase
 */
- (BOOL) _dispatchEventNoFlow:(PXEvent *)event
{
	return [super dispatchEvent:event];
}

/*
 * This is where the actual event flow happens, with capture/bubble phases and all that
 *
 * Event flow notes: (From testing the Flash Player)
 * - Changing the order of the display list while an event is dispatched shouldn't affect its bubble/capture propegation.
 * The event flow uses the display list structure as it existed when the function was called.
*/

- (BOOL) dispatchEvent:(PXEvent *)event
{
	///////////////////
	// Preconditions //
	///////////////////
	
	// If I don't have a parent, thus I'm not on a display list, the event
	// flow is irrelevant
	if (!_parent)
		return [super dispatchEvent:event];
	
	// If the user doesn't want to hear from me, forget about it.
	if (!self.dispatchEvents)
		return NO;
	
	// Even we can't dispatch nil
	if (!event)
	{
		PXThrowNilParam(event);
		return NO;
	}
	
	// Get a retain on the event, or copy it if it's currently being used.
	// Either way we increment the retain count
	if (event->_isBeingDispatched)
		event = [event copy];
	else
		[event retain];
	
	////////////////////
	// Prep the event //
	////////////////////
	
	[self _prepEvent:event];
	
	////////////////////////////////
	// Start processing the event //
	////////////////////////////////

	event->_isBeingDispatched = YES;

	// Make sure I don't get deallocated mid-function by a listener
	[self retain];

	/////////////////////////////////////
	// Make a list of all my ancestors //
	/////////////////////////////////////

	// The list retains all the ancestors, releases them at the end
	PXLinkedList *ancestors = (PXLinkedList *)[PXEngineGetSharedObjectPool() newObjectUsingClass:[PXLinkedList class]];
	[ancestors removeAllObjects];

	PXDisplayObject *node;
	
	node = _parent;
	while (node)
	{
		[ancestors addObject:node];
		node = node->_parent;
	}

	// Start going through the phases
	BOOL propegationStopped = NO;

	/////////////////////////////////////
	// Invoke with the 'capture' phase //
	/////////////////////////////////////
	
	PXLinkedListForEachReverse(ancestors, node)
	{
		[node _invokeEvent:event withCurrentTarget:node eventPhase:PXEventPhase_Capture];

		if (event->_stopPropegationLevel > 0)
		{
			propegationStopped = YES;
			break;
		}
	}

	////////////////////////////////////
	// Invoke with the 'target' phase //
	////////////////////////////////////
	
	if (!propegationStopped)
	{
		[self _invokeEvent:event withCurrentTarget:self eventPhase:PXEventPhase_Target];
		propegationStopped = event->_stopPropegationLevel > 0;
	}

	//////////////////////////////////////
	// Invoke with the 'bubbling' phase //
	//////////////////////////////////////
	
	if (event.bubbles && !propegationStopped)
	{
		
		/* It's been tested and This is not TRUE (that's why it's commented
		 out):
		 
		// Create a new list of the ancestors. This lets things refresh between
		// the capture and bubble phase (ex: if the item was removed from the
		// stage by one of the listeners during the capture or target phase, the
		// stage won't get the bubbling event.
		
		[ancestors removeAllObjects];
		node = _parent;
		while (node)
		{
			[ancestors addObject:node];
			node = node->_parent;
		}
		*/
		
		// Loop through the ancestors, up the chain
		//PXLinkedListForEach(ancestors, object)
		for (node in ancestors)
		{
			//node = (PXDisplayObject *)object;

			[node _invokeEvent:event withCurrentTarget:node eventPhase:PXEventPhase_Bubbling];
			if (event->_stopPropegationLevel > 0)
			{
				propegationStopped = YES;
				break;
			}
		}
	}

	// Get rid of the ancestors list
	[ancestors removeAllObjects];
	[PXEngineGetSharedObjectPool() releaseObject:ancestors];

	// We're done with the event
	event->_isBeingDispatched = NO;
	
	// Let go of my temporary hold
	[self release];
	
	BOOL defaultPrevented = event->_defaultPrevented;
	
	// Release hold on the event
	[event release];
	
	return !defaultPrevented;
}

- (BOOL) willTrigger:(NSString *)type
{
	// Checks whether an event listener is registered with this EventDispatcher
	// object or any of its ancestors for the specified event type.
	// (Using recursive function calls to go up the chain)
	
	// If I listen to the event, it's all good
	if ([self hasEventListenerOfType:type])
		return YES;

	// If I have a parent, and I don't listen for this event.
	// See if my parent does
	if (!_parent)
		return [_parent willTrigger:type];
	
	// Nothing
	return NO;
	
}

#pragma mark Private public Functions

- (void) _dispatchAndPropegateEvent:(PXEvent *)event
{
	[self dispatchEvent:event];
}

@end
