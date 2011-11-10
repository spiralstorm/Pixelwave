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
	inkPoint origin;
	inkSize size;
} inkRect;

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
#define _inkSizeZero {0.0f, 0.0f}
#define _inkRectZero {0.0f, 0.0f}
#define _inkMatrixIdentity {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f}

static inkExtern const inkPoint inkPointZero;
static inkExtern const inkSize inkSizeZero;
static inkExtern const inkRect inkRectZero;
static inkExtern const inkMatrix inkMatrixIdentity;

#pragma mark -
#pragma mark Point Declarations
#pragma mark -

inkExtern inkInline inkPoint inkPointMake(float x, float y);
/*inkExtern inkPoint inkAddPoint(inkPoint pointA, inkPoint pointB);
inkExtern inkPoint inkSubtractPoint(inkPoint pointA, inkPoint pointB);

inkExtern bool inkPointIsEqual(inkPoint pointA, inkPoint pointB);

inkExtern inkPoint inkPointNormalize(inkPoint point);
inkExtern inkPoint inkPointNormalizeWithLength(inkPoint point, float length);
inkExtern inkPoint inkPointOffset(inkPoint point, float dx, float dy);

inkExtern float inkPointLength(inkPoint point);

inkExtern float inkPointDistance(inkPoint pointA, inkPoint pointB);
inkExtern float inkPointAngle(inkPoint pointA, inkPoint pointB);

inkExtern inkPoint inkPointInterpolation(inkPoint pointA, inkPoint pointB, float coefficient);
inkExtern inkPoint inkPointPolar(float length, float angle);*/

#pragma mark -
#pragma mark Size Declarations
#pragma mark -

inkExtern inkInline inkSize inkSizeMake(float width, float height);

//inkExtern bool inkSizeIsEqual(inkSize sizeA, inkSize sizeB);

#pragma mark -
#pragma mark Rect Declarations
#pragma mark -

inkExtern inkInline inkRect inkRectMake(float x, float y, float width, float height);

/*inkExtern float inkRectTop(inkRect rect);
inkExtern float inkRectBottom(inkRect rect);
inkExtern float inkRectLeft(inkRect rect);
inkExtern float inkRectRight(inkRect rect);

inkExtern inkPoint inkRectBottomRight(inkRect rect);
inkExtern inkPoint inkRectTopLeft(inkRect rect);

inkExtern bool inkRectContains(inkRect rect, float x, float y);
inkExtern bool inkRectContainsPoint(inkRect rect, inkPoint point);
inkExtern bool inkRectContainsRect(inkRect rectA, inkRect rectB);
inkExtern bool inkRectIsEmpty(inkRect rect);

inkExtern bool inkRectIntersects(inkRect rectA, inkRect rectB);

inkExtern inkRect inkRectInflate(inkRect rect, float dx, float dy);
inkExtern inkRect inkRectInflateWithPoint(inkRect rect, inkPoint point);
inkExtern inkRect inkRectOffset(float dx, float dy);
inkExtern inkRect inkRectOffsetWithPoint(inkRect rect, inkPoint point);

inkExtern inkRect inkRectIntersection(inkRect rectA, inkRect rectB);
inkExtern inkRect inkRectUnion(inkRect rectA, inkRect rectB);*/

#pragma mark -
#pragma mark Matrix Declaration
#pragma mark -

inkExtern inkInline inkMatrix inkMatrixMake(float a, float b, float c, float d, float tx, float ty);

/*inkExtern inkMatrix inkMatrixConcat(inkMatrix matrixA, inkMatrix matrixB);
inkExtern inkMatrix inkMatrixInvert(inkMatrix matrix);
inkExtern inkMatrix inkMatrixRotate(inkMatrix matrix, float angle);
inkExtern inkMatrix inkMatrixScale(inkMatrix matrix, float sx, float sy);
inkExtern inkMatrix inkMatrixTranslate(inkMatrix matrix, float dx, float dy);

inkExtern inkMatrix inkMatrixCreateBox(inkMatrix matrix, float scaleX, float scaleY, float rotation, float tx, float ty);

inkExtern inkPoint inkMatrixTransformPoint(inkMatrix matrix, inkPoint point);
inkExtern inkPoint inkMatrixDeltaTransformPoint(inkMatrix matrix, inkPoint point);*/

#pragma mark -
#pragma mark Point Implemenations
#pragma mark -

inkExtern inkInline inkPoint inkPointMake(float x, float y)
{
	inkPoint point;

	point.x = x;
	point.y = y;

	return point;
}

#pragma mark -
#pragma mark Size Implemenations
#pragma mark -

inkExtern inkInline inkSize inkSizeMake(float width, float height)
{
	inkSize size;

	size.width = width;
	size.height = height;

	return size;
}

#pragma mark -
#pragma mark Rect Implemenations
#pragma mark -

inkExtern inkInline inkRect inkRectMake(float x, float y, float width, float height)
{
	inkRect rect;

	rect.origin = inkPointMake(x, y);
	rect.size = inkSizeMake(width, height);

	return rect;
}

#pragma mark -
#pragma mark Matrix Implemenations
#pragma mark -

inkExtern inkInline inkMatrix inkMatrixMake(float a, float b, float c, float d, float tx, float ty)
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

#endif
