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

#include "PXHeaderUtils.h"

#include "inkGL.h"

#include <CoreGraphics/CGGeometry.h>

#ifdef __cplusplus
extern "C" {
#endif

// MARK: -
// MARK: Structs
// MARK: -

typedef struct
{
	GLfloat x, y;
} PXGLVertex; // 8 - bytes

typedef struct
{
	GLfloat x, y;
	GLubyte r, g, b, a;
} PXGLColorVertex; // 12 - bytes

typedef struct
{
	GLfloat x, y;
	GLfloat s, t;
} PXGLTextureVertex; // 16 - bytes

typedef struct
{
	GLfloat x, y;
	GLubyte r, g, b, a;
	GLfloat s, t;
} PXGLColoredTextureVertex; // 20 - bytes

typedef struct
{
	GLfloat a, b, c, d;
	GLfloat tx, ty;
} PXGLMatrix; // 24 - bytes

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
	GLint yMax;
} PXGLAABB; // 16 - bytes

typedef struct
{
	GLfloat xMin;
	GLfloat yMin;
	GLfloat xMax;
	GLfloat yMax;
} PXGLAABBf; // 16 - bytes

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
} _PXGLRect; // 16 - bytes

typedef PXGLColorVertices* PXGLColorVerticesRef;

// MARK: -
// MARK: Make Functions
// MARK: -

PXGLVertex PXGLVertexMake(GLfloat x, GLfloat y);
PXGLColorVertex PXGLColorVertexMake(GLfloat x, GLfloat y, GLubyte r, GLubyte g, GLubyte b, GLubyte a);
PXGLTextureVertex PXGLTextureVertexMake(GLfloat x, GLfloat y, GLfloat s, GLfloat t);
PXGLColoredTextureVertex PXGLColoredTextureVertexMake(GLfloat x, GLfloat y, GLubyte r, GLubyte g, GLubyte b, GLubyte a, GLfloat s, GLfloat t);
PXGLMatrix PXGLMatrixMake(GLfloat a, GLfloat b, GLfloat c, GLfloat d, GLfloat tx, GLfloat ty);
PXGLColorTransform PXGLColorTransformMake(GLfloat redMultiplier, GLfloat greenMultiplier, GLfloat blueMultiplier, GLfloat alphaMultiplier);
PXGLAABB PXGLAABBMake(GLint xMin, GLint yMin, GLint xMax, GLint yMax);
PXGLAABBf PXGLAABBfMakeWithInit();
PXGLAABBf PXGLAABBfMake(GLfloat xMin, GLfloat yMin, GLfloat xMax, GLfloat yMax);

PXGLColorVerticesRef PXGLColorVerticesRefMake(GLuint vertexCount, GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
void PXGLColorVerticesRefFree(PXGLColorVertices* ref);
PXGLColorVertices PXGLColorVerticesMake(GLuint vertexCount, GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
void PXGLColorVerticesFree(PXGLColorVertices *colorVertices);

// MARK: -
// MARK: AABB Functions
// MARK: -

extern const PXGLAABB PXGLAABBReset;
void PXGLAABBUpdate(PXGLAABB *toBeUpdated, PXGLAABB *checkVals);
void PXGLAABBExpand(PXGLAABB *aabb, CGPoint point);
void PXGLAABBExpandv(PXGLAABB *aabb, GLint x, GLint y);
void PXGLAABBInflate(PXGLAABB *aabb, CGPoint point);
void PXGLAABBInflatev(PXGLAABB *aabb, GLint x, GLint y);
bool PXGLAABBIsReset(PXGLAABB *aabb);
bool PXGLAABBContainsPoint(PXGLAABB *aabb, CGPoint point);
bool PXGLAABBContainsPointv(PXGLAABB *aabb, GLint x, GLint y);
bool PXGLAABBIsEqual(PXGLAABB *aabb1, PXGLAABB *aabb2);

extern const PXGLAABBf PXGLAABBfReset;
void PXGLAABBfUpdate(PXGLAABBf *toBeUpdated, PXGLAABBf *checkVals);
void PXGLAABBfExpand(PXGLAABBf *aabb, CGPoint point);
void PXGLAABBfExpandv(PXGLAABBf *aabb, GLfloat x, GLfloat y);
void PXGLAABBfInflate(PXGLAABBf *aabb, CGPoint point);
void PXGLAABBfInflatev(PXGLAABBf *aabb, GLfloat x, GLfloat y);
bool PXGLAABBfIsReset(PXGLAABBf *aabb);
bool PXGLAABBfContainsPoint(PXGLAABBf *aabb, CGPoint point);
bool PXGLAABBfContainsPointv(PXGLAABBf *aabb, GLfloat x, GLfloat y);
bool PXGLAABBfIsEqual(PXGLAABBf *aabb1, PXGLAABBf *aabb2);

// MARK: -
// MARK: Matrix Functions
// MARK: -

CGPoint PXGLMatrixConvertPoint(PXGLMatrix *matrix, CGPoint point);
void PXGLMatrixConvertPointv(PXGLMatrix *matrix, GLfloat *x, GLfloat *y);
void PXGLMatrixConvertPoints(PXGLMatrix *matrix, CGPoint *points, GLuint count);
void PXGLMatrixConvertPointsv(PXGLMatrix *matrix, GLfloat *xs, GLfloat *ys, GLuint count);
void PXGLMatrixConvert4Points(PXGLMatrix *matrix, CGPoint *point0, CGPoint *point1, CGPoint *point2, CGPoint *point3);
void PXGLMatrixConvert4Pointsv(PXGLMatrix *matrix, GLfloat *x0, GLfloat *y0, GLfloat *x1, GLfloat *y1, GLfloat *x2, GLfloat *y2, GLfloat *x3, GLfloat *y3);
CGRect PXGLMatrixConvertRect(PXGLMatrix *matrix, CGRect rect);
void PXGLMatrixConvertRectv(PXGLMatrix *matrix, GLfloat *x, GLfloat *y, GLfloat *width, GLfloat *height);
PXGLAABB PXGLMatrixConvertAABB(PXGLMatrix *matrix, PXGLAABB aabb);
void PXGLMatrixConvertAABBv(PXGLMatrix *matrix, GLint *xMin, GLint *yMin, GLint *xMax, GLint *yMax);
PXGLAABBf PXGLMatrixConvertAABBf(PXGLMatrix *matrix, PXGLAABBf aabb);
void PXGLMatrixConvertAABBfv(PXGLMatrix *matrix, GLfloat *xMin, GLfloat *yMin, GLfloat *xMax, GLfloat *yMax);

bool PXGLMatrixIsEqual(PXGLMatrix *matrixA, PXGLMatrix *matrixB);

// MARK: -
// MARK: Rect Functions
// MARK: -

bool _PXGLRectContainsAABB(_PXGLRect *rect, PXGLAABB *aabb);

#ifdef __cplusplus
}
#endif

#endif
