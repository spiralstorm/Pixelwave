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

#import "PXVector3D.h"

#include "PXMathUtils.h"

/**
 * A vector (or point) in a three-dimensional coordinate system,
 * where x represents the horizontal axis and y represents the vertical axis
 * and z represents the depth axis.
 */
@implementation PXVector3D

@synthesize x;
@synthesize y;
@synthesize z;
@synthesize w;

- (id) init
{
	return [self initWithX:0.0f y:0.0f z:0.0f w:0.0f];
}

/**
 * Creates a new vector at (#x, #y, #z).
 *
 * @param x The horizontal coordinate.
 * @param y The vertical coordinate.
 * @param z The depth coordinate.
 *
 * **Example:**
 *	PXVector3D *vector = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f];
 *	// vector will be (5,7,4)
 */
- (id) initWithX:(float)_x y:(float)_y z:(float)_z
{
	return [self initWithX:_x y:_y z:_z w:0.0f];
}

/**
 * Creates a new vector at (#x, #y, #z) with rotation #w.
 *
 * @param x The horizontal coordinate.
 * @param y The vertical coordinate.
 * @param z The depth coordinate.
 * @param w The angle of rotation.
 *
 * **Example:**
 *	PXVector3D *vector = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f w:0.0f];
 *	// vector will be (5,7,4) with angle of rotation 0
 */
- (id) initWithX:(float)_x y:(float)_y z:(float)_z w:(float)_w
{
	self = [super init];

	if (self)
	{
		[self setX:_x y:_y z:_z w:_w];
	}

	return self;
}

#pragma mark NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] initWithX:x y:y z:z w:w];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(x=%f, y=%f, z=%f, w=%f)", x, y, z, w];
}

#pragma mark Pooled Reset

- (void) reset
{
	x = 0.0f;
	y = 0.0f;
	z = 0.0f;

	w = 0.0f;
}

#pragma mark Properties

- (float) length
{
	return sqrtf([self lengthSquared]);
}

- (float) lengthSquared
{
	return ((x * x) + (y * y) + (z * z));
}

#pragma mark Additional Methods

/**
 * Sets the vector to (#x, #y, #z).
 *
 * @param x The horizontal coordinate.
 * @param y The vertical coordinate.
 * @param z The depth coordinate.
 *
 * **Example:**
 *	PXVector3D *vector = [[PXVector3D alloc] init];
 *	[vector setX:5.0f y:7.0f z:4.0f];
 *	// vector will be (5,7,4) with angle of rotation 0
 */
- (void) setX:(float)_x y:(float)_y z:(float)_z
{
	[self setX:_x y:_y z:_z w:w];
}

/**
 * Sets the vector to (#x, #y, #z) with rotation #w.
 *
 * @param x The horizontal coordinate.
 * @param y The vertical coordinate.
 * @param z The depth coordinate.
 * @param w The angle of rotation.
 *
 * **Example:**
 *	PXVector3D *vector = [[PXVector3D alloc] init];
 *	[vector setX:5.0f y:7.0f z:4.0f w:0.0f];
 *	// vector will be (5,7,4) with angle of rotation 0
 */
- (void) setX:(float)_x y:(float)_y z:(float)_z w:(float)_w
{
	x = _x;
	y = _y;
	z = _z;

	w = _w;
}

#pragma mark Flash Methods

/**
 * Adds the values of the given vector to the corresponding values of this
 * vector to create a new vector.
 *
 * @param vector The vector to be added.
 *
 * @return The created vector.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:-3.0f y:10.0f z:-9.0f];
 *	PXVector3D *vec3 = [vec1 addPoint:vec2];
 *	// vec3 will be (2.0f, 17.0f, -5.0f)
 *	PXVector3D *vec4 = [vec2 addPoint:vec3];
 *	// vec4 will be (-1.0f, 27.0f, -14.0f)
 */
- (PXVector3D *)addVector:(PXVector3D *)vector
{
	PXVector3D *newVector = [[PXVector3D alloc] init];

	newVector.x = vector.x + x;
	newVector.y = vector.y + y;
	newVector.z = vector.z + z;

	return [newVector autorelease];
}

/**
 * Subtracts the values of the given vector to the corresponding values of this
 * vector to create a new vector.
 *
 * @param vector The vector to be added.
 *
 * @return The created vector.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:-3.0f y:10.0f z:-9.0f];
 *	PXVector3D *vec3 = [vec1 subtractVector:vec2];
 *	// vec3 will be (-8.0f, 3.0f, -13.0f)
 *	PXVector3D *vec4 = [vec2 subtractVector:vec3];
 *	// vec4 will be (-5.0f, -7.0f, -4.0f)
 */
- (PXVector3D *)subtractVector:(PXVector3D *)vector
{
	PXVector3D *newVector = [[PXVector3D alloc] init];

	newVector.x = vector.x - x;
	newVector.y = vector.y - y;
	newVector.z = vector.z - z;

	return [newVector autorelease];
}

/**
 * Creates a vector that is perpendicular to the current vector and the given
 * vector.
 *
 * @param vector The other vector.
 *
 * @return The created vector.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:0.7f y:0.4f z:0.591608f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:0.3f y:-0.4f z:-0.866025f];
 *	PXVector3D *crossVector = [vec1 crossProductWithVector:vec2];
 *	// crossVector will be (-0.109767f, 0.7837f, -0.4f)
 */
- (PXVector3D *)crossProductWithVector:(PXVector3D *)vector
{
	PXVector3D *newVector = [[PXVector3D alloc] init];

	newVector.x = (y * vector.z) - (z * vector.y);
	newVector.y = (z * vector.x) - (x * vector.z);
	newVector.z = (x * vector.y) - (y * vector.x);

	return [newVector autorelease];
}

/**
 * Subtracts the values of this vector by the corresponding values of the given
 * vector.
 *
 * @param vector The vector to use for subtraction.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:-3.0f y:10.0f z:-9.0f];
 *	[vec1 decrementByVector:vec2];
 *	// vec1 will be (8.0f, -3.0f, 13.0f)
 */
- (void) decrementByVector:(PXVector3D *)vector
{
	x -= vector.x;
	y -= vector.y;
	z -= vector.z;
}

/**
 * Subtracts the values of this vector by the corresponding values of the given
 * vector.
 *
 * @param vector The vector to use for subtraction.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:-3.0f y:10.0f z:-9.0f];
 *	float dotProduct = [vec1 dotProductWithVector:vec2];
 *	// dotProduct will be 19.0f
 */
- (float) dotProductWithVector:(PXVector3D *)vector
{
	return (x * vector.x) + (y * vector.y) + (z * vector.z);
}

/**
 * Check to see if this vector is equal to another.
 *
 * @param vector The vector for checking.
 * @param allFour If `YES` then #w is also used in the test, otherwise just #x, #y
 * and #z are used.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f w:0.0f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f w:1.0f];
 *	BOOL isEqualWithoutAllFour = [vec1 equalsVector:vec2 useAllFour:NO];
 *	BOOL isEqualWithAllFour = [vec1 equalsVector:vec2 useAllFour:YES];
 *	// isEqualWithoutAllFour will be YES, isEqualWithAllFour will be NO.
 */
- (BOOL) equalsVector:(PXVector3D *)vector useAllFour:(BOOL)allFour
{
	if ((PXMathIsEqual(x, vector.x)) &
		(PXMathIsEqual(y, vector.y)) &
		(PXMathIsEqual(z, vector.z)))
	{
		if (allFour)
		{
			if (PXMathIsEqual(w, vector.w))
				return YES;
		}
		else
			return YES;
	}

	return NO;
}

/**
 * Adds the values of this vector by the corresponding values of the given
 * vector.
 *
 * @param vector The vector to use for addition.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:-3.0f y:10.0f z:-9.0f];
 *	[vec1 incrementByVector:vec2];
 *	// vec1 will be (2.0f, 17.0f, -5.0f)
 */
- (void) incrementByVector:(PXVector3D *)vector
{
	x += vector.x;
	y += vector.y;
	z += vector.z;
}

/**
 * Check to see if each of this vector's values are within a tolerance range of
 * another
 *
 * @param vector The vector for checking.
 * @param tolerance The tolerance for the check.
 * @param allFour If `YES` then #w is also used in the test, otherwise just #x, #y
 * and #z are used.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f w:0.0f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:4.2f y:7.4f z:4.1f w:0.9f];
 *	BOOL isNearlyEqualByHalf = [vec1 nearEqualsVector:vec2 withTolerance:0.5f useAllFour:YES];
 *	BOOL isNearlyEqualByOne = [vec1 nearEqualsVector:vec2 withTolerance:1.0f useAllFour:YES];
 *	// isNearlyEqualByHalf will be NO, isNearlyEqualByOne will be YES.
 */
- (BOOL) nearEqualsVector:(PXVector3D *)vector tolerance:(float)tolerance useAllFour:(BOOL)allFour
{
	if ((PXMathIsNearlyEqual(x, vector.x, tolerance)) &
		(PXMathIsNearlyEqual(y, vector.y, tolerance)) &
		(PXMathIsNearlyEqual(z, vector.z, tolerance)))
	{
		if (allFour)
		{
			if (PXMathIsNearlyEqual(w, vector.w, tolerance))
				return YES;
		}
		else
			return YES;
	}

	return NO;
}

/**
 * Negates the #x, #y and #z values of the vector.
 *
 * **Example:**
 *	PXVector3D *vector = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f];
 *	// vector will be (5,7,4)
 *	[vector negate];
 *	// vector will be (-5,-7,-4)
 */
- (void) negate
{
	x = -x;
	y = -y;
	z = -z;
}

/**
 * Normalizes the #x, #y and #z values of the vector.
 *
 * @return The length of the vector.
 *
 * **Example:**
 *	PXVector3D *vector = [[PXVector3D alloc] initWithX:3.0f y:4.0f z:5.0f];
 *	// vector will be (3.0f, 4.0f, 5.0f)
 *	[vector normalize];
 *	// vector will be (0.424264f, 0.565685f, 0.707107f)
 */
- (float) normalize
{
	float length = [self length];

	if (!PXMathIsZero(length))
	{
		float one_length = 1.0f/length;

		x *= one_length;
		y *= one_length;
		z *= one_length;
	}

	return length;
}

/**
 * Scales the #x, #y and #z values of the vector by `1 / ` #w.
 *
 * **Example:**
 *	PXVector3D *vector = [[PXVector3D alloc] initWithX:3.0f y:4.0f z:5.0f w:10.0f];
 *	// vector will be (3.0f, 4.0f, 5.0f, 10.0f)
 *	[vector project];
 *	// vector will be (0.3f, 0.4f, 0.5f, 10.0f)
 */
- (void) project
{
	if (!PXMathIsZero(w))
	{
		float one_w = 1.0f/w;

		x *= one_w;
		y *= one_w;
		z *= one_w;
	}
}

/**
 * Scales the #x, #y and #z values of the vector by the scalar.
 *
 * **Example:**
 *	PXVector3D *vector = [[PXVector3D alloc] initWithX:3.0f y:4.0f z:5.0f];
 *	// vector will be (3.0f, 4.0f, 5.0f, 10.0f)
 *	[vector scaleBy:0.1f];
 *	// vector will be (0.3f, 0.4f, 0.5f, 10.0f)
 */
- (void) scaleBy:(float)scalar
{
	x *= scalar;
	y *= scalar;
	z *= scalar;
}

/**
 * Calculates the angle (in radians) between the two given vectors.
 *
 * @param vectorA The first vector.
 * @param vectorB The second vector.
 *
 * @return The angle in radians between the two vectors.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:3.0f y:4.0f z:5.0f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:-4.0f y:3.0f z:5.0f];
 *	float angleInRadians = [PXVector3D angleBetweenVectorA:vec1 vectorB:vec2];
 *	// in degrees the angle is 60.0f
 */
+ (float) angleBetweenVectorA:(PXVector3D *)vectorA vectorB:(PXVector3D *)vectorB
{
	PXVector3D *vectorANormalized = [vectorA copy];
	PXVector3D *vectorBNormalized = [vectorB copy];

	[vectorANormalized normalize];
	[vectorBNormalized normalize];

	float angle = acosf([vectorANormalized dotProductWithVector:vectorBNormalized]);

	[vectorANormalized release];
	[vectorBNormalized release];

	return angle;
}

/**
 * Calculates the distance between the two given vectors.
 *
 * @param vectorA The first vector.
 * @param vectorB The second vector.
 *
 * @return The distance between the two vectors.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:3.0f y:4.0f z:5.0f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:-4.0f y:3.0f z:5.0f];
 *	float distance = [PXVector3D distanceBetweenVectorA:vec1 vectorB:vec2];
 *	// The distance is 7.071068f
 */
+ (float) distanceBetweenVectorA:(PXVector3D *)vectorA vectorB:(PXVector3D *)vectorB
{
	return sqrtf([PXVector3D distanceSquaredBetweenVectorA:vectorA vectorB:vectorB]);
}

/**
 * Calculates the squared distance between the two given vectors.
 *
 * @param vectorA The first vector.
 * @param vectorB The second vector.
 *
 * @return The squared distance between the two vectors.
 *
 * **Example:**
 *	PXVector3D *vec1 = [[PXVector3D alloc] initWithX:3.0f y:4.0f z:5.0f];
 *	PXVector3D *vec2 = [[PXVector3D alloc] initWithX:-4.0f y:3.0f z:5.0f];
 *	float distance = [PXVector3D distanceSquaredBetweenVectorA:vec1 vectorB:vec2];
 *	// The squared distance is 50.0f
 */
+ (float) distanceSquaredBetweenVectorA:(PXVector3D *)vectorA vectorB:(PXVector3D *)vectorB
{
	float deltaX = vectorA.x - vectorB.x;
	float deltaY = vectorA.y - vectorB.y;
	float deltaZ = vectorA.z - vectorB.z;

	return ((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ));
}

/**
 * Creates a vector at (#x, #y, #z).
 *
 * @param x The horizontal coordinate.
 * @param y The vertical coordinate.
 * @param z The depth coordinate.
 *
 * @return The created vector.
 *
 * **Example:**
 *	PXVector3D *vector = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f];
 *	// vector will be (5,7,4)
 */
+ (PXVector3D *)vector3DWithX:(float)x y:(float)y z:(float)z
{
	return [PXVector3D vector3DWithX:x y:y z:z w:0.0f];
}
/**
 * Creates a new vector at (#x, #y, #z) with rotation #w.
 *
 * @param x The horizontal coordinate.
 * @param y The vertical coordinate.
 * @param z The depth coordinate.
 * @param w The angle of rotation.
 *
 * @return The created vector.
 *
 * **Example:**
 *	PXVector3D *vector = [[PXVector3D alloc] initWithX:5.0f y:7.0f z:4.0f w:0.0f];
 *	// vector will be (5,7,4) with angle of rotation 0
 */
+ (PXVector3D *)vector3DWithX:(float)x y:(float)y z:(float)z w:(float)w
{
	return [[[PXVector3D alloc] initWithX:x y:y z:z w:w] autorelease];
}

@end
