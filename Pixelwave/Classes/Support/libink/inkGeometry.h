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

inkExtern const inkPoint inkPointZero;
inkExtern const inkSize inkSizeZero;
inkExtern const inkRect inkRectZero;
inkExtern const inkMatrix inkMatrixIdentity;

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark -
#pragma mark Point Declarations
#pragma mark -

inkInline inkPoint inkPointMake(float x, float y);
/*inkPoint inkAddPoint(inkPoint pointA, inkPoint pointB);
inkPoint inkSubtractPoint(inkPoint pointA, inkPoint pointB);

bool inkPointIsEqual(inkPoint pointA, inkPoint pointB);

inkPoint inkPointNormalize(inkPoint point);
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

inkPoint inkMatrixTransformPoint(inkMatrix matrix, inkPoint point);
inkPoint inkMatrixDeltaTransformPoint(inkMatrix matrix, inkPoint point);*/

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
