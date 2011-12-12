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

#import "PXPoint.h"
#include "PXMathUtils.h"

/**
 * A PXPoint object represents a location in a two-dimensional coordinate
 * system, where x represents the horizontal axis and y represents the vertical
 * axis.
 */
@implementation PXPoint

@synthesize x, y;

- (id) init
{
	return [self initWithX:0.0f y:0.0f];
}

/**
 * Creates a new point at (x, y).
 *
 * @param x The horizontal coordinate.
 * @param y The vertical coordinate.
 *
 * **Example:**
 *	PXPoint *point = [[PXPoint alloc] initWithX:5 y:7];
 *	// point will be (5,7)
 */
- (id) initWithX:(float)_x y:(float)_y
{
	self = [super init];

	if (self)
	{
		[self setX:_x y:_y];
	}

	return self;
}

- (void) dealloc
{
	[super dealloc];
}

// MARK: NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] initWithX:x y:y];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(x=%f, y=%f)", x, y];
}

// MARK: Pooled Reset

- (void) reset
{
	x = 0.0f;
	y = 0.0f;
}

// MARK: Properties

- (float) length
{
	return sqrtf((x * x) + (y * y));
}

// MARK: Methods

/**
 * Sets the point to (x, y).
 *
 * @param x The horizontal coordinate.
 * @param y The vertical coordinate.
 *
 * **Example:**
 *	PXPoint *point = [PXPoint new];
 *	// point will be (0, 0)
 *	[point setX:5 y:7];
 *	// point will now be (5, 7)
 */
- (void) setX:(float)_x y:(float)_y
{
	x = _x;
	y = _y;
}

// MARK: Flash Methods

/**
 * Adds the coordinates of the given point to the coordinates of this point to
 * create a new point.
 *
 * @param point The point to be added.
 *
 * @return The created point.
 *
 * **Example:**
 *	PXPoint *pt1 = [[PXPoint alloc] initWithX:5 y:7];
 *	PXPoint *pt2 = [[PXPoint alloc] initWithX:-3 y:10];
 *	PXPoint *pt3 = [pt1 addPoint:pt2];
 *	// pt3 will be (2, 17)
 *	PXPoint *pt4 = [pt2 addPoint:pt3];
 *	// pt4 will be (-1, 27)
 */
- (PXPoint *)addPoint:(PXPoint *)point
{
	PXPoint *pt = [PXPoint new];

	pt->x = x + point->x;
	pt->y = y + point->y;

	return [pt autorelease];
}

/**
 * Subtracts the coordinates of the given point from the coordinates of this
 * point to create a new point.
 *
 * @param point The point to be subtracted.
 *
 * @return The created point.
 *
 * **Example:**
 *	PXPoint *pt1 = [[PXPoint alloc] initWithX:5 y:7];
 *	PXPoint *pt2 = [[PXPoint alloc] initWithX:-3 y:10];
 *	PXPoint *pt3 = [pt1 subtractPoint:pt2];
 *	// pt3 will be (8, -3)
 *	PXPoint *pt4 = [pt2 subtractPoint:pt3];
 *	// pt3 will now be (-11, 13)
 */
- (PXPoint *)subtractPoint:(PXPoint *)point
{
	PXPoint *pt = [PXPoint new];

	pt->x = x - point->x;
	pt->y = y - point->y;

	return [pt autorelease];
}

/**
 * Determines whether two points are equal.  Two points are equal if they have
 * the same x and y values.
 *
 * @param point The point to be compared.
 *
 * @return `YES` if the object is equal to this point object;
 * `NO` if it is not equal.
 *
 * **Example:**
 *	PXPoint *pt1 = [[PXPoint alloc] initWithX:5.0f y:7.0f];
 *	PXPoint *pt2 = [[PXPoint alloc] initWithX:-3.0f y:10.0f];
 *	PXPoint *pt3 = [[PXPoint alloc] initWithX:-3.0f y:10.0f];
 *	BOOL isEqual = [pt1 isEqualToPoint:pt2];
 *	// will result in NO
 *	isEqual = [pt2 isEqualToPoint:pt3];
 *	// will result in YES
 */
- (BOOL) isEqualToPoint:(PXPoint *)point
{
	if (PXMathIsEqual(x, point->x) && PXMathIsEqual(y, point->y))
	{
		return YES;
	}

	return NO;
}

/**
 * Sets the vector represented by this point to unit length.
 *
 * **Example:**
 *	PXPoint *point = [[PXPoint alloc] initWithX:3.0f y:4.0f];
 *	[point normalize];
 *	// point will now be (0.6f, 0.8f)
 */
- (void) normalize
{
	float length = sqrtf(x * x + y * y);
	if (PXMathIsZero(length))
		return;

	length = 1.0f / length;

	x *= length;
	y *= length;
}

/**
 * Scales the line segment between (0, 0) and the current point to a set
 * length.
 *
 * @param newLength The scaling value.
 *
 * **Example:**
 *	PXPoint *point = [[PXPoint alloc] initWithX:3.0f y:4.0f];
 *	[point normalizeWithLength:10.0f];
 *	// point will now be (6, 8)
 */
- (void) normalizeWithLength:(float)newLength
{
	[self normalize];

	x *= newLength;
	y *= newLength;
}

/**
 * Offsets the PXPoint object by the specified amount.  The value of dx is
 * added to the original value of x to create the new x value.  The value of dy
 * is added to the original value of y to create the new y value.
 *
 * @param dx The amount by which to offset the horizontal coordinate, x
 * @param dy The amount by which to offset the vertical coordinate, y.
 *
 * **Example:**
 *	PXPoint *point = [[PXPoint alloc] initWithX:3.0f y:4.0f];
 *	[point offsetWithX:11.0f y:-5.0f];
 *	// point will now be (14.0f, -1.0f)
 */
- (void) offsetWithX:(float)dx y:(float)dy
{
	x += dx;
	y += dy;
}

/**
 * Returns the distance between pt1 and pt2.
 *
 * @param pt1 The first point.
 * @param pt2 The second point.
 *
 * @return The distance between the first and second points.
 *
 * **Example:**
 *	PXPoint *pt1 = [[PXPoint alloc] initWithX:3.0f y:4.0f];
 *	PXPoint *pt2 = [[PXPoint alloc] initWithX:-3.0f y:-4.0f];
 *	float dist = [PXPoint distanceBetweenPointA:pt1 pointB:pt2];
 *	// dist will be 10.0f
 */
+ (float) distanceBetweenPointA:(PXPoint *)pt1 pointB:(PXPoint *)pt2
{
	float x = pt2->x - pt1->x;
	float y = pt2->y - pt1->y;

	return sqrtf((x * x) + (y * y));
}

/**
 * Returns the angle between pt1 and pt2.
 *
 * @param pt1 The first point.
 * @param pt2 The second point.
 *
 * @return The angle between the first and second degrees.
 *
 * **Example:**
 *	PXPoint *pt1 = [[PXPoint alloc] initWithX:0.0f y:0.0f];
 *	PXPoint *pt2 = [[PXPoint alloc] initWithX:5.0f y:-5.0f];
 *	float angle = [PXPoint angleBetweenPointA:pt1 pointB:pt2];
 *	// angle will be 45.0f
 */
+ (float) angleBetweenPointA:(PXPoint *)pt1 pointB:(PXPoint *)pt2
{
	float angle = atan2f(pt2.y - pt1.y, pt2.x - pt1.x);
	// + 90 degrees to confert the coordinate space from carteesian to flash.
	return PXMathToDeg(angle) + 90.0f;
}

/**
 * Determines a point between two specified points.  The parameter f determines
 * where the new interpolated point is located relative to the two end points
 * specified by parameters pt1 and pt2.
 * 
 * The closer the value of the parameter f is to 1.0, the closer the
 * interpolated point is to the first point (parameter pt1).
 *
 * @param pt1 The first point.
 * @param pt2 The second point.
 * @param f The level of interpolation between the two points.  Indicates where the
 * new point will be, along the line between pt1 and pt2. If f == 1, pt1
 * is returned; if == 0, pt2 is returned.
 *
 * @return The interpolated point.
 *
 * **Example:**
 *	PXPoint *pt1 = [[PXPoint alloc] initWithX:3.0f y:4.0f];
 *	PXPoint *pt2 = [[PXPoint alloc] initWithX:-3.0f y:-4.0f];
 *	PXPoint *pt3 = [PXPoint pointByInterpolatingBetweenPointA:pt1 pointB:pt2 withCoefficientOfInterpolation:0.3f];
 *	// pt3 will be (-1.2f, -1.6f)
 */
+ (PXPoint *)pointByInterpolatingBetweenPointA:(PXPoint *)pt1 pointB:(PXPoint *)pt2 withCoefficientOfInterpolation:(float)f
{
	float _x = pt2->x;
	float _y = pt2->y;

	float deltaX = (pt1->x - _x) * f;
	float deltaY = (pt1->y - _y) * f;

	_x += deltaX;
	_y += deltaY;

	return [[[PXPoint alloc] initWithX:_x y:_y] autorelease];
}

/**
 * Converts a pair of polar coordinates to a cartesian point coordinate.
 *
 * @param len The length coordinate of the polar pair.
 * @param angle The angle, in radians, of the polar pair.
 *
 * @return The cartesian point.
 *
 * **Example:**
 *	float angle = 45.0f * (M_PI/180.0f);
 *	float length = 1.0f;
 *	PXPoint *point = [PXPoint pointUsingPolarCoordWithLen:length angle:angle];
 *	// point will be (0.707107f, 0.707107f)
 */
+ (PXPoint *)pointUsingPolarCoordWithLen:(float)len angle:(float)angle
{
	PXPoint *pt = [PXPoint new];

	pt->x = cosf(angle) * len;
	pt->y = sinf(angle) * len;

	return [pt autorelease];
}

// MARK: Static Methods

/**
 * Creates a point at (x, y).
 *
 * @param x The horizontal coordinate.
 * @param y The vertical coordinate.
 *
 * @return The created point.
 *
 * **Example:**
 *	PXPoint *point = [PXPoint pointWithX:4 y:5];
 *	// point will be (4, 5)
 */
+ (PXPoint *)pointWithX:(float)x y:(float)y
{
	return [[[PXPoint alloc] initWithX:x y:y] autorelease];
}

@end
