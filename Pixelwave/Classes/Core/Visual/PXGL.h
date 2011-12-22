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

#include "PXGLUtils.h"
#include "PXGLState.h"
#include "PXHeaderUtils.h"

PXExtern GLfloat PXGLGetContentScaleFactor();
PXExtern GLfloat PXGLGetOneOverContentScaleFactor();
PXExtern GLuint PXGLDBGGetRenderCallCount();

PXExtern GLuint PXGLBoundTexture();

PXExtern void PXGLBindTexture(GLenum target, GLuint texture);
PXExtern void PXGLColor4f(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
PXExtern void PXGLColor4ub(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
PXExtern void PXGLColorPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);
PXExtern void PXGLDisable(GLenum cap);
PXExtern void PXGLDisableClientState(GLenum array);
PXExtern void PXGLDrawArrays(GLenum mode, GLint first, GLsizei count);
PXExtern void PXGLDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid *indices);
PXExtern void PXGLEnable(GLenum cap);
PXExtern void PXGLEnableClientState(GLenum array);
PXExtern void PXGLLineWidth(GLfloat width);
PXExtern void PXGLPointSize(GLfloat size);
PXExtern void PXGLPointSizePointer(GLenum type, GLsizei stride, const GLvoid *pointer);
PXExtern void PXGLPopMatrix();
PXExtern void PXGLPushMatrix();
PXExtern void PXGLTexCoordPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);
PXExtern void PXGLTexParameteri(GLenum target, GLenum pname, GLint param);
PXExtern void PXGLVertexPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);

PXExtern void PXGLGetBooleanv(GLenum pname, GLboolean *params);
PXExtern void PXGLGetFloatv(GLenum pname, GLfloat *params);
PXExtern void PXGLGetIntegerv(GLenum pname, GLint *params);
PXExtern void PXGLGetTexParameteriv(GLenum target, GLenum pname, GLint *params);

PXExtern void PXGLShadeModel(GLenum mode);

PXExtern void PXGLTexEnvf(GLenum target, GLenum pname, GLfloat param);
PXExtern void PXGLTexEnvi(GLenum target, GLenum pname, GLint param);
PXExtern void PXGLTexEnvx(GLenum target, GLenum pname, GLfixed param);
PXExtern void PXGLTexEnvfv(GLenum target, GLenum pname, const GLfloat *params);
PXExtern void PXGLTexEnviv(GLenum target, GLenum pname, const GLint *params);
PXExtern void PXGLTexEnvxv(GLenum target, GLenum pname, const GLfixed *params);

PXExtern void PXGLBlendFunc(GLenum sfactor, GLenum dfactor);

PXExtern bool PXGLIsEnabled(GLenum cap);

PXExtern void PXGLPopMatrix();
PXExtern void PXGLPushMatrix();
PXExtern void PXGLLoadIdentity();
PXExtern void PXGLTranslate(GLfloat x, GLfloat y);
PXExtern void PXGLScale(GLfloat x, GLfloat y);
PXExtern void PXGLRotate(GLfloat angle);
PXExtern void PXGLMultMatrix(PXGLMatrix *mat);
PXExtern void PXGLLoadMatrixToGL();
PXExtern void PXGLResetMatrixStack();
PXExtern PXGLMatrix PXGLCurrentMatrix();

PXExtern void PXGLPopColorTransform();
PXExtern void PXGLPushColorTransform();
PXExtern void PXGLLoadColorTransformIdentity();
PXExtern void PXGLResetColorTransformStack();
PXExtern void PXGLSetColorTransform(PXGLColorTransform *transform);

PXExtern void PXGLMatrixMult(PXGLMatrix *store, PXGLMatrix *mat1, PXGLMatrix *mat2);
PXExtern void PXGLMatrixInvert(PXGLMatrix *mat);
PXExtern void PXGLMatrixIdentity(PXGLMatrix *mat);
PXExtern void PXGLColorTransformIdentity(PXGLColorTransform *transform);

PXExtern void PXGLMatrixRotate(PXGLMatrix *mat, GLfloat radians);
PXExtern void PXGLMatrixScale(PXGLMatrix *mat, GLfloat x, GLfloat y);
PXExtern void PXGLMatrixTranslate(PXGLMatrix *mat, GLfloat x, GLfloat y);
PXExtern void PXGLMatrixTransform(PXGLMatrix *mat, GLfloat angle, GLfloat scaleX, GLfloat scaleY, GLfloat x, GLfloat y);

PXExtern PXGLState _PXGLDefaultState();
PXExtern void _PXGLStateEnable(PXGLState *state, GLenum cap);
PXExtern void _PXGLStateDisable(PXGLState *state, GLenum cap);
PXExtern void _PXGLStateEnableClientState(PXGLState *state, GLenum array);
PXExtern void _PXGLStateDisableClientState(PXGLState *state, GLenum array);
//PXExtern void _PXGLStateBindTexture(PXGLState *state, GLuint texture);
PXExtern void _PXGLStateBlendFunc(PXGLState *state, GLenum sfactor, GLenum dfactor);
PXExtern bool _PXGLStateIsEnabled(PXGLState *state, GLenum cap);
PXExtern void _PXGLStateGetIntegerv(PXGLState *state, GLenum pname, GLint *params);

#endif
