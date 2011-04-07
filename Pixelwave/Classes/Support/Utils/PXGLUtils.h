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

#import "PXPrivateUtils.h"

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

PX_INLINE_H PXGLVertex PXGLVertexMake(GLfloat x, GLfloat y);
PX_INLINE_H PXGLColorVertex PXGLColorVertexMake(GLfloat x, GLfloat y, GLubyte r, GLubyte g, GLubyte b, GLubyte a);
PX_INLINE_H PXGLTextureVertex PXGLTextureVertexMake(GLfloat x, GLfloat y, GLfloat s, GLfloat t);
PX_INLINE_H PXGLColoredTextureVertex PXGLColoredTextureVertexMake(GLfloat x, GLfloat y, GLubyte r, GLubyte g, GLubyte b, GLubyte a, GLfloat s, GLfloat t);
PX_INLINE_H PXGLMatrix PXGLMatrixMake(GLfloat a, GLfloat b, GLfloat c, GLfloat d, GLfloat tx, GLfloat ty);
PX_INLINE_H PXGLColorTransform PXGLColorTransformMake(GLfloat redMultiplier, GLfloat greenMultiplier, GLfloat blueMultiplier, GLfloat alphaMultiplier);
PX_INLINE_H PXGLAABB PXGLAABBMake(GLint xMin, GLint yMin, GLint xMax, GLint yMax);
PX_INLINE_H PXGLAABBf PXGLAABBfMakeWithInit();
PX_INLINE_H PXGLAABBf PXGLAABBfMake(GLfloat xMin, GLfloat yMin, GLfloat xMax, GLfloat yMax);

PX_INLINE_H PXGLColorVerticesRef PXGLColorVerticesRefMake(GLuint vertexCount, GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
PX_INLINE_H void PXGLColorVerticesRefFree(PXGLColorVertices* ref);
PX_INLINE_H PXGLColorVertices PXGLColorVerticesMake(GLuint vertexCount, GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
PX_INLINE_H void PXGLColorVerticesFree(PXGLColorVertices *colorVertices);

#pragma mark -
#pragma mark AABB Functions
#pragma mark -

extern const PXGLAABB PXGLAABBReset;
PX_INLINE_H void PXGLAABBUpdate(PXGLAABB *toBeUpdated, PXGLAABB *checkVals);
PX_INLINE_H void PXGLAABBExpand(PXGLAABB *aabb, CGPoint point);
PX_INLINE_H void PXGLAABBExpandv(PXGLAABB *aabb, GLint x, GLint y);
PX_INLINE_H void PXGLAABBInflate(PXGLAABB *aabb, CGPoint point);
PX_INLINE_H void PXGLAABBInflatev(PXGLAABB *aabb, GLint x, GLint y);
PX_INLINE_H bool PXGLAABBIsReset(PXGLAABB *aabb);
PX_INLINE_H bool PXGLAABBContainsPoint(PXGLAABB *aabb, CGPoint point);
PX_INLINE_H bool PXGLAABBContainsPointv(PXGLAABB *aabb, GLint x, GLint y);
PX_INLINE_H bool PXGLAABBIsEqual(PXGLAABB *aabb1, PXGLAABB *aabb2);

extern const PXGLAABBf PXGLAABBfReset;
PX_INLINE_H void PXGLAABBfUpdate(PXGLAABBf *toBeUpdated, PXGLAABBf *checkVals);
PX_INLINE_H void PXGLAABBfExpand(PXGLAABBf *aabb, CGPoint point);
PX_INLINE_H void PXGLAABBfExpandv(PXGLAABBf *aabb, GLfloat x, GLfloat y);
PX_INLINE_H void PXGLAABBfInflate(PXGLAABBf *aabb, CGPoint point);
PX_INLINE_H void PXGLAABBfInflatev(PXGLAABBf *aabb, GLfloat x, GLfloat y);
PX_INLINE_H bool PXGLAABBfIsReset(PXGLAABBf *aabb);
PX_INLINE_H bool PXGLAABBfContainsPoint(PXGLAABBf *aabb, CGPoint point);
PX_INLINE_H bool PXGLAABBfContainsPointv(PXGLAABBf *aabb, GLfloat x, GLfloat y);
PX_INLINE_H bool PXGLAABBfIsEqual(PXGLAABBf *aabb1, PXGLAABBf *aabb2);

#pragma mark -
#pragma mark Matrix Functions
#pragma mark -

PX_INLINE_H CGPoint PXGLMatrixConvertPoint(PXGLMatrix *matrix, CGPoint point);
PX_INLINE_H void PXGLMatrixConvertPointv(PXGLMatrix *matrix, GLfloat *x, GLfloat *y);
PX_INLINE_H void PXGLMatrixConvertPoints(PXGLMatrix *matrix, CGPoint *points, GLuint count);
PX_INLINE_H void PXGLMatrixConvertPointsv(PXGLMatrix *matrix, GLfloat *xs, GLfloat *ys, GLuint count);
PX_INLINE_H void PXGLMatrixConvert4Points(PXGLMatrix *matrix, CGPoint *point0, CGPoint *point1, CGPoint *point2, CGPoint *point3);
PX_INLINE_H void PXGLMatrixConvert4Pointsv(PXGLMatrix *matrix, GLfloat *x0, GLfloat *y0, GLfloat *x1, GLfloat *y1, GLfloat *x2, GLfloat *y2, GLfloat *x3, GLfloat *y3);
PX_INLINE_H CGRect PXGLMatrixConvertRect(PXGLMatrix *matrix, CGRect rect);
PX_INLINE_H void PXGLMatrixConvertRectv(PXGLMatrix *matrix, GLfloat *x, GLfloat *y, GLfloat *width, GLfloat *height);
PX_INLINE_H PXGLAABB PXGLMatrixConvertAABB(PXGLMatrix *matrix, PXGLAABB aabb);
PX_INLINE_H void PXGLMatrixConvertAABBv(PXGLMatrix *matrix, GLint *xMin, GLint *yMin, GLint *xMax, GLint *yMax);
PX_INLINE_H PXGLAABBf PXGLMatrixConvertAABBf(PXGLMatrix *matrix, PXGLAABBf aabb);
PX_INLINE_H void PXGLMatrixConvertAABBfv(PXGLMatrix *matrix, GLfloat *xMin, GLfloat *yMin, GLfloat *xMax, GLfloat *yMax);

#pragma mark -
#pragma mark Rect Functions
#pragma mark -

PX_INLINE_H bool _PXGLRectContainsAABB(_PXGLRect *rect, PXGLAABB *aabb);

#ifdef __cplusplus
}
#endif

#endif
