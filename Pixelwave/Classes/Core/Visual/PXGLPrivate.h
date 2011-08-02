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

#ifndef _PX_GL_PRIVATE_H_
#define _PX_GL_PRIVATE_H_
	
#ifdef __cplusplus
extern "C" {
#endif
	
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

#include "PXGLUtils.h"
#include "PXGLState.h"

void PXGLInit(unsigned width, unsigned height, float scaleFactor);
void PXGLDealloc();

void PXGLFlush();
//GLuint PXGLGetTextureBuffer();
void PXGLSyncPXToGL();
void PXGLSyncGLToPX();

void PXGLSyncTransforms();
void PXGLUnSyncTransforms();

void PXGLPreRender();
void PXGLPostRender();
void PXGLConsolidateBuffers();

void PXGLResetStates(PXGLState desiredState);

void PXGLClipRect(GLint x, GLint y, GLint width, GLint height);
PXGLAABB *PXGLGetCurrentAABB( );
void PXGLResetAABB(bool setToClipRect);
bool PXGLIsAABBVisible(PXGLAABB *aabb);

void PXGLAABBMult(PXGLAABB *aabb);

//void PXGLGetAbsoluteColorTransform(PXGLColorTransform *transform);
//void PXGLSetAbsoluteColorTransform(PXGLColorTransform *transform);

void PXGLSetViewSize(unsigned width, unsigned height, float scaleFactor, bool orientationEnabled);

#ifdef __cplusplus
}
#endif

#endif
