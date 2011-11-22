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
const inkLine inkLineZero = _inkLineZero;
const inkSize inkSizeZero = _inkSizeZero;
const inkRect inkRectZero = _inkRectZero;
const inkBox inkBoxZero = _inkBoxZero;
const inkMatrix inkMatrixIdentity = _inkMatrixIdentity;

#pragma mark -
#pragma mark Point
#pragma mark -

inkPoint inkClosestPointToLine(inkPoint point, inkLine line)
{
	inkPoint delta = inkPointMake(line.pointB.x - line.pointA.x, line.pointB.y - line.pointA.y);

	if (inkIsZerof(delta.x) && inkIsZerof(delta.y))
		return line.pointA;

	float u = (((point.x - line.pointA.x) * delta.x) + ((point.y - line.pointA.y) * delta.y)) / ((delta.x * delta.x) + (delta.y * delta.y));

	if (u < 0.0f)
		return line.pointA;
	else if (u > 1.0f)
		return line.pointB;

	return inkPointMake(line.pointA.x + (u * (delta.x)), line.pointA.y + (u * (delta.y)));
}

float inkPointDistanceToLine(inkPoint point, inkLine line)
{
	return inkPointDistance(inkClosestPointToLine(point, line), point);
}

bool inkIsPointInLine(inkPoint point, inkLine line)
{
	return inkIsZerof(inkPointDistanceToLine(point, line));
}

#pragma mark -
#pragma mark Line
#pragma mark -

inkPoint inkLineIntersection(inkLine lineA, inkLine lineB)
{
	inkPoint deltaA = inkPointMake(lineA.pointB.x - lineA.pointA.x, lineA.pointB.y - lineA.pointA.y);

	// If line A is actually a point, compare that point to the line and see if
	// lyes on it, if so, just return that point.
	if (inkIsZerof(deltaA.x) && inkIsZerof(deltaA.y))
	{
		inkPoint pointInLine = inkClosestPointToLine(lineA.pointA, lineB);

		if (inkIsZerof(inkPointDistanceToLine(pointInLine, lineA)))
		{
			return pointInLine;
		}

		return lineA.pointA;
	}

	inkPoint deltaB = inkPointMake(lineB.pointB.x - lineB.pointA.x, lineB.pointB.y - lineB.pointA.y);

	// If line B is actually a point, compare that point to the line and see if
	// lyes on it, if so, just return that point.
	if (inkIsZerof(deltaB.x) && inkIsZerof(deltaB.y))
	{
		inkPoint pointInLine = inkClosestPointToLine(lineB.pointA, lineA);

		if (inkIsZerof(inkPointDistanceToLine(pointInLine, lineB)))
		{
			return pointInLine;
		}

		return lineB.pointA;
	}

	// If they share an end point, return the end point
	if (inkIsEqualf(lineA.pointA.x, lineB.pointA.x) && inkIsEqualf(lineA.pointA.y, lineB.pointA.y))
		return lineA.pointA;
	if (inkIsEqualf(lineA.pointB.x, lineB.pointA.x) && inkIsEqualf(lineA.pointB.y, lineB.pointA.y))
		return lineA.pointB;
	if (inkIsEqualf(lineA.pointA.x, lineB.pointB.x) && inkIsEqualf(lineA.pointA.y, lineB.pointB.y))
		return lineA.pointA;
	if (inkIsEqualf(lineA.pointB.x, lineB.pointB.x) && inkIsEqualf(lineA.pointB.y, lineB.pointB.y))
		return lineA.pointB;

	float distAB;
	float theCos;
	float theSin;
	float ABpos;

	//  (1) Translate the system so that point A is on the origin.
	lineA.pointB = inkPointMake(lineA.pointB.x - lineA.pointA.x, lineA.pointB.y - lineA.pointA.y);
	lineB.pointA = inkPointMake(lineB.pointA.x - lineA.pointA.x, lineB.pointA.y - lineA.pointA.y);
	lineB.pointB = inkPointMake(lineB.pointB.x - lineA.pointA.x, lineB.pointB.y - lineA.pointA.y);

	// HAS to be greater than 0 at this point, as that test was done earlier
	distAB = inkPointDistanceFromZero(lineA.pointB);

	//  (2) Rotate the system so that point B is on the positive X axis.
	theCos = lineA.pointB.x / distAB;
	theSin = lineA.pointB.y / distAB;

	lineB.pointA = inkPointMake(lineB.pointA.x * theCos + lineB.pointA.y * theCos,
								lineB.pointA.y * theCos - lineB.pointA.x * theSin);
	lineB.pointB = inkPointMake(lineB.pointB.x * theCos + lineB.pointB.y * theSin,
								lineB.pointB.y * theCos - lineB.pointB.x * theSin);

	// Check if they are parallel
	float yDiff = (lineB.pointB.y - lineB.pointA.y);
	if (inkIsZerof(yDiff))
		return inkPointMake(NAN, NAN);

	//  (3) Discover the position of the intersection point along line A-B.
	ABpos = lineB.pointB.x + (lineB.pointA.x - lineB.pointB.x) * lineB.pointB.y / yDiff;

	//  (4) Apply the discovered position to line A-B in the original coordinate system.
	return inkPointMake(lineA.pointA.x + ABpos * theCos, lineA.pointA.y + ABpos * theSin);
}

inkLine inkLineBisectionTraverser(inkLine line, float halfScalar)
{
	inkPoint bisector = inkPointMake(line.pointA.y - line.pointB.y, line.pointB.x - line.pointA.x);

	halfScalar /= sqrtf((bisector.x * bisector.x) + (bisector.y * bisector.y));

	bisector = inkPointMake(bisector.x * halfScalar, bisector.y * halfScalar);

	return inkLineMakev(line.pointB.x - bisector.x, line.pointB.y - bisector.y,
					    line.pointB.x + bisector.x, line.pointB.y + bisector.y);
}

inkBox inkLineExpandToBox(inkLine line, float halfScalar)
{
	inkLine lineA = inkLineBisectionTraverser(line, halfScalar);
	inkLine lineB = inkLineBisectionTraverser(inkLineMake(line.pointB, line.pointA), halfScalar);

	return inkBoxMake(lineA.pointA.x, lineA.pointA.y, lineA.pointB.x, lineA.pointB.y,
					  lineB.pointA.x, lineB.pointA.y, lineB.pointB.x, lineB.pointB.y);
}

inkLine inkTriangleBisectionTraverser(inkPoint pointA, inkPoint pointB, inkPoint pointC, float halfScalar)
{
	if (pointA.x > pointC.x)
		return inkTriangleBisectionTraverser(pointC, pointB, pointA, halfScalar);
	
	inkPoint a = inkPointMake(pointB.x - pointA.x, pointB.y - pointA.y);
	inkPoint c = inkPointMake(pointB.x - pointC.x, pointB.y - pointC.y);

	float aLen = inkPointDistanceFromZero(a);
	float cLen = inkPointDistanceFromZero(c);

	inkPoint bisector;

	float one_aLen = 1.0f / aLen;
	float one_cLen = 1.0f / cLen;

	if (inkIsEqualf(a.x * one_aLen, c.x * one_cLen) && inkIsEqualf(a.y * one_aLen, c.x * one_cLen))
	{
		return inkLineBisectionTraverser(inkLineMake(pointA, pointB), halfScalar);
	}

	bisector = inkPointMake((c.x * aLen) + (a.x * cLen), (c.y * aLen) + (a.y * cLen));

	inkPoint bisectorSq = inkPointMake(bisector.x * bisector.x, bisector.y * bisector.y);

	// Don't need to check if bisectorSq.x + bisectorSq.y is 0. This was
	// actually checked by the 'is triangle' check.
	halfScalar /= sqrtf(bisectorSq.x + bisectorSq.y);
	bisector = inkPointMake(bisector.x * halfScalar, bisector.y * halfScalar);

	return inkLineMakev(pointB.x + bisector.x, pointB.y + bisector.y,
					    pointB.x - bisector.x, pointB.y - bisector.y);
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
