//
//  inkGeometry.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_GEOMETRY_H_
#define _INK_GEOMETRY_H_

#include "inkHeader.h"

typedef struct
{
	float x;
	float y;
} inkPoint;

typedef struct
{
	float width;
	float height;
} inkSize;

typedef struct
{
	inkPoint pointA;
	inkPoint pointB;
} inkLine;

typedef struct
{
	inkPoint pointA;
	inkPoint pointB;
	inkPoint pointC;
} inkTriangle;

typedef struct
{
	inkPoint origin;
	inkSize size;
} inkRect;

typedef struct
{
	inkPoint pointA;
	inkPoint pointB;
	inkPoint pointC;
	inkPoint pointD;
} inkBox;

typedef struct
{
	float a;
	float b;
	float c;
	float d;

	float tx;
	float ty;
} inkMatrix;

typedef enum
{
	inkCurveType_Quadratic = 0,
	inkCurveType_Cubic,
} inkCurveType;

typedef void (*inkCurveNewPointCallback)(inkPoint, void*);
typedef inkPoint (*inkCurveUpdatePointCallback)(inkPoint, void*);

#define _inkPointZero {0.0f, 0.0f}
#define _inkPointNan {NAN, NAN}
#define _inkPointMin {-FLT_MAX, -FLT_MAX}
#define _inkPointMax {FLT_MAX, FLT_MAX}
#define _inkSizeZero {0.0f, 0.0f}
#define _inkLineZero {_inkPointZero, _inkPointZero}
#define _inkRectZero {_inkPointZero, _inkSizeZero}
#define _inkTriangleZero {_inkPointZero, _inkPointZero, _inkPointZero}
#define _inkBoxZero {_inkPointZero, _inkPointZero, _inkPointZero, _inkPointZero}
#define _inkMatrixIdentity {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f}

inkExtern const inkPoint inkPointZero;
inkExtern const inkPoint inkPointNan;
inkExtern const inkPoint inkPointMin;
inkExtern const inkPoint inkPointMax;
inkExtern const inkSize inkSizeZero;
inkExtern const inkLine inkLineZero;
inkExtern const inkTriangle inkTriangleZero;
inkExtern const inkRect inkRectZero;
inkExtern const inkBox inkBoxZero;
inkExtern const inkMatrix inkMatrixIdentity;

inkExtern int inkMaxUlps;

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark -
#pragma mark Math Declarations
#pragma mark -

inkInline void inkSetMaxUlps(int maxUlps);

inkInline bool inkIsNearlyEqualf(float a, float b, int maxUlps);
//inkInline bool inkIsNearlyEqualf(float a, float b, float precision);
inkInline bool inkIsEqualf(float a, float b);
inkInline bool inkIsZerof(float a);
inkInline float inkAngleOrient(float angle);

#pragma mark -
#pragma mark Point Declarations
#pragma mark -

inkInline inkPoint inkPointMake(float x, float y);

inkInline inkPoint inkPointFromSize(inkSize size);

inkInline inkPoint inkPointAdd(inkPoint pointA, inkPoint pointB);
inkInline inkPoint inkPointSubtract(inkPoint pointA, inkPoint pointB);
inkInline inkPoint inkPointMultiply(inkPoint pointA, inkPoint pointB);
inkInline inkPoint inkPointDivide(inkPoint pointA, inkPoint pointB);
inkInline inkPoint inkPointScale(inkPoint point, float value);
inkInline inkPoint inkPointNormalize(inkPoint point);
inkInline inkPoint inkPointNormalizev(inkPoint point, float length);
inkInline inkPoint inkPointFromPolar(float length, float angle);
inkInline inkPoint inkPointFromElliptical(inkSize length, float angle);
inkInline inkPoint inkPointInterpolate(inkPoint from, inkPoint to, float percent);

inkInline float inkPointPerp(inkPoint pointA, inkPoint pointB);
inkInline float inkPointDot(inkPoint pointA, inkPoint pointB);
inkInline float inkPointAngle(inkPoint pointA, inkPoint pointB);
inkInline float inkPointDistanceFromZero(inkPoint point);
inkInline float inkPointDistance(inkPoint pointA, inkPoint pointB);
inkInline float inkPointDistanceSq(inkPoint pointA, inkPoint pointB);
inkInline bool inkPointIsEqual(inkPoint pointA, inkPoint pointB);
bool inkPointIsNan(inkPoint point);

inkPoint inkClosestPointToLine(inkPoint point, inkLine line);
float inkPointDistanceToLine(inkPoint point, inkLine line);

#pragma mark -
#pragma mark Size Declarations
#pragma mark -

inkInline inkSize inkSizeMake(float width, float height);

inkInline inkSize inkSizeFromPoint(inkPoint point);

inkInline bool inkSizeIsEqual(inkSize sizeA, inkSize sizeB);

#pragma mark -
#pragma mark Line Declarations
#pragma mark -

inkInline inkLine inkLineMake(inkPoint pointA, inkPoint pointB);
inkInline inkLine inkLineMakef(float x1, float y1, float x2, float y2);

bool inkLineContainsPoint(inkLine line, inkPoint point);

inkPoint inkLineIntersection(inkLine lineA, inkLine lineB);
inkPoint inkLineIntersectionv(inkLine lineA, inkLine lineB, bool flipT);
inkLine inkLineBisectionTraverser(inkLine line, float halfScalar);
inkBox inkLineExpandToBox(inkLine line, float halfScalar);

#pragma mark -
#pragma mark Triangle Declarations
#pragma mark -

inkInline inkTriangle inkTriangleMake(inkPoint pointA, inkPoint pointB, inkPoint pointC);
inkInline inkTriangle inkTriangleMakef(float x1, float y1, float x2, float y2, float x3, float y3);

inkInline inkTriangle inkTriangleXOrder(inkTriangle triangle);

inkLine inkTriangleBisectionTraverser(inkTriangle triangle, float halfScalar);
bool inkTriangleContainsPoint(inkTriangle triangle, inkPoint point);
float inkTriangleArea(inkTriangle triangle);

#pragma mark -
#pragma mark Box Declarations
#pragma mark -

inkInline inkBox inkBoxMake(inkPoint pointA, inkPoint pointB, inkPoint pointC, inkPoint pointD);
inkInline inkBox inkBoxMakef(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4);
inkInline inkBox inkBoxFromRect(inkRect rect);
inkInline bool inkBoxIsEqual(inkBox boxA, inkBox boxB);
inkInline inkBox inkBoxConcat(inkBox boxA, inkBox boxB);

#pragma mark -
#pragma mark Rect Declarations
#pragma mark -

inkInline inkRect inkRectMake(inkPoint origin, inkSize size);
inkInline inkRect inkRectMakef(float x, float y, float width, float height);

inkInline inkRect inkRectFromBox(inkBox box);

inkInline bool inkRectContainsPoint(inkRect rect, inkPoint point);
inkInline bool inkRectContainsPointf(inkRect rect, float x, float y);

inkInline float inkRectTop(inkRect rect);
inkInline float inkRectBottom(inkRect rect);
inkInline float inkRectLeft(inkRect rect);
inkInline float inkRectRight(inkRect rect);

inkInline inkPoint inkRectBottomLeft(inkRect rect);
inkInline inkPoint inkRectBottomRight(inkRect rect);
inkInline inkPoint inkRectTopLeft(inkRect rect);
inkInline inkPoint inkRectTopRight(inkRect rect);

inkInline bool inkRectIsEmpty(inkRect rect);
inkInline bool inkRectIsEqual(inkRect rectA, inkRect rectB);

inkInline inkRect inkRectInflate(inkRect rect, inkPoint point);
inkInline inkRect inkRectInflatef(inkRect rect, float dx, float dy);
inkInline inkRect inkRectOffset(inkRect rect, inkPoint point);
inkInline inkRect inkRectOffsetf(inkRect rect, float dx, float dy);
inkInline inkRect inkRectStandardize(inkRect rect);

bool inkRectContainsRect(inkRect rectA, inkRect rectB);
bool inkRectIntersects(inkRect rectA, inkRect rectB);
inkRect inkRectIntersection(inkRect rectA, inkRect rectB);
inkRect inkRectUnion(inkRect rectA, inkRect rectB);

#pragma mark -
#pragma mark Matrix Declaration
#pragma mark -

inkInline inkMatrix inkMatrixMake(float a, float b, float c, float d, float tx, float ty);

inkInline inkMatrix inkMatrixInvert(inkMatrix matrix);
inkInline inkMatrix inkMatrixRotate(inkMatrix matrix, float angle);
inkInline inkMatrix inkMatrixScale(inkMatrix matrix, inkSize scale);
inkInline inkMatrix inkMatrixScalef(inkMatrix matrix, float sx, float sy);
inkInline inkMatrix inkMatrixTranslate(inkMatrix matrix, inkPoint offset);
inkInline inkMatrix inkMatrixTranslatef(inkMatrix matrix, float dx, float dy);

inkInline inkMatrix inkMatrixMultiply(inkMatrix matrixA, inkMatrix matrixB);

/*inkMatrix inkMatrixConcat(inkMatrix matrixA, inkMatrix matrixB);

inkMatrix inkMatrixCreateBox(inkMatrix matrix, float scaleX, float scaleY, float rotation, float tx, float ty);
*/
inkInline inkPoint inkMatrixTransformPoint(inkMatrix matrix, inkPoint point);
inkInline inkPoint inkMatrixDeltaTransformPoint(inkMatrix matrix, inkPoint point);

#pragma mark -
#pragma mark Curve Declaration
#pragma mark

float inkCurveLength(inkCurveUpdatePointCallback updatePointFunc, void* updatePointUserData, inkCurveType curveType, inkPoint start, inkPoint controlA, inkPoint controlB, inkPoint end);
void inkCurveApproximation(inkCurveUpdatePointCallback updatePointFunc, void* updatePointUserData, inkCurveType curveType, inkPoint start, inkPoint controlA, inkPoint controlB, inkPoint anchor, unsigned int precicion, inkCurveNewPointCallback newPointFunc, void* newPointUserData);

#pragma mark -
#pragma mark Math Implemenations
#pragma mark -

inkInline void inkSetMaxUlps(int maxUlps)
{
	assert(maxUlps > 0 && maxUlps < 4 * 1024 * 1024);
	inkMaxUlps = maxUlps;
}
	
inkInline bool inkIsNearlyEqualf(float a, float b, int maxUlps)
{
	// Make sure maxUlps is non-negative and small enough that the
	// default NAN won't compare as equal to anything.
	assert(maxUlps > 0 && maxUlps < 4 * 1024 * 1024);
	int aInt = *(int*)&a;
	// Make aInt lexicographically ordered as a twos-complement int
	if (aInt < 0)
		aInt = 0x80000000 - aInt;
	// Make bInt lexicographically ordered as a twos-complement int
	int bInt = *(int*)&b;
	if (bInt < 0)
		bInt = 0x80000000 - bInt;
	int intDiff = abs(aInt - bInt);
	if (intDiff > 0)
	{
		printf("int diff between (%f and %f) is %d\n", a, b, intDiff);
	}
	if (intDiff <= maxUlps)
		return true;
	return false;
}

inkInline bool inkIsNearlyEqualfp(float a, float b, float precision)
{
	return (a <= (b + precision)) && (a >= (b - precision));
}

inkInline bool inkIsEqualf(float a, float b)
{
	// TODO:	Replace with math constant for small number, 0.000015f was a
	//			'off' value that has come up, keep this in mind.
	return inkIsNearlyEqualfp(a, b, 0.00005f);

	//return inkIsNearlyEqualf(a, b, inkMaxUlps);
}

inkInline bool inkIsZerof(float a)
{
	return inkIsEqualf(a, 0.0f);
}

inkInline float inkAngleOrient(float angle)
{
	if (angle > M_PI)
	{
		return angle - (M_PI + M_PI);
	}
	else if (angle < -M_PI)
	{
		return angle + (M_PI + M_PI);
	}
	
	return angle;
}

#pragma mark -
#pragma mark Point Implemenations
#pragma mark -

inkInline inkPoint inkPointMake(float x, float y)
{
	inkPoint point;

	point.x = x;
	point.y = y;

	return point;
}

inkInline inkPoint inkPointFromSize(inkSize size)
{
	return inkPointMake(size.width, size.height);
}

inkInline inkPoint inkPointAdd(inkPoint pointA, inkPoint pointB)
{
	return inkPointMake(pointA.x + pointB.x, pointA.y + pointB.y);
}

inkInline inkPoint inkPointSubtract(inkPoint pointA, inkPoint pointB)
{
	return inkPointMake(pointA.x - pointB.x, pointA.y - pointB.y);
}

inkInline inkPoint inkPointMultiply(inkPoint pointA, inkPoint pointB)
{
	return inkPointMake(pointA.x * pointB.x, pointA.y * pointB.y);
}

inkInline inkPoint inkPointDivide(inkPoint pointA, inkPoint pointB)
{
	return inkPointMake(pointA.x / pointB.x, pointA.y / pointB.y);
}

inkInline inkPoint inkPointScale(inkPoint point, float value)
{
	return inkPointMake(point.x * value, point.y * value);
}

inkInline inkPoint inkPointNormalize(inkPoint point)
{
	return inkPointNormalizev(point, inkPointDistanceFromZero(point));
}

inkInline inkPoint inkPointNormalizev(inkPoint point, float length)
{
	if (length != 0.0f)
	{
		float one_len = 1.0f / length;

		point.x *= one_len;
		point.y *= one_len;
	}

	return point;
}

inkInline inkPoint inkPointInterpolate(inkPoint from, inkPoint to, float percent)
{
	return inkPointMake(from.x + ((to.x - from.x) * percent), from.y + ((to.y - from.y) * percent));
}

inkInline float inkPointPerp(inkPoint pointA, inkPoint pointB)
{
	return ((pointA.x * pointB.y) - (pointA.y * pointB.x));
}

inkInline float inkPointDot(inkPoint pointA, inkPoint pointB)
{
	return ((pointA.x * pointB.x) + (pointA.y * pointB.y));
}

inkInline float inkPointDistanceFromZero(inkPoint point)
{
	return sqrtf((point.x * point.x) + (point.y * point.y));
}

inkInline float inkPointDistance(inkPoint pointA, inkPoint pointB)
{
	return sqrtf(inkPointDistanceSq(pointA, pointB));
}

inkInline float inkPointDistanceSq(inkPoint pointA, inkPoint pointB)
{
	inkPoint diff = inkPointMake(pointA.x - pointB.x, pointA.y - pointB.y);
	
	return ((diff.x * diff.x) + (diff.y * diff.y));
}

inkInline inkPoint inkPointFromPolar(float length, float angle)
{
	return inkPointMake(cosf(angle) * length, sinf(angle) * length);
}

inkInline inkPoint inkPointFromElliptical(inkSize length, float angle)
{
	return inkPointMake(cosf(angle) * length.width, sinf(angle) * length.height);
}

inkInline float inkPointAngle(inkPoint pointA, inkPoint pointB)
{
	return atan2f(pointB.y - pointA.y, pointB.x - pointA.x);
}

inkInline bool inkPointIsEqual(inkPoint pointA, inkPoint pointB)
{
	//return inkPointDistanceSq(pointA, pointB) < (0.3f * 0.3f);
	return inkIsEqualf(pointA.x, pointB.x) && inkIsEqualf(pointA.y, pointB.y);
}

#pragma mark -
#pragma mark Size Implemenations
#pragma mark -

inkInline inkSize inkSizeMake(float width, float height)
{
	inkSize size;

	size.width = width;
	size.height = height;

	return size;
}

inkInline inkSize inkSizeFromPoint(inkPoint point)
{
	return inkSizeMake(point.x, point.y);
}

inkInline bool inkSizeIsEqual(inkSize sizeA, inkSize sizeB)
{
	return inkPointIsEqual(inkPointFromSize(sizeA), inkPointFromSize(sizeB));
}

#pragma mark -
#pragma mark Line Implementations
#pragma mark -

inkInline inkLine inkLineMake(inkPoint pointA, inkPoint pointB)
{
	inkLine line;

	line.pointA = pointA;
	line.pointB = pointB;

	return line;
}

inkInline inkLine inkLineMakef(float x1, float y1, float x2, float y2)
{
	return inkLineMake(inkPointMake(x1, y1), inkPointMake(x2, y2));
}

#pragma mark -
#pragma mark Triangle Implementations
#pragma mark -

inkInline inkTriangle inkTriangleMake(inkPoint pointA, inkPoint pointB, inkPoint pointC)
{
	inkTriangle triangle;

	triangle.pointA = pointA;
	triangle.pointB = pointB;
	triangle.pointC = pointC;

	return triangle;
}

inkInline inkTriangle inkTriangleMakef(float x1, float y1, float x2, float y2, float x3, float y3)
{
	return inkTriangleMake(inkPointMake(x1, y1), inkPointMake(x2, y2), inkPointMake(x3, y3));
}

inkInline inkTriangle inkTriangleXOrder(inkTriangle triangle)
{
	if (triangle.pointC.x < triangle.pointB.x)
	{
		inkPoint temp = triangle.pointB;
		triangle.pointB = triangle.pointC;
		triangle.pointC = temp;
	}
	if (triangle.pointB.x < triangle.pointA.x)
	{
		inkPoint temp = triangle.pointA;
		triangle.pointA = triangle.pointB;
		triangle.pointB = temp;
	}
	if (triangle.pointC.x < triangle.pointB.x)
	{
		inkPoint temp = triangle.pointB;
		triangle.pointB = triangle.pointC;
		triangle.pointC = temp;
	}

	return triangle;
}

#pragma mark -
#pragma mark Rect Implemenations
#pragma mark -

inkInline inkRect inkRectMake(inkPoint origin, inkSize size)
{
	inkRect rect;

	rect.origin = origin;
	rect.size = size;

	return rect;
}

inkInline inkRect inkRectMakef(float x, float y, float width, float height)
{
	inkRect rect;

	rect.origin = inkPointMake(x, y);
	rect.size = inkSizeMake(width, height);

	return rect;
}

inkInline inkRect inkRectFromBox(inkBox box)
{
	return inkRectMake(box.pointA, inkSizeFromPoint(inkPointSubtract(box.pointC, box.pointA)));
}

inkInline bool inkRectContainsPoint(inkRect rect, inkPoint point)
{
	return !(point.x < rect.origin.x || point.x > (rect.origin.x + rect.size.width) || point.y < rect.origin.y || point.y > (rect.origin.y + rect.size.height));
}

inkInline bool inkRectContainsPointf(inkRect rect, float x, float y)
{
	return inkRectContainsPoint(rect, inkPointMake(x, y));
}

inkInline float inkRectTop(inkRect rect)
{
	return rect.origin.y;
}

inkInline float inkRectBottom(inkRect rect)
{
	return rect.origin.y + rect.size.height;
}

inkInline float inkRectLeft(inkRect rect)
{
	return rect.origin.x;
}

inkInline float inkRectRight(inkRect rect)
{
	return rect.origin.x + rect.size.width;
}

inkInline inkPoint inkRectBottomLeft(inkRect rect)
{
	return inkPointMake(inkRectLeft(rect), inkRectBottom(rect));
}

inkInline inkPoint inkRectBottomRight(inkRect rect)
{
	return inkPointMake(inkRectRight(rect), inkRectBottom(rect));
}

inkInline inkPoint inkRectTopLeft(inkRect rect)
{
	return inkPointMake(inkRectLeft(rect), inkRectTop(rect));
}

inkInline inkPoint inkRectTopRight(inkRect rect)
{
	return inkPointMake(inkRectRight(rect), inkRectTop(rect));
}

inkInline bool inkRectIsEmpty(inkRect rect)
{
	return (rect.size.width <= 0.0f || rect.size.height <= 0.0f);
}

inkInline bool inkRectIsEqual(inkRect rectA, inkRect rectB)
{
	return inkPointIsEqual(rectA.origin, rectB.origin) && inkSizeIsEqual(rectA.size, rectB.size);
}

inkInline inkRect inkRectInflate(inkRect rect, inkPoint point)
{
	rect.origin = inkPointSubtract(rect.origin, point);
	rect.size = inkSizeFromPoint(inkPointAdd(inkPointFromSize(rect.size), inkPointScale(point, 2.0f)));
	return rect;
}

inkInline inkRect inkRectInflatef(inkRect rect, float dx, float dy)
{
	return inkRectInflate(rect, inkPointMake(dx, dy));
}

inkInline inkRect inkRectOffset(inkRect rect, inkPoint point)
{
	rect.origin = inkPointAdd(rect.origin, point);
	return rect;
}

inkInline inkRect inkRectOffsetf(inkRect rect, float dx, float dy)
{
	return inkRectOffset(rect, inkPointMake(dx, dy));
}

inkInline inkRect inkRectStandardize(inkRect rect)
{
	if (rect.size.width < 0.0f)
	{
		rect.origin.x += rect.size.width;
		rect.size.width = -rect.size.width;
	}

	if (rect.size.height < 0.0f)
	{
		rect.origin.y += rect.size.height;
		rect.size.height = -rect.size.height;
	}

	return rect;
}

#pragma mark -
#pragma mark Box Declarations
#pragma mark -

inkInline inkBox inkBoxMake(inkPoint pointA, inkPoint pointB, inkPoint pointC, inkPoint pointD)
{
	inkBox box;

	box.pointA = pointA;
	box.pointB = pointB;
	box.pointC = pointC;
	box.pointD = pointD;

	return box;
}

inkInline inkBox inkBoxMakef(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
{
	return inkBoxMake(inkPointMake(x1, y1), inkPointMake(x2, y2), inkPointMake(x3, y3), inkPointMake(x4, y4));
}

inkInline inkBox inkBoxFromRect(inkRect rect)
{
	return inkBoxMake(rect.origin, inkPointAdd(rect.origin, inkPointMake(rect.size.width, 0)), inkPointAdd(rect.origin, inkPointFromSize(rect.size)), inkPointAdd(rect.origin, inkPointMake(0, rect.size.height)));
}

inkInline bool inkBoxIsEqual(inkBox boxA, inkBox boxB)
{
	return inkPointIsEqual(boxA.pointA, boxB.pointA) && inkPointIsEqual(boxA.pointB, boxB.pointB) && inkPointIsEqual(boxA.pointC, boxB.pointC) && inkPointIsEqual(boxA.pointD, boxB.pointD);
}

inkInline inkBox inkBoxConcat(inkBox boxA, inkBox boxB)
{
	return inkBoxMake(boxA.pointA, boxB.pointB, boxB.pointC, boxA.pointD);
}

#pragma mark -
#pragma mark Matrix Implemenations
#pragma mark -

inkInline inkMatrix inkMatrixMake(float a, float b, float c, float d, float tx, float ty)
{
	inkMatrix matrix;

	matrix.a = a;
	matrix.b = b;
	matrix.c = c;
	matrix.d = d;
	matrix.tx = tx;
	matrix.ty = ty;

	return matrix;
}

inkInline inkMatrix inkMatrixInvert(inkMatrix matrix)
{
	float denom = (matrix.a * matrix.d - matrix.b * matrix.c);

	if (inkIsZerof(denom))
	{
		return inkMatrixIdentity;
	}

	float invBottom = 1.0f / denom;

	return inkMatrixMake(  matrix.d * invBottom,
						  -matrix.b * invBottom,
						  -matrix.c * invBottom,
						   matrix.a * invBottom,
						  (matrix.c * matrix.ty - matrix.d * matrix.tx) * invBottom,
						 -(matrix.a * matrix.ty - matrix.b * matrix.tx) * invBottom);
}

inkInline inkMatrix inkMatrixRotate(inkMatrix matrix, float angle)
{
	float sinVal = sinf(angle);
	float cosVal = cosf(angle);

	return inkMatrixMake(matrix.a * cosVal - matrix.b * sinVal,
						 matrix.a * sinVal + matrix.b * cosVal,
						 matrix.c * cosVal - matrix.d * sinVal,
						 matrix.c * sinVal + matrix.d * cosVal,
						 matrix.tx * cosVal - matrix.ty * sinVal,
						 matrix.tx * sinVal + matrix.ty * cosVal);
}

inkInline float inkMatrixRotation(inkMatrix matrix)
{
	inkPoint transformPoint = inkMatrixDeltaTransformPoint(matrix, inkPointMake(1.0f, 0.0f));
	return inkPointAngle(inkPointZero, transformPoint);
}

inkInline inkSize inkMatrixSize(inkMatrix matrix)
{
	float angle = inkMatrixRotation(matrix);
	matrix = inkMatrixRotate(matrix, -angle);
	return inkSizeMake(matrix.a, matrix.d);
}

inkInline inkMatrix inkMatrixScale(inkMatrix matrix, inkSize scale)
{
	return inkMatrixMake(matrix.a * scale.width, matrix.b, matrix.c, matrix.d * scale.height, matrix.tx * scale.width, matrix.ty * scale.height);
}

inkInline inkMatrix inkMatrixScalef(inkMatrix matrix, float sx, float sy)
{
	return inkMatrixScale(matrix, inkSizeMake(sx, sy));
}

inkInline inkMatrix inkMatrixTranslate(inkMatrix matrix, inkPoint offset)
{
	return inkMatrixMake(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx + offset.x, matrix.ty + offset.y);
}

inkInline inkMatrix inkMatrixTranslatef(inkMatrix matrix, float dx, float dy)
{
	return inkMatrixTranslate(matrix, inkPointMake(dx, dy));
}

inkInline inkMatrix inkMatrixMultiply(inkMatrix matrixA, inkMatrix matrixB)
{
	return inkMatrixMake(matrixA.a * matrixB.a + matrixA.b * matrixB.c,
						 matrixA.a * matrixB.b + matrixA.b * matrixB.d,
						 matrixA.c * matrixB.a + matrixA.d * matrixB.c,
						 matrixA.c * matrixB.b + matrixA.d * matrixB.d,
						 matrixA.tx * matrixB.a + matrixA.ty * matrixB.c + matrixB.tx,
						 matrixA.tx * matrixB.b + matrixA.ty * matrixB.d + matrixB.ty);
}
	
inkInline inkPoint inkMatrixTransformPoint(inkMatrix matrix, inkPoint point)
{
	return inkPointMake((point.x * matrix.a) + (point.y * matrix.c) + matrix.tx,
						(point.x * matrix.b) + (point.y * matrix.d) + matrix.ty);
}

inkInline inkPoint inkMatrixDeltaTransformPoint(inkMatrix matrix, inkPoint point)
{
	return inkPointMake((point.x * matrix.a) + (point.y * matrix.c),
						(point.x * matrix.b) + (point.y * matrix.d));
}

#ifdef __cplusplus
}
#endif

#endif
