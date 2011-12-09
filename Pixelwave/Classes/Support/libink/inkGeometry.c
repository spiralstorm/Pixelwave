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

typedef struct
{
	float totalDistance;
	inkPoint previousPoint;
} inkCurveLengthApproximator;

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

	inkPoint v3v = inkPointSubtract(lineB.pointA, lineA.pointA);

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
	}

	inkPoint deltaB = inkPointMake(lineB.pointB.x - lineB.pointA.x, lineB.pointB.y - lineB.pointA.y);

	// If line B is actually a point, compare that point to the line and see if
	// lyes on it, if so, just return that point.
	if (inkIsZerof(deltaB.x) && inkIsZerof(deltaB.y))
	{
		return inkPointNan;
	}

	if (inkPointIsEqual(lineA.pointA, lineB.pointA) || inkPointIsEqual(lineA.pointB, lineB.pointA) || inkPointIsEqual(lineA.pointA, lineB.pointB) || inkPointIsEqual(lineA.pointB, lineB.pointB))
		return inkPointNan;

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

	lineB.pointA = inkPointMake(lineB.pointA.x * theCos + lineB.pointA.y * theSin,
								lineB.pointA.y * theCos - lineB.pointA.x * theSin);
	lineB.pointB = inkPointMake(lineB.pointB.x * theCos + lineB.pointB.y * theSin,
								lineB.pointB.y * theCos - lineB.pointB.x * theSin);

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

	inkPoint a = inkPointSubtract(triangle.pointB, triangle.pointC);
	inkPoint c = inkPointSubtract(triangle.pointB, triangle.pointA);

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
}

bool inkTriangleContainsPoint(inkTriangle triangle, inkPoint point)
{
	if (point.x < triangle.pointA.x && point.x < triangle.pointB.x && point.x < triangle.pointC.x)
		return false;
	if (point.x > triangle.pointA.x && point.x > triangle.pointB.x && point.x > triangle.pointC.x)
		return false;
	if (point.y < triangle.pointA.y && point.y < triangle.pointB.y && point.y < triangle.pointC.y)
		return false;
	if (point.y > triangle.pointA.y && point.y > triangle.pointB.y && point.y > triangle.pointC.y)
		return false;

	if (inkPointIsEqual(triangle.pointA, triangle.pointB))
		return inkLineContainsPoint(inkLineMake(triangle.pointA, triangle.pointC), point);
	if (inkPointIsEqual(triangle.pointA, triangle.pointC) || inkPointIsEqual(triangle.pointB, triangle.pointC))
		return inkLineContainsPoint(inkLineMake(triangle.pointA, triangle.pointB), point);

	//triangle = inkTriangleXOrder(triangle);

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

	//bool success = (u >= -0.5f) && (v >= -0.5f) && (u + v <= 1.0f);

	// Check if point is in triangle
	//return success;
	return (u >= 0.0f) && (v >= 0.0f) && (u + v <= 1.0f);
//	return (u >= -0.75f) && (v >= -0.75f) && (u + v <= 1.0f);
	//return ((u > 0.0f) || inkIsZerof(u)) && ((v > 0.0f) || inkIsZerof(v)) && ((u + v) < 1.0f || inkIsEqualf(u + v, 1.0f));
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

#pragma mark -
#pragma mark Size
#pragma mark -

#pragma mark -
#pragma mark Rect
#pragma mark -

bool inkRectContainsRect(inkRect rectA, inkRect rectB)
{
	return inkRectContainsPoint(rectA, inkRectTopLeft(rectB)) && inkRectContainsPoint(rectA, inkRectTopRight(rectB)) && inkRectContainsPoint(rectA, inkRectBottomLeft(rectB)) && inkRectContainsPoint(rectA, inkRectBottomRight(rectB));
}

bool inkRectIntersects(inkRect rectA, inkRect rectB)
{
	return inkRectIsEmpty(inkRectIntersection(rectA, rectB));
}

inkRect inkRectIntersection(inkRect rectA, inkRect rectB)
{
	if (inkRectIsEmpty(rectA))
		return rectB;
	if (inkRectIsEmpty(rectB))
		return rectA;

	rectA = inkRectStandardize(rectA);
	rectB = inkRectStandardize(rectB);

	// If one rect contains no portion of the other then their intersection is
	// zero.
	if (rectA.origin.x + rectA.size.width  <= rectB.origin.x ||
		rectA.origin.y + rectA.size.height <= rectB.origin.y ||
		rectB.origin.x + rectB.size.width  <= rectA.origin.x ||
		rectB.origin.y + rectB.size.height <= rectA.origin.y)
	{
		return inkRectZero;
	}

	inkPoint origin = inkPointMake(fmaxf(rectA.origin.x, rectB.origin.x), fmaxf(rectA.origin.y, rectB.origin.y));

	return inkRectMake(origin,
					   inkSizeMake(fminf(rectA.origin.x + rectA.size.width,  rectB.origin.x + rectB.size.width)  - origin.x,
								   fminf(rectA.origin.y + rectA.size.height, rectB.origin.y + rectB.size.height) - origin.y));
}

inkRect inkRectUnion(inkRect rectA, inkRect rectB)
{
	if (inkRectIsEmpty(rectA))
		return rectB;
	if (inkRectIsEmpty(rectB))
		return rectA;

	rectA = inkRectStandardize(rectA);
	rectB = inkRectStandardize(rectB);

	return inkRectMakef(fminf(rectA.origin.x, rectB.origin.x),
						fminf(rectA.origin.y, rectB.origin.y),
						fmaxf(rectA.origin.x + rectA.size.width,  rectB.origin.x + rectB.size.width),
						fmaxf(rectA.origin.y + rectA.size.height, rectB.origin.y + rectB.size.height));
}

#pragma mark -
#pragma mark Matrix
#pragma mark -

#pragma mark -
#pragma mark Curve
#pragma mark

void inkCurveLengthAdd(inkPoint point, void* userData)
{
	if (userData == NULL)
		return;

	inkCurveLengthApproximator* approximator = (inkCurveLengthApproximator*)userData;

	approximator->totalDistance += inkPointDistance(approximator->previousPoint, point);
	approximator->previousPoint = point;
}

float inkQuadraticCurveLength(inkPoint start, inkPoint control, inkPoint end)
{
	// TODO: Figure out why this doesn't work.
	inkPoint a = inkPointMake(start.x - (2.0f * control.x) + end.x, start.y - (2.0f * control.x) + end.y);
	inkPoint b = inkPointMake(2.0f * control.x - 2.0f * start.x, 2.0f * control.y - 2.0f * start.y);

	float A = 4.0f * (a.x * a.x + a.y * a.y);
	float B = 4.0f * (a.x * b.x + a.y * b.y);
	float C = b.x * b.x + b.y * b.y;

	float Sabc = 2 * sqrtf(A+B+C);
	float A_2 = sqrtf(A);
	float A_32 = 2 * A*A_2;
	float C_2 = 2 * sqrtf(C);
	float BA = B / A_2;

	return (A_32 * Sabc + A_2 * B * (Sabc - C_2) + (4.0f * C * A - B * B) * logf((2 * A_2 + BA + Sabc) / (BA + C_2))) / (4.0f * A_32);
}

float inkCurveLength(inkCurveUpdatePointCallback updatePointFunc, void* updatePointUserData, inkCurveType curveType, inkPoint start, inkPoint controlA, inkPoint controlB, inkPoint end)
{
	inkCurveLengthApproximator approximator;
	approximator.totalDistance = 0.0f;
	approximator.previousPoint = start;

	inkCurveApproximation(updatePointFunc, updatePointUserData, curveType, start, controlA, controlB, end, 10, inkCurveLengthAdd, (void*)(&approximator));
	return approximator.totalDistance;
}

void inkCurveApproximation(inkCurveUpdatePointCallback updatePointFunc, void* updatePointUserData, inkCurveType curveType, inkPoint start, inkPoint controlA, inkPoint controlB, inkPoint anchor, unsigned int precicion, inkCurveNewPointCallback newPointFunc, void* newPointUserData)
{
	if (newPointFunc == NULL)
		return;

	if (precicion < 2)
		precicion = 2;

	inkPoint d = start;

	inkPoint point;
	inkPoint previousPoint = d;

	float tIncrement = 1.0f / (float)(precicion - 1);
	float t;
	float t2;
	float t3;

	inkPoint a;
	inkPoint b;
	inkPoint c;

	if (curveType == inkCurveType_Cubic)
	{
		inkPoint a3 = inkPointScale(controlA, 3.0f);
		inkPoint b3 = inkPointScale(controlB, 3.0f);
		inkPoint d3 = inkPointScale(d, 3.0f);
		c = inkPointSubtract(a3, d3);
		b = inkPointAdd(inkPointSubtract(b3, inkPointScale(controlA, 6.0f)), d3);
		a = inkPointSubtract(inkPointAdd(inkPointSubtract(anchor, b3), a3), d);
	}
	else if (curveType == inkCurveType_Quadratic)
	{
		inkPoint b2 = inkPointScale(controlB, 2.0f);
		c = inkPointSubtract(b2, inkPointScale(d, 2.0f));
		b = inkPointAdd(inkPointSubtract(anchor, b2), d);
		a = inkPointZero;
	}
	else
		return;

	unsigned int index;

	for (index = 0, t = 0.0f; index < precicion; ++index, t += tIncrement)
	{
		t2 = t * t;
		t3 = t2 * t;

		point = inkPointMake((a.x * t3) + (b.x * t2) + (c.x * t) + d.x,
							 (a.y * t3) + (b.y * t2) + (c.y * t) + d.y);

		if (inkPointIsEqual(previousPoint, point) == false)
		{
			previousPoint = point;

			if (updatePointFunc != NULL)
				point = updatePointFunc(point, updatePointUserData);

			newPointFunc(point, newPointUserData);
		}
	}
}
