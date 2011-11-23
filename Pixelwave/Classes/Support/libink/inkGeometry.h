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

#define _inkPointZero {0.0f, 0.0f}
#define _inkLineZero {0.0f, 0.0f, 0.0f, 0.0f}
#define _inkSizeZero {0.0f, 0.0f}
#define _inkRectZero {0.0f, 0.0f, 0.0f, 0.0f}
#define _inkBoxZero {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f}
#define _inkMatrixIdentity {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f}

inkExtern const inkPoint inkPointZero;
inkExtern const inkLine inkLineZero;
inkExtern const inkSize inkSizeZero;
inkExtern const inkRect inkRectZero;
inkExtern const inkBox inkBoxZero;
inkExtern const inkMatrix inkMatrixIdentity;

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark -
#pragma mark Math Declarations
#pragma mark -

inkInline bool inkIsNearlyEqualf(float a, float b, float precision);
inkInline bool inkIsEqualf(float a, float b);
inkInline bool inkIsZerof(float a);

#pragma mark -
#pragma mark Point Declarations
#pragma mark -

inkInline inkPoint inkPointMake(float x, float y);

inkInline inkPoint inkPointAdd(inkPoint pointA, inkPoint pointB);
inkInline inkPoint inkPointSubtract(inkPoint pointA, inkPoint pointB);
inkInline inkPoint inkPointNormalize(inkPoint point);
inkInline inkPoint inkPointFromPolar(float length, float angle);
inkInline inkPoint inkPointInterpolate(inkPoint from, inkPoint to, float percent);
inkInline float inkPointAngle(inkPoint pointA, inkPoint pointB);
inkInline float inkPointDistanceFromZero(inkPoint point);
inkInline float inkPointDistance(inkPoint pointA, inkPoint pointB);
inkInline bool inkPointIsEqual(inkPoint pointA, inkPoint pointB);

inkPoint inkClosestPointToLine(inkPoint point, inkLine line);
float inkPointDistanceToLine(inkPoint point, inkLine line);
bool inkIsPointInLine(inkPoint point, inkLine line);

/*inkPoint inkAddPoint(inkPoint pointA, inkPoint pointB);
inkPoint inkSubtractPoint(inkPoint pointA, inkPoint pointB);

bool inkPointIsEqual(inkPoint pointA, inkPoint pointB);

inkPoint inkPointNormalizeWithLength(inkPoint point, float length);
inkPoint inkPointOffset(inkPoint point, float dx, float dy);

float inkPointLength(inkPoint point);

float inkPointDistance(inkPoint pointA, inkPoint pointB);
float inkPointAngle(inkPoint pointA, inkPoint pointB);

inkPoint inkPointInterpolation(inkPoint pointA, inkPoint pointB, float coefficient);
inkPoint inkPointPolar(float length, float angle);*/

#pragma mark -
#pragma mark Size Declarations
#pragma mark -

inkInline inkSize inkSizeMake(float width, float height);

//bool inkSizeIsEqual(inkSize sizeA, inkSize sizeB);

#pragma mark -
#pragma mark Line Declarations
#pragma mark -

inkInline inkLine inkLineMake(inkPoint pointA, inkPoint pointB);
inkInline inkLine inkLineMakev(float x1, float y1, float x2, float y2);

inkPoint inkLineIntersection(inkLine lineA, inkLine lineB);
inkLine inkLineBisectionTraverser(inkLine line, float halfScalar);
inkBox inkLineExpandToBox(inkLine line, float halfScalar);
inkLine inkTriangleBisectionTraverser(inkPoint pointA, inkPoint pointB, inkPoint pointC, float halfScalar);

#pragma mark -
#pragma mark Box Declarations
#pragma mark -

inkInline inkBox inkBoxMake(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4);

#pragma mark -
#pragma mark Rect Declarations
#pragma mark -

inkInline inkRect inkRectMake(float x, float y, float width, float height);

/*float inkRectTop(inkRect rect);
float inkRectBottom(inkRect rect);
float inkRectLeft(inkRect rect);
float inkRectRight(inkRect rect);

inkPoint inkRectBottomRight(inkRect rect);
inkPoint inkRectTopLeft(inkRect rect);

bool inkRectContains(inkRect rect, float x, float y);
bool inkRectContainsPoint(inkRect rect, inkPoint point);
bool inkRectContainsRect(inkRect rectA, inkRect rectB);
bool inkRectIsEmpty(inkRect rect);

bool inkRectIntersects(inkRect rectA, inkRect rectB);

inkRect inkRectInflate(inkRect rect, float dx, float dy);
inkRect inkRectInflateWithPoint(inkRect rect, inkPoint point);
inkRect inkRectOffset(float dx, float dy);
inkRect inkRectOffsetWithPoint(inkRect rect, inkPoint point);

inkRect inkRectIntersection(inkRect rectA, inkRect rectB);
inkRect inkRectUnion(inkRect rectA, inkRect rectB);*/

#pragma mark -
#pragma mark Matrix Declaration
#pragma mark -

inkInline inkMatrix inkMatrixMake(float a, float b, float c, float d, float tx, float ty);

/*inkMatrix inkMatrixConcat(inkMatrix matrixA, inkMatrix matrixB);
inkMatrix inkMatrixInvert(inkMatrix matrix);
inkMatrix inkMatrixRotate(inkMatrix matrix, float angle);
inkMatrix inkMatrixScale(inkMatrix matrix, float sx, float sy);
inkMatrix inkMatrixTranslate(inkMatrix matrix, float dx, float dy);

inkMatrix inkMatrixCreateBox(inkMatrix matrix, float scaleX, float scaleY, float rotation, float tx, float ty);
*/
inkPoint inkMatrixTransformPoint(inkMatrix matrix, inkPoint point);
inkPoint inkMatrixDeltaTransformPoint(inkMatrix matrix, inkPoint point);

#pragma mark -
#pragma mark Math Implemenations
#pragma mark -

inkInline bool inkIsNearlyEqualf(float a, float b, float precision)
{
	return (a <= (b + precision)) && (a >= (b - precision));
}

inkInline bool inkIsEqualf(float a, float b)
{
	// TODO: Replace with math constant for small number
	return inkIsNearlyEqualf(a, b, 0.000001f);
}

inkInline bool inkIsZerof(float a)
{
	return inkIsEqualf(a, 0.0f);
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

inkInline inkPoint inkPointAdd(inkPoint pointA, inkPoint pointB)
{
	return inkPointMake(pointA.x + pointB.x, pointA.y + pointB.y);
}

inkInline inkPoint inkPointSubtract(inkPoint pointA, inkPoint pointB)
{
	return inkPointMake(pointA.x - pointB.x, pointA.y - pointB.y);
}

inkInline inkPoint inkPointNormalize(inkPoint point)
{
	float len = inkPointDistanceFromZero(point);
	
	if (len != 0.0f)
	{
		float one_len = 1.0f / len;
		
		point.x *= one_len;
		point.y *= one_len;
	}
	
	return point;
}

inkInline inkPoint inkPointInterpolate(inkPoint from, inkPoint to, float percent)
{
	return inkPointMake(from.x + (to.x * percent), from.y + (to.y * percent));
}

inkInline float inkPointDistanceFromZero(inkPoint point)
{
	return sqrtf((point.x * point.x) + (point.y * point.y));
}

inkInline float inkPointDistance(inkPoint pointA, inkPoint pointB)
{
	inkPoint diff = inkPointMake(pointA.x - pointB.x, pointA.y - pointB.y);
	
	return sqrtf((diff.x * diff.x) + (diff.y * diff.y));
}

inkInline inkPoint inkPointFromPolar(float length, float angle)
{
	return inkPointMake(cosf(angle) * length, sinf(angle) * length);
}

inkInline float inkPointAngle(inkPoint pointA, inkPoint pointB)
{
	return atan2f(pointB.y - pointA.y, pointB.x - pointA.x);
}

inkInline bool inkPointIsEqual(inkPoint pointA, inkPoint pointB)
{
	return inkIsEqualf(pointA.x, pointB.x) && inkIsEqualf(pointA.y, pointB.y);
}

#pragma mark -
#pragma mark Line Declarations
#pragma mark -

inkInline inkLine inkLineMake(inkPoint pointA, inkPoint pointB)
{
	inkLine line;

	line.pointA = pointA;
	line.pointB = pointB;

	return line;
}

inkInline inkLine inkLineMakev(float x1, float y1, float x2, float y2)
{
	return inkLineMake(inkPointMake(x1, y1), inkPointMake(x2, y2));
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

#pragma mark -
#pragma mark Rect Implemenations
#pragma mark -

inkInline inkRect inkRectMake(float x, float y, float width, float height)
{
	inkRect rect;

	rect.origin = inkPointMake(x, y);
	rect.size = inkSizeMake(width, height);

	return rect;
}

#pragma mark -
#pragma mark Box Declarations
#pragma mark -

inkInline inkBox inkBoxMake(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
{
	inkBox box;

	box.pointA = inkPointMake(x1, y1);
	box.pointB = inkPointMake(x2, y2);
	box.pointC = inkPointMake(x3, y3);
	box.pointD = inkPointMake(x4, y4);

	return box;
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

#ifdef __cplusplus
}
#endif

#endif
