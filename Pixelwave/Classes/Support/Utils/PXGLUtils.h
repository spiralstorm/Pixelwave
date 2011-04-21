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

#ifndef _PX_GL_UTILS_H_
#define _PX_GL_UTILS_H_

#ifdef __cplusplus
extern "C" {
#endif

#import "PXHeaderUtils.h"

#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
#include <CoreGraphics/CGGeometry.h>

#pragma mark -
#pragma mark Structs
#pragma mark -

typedef struct
{
	GLfloat x, y;
} PXGLVertex; //8 - bytes

typedef struct
{
	GLfloat x, y;
	GLubyte r, g, b, a;    //12 - bytes
} PXGLColorVertex;

typedef struct
{
	GLfloat x, y;
	GLfloat s, t;
} PXGLTextureVertex; //16 - bytes

typedef struct
{
	GLfloat x, y;
	GLubyte r, g, b, a;
	GLfloat s, t;
} PXGLColoredTextureVertex; //20 - bytes

typedef struct
{
	GLfloat a, b, c, d;
	GLfloat tx, ty;
} PXGLMatrix; //24 - bytes

typedef struct
{
	GLfloat redMultiplier;
	GLfloat greenMultiplier;
	GLfloat blueMultiplier;
	GLfloat alphaMultiplier;
} PXGLColorTransform; // 16 - bytes

typedef struct
{
	GLint xMin;
	GLint yMin;
	GLint xMax;
	GLint yMax; // 16 - bytes
} PXGLAABB;

typedef struct
{
	GLfloat xMin;
	GLfloat yMin;
	GLfloat xMax;
	GLfloat yMax; // 16 - bytes
} PXGLAABBf;

typedef struct
{
	PXGLVertex *vertices;
	GLuint vertexCount;

	GLubyte r, g, b, a;
} PXGLColorVertices; // 12 - bytes

typedef struct
{
	GLint x;
	GLint y;
	GLint width;
	GLint height;
} _PXGLRect;

typedef PXGLColorVertices* PXGLColorVerticesRef;

#pragma mark -
#pragma mark Make Functions
#pragma mark -

PXInline_h PXGLVertex PXGLVertexMake(GLfloat x, GLfloat y);
PXInline_h PXGLColorVertex PXGLColorVertexMake(GLfloat x, GLfloat y, GLubyte r, GLubyte g, GLubyte b, GLubyte a);
PXInline_h PXGLTextureVertex PXGLTextureVertexMake(GLfloat x, GLfloat y, GLfloat s, GLfloat t);
PXInline_h PXGLColoredTextureVertex PXGLColoredTextureVertexMake(GLfloat x, GLfloat y, GLubyte r, GLubyte g, GLubyte b, GLubyte a, GLfloat s, GLfloat t);
PXInline_h PXGLMatrix PXGLMatrixMake(GLfloat a, GLfloat b, GLfloat c, GLfloat d, GLfloat tx, GLfloat ty);
PXInline_h PXGLColorTransform PXGLColorTransformMake(GLfloat redMultiplier, GLfloat greenMultiplier, GLfloat blueMultiplier, GLfloat alphaMultiplier);
PXInline_h PXGLAABB PXGLAABBMake(GLint xMin, GLint yMin, GLint xMax, GLint yMax);
PXInline_h PXGLAABBf PXGLAABBfMakeWithInit();
PXInline_h PXGLAABBf PXGLAABBfMake(GLfloat xMin, GLfloat yMin, GLfloat xMax, GLfloat yMax);

PXInline_h PXGLColorVerticesRef PXGLColorVerticesRefMake(GLuint vertexCount, GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
PXInline_h void PXGLColorVerticesRefFree(PXGLColorVertices* ref);
PXInline_h PXGLColorVertices PXGLColorVerticesMake(GLuint vertexCount, GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
PXInline_h void PXGLColorVerticesFree(PXGLColorVertices *colorVertices);

#pragma mark -
#pragma mark AABB Functions
#pragma mark -

extern const PXGLAABB PXGLAABBReset;
PXInline_h void PXGLAABBUpdate(PXGLAABB *toBeUpdated, PXGLAABB *checkVals);
PXInline_h void PXGLAABBExpand(PXGLAABB *aabb, CGPoint point);
PXInline_h void PXGLAABBExpandv(PXGLAABB *aabb, GLint x, GLint y);
PXInline_h void PXGLAABBInflate(PXGLAABB *aabb, CGPoint point);
PXInline_h void PXGLAABBInflatev(PXGLAABB *aabb, GLint x, GLint y);
PXInline_h bool PXGLAABBIsReset(PXGLAABB *aabb);
PXInline_h bool PXGLAABBContainsPoint(PXGLAABB *aabb, CGPoint point);
PXInline_h bool PXGLAABBContainsPointv(PXGLAABB *aabb, GLint x, GLint y);
PXInline_h bool PXGLAABBIsEqual(PXGLAABB *aabb1, PXGLAABB *aabb2);

extern const PXGLAABBf PXGLAABBfReset;
PXInline_h void PXGLAABBfUpdate(PXGLAABBf *toBeUpdated, PXGLAABBf *checkVals);
PXInline_h void PXGLAABBfExpand(PXGLAABBf *aabb, CGPoint point);
PXInline_h void PXGLAABBfExpandv(PXGLAABBf *aabb, GLfloat x, GLfloat y);
PXInline_h void PXGLAABBfInflate(PXGLAABBf *aabb, CGPoint point);
PXInline_h void PXGLAABBfInflatev(PXGLAABBf *aabb, GLfloat x, GLfloat y);
PXInline_h bool PXGLAABBfIsReset(PXGLAABBf *aabb);
PXInline_h bool PXGLAABBfContainsPoint(PXGLAABBf *aabb, CGPoint point);
PXInline_h bool PXGLAABBfContainsPointv(PXGLAABBf *aabb, GLfloat x, GLfloat y);
PXInline_h bool PXGLAABBfIsEqual(PXGLAABBf *aabb1, PXGLAABBf *aabb2);

#pragma mark -
#pragma mark Matrix Functions
#pragma mark -

PXInline_h CGPoint PXGLMatrixConvertPoint(PXGLMatrix *matrix, CGPoint point);
PXInline_h void PXGLMatrixConvertPointv(PXGLMatrix *matrix, GLfloat *x, GLfloat *y);
PXInline_h void PXGLMatrixConvertPoints(PXGLMatrix *matrix, CGPoint *points, GLuint count);
PXInline_h void PXGLMatrixConvertPointsv(PXGLMatrix *matrix, GLfloat *xs, GLfloat *ys, GLuint count);
PXInline_h void PXGLMatrixConvert4Points(PXGLMatrix *matrix, CGPoint *point0, CGPoint *point1, CGPoint *point2, CGPoint *point3);
PXInline_h void PXGLMatrixConvert4Pointsv(PXGLMatrix *matrix, GLfloat *x0, GLfloat *y0, GLfloat *x1, GLfloat *y1, GLfloat *x2, GLfloat *y2, GLfloat *x3, GLfloat *y3);
PXInline_h CGRect PXGLMatrixConvertRect(PXGLMatrix *matrix, CGRect rect);
PXInline_h void PXGLMatrixConvertRectv(PXGLMatrix *matrix, GLfloat *x, GLfloat *y, GLfloat *width, GLfloat *height);
PXInline_h PXGLAABB PXGLMatrixConvertAABB(PXGLMatrix *matrix, PXGLAABB aabb);
PXInline_h void PXGLMatrixConvertAABBv(PXGLMatrix *matrix, GLint *xMin, GLint *yMin, GLint *xMax, GLint *yMax);
PXInline_h PXGLAABBf PXGLMatrixConvertAABBf(PXGLMatrix *matrix, PXGLAABBf aabb);
PXInline_h void PXGLMatrixConvertAABBfv(PXGLMatrix *matrix, GLfloat *xMin, GLfloat *yMin, GLfloat *xMax, GLfloat *yMax);

#pragma mark -
#pragma mark Rect Functions
#pragma mark -

PXInline_h bool _PXGLRectContainsAABB(_PXGLRect *rect, PXGLAABB *aabb);

#ifdef __cplusplus
}
#endif

#endif
