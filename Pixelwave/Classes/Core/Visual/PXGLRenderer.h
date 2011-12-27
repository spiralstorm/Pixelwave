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

#ifndef PX_GL_RENDERER_H
#define PX_GL_RENDERER_H

#include "PXGL.h"
#include "PXHeaderUtils.h"

#include "PXGLState.h"

#define PX_GL_VERTEX_COLOR_RESET 0
#define PX_GL_VERTEX_COLOR_ONE 1
#define PX_GL_VERTEX_COLOR_MULTIPLE 2

#define PXGLElementsType GLushort

extern PXGLState pxGLDefaultState;
extern PXGLState pxGLState;
extern PXGLState pxGLStateInGL;

extern GLuint pxGLBufferVertexColorState;

typedef struct
{
	PXGLColoredTextureVertex *vertex;
	GLfloat *pointSize;
	PXGLElementsType vertexIndex;
} PXGLElementBucket;

void PXGLRendererInit();
void PXGLRendererDealloc();

void PXGLSetDrawMode(GLenum mode);
void PXGLSetBufferLastVertexColor(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
void PXGLEnableColorArray();
void PXGLDisableColorArray();

// TODO Later: Change these to use PXArrayBuffer.
unsigned PXGLGetCurrentVertexIndex();
void PXGLSetCurrentVertexIndex(unsigned int index);
unsigned PXGLGetCurrentIndex();
void PXGLSetCurrentIndex(unsigned int index);
unsigned PXGLGetCurrentPointSizeIndex();
void PXGLSetCurrentPointSizeIndex(unsigned int index);

//PXGLColoredTextureVertex *PXGLNextVertex();
PXGLColoredTextureVertex *PXGLGetVertexAt(unsigned int index);
PXGLColoredTextureVertex *PXGLCurrentVertex();
PXGLColoredTextureVertex *PXGLAskForVertices(unsigned int count);
void PXGLUsedVertices(unsigned int count);

PXGLElementsType *PXGLGetIndexAt(unsigned int index);
PXGLElementsType *PXGLCurrentIndex();
PXGLElementsType *PXGLAskForIndices(unsigned int count);
void PXGLUsedIndices(unsigned int count);

//GLfloat *PXGLNextPointSize();
GLfloat *PXGLGetPointSizeAt(unsigned int index);
GLfloat *PXGLCurrentPointSize();
GLfloat *PXGLAskForPointSizes(unsigned int count);
void PXGLUsedPointSizes(unsigned int count);

PXGLElementBucket *PXGLGetElementBuckets(unsigned int maxBucketVal);

void PXGLRendererPreRender();
void PXGLRendererPostRender();
void PXGLConsolidateBuffer();

void PXGLFlushBuffer();

PXInline_h void PXGLSetupEnables();
PXInline_h int PXGLGetDrawCountThenResetIt();

#endif
