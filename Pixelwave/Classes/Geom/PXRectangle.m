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

#import "PXRectangle.h"

#import <UIKit/UIKit.h>

#import "PXPoint.h"

#include "PXMathUtils.h"

/**
 * A PXRectangle object is an area defined by its position, as indicated by its
 * <code>top-left</code> corner (<code>x</code>, <code>y</code>) and by its
 * <code>width</code> and its <code>height</code>.
 *
 * The <code>x</code>, <code>y</code>, <code>width</code> and
 * <code>height</code> properties of the PXRectangle class are independent of
 * each other; changing the value of one property has no effect on the others.
 * However, the <code>right</code> and <code>bottom</code> properties are
 * integrally related to those four properties.  For example, if you change the
 * value of the <code>right</code> property, the value of the
 * <code>width</code> property changes; if you change the <code>bottom</code>
 * property, the value of the <code>height</code> property changes.
 *
 * The following code creates a rectangle at (0, 0) with a size of (0, 0):
 * @code
 * PXRectangle *rect = [PXRectangle new];
 * @endcode
 *
 * The following code creates a rectangle at (10, -7) with a size of (20, 10):
 * @code
 * PXRectangle *rect = [[PXRectangle alloc] initWithX:10 y:-7 width:20 height:10];
 * @endcode
 *
 * @see PXPoint
 */
@implementation PXRectangle

@synthesize x, y, width, height;

- (id) init
{
	return [self initWithX:0.0f y:0.0f width:0.0f height:0.0f];
}

/**
 * Creates a new rectangle with <code>topLeft</code> corner at (<code>x</code>,
 * <code>y</code>) and <code>size</code> of (<code>width</code>,
 * <code>height</code>).
 *
 * @param x The horizontal coordinate of the <code>topLeft</code> corner.
 * @param y The vertical coordinate of the <code>topLeft</code> corner.
 * @param width The width in pixels.
 * @param height The height in pixels.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // Top-left will be (-5, 7) size will be (10, 4).
 * @endcode
 */
- (id) initWithX:(float)_x y:(float)_y width:(float)_width height:(float)_height
{
	self = [super init];

	if (self)
	{
		[self setX:_x y:_y width:_width height:_height];
	}

	return self;
}

#pragma mark NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] initWithX:x
												   y:y
											   width:width
											  height:height];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(x=%f, y=%f, w=%f, h=%f)", x, y, width, height];
}

#pragma mark Pooled Reset

- (void) reset
{
	x = 0.0f;
	y = 0.0f;
	width  = 0.0f;
	height = 0.0f;
}

#pragma mark Properties

- (void) setLeft:(float)left
{
	float cRight = x + width;
	x = left;
	width = cRight - left;
}

- (float) left
{
	return x;
}

- (void) setRight:(float)right
{
	width = right - x;
}

- (float) right
{
	return x + width;
}

- (void) setTop:(float)top
{
	float cBottom = y + height;
	y = top;
	height = cBottom - top;
}

- (float) top
{
	return y;
}

- (void) setBottom:(float)bottom
{
	height = bottom - y;
}

- (float) bottom
{
	return y + height;
}

- (void) setSize:(PXPoint *)point
{
	width = point.x;
	height = point.y;
}

- (PXPoint *)size
{
	return [[[PXPoint alloc] initWithX:width y:height] autorelease];
}

- (void) setBottomRight:(PXPoint *)point
{
	width = point.x - x;
	height = point.y - y;
}

- (PXPoint *)bottomRight
{
	return [[[PXPoint alloc] initWithX:x + width y:y + height] autorelease];
}

- (void) setTopLeft:(PXPoint *)point
{
	x = point.x;
	y = point.y;
}

- (PXPoint *)topLeft
{
	return [[[PXPoint alloc] initWithX:x y:y] autorelease];
}

#pragma mark Methods

/**
 * Sets the rectangle's <code>topLeft</code> corner to (<code>x</code>,
 * <code>y</code>) and <code>size</code> of (<code>width</code>,
 * <code>height</code>).
 *
 * @param x The horizontal coordinate of the <code>topLeft</code> corner.
 * @param y The vertical coordinate of the <code>topLeft</code> corner.
 * @param width The width in pixels.
 * @param height The height in pixels.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [PXRectangle new];
 * // Top-left will be (0, 0) size will be (0, 0).
 * [rect setX:-5 y:7 width:10 height:4];
 * // Top-left will be (-5, 7) size will be (10, 4).
 * @endcode
 */
- (void) setX:(float)_x y:(float)_y width:(float)_width height:(float)_height
{
	x = _x;
	y = _y;
	width = _width;
	height = _height;
}

#pragma mark Flash Methods

/**
 * Determines whether the specified point is contained within the rectangle's
 * area.
 *
 * @param x The horizontal coordinate of the point.
 * @param y The vertical coordinate of the point.
 *
 * @return <code>YES</code> if the rectangle contains the point, otherwise
 * <code>NO</code>.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // Top-left will be (-5, 7) size will be (10, 4).
 * BOOL isContained = [rect containsX:3 y:8];
 * // isContained is YES
 * @endcode
 */
- (BOOL) containsX:(float)_x y:(float)_y
{
	if (_x >= x && _x <= x + width
	    && _y >= y && _y <= y + height)
		return YES;

	return NO;
}

/**
 * Determines whether the specified point is contained within the rectangle's
 * area.
 *
 * @param point The point to test.
 *
 * @return <code>YES</code> if the rectangle contains the point, otherwise
 * <code>NO</code>.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // Top-left will be (-5, 7) size will be (10, 4).
 * PXPoint *point = [[PXPoint alloc] initWithX:3 y:8];
 * BOOL isContained = [rect containsPoint:point];
 * // isContained is YES
 * @endcode
 */
- (BOOL) containsPoint:(PXPoint *)point
{
	return [self containsX:point.x y:point.y];
}

/**
 * Determines whether the entire specified rectangle is contained within this
 * rectangle's area.
 *
 * @param rect The rectangle to test.
 *
 * @return <code>YES</code> if this rectangle contains the rectangle provided,
 * otherwise <code>NO</code>.
 *
 * @b Example:
 * @code
 * PXRectangle *rect1 = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // rect1 will have its top-left will be (-5, 7) size will be (10, 4).
 * PXRectangle *rect2 = [[PXRectangle alloc] initWithX:-3 y:8 width:4 height:2];
 * // rect2 will have its top-left will be (-3, 8) size will be (4, 2).
 * BOOL isContained = [rect1 containsRect:rect2];
 * // isContained is YES
 * isContained = [rect2 containsRect:rect1];
 * // isContained is NO
 * @endcode
 */
- (BOOL) containsRect:(PXRectangle *)rect
{
	float _x = rect.x;
	float _y = rect.y;
	if (![self containsX:_x y:_y])
		return NO;

	_x = rect.x + rect.width;
	_y = rect.y;
	if (![self containsX:_x y:_y])
		return NO;

	_x = rect.x;
	_y = rect.y + rect.height;
	if (![self containsX:_x y:_y])
		return NO;

	_x = rect.x + rect.width;
	_y = rect.y + rect.height;
	if (![self containsX:_x y:_y])
		return NO;

	return YES;
}

/**
 * Determines whether the rectangle specified is equal to this rectangle.  This
 * is only true if the <code>x</code>, <code>y</code>, <code>width</code> and
 * <code>height</code> properties are the same.
 *
 * @param rect The rectangle to compare.
 *
 * @return <code>YES</code> if the rectangle specified is equal to this rectangle;
 * otherwise <code>NO</code>.
 *
 * @b Example:
 * @code
 * PXRectangle *rect1 = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // rect1 will have its top-left will be (-5, 7) size will be (10, 4).
 * PXRectangle *rect2 = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // rect2 will have its top-left will be (-5, 7) size will be (10, 4).
 * BOOL isEqual = [rect1 isEqualToRect:rect2];
 * // isEqual is YES
 * @endcode
 */
- (BOOL) isEqualToRect:(PXRectangle *)rectangle
{
	if (PXMathIsEqual(x, rectangle.x)		 &&
		PXMathIsEqual(width, rectangle.width) &&
		PXMathIsEqual(y, rectangle.y)		 &&
		PXMathIsEqual(height, rectangle.height))
	{
		return YES;
	}

	return NO;
}

/**
 * Determines if the rectangle has an area of 0.
 *
 * @return <code>YES</code> if the rectangle has an area of 0; otherwise
 * <code>NO</code>.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * BOOL emptyRect = [rect isEmpty];
 * // emptyRect is NO.
 * rect.width = 0;
 * emptyRect = [rect isEmpty];
 * // emptyRect is YES.
 * @endcode
 */
- (BOOL) isEmpty
{
	if (width <= 0.0f || height <= 0.0f)
		return YES;

	return NO;
}

/**
 * Increases the <code>size</code> of the rectangle by specified amounts, in
 * pixels, from the center.
 *
 * @param dx The size change, in pixels, in the horizontal position.
 * @param dy The size change, in pixels, in the vertical position.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // Top-left will be (-5, 7) size will be (10, 4).
 * [rect inflateWithX:1 y:0.5f];
 * // Top-left will be (-6, 6.5) size will be (12, 5).
 * @endcode
 */
- (void) inflateWithX:(float)dx y:(float)dy
{
	x -= dx;
	y -= dy;
	width += dx * 2.0f;
	height += dy * 2.0f;
}

/**
 * Increases the <code>size</code> of the rectangle by specified amounts, in
 * pixels, from the center.
 *
 * @param point The size change, in pixels.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // Top-left will be (-5, 7) size will be (10, 4).
 * PXPoint *point = [[PXPoint alloc] initWithX:1 y:0.5f];
 * [rect inflateWithPoint:point];
 * // Top-left will be (-6, 6.5) size will be (12, 5).
 * @endcode
 */
- (void) inflateWithPoint:(PXPoint *)point
{
	[self inflateWithX:point.x y:point.y];
}

/**
 * If the rectangle specified interesects with this rectangle, then the
 * interesection of the two rectangles is returned as a rectangle.  Otherwise
 * an empty rectangle is returned.
 *
 * @param toIntersect The rectangle to compare.
 *
 * @return A rectangle defining the intersection of the rectangle specified, and
 * this rectangle.  It's empty if no interesection was found.
 *
 * @b Example:
 * @code
 * PXRectangle *rect1 = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // rect1 will have its top-left will be (-5, 7) size will be (10, 4).
 * PXRectangle *rect2 = [[PXRectangle alloc] initWithX:-7 y:3 width:5 height:8];
 * // rect2 will have its top-left will be (-7, 3) size will be (5, 8).
 * PXRectangle *intersection = [rect1 intersectionWithRect:rect2];
 * // intersection will have its top-left will be (-5, 7) size will be (3, 4).
 * @endcode
 */
- (PXRectangle *)intersectionWithRect:(PXRectangle *)toIntersect
{
	PXRectangle *intersection = [[PXRectangle new] autorelease];

	if ([self isEmpty] || [toIntersect isEmpty])
		return intersection;

	CGRect rect1 = CGRectMake(x, y, width, height);
	CGRect rect2 = CGRectMake(toIntersect->x, toIntersect->y, toIntersect->width, toIntersect->height);
	CGRect rectIntersection = CGRectIntersection(rect1, rect2);

	if (CGRectIsNull(rectIntersection))
		return intersection;

	intersection->x = rectIntersection.origin.x;
	intersection->y = rectIntersection.origin.y;
	intersection->width = rectIntersection.size.width;
	intersection->height = rectIntersection.size.height;

	return intersection;
}

/**
 * Determines if the rectangle specified intersects with this rectangle.
 *
 * @param toIntersect The rectangle to compare.
 *
 * @return <code>YES</code> if this rectangle intersects with the rectangle
 * specified; otherwise <code>NO</code>.
 *
 * @b Example:
 * @code
 * PXRectangle *rect1 = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // rect1 will have its top-left will be (-5, 7) size will be (10, 4).
 * PXRectangle *rect2 = [[PXRectangle alloc] initWithX:-7 y:3 width:5 height:8];
 * // rect2 will have its top-left will be (-7, 3) size will be (5, 8).
 * BOOL intersects = [rect1 intersectsWithRect:rect2];
 * // intersects is YES.
 * @endcode
 */
- (BOOL) intersectsWithRect:(PXRectangle *)toIntersect
{
	return !([[self intersectionWithRect:toIntersect] isEmpty]);
}

/**
 * Adjusts the location of the rectangle.
 *
 * @param dx The horizontal change in position.
 * @param dy The vertical change in position.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // Top-left will be (-5, 7) size will be (10, 4).
 * [rect offsetWithX:4 y:-6];
 * // Top-left will be (-1, 1) size will be (10, 4).
 * @endcode
 */
- (void) offsetWithX:(float)dx y:(float)dy
{
	x += dx;
	y += dy;
}

/**
 * Adjusts the location of the rectangle.
 *
 * @param point The change in position.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // Top-left will be (-5, 7) size will be (10, 4).
 * PXPoint *point = [[PXPoint alloc] initWithX:4 y:-6];
 * [rect offsetWithPoint:point];
 * // Top-left will be (-1, 1) size will be (10, 4).
 * @endcode
 */
- (void) offsetWithPoint:(PXPoint *)point
{
	[self offsetWithX:point.x y:point.y];
}

/**
 * Sets all of the rectangle's properties to 0.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // Top-left will be (-5, 7) size will be (10, 4).
 * [rect setEmpty];
 * // Top-left will be (0, 0) size will be (0, 0).
 * @endcode
 */
- (void) setEmpty
{
	x = 0.0f;
	y = 0.0f;
	width = 0.0f;
	height = 0.0f;
}

/**
 * Adds two rectangles together to create a rectangle with their combined
 * properties.
 *
 * @param rect Rectangle to union with.
 *
 * @return The combined rectangle.
 *
 * @b Example:
 * @code
 * PXRectangle *rect1 = [[PXRectangle alloc] initWithX:-5 y:7 width:10 height:4];
 * // rect1 will have its top-left will be (-5, 7) size will be (10, 4).
 * PXRectangle *rect2 = [[PXRectangle alloc] initWithX:-7 y:3 width:5 height:8];
 * // rect2 will have its top-left will be (-7, 3) size will be (5, 8).
 * PXRectangle *unionRect = [rect1 unionWithRect:rect2];
 * // unionRect will have its top-left will be (-7, 3) size will be (12, 8).
 * @endcode
 */
- (PXRectangle *)unionWithRect:(PXRectangle *)toUnion
{
	PXRectangle *retUnion = [[PXRectangle new] autorelease];

	CGRect rect1 = CGRectMake(x, y, width, height);
	CGRect rect2 = PXRectangleToCGRect(toUnion);
	CGRect rectUnion = CGRectUnion(rect1, rect2);

	if (CGRectIsNull(rectUnion))
		return retUnion;

	retUnion->x = rectUnion.origin.x;
	retUnion->y = rectUnion.origin.y;
	retUnion->width = rectUnion.size.width;
	retUnion->height = rectUnion.size.height;

	return retUnion;
}

#pragma mark Static Methods

/**
 * Creates a rectangle with <code>topLeft</code> corner at (<code>x</code>,
 * <code>y</code>) and <code>size</code> of (<code>width</code>,
 * <code>height</code>).
 *
 * @param x The horizontal coordinate of the <code>topLeft</code> corner.
 * @param y The vertical coordinate of the <code>topLeft</code> corner.
 * @param width The width in pixels.
 * @param height The height in pixels.
 *
 * @return The created rectangle.
 *
 * @b Example:
 * @code
 * PXRectangle *rect = [PXRectangle rectangleWithX:-5 y:7 width:10 height:4];
 * // Top-left will be (-5, 7) size will be (10, 4).
 * @endcode
 */
+ (PXRectangle *)rectangleWithX:(float)x y:(float)y width:(float)width height:(float)height
{
	return [[[PXRectangle alloc] initWithX:x y:y width:width height:height] autorelease];
}

@end
