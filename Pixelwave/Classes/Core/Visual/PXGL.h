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

#ifndef _PX_GL_H_
#define _PX_GL_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "PXGLUtils.h"
#include "PXGLState.h"
#include "PXHeaderUtils.h"

GLfloat PXGLGetContentScaleFactor();
GLfloat PXGLGetOneOverContentScaleFactor();
GLuint PXGLDBGGetRenderCallCount( );

void PXGLBindFramebuffer(GLenum target, GLuint framebuffer);
GLuint PXGLBoundTexture( );

void PXGLBindTexture(GLenum target, GLuint texture);
void PXGLColor4f(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
void PXGLColor4ub(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
void PXGLColorPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);
void PXGLDisable(GLenum cap);
void PXGLDisableClientState(GLenum array);
void PXGLDrawArrays(GLenum mode, GLint first, GLsizei count);
void PXGLDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid *indices);
void PXGLEnable(GLenum cap);
void PXGLEnableClientState(GLenum array);
void PXGLLineWidth(GLfloat width);
void PXGLPointSize(GLfloat size);
void PXGLPointSizePointer(GLenum type, GLsizei stride, const GLvoid *pointer);
void PXGLPopMatrix( );
void PXGLPushMatrix( );
void PXGLTexCoordPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);
void PXGLTexParameteri(GLenum target, GLenum pname, GLint param);
void PXGLVertexPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);

void PXGLShadeModel(GLenum mode);

void PXGLTexEnvf(GLenum target, GLenum pname, GLfloat param);
void PXGLTexEnvi(GLenum target, GLenum pname, GLint param);
void PXGLTexEnvx(GLenum target, GLenum pname, GLfixed param);
void PXGLTexEnvfv(GLenum target, GLenum pname, const GLfloat *params);
void PXGLTexEnviv(GLenum target, GLenum pname, const GLint *params);
void PXGLTexEnvxv(GLenum target, GLenum pname, const GLfixed *params);

void PXGLBlendFunc(GLenum sfactor, GLenum dfactor);

void PXGLPopMatrix( );
void PXGLPushMatrix( );
void PXGLLoadIdentity( );
void PXGLTranslate(GLfloat x, GLfloat y);
void PXGLScale(GLfloat x, GLfloat y);
void PXGLRotate(GLfloat angle);
void PXGLMultMatrix(PXGLMatrix *mat);
void PXGLLoadMatrixToGL( );
void PXGLResetMatrixStack( );

void PXGLPopColorTransform( );
void PXGLPushColorTransform( );
void PXGLLoadColorTransformIdentity( );
void PXGLResetColorTransformStack( );
void PXGLSetColorTransform(PXGLColorTransform *transform);

void PXGLMatrixMult(PXGLMatrix *store, PXGLMatrix *mat1, PXGLMatrix *mat2);
void PXGLMatrixInvert(PXGLMatrix *mat);
void PXGLMatrixIdentity(PXGLMatrix *mat);
void PXGLColorTransformIdentity(PXGLColorTransform *transform);

PXInline_h void PXGLMatrixRotate(PXGLMatrix *mat, GLfloat radians);
PXInline_h void PXGLMatrixScale(PXGLMatrix *mat, GLfloat x, GLfloat y);
PXInline_h void PXGLMatrixTranslate(PXGLMatrix *mat, GLfloat x, GLfloat y);
PXInline_h void PXGLMatrixTransform(PXGLMatrix *mat, GLfloat angle, GLfloat scaleX, GLfloat scaleY, GLfloat x, GLfloat y);

PXInline_h PXGLState _PXGLDefaultState();
PXInline_h void _PXGLStateEnable(PXGLState *state, GLenum cap);
PXInline_h void _PXGLStateDisable(PXGLState *state, GLenum cap);
PXInline_h void _PXGLStateEnableClientState(PXGLState *state, GLenum array);
PXInline_h void _PXGLStateDisableClientState(PXGLState *state, GLenum array);
//PXInline_h void _PXGLStateBindTexture(PXGLState *state, GLuint texture);
PXInline_h void _PXGLStateBlendFunc(PXGLState *state, GLenum sfactor, GLenum dfactor);
PXInline_h bool _PXGLStateIsEnabled(PXGLState *state, GLenum cap);
PXInline_h void _PXGLStateGetIntegerv(PXGLState *state, GLenum pname, GLint *params);

#ifdef __cplusplus
}
#endif

#endif
