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

#import "PXGLUtils.h"

#import "PXMathUtils.h"

#define PXGLAABBResetMin INT_MAX
#define PXGLAABBResetMax INT_MIN

#define PXGLAABBfResetMin MAXFLOAT
#define PXGLAABBfResetMax (-MAXFLOAT)

const PXGLAABB PXGLAABBReset = {PXGLAABBResetMin, PXGLAABBResetMin, PXGLAABBResetMax, PXGLAABBResetMax};
const PXGLAABBf PXGLAABBfReset = {PXGLAABBfResetMin, PXGLAABBfResetMin, PXGLAABBfResetMax, PXGLAABBfResetMax};

#pragma mark -
#pragma mark Make Functions
#pragma mark -

PXInline_c PXGLVertex PXGLVertexMake(GLfloat x, GLfloat y)
{
	PXGLVertex retVal;

	retVal.x = x;
	retVal.y = y;

	return retVal;
}
PXInline_c PXGLColorVertex PXGLColorVertexMake(GLfloat x, GLfloat y,
												GLubyte r, GLubyte g, GLubyte b, GLubyte a)
{
	PXGLColorVertex retVal;

	retVal.x = x;
	retVal.y = y;
	retVal.r = r;
	retVal.g = g;
	retVal.b = b;
	retVal.a = a;

	return retVal;
}
PXInline_c PXGLTextureVertex PXGLTextureVertexMake(GLfloat x, GLfloat y,
													GLfloat s, GLfloat t)
{
	PXGLTextureVertex retVal;

	retVal.x = x;
	retVal.y = y;
	retVal.s = s;
	retVal.t = t;

	return retVal;
}
PXInline_c PXGLColoredTextureVertex PXGLColoredTextureVertexMake(GLfloat x, GLfloat y,
																  GLubyte r, GLubyte g, GLubyte b, GLubyte a,
																  GLfloat s, GLfloat t)
{
	PXGLColoredTextureVertex retVal;

	retVal.x = x;
	retVal.y = y;
	retVal.r = r;
	retVal.g = g;
	retVal.b = b;
	retVal.a = a;
	retVal.s = s;
	retVal.t = t;

	return retVal;
}
PXInline_c PXGLMatrix PXGLMatrixMake(GLfloat a, GLfloat b,
									  GLfloat c, GLfloat d,
									  GLfloat tx, GLfloat ty)
{
	PXGLMatrix retVal;

	retVal.a = a;
	retVal.b = b;
	retVal.c = c;
	retVal.d = d;
	retVal.tx = tx;
	retVal.ty = ty;

	return retVal;
}
PXInline_c PXGLColorTransform PXGLColorTransformMake(GLfloat redMultiplier,
													  GLfloat greenMultiplier,
													  GLfloat blueMultiplier,
													  GLfloat alphaMultiplier)
{
	PXGLColorTransform retVal;

	retVal.redMultiplier   = redMultiplier;
	retVal.greenMultiplier = greenMultiplier;
	retVal.blueMultiplier  = blueMultiplier;
	retVal.alphaMultiplier = alphaMultiplier;

	return retVal;
}
PXInline_c PXGLAABB PXGLAABBMake(GLint xMin,
							 GLint yMin,
							 GLint xMax,
							 GLint yMax)
{
	PXGLAABB retVal;

	retVal.xMin = xMin;
	retVal.yMin = yMin;
	retVal.xMax = xMax;
	retVal.yMax = yMax;

	return retVal;
}

PXInline_c PXGLAABBf PXGLAABBfMake(GLfloat xMin,
							   GLfloat yMin,
							   GLfloat xMax,
							   GLfloat yMax)
{
	PXGLAABBf retVal;

	retVal.xMin = xMin;
	retVal.yMin = yMin;
	retVal.xMax = xMax;
	retVal.yMax = yMax;

	return retVal;
}

PXInline_c PXGLColorVerticesRef PXGLColorVerticesRefMake(unsigned vertexCount,
													 unsigned char red,
													 unsigned char green,
													 unsigned char blue,
													 unsigned char alpha)
{
	PXGLColorVerticesRef ref = calloc(1, sizeof(PXGLColorVertices));

	if (ref)
	{
		if (vertexCount > 0)
		{
			ref->vertices = calloc(vertexCount, sizeof(PXGLVertex));
			if (ref->vertices)
				ref->vertexCount = vertexCount;
		}
		// Else is taken care of by calloc...

		ref->r = red;
		ref->g = green;
		ref->b = blue;
		ref->a = alpha;
	}

	return ref;
}
PXInline_c void PXGLColorVerticesRefFree(PXGLColorVertices * ref)
{
	if (ref)
	{
		if (ref->vertices)
		{
			free(ref->vertices);
			ref->vertices = 0;
			ref->vertexCount = 0;
		}

		free(ref);
	}
}

PXInline_c PXGLColorVertices PXGLColorVerticesMake(unsigned vertexCount,
											   unsigned char red,
											   unsigned char green,
											   unsigned char blue,
											   unsigned char alpha)
{
	PXGLColorVertices ref;

	if (vertexCount > 0)
	{
		ref.vertices = calloc(vertexCount, sizeof(PXGLVertex));
		if (ref.vertices)
			ref.vertexCount = vertexCount;
	}
	else
	{
		ref.vertices = 0;
		ref.vertexCount = 0;
	}

	ref.r = red;
	ref.g = green;
	ref.b = blue;
	ref.a = alpha;

	return ref;
}
PXInline_c void PXGLColorVerticesFree(PXGLColorVertices *colorVertices)
{
	if (colorVertices)
	{
		if (colorVertices->vertices)
		{
			free(colorVertices->vertices);
			colorVertices->vertices = 0;
		}

		colorVertices->vertexCount = 0;
	}
}

#pragma mark -
#pragma mark AABB Functions
#pragma mark -

/*PXInline_c PXGLAABB PXGLAABBReset()
{
	return PXGLAABBMake(PXGLAABBResetMin, PXGLAABBResetMin, PXGLAABBResetMax, PXGLAABBResetMax);
}*/
PXInline_c void PXGLAABBUpdate(PXGLAABB *toBeUpdated, PXGLAABB *checkVals)
{
	*toBeUpdated = PXGLAABBMake(MIN(toBeUpdated->xMin, checkVals->xMin),
								MIN(toBeUpdated->yMin, checkVals->yMin),
								MAX(toBeUpdated->xMax, checkVals->xMax),
								MAX(toBeUpdated->yMax, checkVals->yMax));
}
PXInline_c void PXGLAABBExpand(PXGLAABB *aabb, CGPoint point)
{
	return PXGLAABBExpandv(aabb, roundf(point.x), roundf(point.y));
}
PXInline_c void PXGLAABBExpandv(PXGLAABB *aabb, GLint x, GLint y)
{
	*aabb = PXGLAABBMake(MIN(aabb->xMin, x),
						 MIN(aabb->yMin, y),
						 MAX(aabb->xMax, x),
						 MAX(aabb->yMax, y));
}
PXInline_c void PXGLAABBInflate(PXGLAABB *aabb, CGPoint point)
{
	return PXGLAABBInflatev(aabb, roundf(point.x), roundf(point.y));
}
PXInline_c void PXGLAABBInflatev(PXGLAABB *aabb, GLint x, GLint y)
{
	aabb->xMin -= x;
	aabb->yMin -= y;
	aabb->xMax += x;
	aabb->yMax += y;
}
PXInline_c bool PXGLAABBIsReset(PXGLAABB *aabb)
{
	return (aabb->xMin == PXGLAABBResetMin ||
			aabb->yMin == PXGLAABBResetMin ||
			aabb->xMax == PXGLAABBResetMax ||
			aabb->yMax == PXGLAABBResetMax);
}
PXInline_c bool PXGLAABBContainsPoint(PXGLAABB *aabb, CGPoint point)
{
	return PXGLAABBContainsPointv(aabb, (GLint)(point.x), (GLint)(point.y));
}
PXInline_c bool PXGLAABBContainsPointv(PXGLAABB *aabb, GLint x, GLint y)
{
	return ((x >= aabb->xMin) &&
			(x <= aabb->xMax) &&
			(y >= aabb->yMin) &&
			(y <= aabb->yMax));
}
PXInline_c bool PXGLAABBIsEqual(PXGLAABB *aabb1, PXGLAABB *aabb2)
{
	return (aabb1->xMin == aabb2->xMin &&
			aabb1->yMin == aabb2->yMin &&
			aabb1->xMax == aabb2->xMax &&
			aabb1->yMax == aabb2->yMax);
}

#pragma mark -
#pragma mark AABBf Functions
#pragma mark -

//PXInline_c PXGLAABBf PXGLAABBfReset()
//{
//	return PXGLAABBfMake(PXGLAABBfResetMin, PXGLAABBfResetMin, PXGLAABBfResetMax, PXGLAABBfResetMax);
//}
PXInline_c void PXGLAABBfUpdate(PXGLAABBf *toBeUpdated, PXGLAABBf *checkVals)
{
	*toBeUpdated = PXGLAABBfMake(MIN(toBeUpdated->xMin, checkVals->xMin),
								 MIN(toBeUpdated->yMin, checkVals->yMin),
								 MAX(toBeUpdated->xMax, checkVals->xMax),
								 MAX(toBeUpdated->yMax, checkVals->yMax));
}
PXInline_c void PXGLAABBfExpand(PXGLAABBf *aabb, CGPoint point)
{
	return PXGLAABBfExpandv(aabb, point.x, point.y);
}
PXInline_c void PXGLAABBfExpandv(PXGLAABBf *aabb, GLfloat x, GLfloat y)
{
	*aabb = PXGLAABBfMake(MIN(aabb->xMin, x),
						  MIN(aabb->yMin, y),
						  MAX(aabb->xMax, x),
						  MAX(aabb->yMax, y));
}
PXInline_c void PXGLAABBfInflate(PXGLAABBf *aabb, CGPoint point)
{
	return PXGLAABBfInflatev(aabb, point.x, point.y);
}
PXInline_c void PXGLAABBfInflatev(PXGLAABBf *aabb, GLfloat x, GLfloat y)
{
	aabb->xMin -= x;
	aabb->yMin -= y;
	aabb->xMax += x;
	aabb->yMax += y;
}
PXInline_c bool PXGLAABBfIsReset(PXGLAABBf *aabb)
{
	return (PXMathIsEqual(aabb->xMin, PXGLAABBfResetMin) ||
			PXMathIsEqual(aabb->xMin, PXGLAABBfResetMin) ||
			PXMathIsEqual(aabb->xMax, PXGLAABBfResetMax) ||
			PXMathIsEqual(aabb->xMax, PXGLAABBfResetMax));
}
PXInline_c bool PXGLAABBfContainsPoint(PXGLAABBf *aabb, CGPoint point)
{
	return PXGLAABBfContainsPointv(aabb, point.x, point.y);
}
PXInline_c bool PXGLAABBfContainsPointv(PXGLAABBf *aabb, GLfloat x, GLfloat y)
{
	return ((x >= aabb->xMin) &&
			(x <= aabb->xMax) &&
			(y >= aabb->yMin) &&
			(y <= aabb->yMax));
}
PXInline_c bool PXGLAABBfIsEqual(PXGLAABBf *aabb1, PXGLAABBf *aabb2)
{
	return (PXMathIsEqual(aabb1->xMin, aabb2->xMin) &&
			PXMathIsEqual(aabb1->xMin, aabb2->yMin) &&
			PXMathIsEqual(aabb1->xMax, aabb2->xMax) &&
			PXMathIsEqual(aabb1->xMax, aabb2->yMax));
}

#pragma mark -
#pragma mark Matrix Functions
#pragma mark -

PXInline_c CGPoint PXGLMatrixConvertPoint(PXGLMatrix *matrix,
									  CGPoint point)
{
	CGPoint retVal = point;

	PXGLMatrixConvertPointv(matrix, &(retVal.x), &(retVal.y));

	return retVal;
}
PXInline_c void PXGLMatrixConvertPointv(PXGLMatrix *matrix,
									float *x,
									float *y)
{
	float _x = *x;
	float _y = *y;

	*x = (_x * matrix->a) + (_y * matrix->c) + matrix->tx;
	*y = (_x * matrix->b) + (_y * matrix->d) + matrix->ty;
}
PXInline_c void PXGLMatrixConvertPoints(PXGLMatrix *matrix,
									CGPoint *points,
									unsigned count)
{
	CGPoint *point;
	unsigned index;

	for (index = 0, point = points; index < count; ++index, ++point)
	{
		PXGLMatrixConvertPointv(matrix, &(point->x), &(point->y));
	}
}
PXInline_c void PXGLMatrixConvertPointsv(PXGLMatrix *matrix,
									 float *xs,
									 float *ys,
									 unsigned count)
{
	float *curX;
	float *curY;
	unsigned index;

	for (index = 0, curX = xs, curY = ys; index < count; ++curX, ++curY)
	{
		PXGLMatrixConvertPointv(matrix, curX, curY);
	}
}
PXInline_c void PXGLMatrixConvert4Points(PXGLMatrix *matrix,
									 CGPoint *point0,
									 CGPoint *point1,
									 CGPoint *point2,
									 CGPoint *point3)
{
	PXGLMatrixConvertPointv(matrix, &(point0->x), &(point0->y));
	PXGLMatrixConvertPointv(matrix, &(point1->x), &(point1->y));
	PXGLMatrixConvertPointv(matrix, &(point2->x), &(point2->y));
	PXGLMatrixConvertPointv(matrix, &(point3->x), &(point3->y));
}
PXInline_c void PXGLMatrixConvert4Pointsv(PXGLMatrix *matrix,
									  float *x0, float *y0,
									  float *x1, float *y1,
									  float *x2, float *y2,
									  float *x3, float *y3)
{
	
	PXGLMatrixConvertPointv(matrix, x0, y0);
	PXGLMatrixConvertPointv(matrix, x1, y1);
	PXGLMatrixConvertPointv(matrix, x2, y2);
	PXGLMatrixConvertPointv(matrix, x3, y3);
}
PXInline_c CGRect PXGLMatrixConvertRect(PXGLMatrix *matrix,
									CGRect rect)
{
	CGRect retVal = rect;

	PXGLMatrixConvertRectv(matrix,
						   &(retVal.origin.x),   &(retVal.origin.y),
						   &(retVal.size.width), &(retVal.size.height));

	return retVal;
}
PXInline_c void PXGLMatrixConvertRectv(PXGLMatrix *matrix,
								   float *x, float *y,
								   float *width, float *height)
{
	PXGLAABBf aabb = PXGLAABBfMake(*x, *y, *x + *width, *y + *height);

	aabb = PXGLMatrixConvertAABBf(matrix, aabb);

	*x = aabb.xMin;
	*y = aabb.yMin;
	*width  = aabb.xMax - aabb.xMin;
	*height = aabb.yMax - aabb.yMin;
}

PXInline_c PXGLAABB PXGLMatrixConvertAABB(PXGLMatrix *matrix, PXGLAABB aabb)
{
	PXGLAABB retVal = aabb;

	PXGLMatrixConvertAABBv(matrix,
							(&(retVal.xMin)),
							(&(retVal.yMin)),
							(&(retVal.xMax)),
							(&(retVal.yMax)));

	return retVal;
}
PXInline_c void PXGLMatrixConvertAABBv(PXGLMatrix *matrix,
								   GLint *xMin, GLint *yMin,
								   GLint *xMax, GLint *yMax)
{
	float xMinf = *xMin;
	float yMinf = *yMin;
	float xMaxf = *xMax;
	float yMaxf = *yMax;

	PXGLMatrixConvertAABBfv(matrix, &xMinf, &yMinf, &xMaxf, &yMaxf);

	*xMin = floorf(xMinf);
	*yMin = floorf(yMinf);
	*xMax = ceilf(xMaxf);
	*yMax = ceilf(yMaxf);
}

PXInline_c PXGLAABBf PXGLMatrixConvertAABBf(PXGLMatrix *matrix, PXGLAABBf aabb)
{
	PXGLAABBf retVal = aabb;

	PXGLMatrixConvertAABBfv(matrix,
							&(retVal.xMin), &(retVal.yMin),
							&(retVal.xMax), &(retVal.yMax));

	return retVal;
}
PXInline_c void PXGLMatrixConvertAABBfv(PXGLMatrix *matrix,
									GLfloat *xMin, GLfloat *yMin,
									GLfloat *xMax, GLfloat *yMax)
{
	CGPoint p1 = CGPointMake(*xMin, *yMin);
	CGPoint p2 = CGPointMake(*xMax, *yMin);
	CGPoint p3 = CGPointMake(*xMin, *yMax);
	CGPoint p4 = CGPointMake(*xMax, *yMax);

	PXGLMatrixConvert4Points(matrix, &p1, &p2, &p3, &p4);

	*xMin = fminf(p1.x, fminf(p2.x, fminf(p3.x, p4.x)));
	*yMin = fminf(p1.y, fminf(p2.y, fminf(p3.y, p4.y)));
	*xMax = fmaxf(p1.x, fmaxf(p2.x, fmaxf(p3.x, p4.x)));
	*yMax = fmaxf(p1.y, fmaxf(p2.y, fmaxf(p3.y, p4.y)));
}

#pragma mark -
#pragma mark Rect Functions
#pragma mark -

PXInline_c bool _PXGLRectContainsAABB(_PXGLRect *rect, PXGLAABB *aabb)
{
	// If max is less then, or min is greater then, then it is out of bounds.
	if (aabb->xMax < rect->x ||
		aabb->yMax < rect->y ||
		aabb->xMin > rect->x + rect->width ||
		aabb->yMin > rect->y + rect->height)
	{
		return NO;
	}

	return YES;
}
