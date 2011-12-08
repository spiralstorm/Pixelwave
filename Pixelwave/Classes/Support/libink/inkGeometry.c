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
const inkPoint inkPointNan = _inkPointNan;
const inkPoint inkPointMin = _inkPointMin;
const inkPoint inkPointMax = _inkPointMax;
const inkSize inkSizeZero = _inkSizeZero;
const inkLine inkLineZero = _inkLineZero;
const inkTriangle inkTriangleZero = _inkTriangleZero;
const inkRect inkRectZero = _inkRectZero;
const inkBox inkBoxZero = _inkBoxZero;
const inkMatrix inkMatrixIdentity = _inkMatrixIdentity;

//int inkMaxUlps = 4 * 1024 * 512;
//int inkMaxUlps = 4096;
//int inkMaxUlps = 10;
//int inkMaxUlps = 2048;
//int inkMaxUlps = 1024;
int inkMaxUlps = 64;

#pragma mark -
#pragma mark Point
#pragma mark -

bool inkPointIsNan(inkPoint point)
{
	return isnan(point.x) || isnan(point.y);
}

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

bool inkLineContainsPoint(inkLine line, inkPoint point)
{
	return inkIsZerof(inkPointDistanceToLine(point, line));
}

#pragma mark -
#pragma mark Line
#pragma mark -

inkPoint inkLineIntersection(inkLine lineA, inkLine lineB)
{
	return inkLineIntersectionv(lineA, lineB, false);
}

inkPoint inkLineIntersectionv(inkLine lineA, inkLine lineB, bool flipT)
{
	inkPoint v1v = inkPointSubtract(lineA.pointB, lineA.pointA);
	inkPoint v2v = inkPointSubtract(lineB.pointB, lineB.pointA);

	if (inkPointIsEqual(v1v, inkPointZero))
	{
		return inkPointNan;
	}
	if (inkPointIsEqual(v2v, inkPointZero))
	{
		return inkPointNan;
	}

	inkPoint v1d = inkPointNormalize(v1v);
	inkPoint v2d = inkPointNormalize(v2v);

	if (inkPointIsEqual(v1d, v2d) || inkPointIsEqual(v1d, inkPointScale(v2d, -1.0f)))
	{
		return inkPointNan;
	}

	//var v3 = {vx:v2.p0.x-v1.p0.x, vy:v2.p0.y-v1.p0.y};
	inkPoint v3v = inkPointSubtract(lineB.pointA, lineA.pointA);

//	var t = perP(v3, v2)/perP(v1, v2);
	float perpA = inkPointPerp(v3v, v2v);
	float perpB = inkPointPerp(v1v, v2v);
	float t = perpA / perpB;

	if (flipT == true)
		t = -t;

	return inkPointMake(lineA.pointA.x + v1v.x * t, lineA.pointA.y + v1v.y * t);
}

inkPoint inkLineIntersectiona(inkLine lineA, inkLine lineB)
{
	inkPoint deltaA = inkPointMake(lineA.pointB.x - lineA.pointA.x, lineA.pointB.y - lineA.pointA.y);

	// If line A is actually a point, compare that point to the line and see if
	// lyes on it, if so, just return that point.
	if (inkIsZerof(deltaA.x) && inkIsZerof(deltaA.y))
	{
		return inkPointNan;
		/*inkPoint pointInLine = inkClosestPointToLine(lineA.pointA, lineB);

		if (inkIsZerof(inkPointDistanceToLine(pointInLine, lineA)))
		{
			return pointInLine;
		}

		return lineA.pointA;*/
	}

	inkPoint deltaB = inkPointMake(lineB.pointB.x - lineB.pointA.x, lineB.pointB.y - lineB.pointA.y);

	// If line B is actually a point, compare that point to the line and see if
	// lyes on it, if so, just return that point.
	if (inkIsZerof(deltaB.x) && inkIsZerof(deltaB.y))
	{
		return inkPointNan;
		/*inkPoint pointInLine = inkClosestPointToLine(lineB.pointA, lineA);

		if (inkIsZerof(inkPointDistanceToLine(pointInLine, lineB)))
		{
			return pointInLine;
		}

		return lineB.pointA;*/
	}

	if (inkPointIsEqual(lineA.pointA, lineB.pointA))
		return inkPointNan;
	//	return lineA.pointA;
	if (inkPointIsEqual(lineA.pointB, lineB.pointA))
		return inkPointNan;
	//	return lineA.pointB;
	if (inkPointIsEqual(lineA.pointA, lineB.pointB))
		return inkPointNan;
	//	return lineA.pointA;
	if (inkPointIsEqual(lineA.pointB, lineB.pointB))
		return inkPointNan;
	//	return lineA.pointB;

	// If they share an end point, return the end point
	/*if (inkIsEqualf(lineA.pointA.x, lineB.pointA.x) && inkIsEqualf(lineA.pointA.y, lineB.pointA.y))
		return lineA.pointA;
	if (inkIsEqualf(lineA.pointB.x, lineB.pointA.x) && inkIsEqualf(lineA.pointB.y, lineB.pointA.y))
		return lineA.pointB;
	if (inkIsEqualf(lineA.pointA.x, lineB.pointB.x) && inkIsEqualf(lineA.pointA.y, lineB.pointB.y))
		return lineA.pointA;
	if (inkIsEqualf(lineA.pointB.x, lineB.pointB.x) && inkIsEqualf(lineA.pointB.y, lineB.pointB.y))
		return lineA.pointB;*/

	float distAB;
	float theCos;
	float theSin;
	float ABpos;

//	Bx-=Ax; By-=Ay;
//	Cx-=Ax; Cy-=Ay;
//	Dx-=Ax; Dy-=Ay;

	//  (1) Translate the system so that point A is on the origin.
	lineA.pointB = inkPointMake(lineA.pointB.x - lineA.pointA.x, lineA.pointB.y - lineA.pointA.y);
	lineB.pointA = inkPointMake(lineB.pointA.x - lineA.pointA.x, lineB.pointA.y - lineA.pointA.y);
	lineB.pointB = inkPointMake(lineB.pointB.x - lineA.pointA.x, lineB.pointB.y - lineA.pointA.y);

	//  Discover the length of segment A-B.
//	distAB=sqrt(Bx*Bx+By*By);

	// HAS to be greater than 0 at this point, as that test was done earlier
	distAB = inkPointDistanceFromZero(lineA.pointB);

//	theCos=Bx/distAB;
//	theSin=By/distAB;

	//  (2) Rotate the system so that point B is on the positive X axis.
	theCos = lineA.pointB.x / distAB;
	theSin = lineA.pointB.y / distAB;

//	newX=Cx*theCos+Cy*theSin;
//	Cy  =Cy*theCos-Cx*theSin; Cx=newX;
//	newX=Dx*theCos+Dy*theSin;
//	Dy  =Dy*theCos-Dx*theSin; Dx=newX;

	lineB.pointA = inkPointMake(lineB.pointA.x * theCos + lineB.pointA.y * theSin,
								lineB.pointA.y * theCos - lineB.pointA.x * theSin);
	lineB.pointB = inkPointMake(lineB.pointB.x * theCos + lineB.pointB.y * theSin,
								lineB.pointB.y * theCos - lineB.pointB.x * theSin);

//	if (Cy<0. && Dy<0. || Cy>=0. && Dy>=0.) return NO;

	//	ABpos=Dx+(Cx-Dx)*Dy/(Dy-Cy);
	//	if (ABpos<0. || ABpos>distAB) return NO;
	//	*X=Ax+ABpos*theCos;
	//	*Y=Ay+ABpos*theSin;

	// Check if they are parallel
	float yDiff = (lineB.pointB.y - lineB.pointA.y);
	if (inkIsZerof(yDiff))
		return inkPointNan;

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

	return inkLineMake(inkPointSubtract(line.pointB, bisector), inkPointAdd(line.pointB, bisector));
//	return inkLineMakef(line.pointB.x - bisector.x, line.pointB.y - bisector.y,
//					    line.pointB.x + bisector.x, line.pointB.y + bisector.y);
}

inkBox inkLineExpandToBox(inkLine line, float halfScalar)
{
	inkLine lineA = inkLineBisectionTraverser(line, halfScalar);
	inkLine lineB = inkLineBisectionTraverser(inkLineMake(line.pointB, line.pointA), halfScalar);

	return inkBoxMake(lineA.pointA, lineA.pointB, lineB.pointA, lineB.pointB);
}

inkLine inkTriangleBisectionTraverser(inkTriangle triangle, float halfScalar)
{
	if (triangle.pointA.x > triangle.pointC.x)
		return inkTriangleBisectionTraverser(inkTriangleMake(triangle.pointC, triangle.pointB, triangle.pointA), halfScalar);
		//return inkTriangleBisectionTraverser(pointC, pointB, pointA, halfScalar);

	inkPoint a = inkPointSubtract(triangle.pointB, triangle.pointC);
	inkPoint c = inkPointSubtract(triangle.pointB, triangle.pointA);
//	inkPoint a = inkPointMake(pointB.x - pointA.x, pointB.y - pointA.y);
//	inkPoint c = inkPointMake(pointB.x - pointC.x, pointB.y - pointC.y);

	float aLen = inkPointDistanceFromZero(a);
	float cLen = inkPointDistanceFromZero(c);

	inkPoint bisector;

	float one_aLen = 1.0f / aLen;
	float one_cLen = 1.0f / cLen;

	if (inkIsEqualf(a.x * one_aLen, c.x * one_cLen) && inkIsEqualf(a.y * one_aLen, c.x * one_cLen))
	{
		return inkLineBisectionTraverser(inkLineMake(triangle.pointA, triangle.pointB), halfScalar);
	}

	bisector = inkPointMake((c.x * aLen) + (a.x * cLen), (c.y * aLen) + (a.y * cLen));

	inkPoint bisectorSq = inkPointMake(bisector.x * bisector.x, bisector.y * bisector.y);

	// Don't need to check if bisectorSq.x + bisectorSq.y is 0. This was
	// actually checked by the 'is triangle' check.
	halfScalar /= sqrtf(bisectorSq.x + bisectorSq.y);
	bisector = inkPointMake(bisector.x * halfScalar, bisector.y * halfScalar);

	return inkLineMake(inkPointAdd(triangle.pointB, bisector), inkPointSubtract(triangle.pointB, bisector));
//	return inkLineMakev(triangle.pointB.x + bisector.x, triangle.pointB.y + bisector.y,
//					    triangle.pointB.x - bisector.x, triangle.pointB.y - bisector.y);
}

bool inkTriangleContainsPoint(inkTriangle triangle, inkPoint point)
{
	// TODO:	Make a cheaper version of this test.
	float area = inkTriangleArea(triangle);
	if (inkIsZerof(area))
	{
		return false;
	}

	inkPoint v0 = inkPointSubtract(triangle.pointC, triangle.pointA);
	inkPoint v1 = inkPointSubtract(triangle.pointB, triangle.pointA);

	inkPoint v2 = inkPointSubtract(point, triangle.pointA);

	// Compute dot products
	float dot00 = inkPointDot(v0, v0);
	float dot01 = inkPointDot(v0, v1);
	float dot02 = inkPointDot(v0, v2);
	float dot11 = inkPointDot(v1, v1);
	float dot12 = inkPointDot(v1, v2);

	// Compute barycentric coordinates
	float denom = ((dot00 * dot11) - (dot01 * dot01));
	if (inkIsZerof(denom))
		return false;

	float invDenom = 1.0f / denom;
	float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
	float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

	// Check if point is in triangle
	return (u >= 0) && (v >= 0) && (u + v <= 1);
}

float inkTriangleArea(inkTriangle triangle)
{
	float ab = inkPointDistanceSq(triangle.pointA, triangle.pointB);
	float ac = inkPointDistanceSq(triangle.pointA, triangle.pointC);
	float bc = inkPointDistanceSq(triangle.pointB, triangle.pointC);

	if ((ab <= 0.0f) || (ac <= 0.0f) || (bc <= 0.0f))
		return 0.0f;

	ab = sqrtf(ab);
	ac = sqrtf(ac);
	bc = sqrtf(bc);

	if (((ab + ac > bc) && (ab + bc > ac) && (ac + bc > ab)))
	{
		float s = (ab + ac + bc) * 0.5f;
		return sqrtf(s * (s - ab) * (s - ac) * (s - bc));
	}

	return 0.0f;
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
