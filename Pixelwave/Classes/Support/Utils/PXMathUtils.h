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

#ifndef _PX_MATH_UTILS_H_
#define _PX_MATH_UTILS_H_

#ifdef __cplusplus
extern "C" {
#endif

#import "PXHeaderUtils.h"

#pragma mark -
#pragma mark Macros
#pragma mark -

static const float pxMath1_3 = 1.0f / 3.0f;
static const float pxMath2_3 = 2.0f / 3.0f;

static const float pxMathPI_180 = M_PI / 180.0f;
static const float pxMath180_PI = 180.0f / M_PI;

#define PX_SMALL_NUM 0.00001f

#define PXMathIsZero(_num_) ((_num_) <= PX_SMALL_NUM && (_num_) >= -PX_SMALL_NUM)
#define PXMathIsOne(_num_) ((_num_) <= (1.0f + PX_SMALL_NUM) && (_num_) >= (1.0f - PX_SMALL_NUM))
#define PXMathIsNearlyEqual(_num1_, _num2_, _tol_) ((_num1_) <= ((_num2_) + _tol_) && (_num1_) >= ((_num2_) - _tol_))
#define PXMathIsEqual(_num1_, _num2_) PXMathIsNearlyEqual(_num1_, _num2_, PX_SMALL_NUM)

#define PXMathToDeg(_rads_) ((_rads_) * pxMath180_PI)
#define PXMathToRad(_degs_) ((_degs_) * pxMathPI_180)

#define PXMathMin(_val1_, _val2_) (((_val1_) < (_val2_)) ? (_val1_) : (_val2_))
#define PXMathMax(_val1_, _val2_) (((_val1_) > (_val2_)) ? (_val1_) : (_val2_))
#define PXMathClamp(_val_, _minVal_, _maxVal_) ((_val_) = ((_val_) = ((_val_) < (_minVal_) ? (_minVal_) : (_val_))) > (_maxVal_) ? (_maxVal_) : (_val_))

#pragma mark -
#pragma mark Structs
#pragma mark -

typedef struct
{
	float min;
	float max;
} PXMathRange;

typedef struct
{
	float x;
	float y;
} PXMathPoint;

typedef struct
{
	PXMathPoint pointA;
	PXMathPoint pointB;
} PXMathLine;

typedef struct
{
	PXMathPoint pointA;
	PXMathPoint pointB;
	PXMathPoint pointC;
} PXMathTriangle;

typedef struct
{
	float x;
	float y;
	float z;
} PXMathPoint3D;

typedef struct
{
	PXMathPoint3D pointA;
	PXMathPoint3D pointB;
} PXMathLine3D;

typedef struct
{
	PXMathPoint3D pointA;
	PXMathPoint3D pointB;
	PXMathPoint3D pointC;
} PXMathTriangle3D;

#pragma mark -
#pragma mark Declerations
#pragma mark -

BOOL PXMathIsNan(float val);

float PXMathRandom();
float PXMathFloatInRange(float min, float max);
int PXMathIntInRange(int min, int max);

void PXMathSeedRandomWithTime();
void PXMathSeedRandomWithValue(unsigned value);

float PXMathLog(float val, float base);

float PXMathLerpf(float start, float end, float percent);
float PXMathContentRoundf(float val);
int32_t PXMathNextPowerOfTwo(int32_t val);
int64_t PXMathNextPowerOfTwo64(int64_t val);

PXInline PXMathRange PXMathRangeMake(float min, float max) PXAlwaysInline;

PXInline PXMathPoint PXMathPointMake(float x, float y) PXAlwaysInline;
PXInline float PXMathPointDot(PXMathPoint point1, PXMathPoint point2) PXAlwaysInline;
PXInline float PXMathPointLen(PXMathPoint point) PXAlwaysInline;
PXInline float PXMathPointLenSq(PXMathPoint point) PXAlwaysInline;
PXInline float PXMathPointDist(PXMathPoint point1, PXMathPoint point2) PXAlwaysInline;
PXInline float PXMathPointDistSq(PXMathPoint point1, PXMathPoint point2) PXAlwaysInline;
PXInline void PXMathPointNorm(PXMathPoint * point) PXAlwaysInline;
PXInline void PXMathPointSet(PXMathPoint *point, float x, float y) PXAlwaysInline;
PXInline PXMathLine PXMathLineMake(float x1, float y1, float x2, float y2) PXAlwaysInline;
PXInline void PXMathLineSet(PXMathLine *line, float x1, float y1, float x2, float y2) PXAlwaysInline;
PXInline PXMathTriangle PXMathTriangleMake(float x1, float y1, float x2, float y2, float x3, float y3) PXAlwaysInline;
PXInline void PXMathTriangleSet(PXMathTriangle *triangle, float x1, float y1, float x2, float y2, float x3, float y3) PXAlwaysInline;

PXInline PXMathPoint3D PXMathPoint3DMake(float x, float y, float z) PXAlwaysInline;
PXInline float PXMathPoint3DDot(PXMathPoint3D point1, PXMathPoint3D point2) PXAlwaysInline;
PXInline float PXMathPoint3DLen(PXMathPoint3D point) PXAlwaysInline;
PXInline float PXMathPoint3DLenSq(PXMathPoint3D point) PXAlwaysInline;
PXInline float PXMathPoint3DDist(PXMathPoint3D point1, PXMathPoint3D point2) PXAlwaysInline;
PXInline float PXMathPoint3DDistSq(PXMathPoint3D point1, PXMathPoint3D point2) PXAlwaysInline;
PXInline PXMathPoint3D PXMathPoint3DCross(PXMathPoint3D point1, PXMathPoint3D point2) PXAlwaysInline;
PXInline void PXMathPoint3DNorm(PXMathPoint3D * point) PXAlwaysInline;
PXInline void PXMathPoint3DSet(PXMathPoint3D *point, float x, float y, float z) PXAlwaysInline;
PXInline PXMathLine3D PXMathLine3DMake(float x1, float y1, float z1, float x2, float y2, float z2) PXAlwaysInline;
PXInline void PXMathLine3DSet(PXMathLine3D *line, float x1, float y1, float z1, float x2, float y2, float z2) PXAlwaysInline;
PXInline PXMathTriangle3D PXMathTriangle3DMake(float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3) PXAlwaysInline;
PXInline void PXMathTriangl3DeSet(PXMathTriangle3D *triangle, float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3) PXAlwaysInline;

float PXMathPointDistanceToLine(PXMathPoint *point, PXMathLine *line );
bool PXMathPointInLine(PXMathPoint *ans, PXMathPoint *point, PXMathLine *line);
bool PXMathIsPointInLine(PXMathPoint *point, PXMathLine *line);
bool PXMathIsPointInTriangle(PXMathPoint *point, PXMathTriangle *triangle);

#pragma mark -
#pragma mark Implementations
#pragma mark -

PXInline PXMathRange PXMathRangeMake(float min, float max)
{
	PXMathRange range;

	range.min = min;
	range.max = max;

	return range;
}

PXInline PXMathPoint PXMathPointMake(float x, float y)
{
	PXMathPoint point;

	point.x = x;
	point.y = y;

	return point;
}
PXInline float PXMathPointDot(PXMathPoint point1, PXMathPoint point2)
{
	return ((point1.x * point2.x) + (point1.y * point2.y));
}
PXInline float PXMathPointLen(PXMathPoint point)
{
	float xSq = point.x * point.x;
	float ySq = point.y * point.y;

	return sqrtf(xSq + ySq);
}
PXInline float PXMathPointLenSq(PXMathPoint point)
{
	float xSq = point.x * point.x;
	float ySq = point.y * point.y;

	return xSq + ySq;
}
PXInline float PXMathPointDist(PXMathPoint point1, PXMathPoint point2)
{
	float xSq = point2.x - point1.x;
	xSq *= xSq;
	float ySq = point2.y - point1.y;
	ySq *= ySq;

	return sqrtf(xSq + ySq);
}
PXInline float PXMathPointDistSq(PXMathPoint point1, PXMathPoint point2)
{
	float xSq = point2.x - point1.x;
	xSq *= xSq;
	float ySq = point2.y - point1.y;
	ySq *= ySq;

	return (xSq + ySq);
}
PXInline void PXMathPointNorm(PXMathPoint *point)
{
	float xSq = point->x * point->x;
	float ySq = point->y * point->y;

	float len = sqrtf(xSq + ySq);

	if (!PXMathIsZero(len))
	{
		float one_len = 1.0f / len;

		point->x *= one_len;
		point->y *= one_len;
	}
}
PXInline void PXMathPointSet(PXMathPoint *point, float x, float y)
{
	point->x = x;
	point->y = y;
}

PXInline PXMathLine PXMathLineMake(float x1, float y1,
								   float x2, float y2)
{
	PXMathLine line;

	line.pointA.x = x1;
	line.pointA.y = y1;
	line.pointB.x = x2;
	line.pointB.y = y2;

	return line;
}

PXInline void PXMathLineSet(PXMathLine *line,
							float x1, float y1,
							float x2, float y2)
{
	line->pointA.x = x1;
	line->pointA.y = y1;
	line->pointB.x = x2;
	line->pointB.y = y2;
}

PXInline PXMathTriangle PXMathTriangleMake(float x1, float y1,
												float x2, float y2,
												float x3, float y3)
{
	PXMathTriangle triangle;

	triangle.pointA.x = x1;
	triangle.pointA.y = y1;
	triangle.pointB.x = x2;
	triangle.pointB.y = y2;
	triangle.pointC.x = x3;
	triangle.pointC.y = y3;

	return triangle;
}

PXInline void PXMathTriangleSet(PXMathTriangle *triangle,
								float x1, float y1,
								float x2, float y2,
								float x3, float y3)
{
	triangle->pointA.x = x1;
	triangle->pointA.y = y1;
	triangle->pointB.x = x2;
	triangle->pointB.y = y2;
	triangle->pointC.x = x3;
	triangle->pointC.y = y3;
}

PXInline PXMathPoint3D PXMathPoint3DMake(float x, float y, float z)
{
	PXMathPoint3D point;

	point.x = x;
	point.y = y;
	point.z = z;

	return point;
}
PXInline float PXMathPoint3DDot(PXMathPoint3D point1, PXMathPoint3D point2)
{
	return ((point1.x * point2.x) + (point1.y * point2.y) + (point1.z * point2.z));
}
PXInline float PXMathPoint3DLen(PXMathPoint3D point)
{
	float xSq = point.x * point.x;
	float ySq = point.y * point.y;
	float zSq = point.z * point.z;

	return sqrtf(xSq + ySq + zSq);
}
PXInline float PXMathPoint3DLenSq(PXMathPoint3D point)
{
	float xSq = point.x * point.x;
	float ySq = point.y * point.y;
	float zSq = point.z * point.z;

	return (xSq + ySq + zSq);
}
PXInline float PXMathPoint3DDist(PXMathPoint3D point1, PXMathPoint3D point2)
{
	float xSq = point2.x - point1.x;
	xSq *= xSq;
	float ySq = point2.y - point1.y;
	ySq *= ySq;
	float zSq = point2.z - point1.z;
	zSq *= zSq;

	return sqrtf(xSq + ySq + zSq);
}
PXInline float PXMathPoint3DDistSq(PXMathPoint3D point1, PXMathPoint3D point2)
{
	float xSq = point2.x - point1.x;
	xSq *= xSq;
	float ySq = point2.y - point1.y;
	ySq *= ySq;
	float zSq = point2.z - point1.z;
	zSq *= zSq;

	return (xSq + ySq + zSq);
}
PXInline PXMathPoint3D PXMathPoint3DCross(PXMathPoint3D point1, PXMathPoint3D point2)
{
	PXMathPoint3D point;

	point.x = (point1.y * point2.z) - (point1.z * point2.y);
	point.y = (point1.z * point2.x) - (point1.x * point2.z);
	point.z = (point1.x * point2.y) - (point1.y * point2.x);

	return point;
}
PXInline void PXMathPoint3DNorm(PXMathPoint3D * point)
{
	float xSq = point->x * point->x;
	float ySq = point->y * point->y;
	float zSq = point->z * point->z;

	float len = sqrtf(xSq + ySq + zSq);

	if (!PXMathIsZero(len))
	{
		float one_len = 1.0f / len;

		point->x *= one_len;
		point->y *= one_len;
		point->z *= one_len;
	}
}
PXInline void PXMathPoint3DSet(PXMathPoint3D *point, float x, float y, float z)
{
	point->x = x;
	point->y = y;
	point->z = z;
}
PXInline PXMathLine3D PXMathLine3DMake(float x1, float y1, float z1,
									   float x2, float y2, float z2)
{
	PXMathLine3D line;

	line.pointA.x = x1;
	line.pointA.y = y1;
	line.pointA.z = z1;

	line.pointB.x = x2;
	line.pointB.y = y2;
	line.pointB.z = z2;

	return line;
}

PXInline void PXMathLine3DSet(PXMathLine3D *line,
								   float x1, float y1, float z1,
								   float x2, float y2, float z2)
{
	line->pointA.x = x1;
	line->pointA.y = y1;
	line->pointA.z = z1;

	line->pointB.x = x2;
	line->pointB.y = y2;
	line->pointB.z = z2;
}

PXInline PXMathTriangle3D PXMathTriangle3DMake(float x1, float y1, float z1,
											   float x2, float y2, float z2,
											   float x3, float y3, float z3)
{
	PXMathTriangle3D triangle;

	triangle.pointA.x = x1;
	triangle.pointA.y = y1;
	triangle.pointA.z = z1;

	triangle.pointB.x = x2;
	triangle.pointB.y = y2;
	triangle.pointB.z = z2;

	triangle.pointC.x = x3;
	triangle.pointC.y = y3;
	triangle.pointC.z = z3;

	return triangle;
}

PXInline void PXMathTriangl3DeSet(PXMathTriangle3D *triangle,
								  float x1, float y1, float z1,
								  float x2, float y2, float z2,
								  float x3, float y3, float z3)
{
	triangle->pointA.x = x1;
	triangle->pointA.y = y1;
	triangle->pointA.z = z1;

	triangle->pointB.x = x2;
	triangle->pointB.y = y2;
	triangle->pointB.z = z2;

	triangle->pointC.x = x3;
	triangle->pointC.y = y3;
	triangle->pointC.z = z3;
}

#ifdef __cplusplus
}
#endif
	
#endif
