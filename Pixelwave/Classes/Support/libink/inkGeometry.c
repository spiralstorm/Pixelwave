//
//  inkGeometry.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "inkGeometry.h"

#pragma mark -
#pragma mark Constants
#pragma mark -

const inkPoint inkPointZero = _inkPointZero;
const inkSize inkSizeZero = _inkSizeZero;
const inkRect inkRectZero = _inkRectZero;
const inkMatrix inkMatrixIdentity = _inkMatrixIdentity;

#pragma mark -
#pragma mark Math
#pragma mark -

float inkQ_rsqrt(float number)
{
	if (inkIsEqualf(number, 0.0f))
		return 0.0f;

	return 1.0f / sqrtf(number);

	long i;
	float x2, y;
	const float threehalfs = 1.5F;

	x2 = number * 0.5F;
	y  = number;
	i  = * ( long * ) &y;                       // evil floating point bit level hacking
	i  = 0x5f3759df - ( i >> 1 );               // what the fuck?
	y  = * ( float * ) &i;
	y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration
	//      y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed

	return y;
}

#pragma mark -
#pragma mark Point
#pragma mark -

void inkPointBisectionTraverser(inkPoint pointA, inkPoint pointB, inkPoint pointC, float halfScalar, inkPoint* inner, inkPoint* outer)
{
	inkPoint a = inkPointMake(pointB.x - pointA.x, pointB.y - pointA.y);
	inkPoint c = inkPointMake(pointB.x - pointC.x, pointB.y - pointC.y);

	float aLen = inkPointDistanceFromZero(a);
	float cLen = inkPointDistanceFromZero(c);

	inkPoint bisector;

	float one_aLen = 1.0f / aLen;
	float one_cLen = 1.0f / cLen;

	if (inkIsEqualf(a.x * one_aLen, c.x * one_cLen) && inkIsEqualf(a.y * one_aLen, c.x * one_cLen))
	{
		// This is not a triangle. Because this is a line, and our method
		// resolves around bisection of B, we don't care if we use A or C, it
		// will yield the same result; thus we choose A!
		bisector = inkPointMake(pointB.x - pointA.x, pointB.y - pointA.y);
		halfScalar *= inkQ_rsqrt((bisector.x * bisector.x) + (bisector.y * bisector.y));

		bisector = inkPointMake(bisector.x * halfScalar, bisector.y * halfScalar);

		// Perpendicular points
		if (inner != NULL)
		{
			*inner = inkPointMake(pointB.x + bisector.y, pointB.y - bisector.x);
		}

		if (outer != NULL)
		{
			*outer = inkPointMake(pointB.x - bisector.y, pointB.y + bisector.x);
		}

		return;
	}

	bisector = inkPointMake((c.x * aLen) + (a.x * cLen), (c.y * aLen) + (a.y * cLen));

	inkPoint bisectorSq = inkPointMake(bisector.x * bisector.x, bisector.y * bisector.y);

	// Don't need to check if bisectorSq.x + bisectorSq.y is 0. This was
	// actually checked by the 'is triangle' check.
	halfScalar *= inkQ_rsqrt(bisectorSq.x + bisectorSq.y);
	bisector = inkPointMake(bisector.x * halfScalar, bisector.y * halfScalar);

	if (inner != NULL)
	{
		*inner = inkPointMake(pointB.x + bisector.x, pointB.y + bisector.y);
	}

	if (outer != NULL)
	{
		*outer = inkPointMake(pointB.x - bisector.x, pointB.y - bisector.y);
	}
}

/*void inkPointBisectionTraverser(inkPoint pointA, inkPoint pointB, inkPoint pointC, float halfScalar, inkPoint* inner, inkPoint* outer)
{
//	inkPointMake(bisector.x * halfScalar, bisector.y * halfScalar);

	float ratio = 1.0f;

	float bcDist = inkPointDistance(pointB, pointC);
	if (bcDist != 0.0f)
		ratio = (inkPointDistance(pointA, pointB) / bcDist) * 0.5f;

	inkPoint tangent = inkPointMake((pointA.x + pointC.x) * ratio, (pointA.y + pointC.y) * (1.0f - ratio));

	inkPoint diff = inkPointMake(tangent.x - pointB.x, tangent.y - pointB.y);
	float dist = sqrtf((diff.x * diff.x) + (diff.y * diff.y));

	if (dist != 0.0f)
	{
		halfScalar /= dist;
	}

	diff = inkPointMake(diff.x * halfScalar, diff.y * halfScalar);

	if (inner != NULL)
	{
		*inner = inkPointMake(pointB.x + diff.x, pointB.y + diff.y);
	}

	if (outer != NULL)
	{
		*outer = inkPointMake(pointB.x - diff.x, pointB.y - diff.y);
	}
}*/

#pragma mark -
#pragma mark Size
#pragma mark -

#pragma mark -
#pragma mark Rect
#pragma mark -

#pragma mark -
#pragma mark Matrix
#pragma mark -

inkPoint inkMatrixTransformPoint(inkMatrix matrix, inkPoint point)
{
	return inkPointMake((point.x * matrix.a) + (point.y * matrix.c) + matrix.tx,
						(point.x * matrix.b) + (point.y * matrix.d) + matrix.ty);
}

inkPoint inkMatrixDeltaTransformPoint(inkMatrix matrix, inkPoint point)
{
	return inkPointMake((point.x * matrix.a) + (point.y * matrix.c),
						(point.x * matrix.b) + (point.y * matrix.d));
}
