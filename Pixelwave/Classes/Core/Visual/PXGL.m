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

#include "PXSettings.h"
#include "PXGL.h"
#include "PXGLPrivate.h"
#import "PXGLRenderer.h"
#import "PXGLException.h"

#import "PXPrivateUtils.h"
#import "PXDebugUtils.h"

#import "PXGLUtils.h"
#include "PXGLStatePrivate.h"

#define PX_GL_MATRIX_STACK_SIZE 16
#define PX_GL_COLOR_STACK_SIZE 16

PXInline GLuint PXGLGLStateToPXState(GLenum cap);
PXInline GLenum PXGLPXStateToGLState(GLuint cap);
PXInline GLuint PXGLGLClientStateToPXClientState(GLenum array);
PXInline GLuint PXGLPXClientStateToGLClientState(GLenum array);

PXGLMatrix pxGLMatrices[PX_GL_MATRIX_STACK_SIZE];
PXGLColorTransform pxGLColors[PX_GL_COLOR_STACK_SIZE];

PXGLMatrix *pxGLCurrentMatrix = pxGLMatrices;
PXGLColorTransform *pxGLCurrentColor = pxGLColors;

unsigned short pxGLCurrentMatrixIndex = 0;
unsigned short pxGLCurrentColorIndex = 0;

#ifdef PX_DEBUG_MODE
GLuint pxGLRenderCallCount;
#endif

float pxGLScaleFactor = 1.0f;
float pxGLOne_ScaleFactor = 1.0f;
unsigned pxGLWidthInPoints  = 0;
unsigned pxGLHeightInPoints = 0;

typedef struct
{
	GLint size;
	GLenum type;
	GLsizei stride;
	const GLvoid *pointer;  //Weakly referenced
} _PXGLArrayPointer;

_PXGLRect pxGLRectClip;
PXGLAABB pxGLAABB;

GLfloat pxGLPointSize = 0;
GLfloat pxGLLineWidth = 0;

GLuint pxGLTexture = 0;
GLuint pxGLFramebuffer = 0;

_PXGLArrayPointer pxGLPointSizePointer;
_PXGLArrayPointer pxGLVertexPointer;
_PXGLArrayPointer pxGLColorPointer;
_PXGLArrayPointer pxGLTexCoordPointer;

GLfloat pxGLMatrix[16] =
{
	1.0f, 0.0f, 0.0f, 0.0f,
	0.0f, 1.0f, 0.0f, 0.0f,
	0.0f, 0.0f, 1.0f, 0.0f,
	0.0f, 0.0f, 0.0f, 1.0f
};

GLubyte pxGLRed   = 0xFF;
GLubyte pxGLGreen = 0xFF;
GLubyte pxGLBlue  = 0xFF;
GLubyte pxGLAlpha = 0xFF;

/*
 * This method initializes GL with the width and height given
 *
 * @param width The width of the screen.
 * @param height The height of the screen.
 */
void PXGLInit(unsigned width, unsigned height, float scaleFactor)
{
	PXGLClipRect(0, 0, width, height);

	pxGLPointSizePointer.pointer = NULL;
	pxGLVertexPointer.pointer = NULL;
	pxGLColorPointer.pointer = NULL;
	pxGLTexCoordPointer.pointer = NULL;

	PXGLSetViewSize(width, height, scaleFactor, true);

	pxGLDefaultState.blendSource = GL_SRC_ALPHA;
	pxGLDefaultState.blendDestination = GL_ONE_MINUS_SRC_ALPHA;
	
	glBlendFunc(pxGLDefaultState.blendSource, pxGLDefaultState.blendDestination);
	// TODO: This function should be used to make rendering to texture work
	// better. It doesn't really make a difference when just rendering to the
	// screen. So, glBlendFunc should be replaced by glBlendFuncSeparateOES
	// everywhere. The problem is that glBlendFuncSeparateOES is only available
	// in iOS 3.1 and above. So we need to check if
	// (glBlendFuncSeparateOES != NULL) before calling it. Otherwise,
	// glBlendFunc could just be used.
	//
	// glBlendFuncSeparateOES(pxGLDefaultState.blendSource, pxGLDefaultState.blendDestination,
	//					   GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_LIGHTING);

	// Set defaults
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_POINT_SMOOTH);

	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_POINT_SIZE_ARRAY_OES);

	// Always enabled
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnable(GL_BLEND);

	PX_ENABLE_BIT(pxGLDefaultState.clientState, PX_GL_VERTEX_ARRAY);

	pxGLState = pxGLDefaultState;
	pxGLStateInGL = pxGLDefaultState;

	// Lets load the matrix identity, and color transform identity
	PXGLLoadIdentity( );
	PXGLLoadColorTransformIdentity( );

	// Lets intialize the renderer
	PXGLRendererInit( );

	// and sync up with gl
	PXGLSyncPXToGL( );

	// Lets initialize the color to white
	pxGLRed   = 0xFF;
	pxGLGreen = 0xFF;
	pxGLBlue  = 0xFF;
	pxGLAlpha = 0xFF;

	pxGLCurrentColor->redMultiplier   = 1.0f;
	pxGLCurrentColor->greenMultiplier = 1.0f;
	pxGLCurrentColor->blueMultiplier  = 1.0f;
	pxGLCurrentColor->alphaMultiplier = 1.0f;

	// then reset the aabb
	PXGLResetAABB(false);
}

/*
 * This method flushes the buffer, it is a method in pxgl so that the engine
 * can use it also rather then just pxgl.
 */
void PXGLFlush( )
{
	PXGLFlushBuffer( );
}

/*
 * This method returns the texture id for the render to texture buffer.
 *
 * @return - The texture id for the render to texture buffer.
 */
/*
GLuint PXGLGetTextureBuffer( )
{
	return pxGLRTTFBO;
}
*/

void PXGLSyncPXToGL( )
{
	GLushort changed = false;
	GLshort bVal = 0;

	GLint nVal;
	GLfloat fVals[4];

	//Check texture
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &nVal);
	if (pxGLTexture != nVal)
	{
		changed = true;
		pxGLTexture = nVal;
	}

	//Check color
	glGetFloatv(GL_CURRENT_COLOR, fVals);
	bVal = PX_COLOR_BYTE_TO_FLOAT(fVals[0]);
	if (pxGLRed != bVal)
	{
		changed = true; pxGLRed = bVal;
	}

	bVal = PX_COLOR_BYTE_TO_FLOAT(fVals[1]);
	if (pxGLGreen != bVal)
	{
		changed = true; pxGLGreen = bVal;
	}

	bVal = PX_COLOR_BYTE_TO_FLOAT(fVals[2]);
	if (pxGLBlue != bVal)
	{
		changed = true; pxGLBlue = bVal;
	}

	bVal = PX_COLOR_BYTE_TO_FLOAT(fVals[3]);
	if (pxGLAlpha != bVal)
	{
		changed = true; pxGLAlpha = bVal;
	}

	//Check line width
	glGetFloatv(GL_LINE_WIDTH, fVals);
	if (pxGLLineWidth != fVals[0])
	{
		changed = true;
		pxGLLineWidth = fVals[0];
	}

	//Check point size
	glGetFloatv(GL_POINT_SIZE, fVals);
	if (pxGLPointSize != fVals[0])
	{
		changed = true;
		pxGLPointSize = fVals[0];
	}

	//Check color type, reason for doing this is that we don't want anyone to
	//start batching with the wrong type.
	if (!changed)
	{
		//Keep this in the if statement so we might not have to do it.
		glGetIntegerv(GL_COLOR_ARRAY_TYPE, &nVal);
		if (pxGLColorPointer.type != nVal)
			changed = true;
	}

	//Check color type, reason for doing this is that we don't want anyone to
	//start batching with the wrong type.
	if (!changed)
	{
		//Keep this in the if statement so we might not have to do it.
		glGetIntegerv(GL_VERTEX_ARRAY_TYPE, &nVal);
		if (pxGLVertexPointer.type != nVal)
			changed = true;
	}

	//Check color type, reason for doing this is that we don't want anyone to
	//start batching with the wrong type.
	if (!changed)
	{
		//Keep this in the if statement so we might not have to do it.
		glGetIntegerv(GL_TEXTURE_COORD_ARRAY_TYPE, &nVal);
		if (pxGLTexCoordPointer.type != nVal)
			changed = true;
	}

	//Check color type, reason for doing this is that we don't want anyone to
	//start batching with the wrong type.
	if (!changed)
	{
		//Keep this in the if statement so we might not have to do it.
		glGetIntegerv(GL_POINT_SIZE_ARRAY_TYPE_OES, &nVal);
		if (pxGLPointSizePointer.type != nVal)
			changed = true;
	}

	//We need to check the texture parameters now...

	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &nVal);
	if (pxGLFramebuffer != nVal)
	{
		pxGLFramebuffer = nVal;
		changed = true;
	}

	//If any of our values have changed, then we should flush the buffer
	if (changed)
		PXGLFlushBuffer( );
}

/*
 * This method syncs up a server side state; this will set the gl state to
 * whatever state we are currently using.
 *
 * @param GLenum cap - The gl server state you wish to sync with.
 */
void PXGLSyncState(GLenum cap)
{
	GLuint state = PXGLGLStateToPXState(cap);

	if (PX_IS_BIT_ENABLED(pxGLStateInGL.state, state))
		glEnable(cap);
	else
		glDisable(cap);
}

/*
 * This method syncs up a client side state; this will set the gl state to
 * whatever state we are currently using.
 *
 * @param GLenum cap - The gl client state you wish to sync with.
 */
void PXGLSyncClientState(GLenum array)
{
	GLuint state = PXGLGLClientStateToPXClientState(array);

	if (PX_IS_BIT_ENABLED(pxGLStateInGL.clientState, state))
		glEnableClientState(array);
	else
		glDisableClientState(array);
}

/*
 * This method synchronizes each of the gl states with our states; meaning if
 * we are using GL_TEXTURE_2D, then we will turn that on in GL.  This does both
 * client and server states.
 */
void PXGLSyncGLToPX( )
{
	// Lets make sure vertex array is on... we do wish to draw stuff after all.
	glEnableClientState(GL_VERTEX_ARRAY);

	// Lets synchronize the rest of our states,
	PXGLSyncState(GL_POINT_SPRITE_OES);
	PXGLSyncState(GL_TEXTURE_2D);
	PXGLSyncState(GL_POINT_SMOOTH);
	PXGLSyncState(GL_LINE_SMOOTH);
	PXGLSyncClientState(GL_TEXTURE_COORD_ARRAY);
	PXGLSyncClientState(GL_POINT_SIZE_ARRAY_OES);

	// Bind the texture, color, line width and point size we are currently using,
	glBindTexture(GL_TEXTURE_2D, pxGLTexture);
	glColor4ub(pxGLRed, pxGLGreen, pxGLBlue, pxGLAlpha);
	glLineWidth(pxGLLineWidth);
	glPointSize(pxGLPointSize);

	glBindFramebufferOES(GL_FRAMEBUFFER_OES, pxGLFramebuffer);

	//and enable the color array.
	PXGLEnableColorArray( );
	glEnableClientState(GL_COLOR_ARRAY);

	if (PX_IS_BIT_ENABLED(pxGLStateInGL.state, PX_GL_SHADE_MODEL_FLAT))
		glShadeModel(GL_FLAT);
	else
		glShadeModel(GL_SMOOTH);
}

void PXGLSyncTransforms()
{
	glPushMatrix( );
	PXGLLoadMatrixToGL( );

	glColor4ub(pxGLRed, pxGLGreen, pxGLBlue, pxGLAlpha);
}
void PXGLUnSyncTransforms()
{
	// We don't do anything with the color, as the engine takes care of that
	// upon rendering.

	// Pops the matrix which was pushed in sync transforms above.
	glPopMatrix();
}

/*
 * This method frees any of the memory we were using, and releases the render
 * to texture.. texture.
 */
void PXGLDealloc( )
{
	PXGLRendererDealloc( );
}

/*
 * This method prepairs both PXGL and GL for rendering.
 */
void PXGLPreRender( )
{
	//Lets reset the color transform, and matrix stacks... so they are reaady to
	//be used by another render cycle.
	PXGLResetColorTransformStack( );
	PXGLResetMatrixStack( );

	glPushMatrix( );
	glLoadIdentity( );
	//glTranslatef(100.0f, -0.0f, 0.0f);
	PXGLRendererPreRender( );
}

/*
 * This method finishes both PXGL and GL rendering cycle (flushing the buffer,
 * etc.).
 */
void PXGLPostRender( )
{
	PXGLRendererPostRender( );
	glPopMatrix( );

#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_CountGLCalls))
	{
		pxGLRenderCallCount = PXGLGetDrawCountThenResetIt();
	}
#endif
}

/*
 * This method consolidates the buffers; meaning it reduces the buffers down to
 * reasonable sizes if they are overly large and the data they are containing
 * is small.
 */
void PXGLConsolidateBuffers( )
{
	PXGLConsolidateBuffer( );
}

GLfloat PXGLGetContentScaleFactor()
{
	return pxGLScaleFactor;
}
GLfloat PXGLGetOneOverContentScaleFactor()
{
	return pxGLOne_ScaleFactor;
}
GLuint PXGLDBGGetRenderCallCount( )
{
#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_CountGLCalls))
	{
		return pxGLRenderCallCount;
	}
#endif

	return 0;
}

/*
 * PXGLBindFramebuffer lets you create or use a named framebuffer object.
 * Calling PXGLBindFramebuffer with target set to GL_FRAMEBUFFER and
 * framebuffer set to the name of the new framebuffer object binds the
 * framebuffer object name.  When a framebuffer object is bound, the previous
 * binding is automatically broken.
 *
 * PXGLBindFramebuffer does a check to see if the buffer you are binding has
 * the same name as the one that is currently bound, if it is then it does not
 * change the buffer; this is done to help stop redundant gl state changes.
 *
 * @param GLenum target - Specifies the target to which the framebuffer object
 * is bound.  The symbolic constraint must be GL_FRAMEBUFFER.
 * @param GLuint framebuffer - Specifies the name of a framebuffer object.
 */
void PXGLBindFramebuffer(GLenum target, GLuint framebuffer)
{
	if (target != GL_FRAMEBUFFER_OES || pxGLFramebuffer == framebuffer)
		return;

	PXGLFlushBuffer( );

	pxGLFramebuffer = framebuffer;
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, pxGLFramebuffer);
}

/*
 * PXGLClipRect sets a bounding area where objects can be drawn.  If an object
 * has any point within this area, it will be drawn, however if all of it's
 * points are outside, then it will not be.  This does not mean that the object
 * itself will be clipped, therefore if an object has only 1 point inside, all
 * of the other points (even outside of the clipped area) will still be drawn.
 *
 * @param GLint x - The x starting position of the clipping area.
 * @param GLint y - The y starting position of the clipping area.
 * @param GLint width - The width of the clipping area.
 * @param GLint height - The height of the clipping area.
 */
void PXGLClipRect(GLint x, GLint y, GLint width, GLint height)
{
	pxGLRectClip.x = x;
	pxGLRectClip.y = y;
	pxGLRectClip.width = width;
	pxGLRectClip.height = height;
}

/*
 * PXGLGetCurrentAABB returns a pointer to a axis-aligned bounding box that
 * defines an object the object that was most recently drawn.
 *
 * @return PXGLAABB * - A pointer to the axis-aligned bounding box that
 * represents the object that was most recently drawn.
 */
PXGLAABB *PXGLGetCurrentAABB( )
{
	return &pxGLAABB;
}

/*
 * PXGLResetAABB resets the current axis-aligned bounding box to the max and
 * min values, thus ready to be modified.
 */
void PXGLResetAABB(bool setToClipRect)
{
	if (setToClipRect)
	{
		pxGLAABB.xMin = pxGLRectClip.x;
		pxGLAABB.yMin = pxGLRectClip.y;
		pxGLAABB.xMax = pxGLRectClip.x + pxGLRectClip.width;
		pxGLAABB.yMax = pxGLRectClip.y + pxGLRectClip.height;
	}
	else
	{
		pxGLAABB.xMin = INT_MAX;
		pxGLAABB.yMin = INT_MAX;
		pxGLAABB.xMax = INT_MIN;
		pxGLAABB.yMax = INT_MIN;
	}
}

/*
 * PXGLIsAABBVisible returns true when the axis-aligned bounding box given is
 * within the clip rect defined by PXGLClipRect.
 *
 * @param PXGLAABB * aabb - The axis-aligned bounding box to be checked.
 *
 * @return bool - true if any portion of the axis-aligned bounding box is
 * within the clipping rectangle.
 */
bool PXGLIsAABBVisible(PXGLAABB *aabb)
{
	if (aabb->xMin > (pxGLRectClip.x + pxGLRectClip.width))
		return false;

	if (aabb->yMin > (pxGLRectClip.y + pxGLRectClip.height))
		return false;

	if (aabb->xMax < pxGLRectClip.x)
		return false;

	if (aabb->yMax < pxGLRectClip.y)
		return false;

	return true;
}

/*
 * PXGLBoundTexture returns the currently bound texture to gl.
 *
 * @return GLuint - The currently bound texture to gl.
 */
GLuint PXGLBoundTexture( )
{
	return pxGLTexture;
}

/*
 * PXGLBindTexture lets you create or use a named texture. Calling
 * PXGLBindTexture with target set to GL_TEXTURE_2D, and texture set to the
 * name of the new texture binds the texture name to the target. When a texture
 * is bound to a target, the previous binding for that target is automatically
 * broken.
 *
 * If the texture you are binding is already bound or the target is not
 * GL_TEXTURE_2D, then this method just returns.
 *
 * @param GLenum target - Specifies the target to which the texture is bound.
 * Must be GL_TEXTURE_2D.
 * @param GLuint texture - Specifies the name of a texture.
 */
void PXGLBindTexture(GLenum target, GLuint texture)
{
	if (target != GL_TEXTURE_2D || pxGLTexture == texture)
		return;

	PXGLFlushBuffer( );
	pxGLTexture = texture;
	glBindTexture(target, texture);
}

/*
 * PXGLColor4f sets a new four-valued current RGBA color.  Current color values
 * are stored in bytes, thus it is more efficent to call PXGLColor4ub.
 *
 * PXGLColor4f does a check to see if the color you are setting has is the same
 * as the one that is currently set, if it is then it does not set the color;
 * this is done to help stop redundant gl state changes.
 *
 * @param GLfloat red   - The red value for the current color.
 * @param GLfloat green - The green value for the current color.
 * @param GLfloat blue  - The blue value for the current color.
 * @param GLfloat alpha - The alpha value for the current color.
 */
void PXGLColor4f(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
{
	PXGLColor4ub(PX_COLOR_FLOAT_TO_BYTE(red),
	             PX_COLOR_FLOAT_TO_BYTE(green),
	             PX_COLOR_FLOAT_TO_BYTE(blue),
	             PX_COLOR_FLOAT_TO_BYTE(alpha));
}

/*
 * PXGLColor4ub sets a new four-valued current RGBA color.  Current color values
 * are stored in bytes.
 *
 * PXGLColor4ub does a check to see if the color you are setting has is the
 * same as the one that is currently set, if it is then it does not set the
 * color; this is done to help stop redundant gl state changes.
 *
 * @param GLfloat red   - The red value for the current color.
 * @param GLfloat green - The green value for the current color.
 * @param GLfloat blue  - The blue value for the current color.
 * @param GLfloat alpha - The alpha value for the current color.
 */
void PXGLColor4ub(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha)
{
	// Lets convert the color to inherit properties from the parents.
	red   *= pxGLCurrentColor->redMultiplier;
	green *= pxGLCurrentColor->greenMultiplier;
	blue  *= pxGLCurrentColor->blueMultiplier;
	alpha *= pxGLCurrentColor->alphaMultiplier;

	// If we are already using this color, then lets just return as no change to
	// gl needs to occur.
	if (red == pxGLRed && green == pxGLGreen && blue == pxGLBlue && alpha == pxGLAlpha)
		return;

	// If we are not usiong our color method, then lets break the buffer as we
	// actually need to change gl.

	pxGLRed   = red;
	pxGLGreen = green;
	pxGLBlue  = blue;
	pxGLAlpha = alpha;
}

/*
 * This method sets the gl state, if that state is not already on.  This is a
 * pre check before sending the data to the hardware so that unnecessary
 * synchronization doesn't occur as we handle all of the states locally.
 *
 * PXGLEnable does a check to see if the GL capability you are enabeling is
 * currently enabled, if it is then it does not enable the state again; this is
 * done to help stop redundant gl state changes.
 *
 * @param GLenum cap - Specifies a symbolic constant indicating a GL capability
 */
void PXGLEnable(GLenum cap)
{
	GLuint state = PXGLGLStateToPXState(cap);

	PX_ENABLE_BIT(pxGLState.state, state);
}

/*
 * This method sets the gl client state, if that state is not already on.  This
 * is a pre check before sending the data to the hardware so that unnecessary
 * synchronization doesn't occur as we handle all of the states locally.
 *
 * PXGLEnableClientState does a check to see if the GL capability you are
 * enabeling is currently enabled, if it is then it does not enable the state
 * again; this is done to help stop redundant gl state changes.
 *
 * @param GLenum array - Specifies the capability to enable or disable.
 * Symbolic constants GL_COLOR_ARRAY, GL_POINT_SIZE_ARRAY_OES,
 * GL_TEXTURE_COORD_ARRAY are accepted.
 */
void PXGLEnableClientState(GLenum array)
{
	// If we are using our color array method, then we don't actually want to
	// enable the color array here, we just wish to know that the user wants to;
	// thus we are also not breaking the batch.

	// Lets convert the client state from gl to ours, so we can check it
	// properly
	GLuint state = PXGLGLClientStateToPXClientState(array);

	PX_ENABLE_BIT(pxGLState.clientState, state);
}

/*
 * This method disables the gl state, if that state is not already disabled.
 * This is a pre check before sending the data to the hardware so that
 * unnecessary synchronization doesn't occur as we handle all of the states
 * locally.
 *
 * PXGLDisable does a check to see if the GL capability you are dosabling is
 * currently disabled, if it is then it does not disable the state again;
 * this is done to help stop redundant gl state changes.
 *
 * @param GLenum cap - Specifies a symbolic constant indicating a GL capability
 */
void PXGLDisable(GLenum cap)
{
	// Lets convert the client state from gl to ours, so we can check it
	// properly
	GLuint state = PXGLGLStateToPXState(cap);

	PX_DISABLE_BIT(pxGLState.state, state);
}

/*
 * This method disables the gl client state, if that state is not already
 * disabled.  This is a pre check before sending the data to the hardware so
 * that unnecessary synchronization doesn't occur as we handle all of the
 * states locally.
 *
 * PXGLDisableClientState does a check to see if the GL capability you are
 * disabling is currently disabled, if it is then it does not disable the state
 * again; this is done to help stop redundant gl state changes.
 *
 * @param GLenum cap - Specifies a symbolic constant indicating a GL capability
 */
void PXGLDisableClientState(GLenum array)
{
	// If we are using our color array method, then we don't actually want to
	// disable the color array here, we just wish to know that the user wants
	// to; thus we are also not breaking the batch.

	// Lets convert the client state from gl to ours, so we can check it
	// properly
	GLuint state = PXGLGLClientStateToPXClientState(array);

	PX_DISABLE_BIT(pxGLState.clientState, state);
}

/*
 * Texture mapping is a technique that applies an image onto an object's
 * surface as if the image were a decal or cellophane shrink-wrap.  The image
 * is created in texture space, with an (s, t) coordinate system. A texture is
 * a one- or two-dimensional image and a set of parameters that determine how
 * samples are derived from the image.
 *
 * PXGLTexParameter assigns the value in param or params to the texture
 * parameter specified as pname.  target defines the target texture, which must
 * be GL_TEXTURE_2D.
 *
 * @param GLenum target Specifies the target texture, which must be GL_TEXTURE_2D.
 * @param GLenum pname Specifies the symbolic name of a single-valued texture parameter. Which
 * can be one of the following: GL_TEXTURE_MIN_FILTER,
 * GL_TEXTURE_MAG_FILTER, GL_TEXTURE_WRAP_S, or GL_TEXTURE_WRAP_T.
 * @param GLint param Specifies the value of pname.
 */
void PXGLTexParameteri(GLenum target, GLenum pname, GLint param)
{
	// If the value has changed, we need to flush the buffer before changing it.
	PXGLFlushBuffer( );

	// then update gl.
	glTexParameteri(target, pname, param);
}

/*
 * PXGLLineWidth specifies the rasterized width of both aliased and antialiased
 * lines. Using a line width other than 1 has different effects, depending on
 * whether line antialiasing is enabled. To enable and disable line
 * antialiasing, call PXGLEnable and PXGLDisable with argument GL_LINE_SMOOTH.
 * Line antialiasing is initially disabled.
 *
 * PXGLLineWidth does a check to see if the width you are setting is currently
 * set, if it is then it does not set the width again; this is done to help
 * stop redundant gl calls.
 *
 * @param GLfloat width - Specifies the width of rasterized lines. The initial
 * value is 1.
 */
void PXGLLineWidth(GLfloat width)
{
	width *= pxGLScaleFactor;

	// If the line width is already equal to the width given, then we do not
	// need to set it in gl.
	if (pxGLLineWidth == width)
		return;

	//Lets flush the buffer, as we do not know what is yet to come, and need to
	//have the buffer use the current gl state rather then the chagned one.
	PXGLFlushBuffer( );
	pxGLLineWidth = width;

	//Lets actually change the gl state.
	glLineWidth(width);
}

/*
 * PXGLPointSize specifies the rasterized diameter of both aliased and
 * antialiased points. Using a point size other than 1 has different effects,
 * depending on whether point antialiasing is enabled. To enable and disable
 * point antialiasing, call PXGLEnable and PXGLDisable with argument
 * GL_POINT_SMOOTH. Point antialiasing is initially disabled.
 *
 * PXGLPointSize does a check to see if the size you are setting is currently
 * set, if it is then it does not set the size again; this is done to help stop
 * redundant gl calls.
 *
 * @param GLfloat size - Specifies the diameter of rasterized points. The
 * initial value is 1.
 */
void PXGLPointSize(GLfloat size)
{
	size *= pxGLScaleFactor;

	if (pxGLPointSize == size)
		return;

	// Lets flush the buffer, as we do not know what is yet to come, and need to
	// have the buffer use the current gl state rather then the chagned one.
	PXGLFlushBuffer( );
	pxGLPointSize = size;

	// Lets actually change the gl state.
	glPointSize(size);
}

/*
 * PXGLColorPointer specifies the location and data of an array of color
 * components to use when rendering.  size specifies the number of components
 * per color, and must be 4.  type specifies the data type of each color
 * component, and stride specifies the byte stride from one color to the next
 * allowing vertices and attributes to be packed into a single array or stored
 * in separate arrays. (Single-array storage may be more efficient on some
 * implementations).
 *
 * @param GLint size - Specifies the number of coordinates per array element.
 * Must be 4.
 * @param GLenum type - Specifies the data type of each texture coordinate.
 * Must be GL_UNSIGNED_BYTE.
 * @param GLsizei stride - Specifies the byte offset between consecutive array
 * elements. If stride is 0, the array elements are understood to be tightly
 * packed. The initial value is 0.
 * @param GLvoid * pointer - Specifies a pointer to the first coordinate of the
 * first element in the array. The initial value is 0.
 */
void PXGLColorPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
{
	assert(type == GL_UNSIGNED_BYTE);
	//We actually store this because we need to manipulate the data, such as
	//batching and transforming.

	if (stride == 0)
		stride = sizeof(GLubyte) * size;

	pxGLColorPointer.size = size;
	pxGLColorPointer.type = type;
	pxGLColorPointer.stride = stride;
	pxGLColorPointer.pointer = pointer;
}

/*
 * PXGLPointSizePointer specifies the location and data of an array of point
 * sizes to use when rendering points. type specifies the data type of the
 * coordinates. stride specifies the byte stride from one point size to the
 * next, allowing vertices and attributes to be packed into a single array or
 * stored in separate arrays. (Single-array storage may be more efficient on
 * some implementations).
 *
 * @param GLint size - Specifies the number of coordinates per array element.
 * Must be 2.
 * @param GLenum type - Specifies the data type of each texture coordinate.
 * Must be GL_FLOAT.
 * @param GLsizei stride - Specifies the byte offset between consecutive array
 * elements. If stride is 0, the array elements are understood to be tightly
 * packed. The initial value is 0.
 * @param GLvoid * pointer - Specifies a pointer to the first coordinate of the
 * first element in the array. The initial value is 0.
 */
void PXGLPointSizePointer(GLenum type, GLsizei stride, const GLvoid *pointer)
{
	assert(type == GL_FLOAT);
	//We actually store this because we need to manipulate the data, such as
	//batching and transforming.

	if (stride == 0)
		stride = sizeof(GLfloat);

	pxGLPointSizePointer.type = type;
	pxGLPointSizePointer.stride = stride;
	pxGLPointSizePointer.pointer = pointer;
}

/*
 * PXGLTexCoordPointer specifies the location and data of an array of texture
 * coordinates to use when rendering.  size specifies the number of coordinates
 * per element, and must be 2.  type specifies the data type of each texture
 * coordinate and stride specifies the byte stride from one array element to
 * the next allowing vertices and attributes to be packed into a single array
 * or stored in separate arrays. (Single-array storage may be more efficient on
 * some implementations).
 *
 * @param GLint size - Specifies the number of coordinates per array element.
 * Must be 2.
 * @param GLenum type - Specifies the data type of each texture coordinate.
 * Must be GL_FLOAT.
 * @param GLsizei stride - Specifies the byte offset between consecutive array
 * elements. If stride is 0, the array elements are understood to be tightly
 * packed. The initial value is 0.
 * @param GLvoid * pointer - Specifies a pointer to the first coordinate of the
 * first element in the array. The initial value is 0.
 */
void PXGLTexCoordPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
{
	assert(type == GL_FLOAT);

	// We actually store this because we need to manipulate the data, such as
	// batching and transforming.

	if (stride == 0)
		stride = sizeof(GLfloat) * size;

	// Lets copy the values over
	pxGLTexCoordPointer.size = size;
	pxGLTexCoordPointer.type = type;
	pxGLTexCoordPointer.stride = stride;
	pxGLTexCoordPointer.pointer = pointer;
}

/*
 * PXGLVertexPointer specifies the location and data of an array of vertex
 * coordinates to use when rendering. size specifies the number of coordinates
 * per vertex and type the data type of the coordinates. stride specifies the
 * byte stride from one vertex to the next allowing vertices and attributes to
 * be packed into a single array or stored in separate arrays. (Single-array
 * storage may be more efficient on some implementations).
 *
 * @param GLint size - Specifies the number of coordinates per array element.
 * Must be 2.
 * @param GLenum type - Specifies the data type of each texture coordinate.
 * Must be GL_FLOAT.
 * @param GLsizei stride - Specifies the byte offset between consecutive array
 * elements. If stride is 0, the array elements are understood to be tightly
 * packed. The initial value is 0.
 * @param GLvoid * pointer - Specifies a pointer to the first coordinate of the
 * first element in the array. The initial value is 0.
 */
void PXGLVertexPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
{
	assert(type == GL_FLOAT);
	// We actually store this because we need to manipulate the data, such as
	// batching and transforming.

	if (stride == 0)
		stride = sizeof(GLfloat) * size;

	pxGLVertexPointer.size = size;
	pxGLVertexPointer.type = type;
	pxGLVertexPointer.stride = stride;
	pxGLVertexPointer.pointer = pointer;
}

void PXGLShadeModel(GLenum mode)
{
	// If you are asking for flat
	if (mode == GL_FLAT)
	{
		PX_ENABLE_BIT(pxGLState.state, PX_GL_SHADE_MODEL_FLAT);
	}
	else
	{
		PX_DISABLE_BIT(pxGLState.state, PX_GL_SHADE_MODEL_FLAT);
	}
}

void PXGLTexEnvf(GLenum target, GLenum pname, GLfloat param)
{
	PXGLFlush();

	glTexEnvf(target, pname, param);
}
void PXGLTexEnvi(GLenum target, GLenum pname, GLint param)
{
	PXGLFlush();

	glTexEnvi(target, pname, param);
}
void PXGLTexEnvx(GLenum target, GLenum pname, GLfixed param)
{
	PXGLFlush();

	glTexEnvx(target, pname, param);
}
void PXGLTexEnvfv(GLenum target, GLenum pname, const GLfloat *params)
{
	PXGLFlush();

	glTexEnvfv(target, pname, params);
}
void PXGLTexEnviv(GLenum target, GLenum pname, const GLint *params)
{
	PXGLFlush();

	glTexEnviv(target, pname, params);
}
void PXGLTexEnvxv(GLenum target, GLenum pname, const GLfixed *params)
{
	PXGLFlush();

	glTexEnvxv(target, pname, params);
}

PXInline void PXGLDefineVertex(PXGLColoredTextureVertex *point,
							   GLfloat *pointSize,
							   const GLfloat **verticesPtr,
							   const GLfloat **texCoordsPtr,
							   const GLubyte **colorsPtr,
							   const GLfloat **pointSizesPtr,
							   float a, float b, float c, float d, float tx, float ty)
{
	float x = **verticesPtr; ++(*verticesPtr);
	float y = **verticesPtr;

	// Do the matrix multiplication on them.
	point->x = x * a + y * c + tx;
	point->y = x * b + y * d + ty;

	// If it is textured we need to grab the texture info
	if (*texCoordsPtr)
	{
		point->s = **texCoordsPtr; ++(*texCoordsPtr);
		point->t = **texCoordsPtr;
	}

	// If it is colored we need to grab the color info
	if (*colorsPtr)
	{
#if (!PX_ACCURATE_COLOR_TRANSFORMATION_MODE)
		// If we are going to round the color value, we are going to use this
		// method.
		point->r = ((**colorsPtr) * pxGLRed)   >> 8; ++(*colorsPtr);
		point->g = ((**colorsPtr) * pxGLGreen) >> 8; ++(*colorsPtr);
		point->b = ((**colorsPtr) * pxGLBlue)  >> 8; ++(*colorsPtr);
		point->a = ((**colorsPtr) * pxGLAlpha) >> 8;
#else
		// If we want accurate info, then we will use this method.
		point->r = ((**colorsPtr) * pxGLCurrentColor->redMultiplier);   ++(*colorsPtr);
		point->g = ((**colorsPtr) * pxGLCurrentColor->greenMultiplier); ++(*colorsPtr);
		point->b = ((**colorsPtr) * pxGLCurrentColor->blueMultiplier);  ++(*colorsPtr);
		point->a = ((**colorsPtr) * pxGLCurrentColor->alphaMultiplier);
#endif
	}
	else
	{
		// If we weren't colored, and are using our special color array method,
		// then we have to set the values for the array.
		point->r = pxGLRed;
		point->g = pxGLGreen;
		point->b = pxGLBlue;
		point->a = pxGLAlpha;
	}

	// If we haven't had multiple values for colors yet, then we have to check
	// if this addition will make it so.
	if (pxGLBufferVertexColorState != PX_GL_VERTEX_COLOR_MULTIPLE)
		PXGLSetBufferLastVertexColor(point->r, point->g, point->b, point->a);

	if (*pointSizesPtr)
	{
		*pointSize = **pointSizesPtr * pxGLScaleFactor;
	}
}

/*
 * When PXGLDrawArrays is called, it uses count sequential elements from each
 * enabled array to construct a sequence of geometric primitives, beginning
 * with element first. mode specifies what kind of primitives are constructed,
 * and how the array elements construct those primitives. If GL_VERTEX_ARRAY
 * is not enabled, no geometric primitives are generated.
 *
 * PXGLDrawArrays batches similar draw calls together prior to sending the
 * information to gl.
 *
 * @param GLenum mode - Specifies what kind of primitives to render. Symbolic
 * constants GL_POINTS, GL_LINE_STRIP, GL_LINE_LOOP, GL_LINES,
 * GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, and GL_TRIANGLES are accepted.
 * @param GLint first - Specifies the starting index in the enabled arrays.
 * @param GLsizei count - Specifies the number of indices to be rendered.
 */
void PXGLDrawArrays(GLenum mode, GLint first, GLsizei count)
{
	// If our pointer is empty, then lets just return.
	if (!pxGLVertexPointer.pointer || count == 0) //|| pxGLCurrentColor->alphaMultiplier < 0.001f )
		return;

	PX_DISABLE_BIT(pxGLState.state, PX_GL_DRAW_ELEMENTS);
	PXGLSetupEnables();

	// Lets change the draw mode.
	PXGLSetDrawMode(mode);

	// This variable is for tracking the current point we are manipulating.
	PXGLColoredTextureVertex *point;
	GLfloat *pointSize;

	// Lets store the strides of each of these so we do not need to access them
	// again.
	GLsizei vertexStride = pxGLVertexPointer.stride;
	GLsizei texStride = pxGLTexCoordPointer.stride;
	GLsizei colorStride = pxGLColorPointer.stride;
	GLsizei pointSizeStride = pxGLPointSizePointer.stride;

	// What was the vertex index before we added points.
	unsigned int oldVertexIndex = PXGLGetCurrentVertexIndex();
	unsigned int oldPointSizeIndex = PXGLGetCurrentPointSizeIndex();

	bool isTextured = PX_IS_BIT_ENABLED(pxGLState.clientState, PX_GL_TEXTURE_COORD_ARRAY);
	bool isColored = PX_IS_BIT_ENABLED(pxGLState.clientState, PX_GL_COLOR_ARRAY);
	bool isPointSizeArray = PX_IS_BIT_ENABLED(pxGLState.clientState, PX_GL_POINT_SIZE_ARRAY) && mode == GL_POINTS;
	bool isStrip = (mode == GL_TRIANGLE_STRIP);

	// Lets set the pointer to the starting point of the vertices, texture
	// coords, colors and point sizes; however we only want to grab the pointer
	// info if it is applicable.
	const GLfloat *vertices = pxGLVertexPointer.pointer + first * vertexStride;
	const void *currentVertex = vertices;
	const GLfloat *texCoords = isTextured ? pxGLTexCoordPointer.pointer + first * texStride : NULL;
	const void *currentTexCoord = texCoords;
	const GLubyte *colors = isColored ? pxGLColorPointer.pointer + first * colorStride : NULL;
	const void *currentColor = colors;
	const GLfloat *pointSizes = isPointSizeArray ? pxGLPointSizePointer.pointer + first * pointSizeStride : NULL;
	const void *currentPointSize = pointSizes;

	float a = pxGLCurrentMatrix->a;
	float b = pxGLCurrentMatrix->b;
	float c = pxGLCurrentMatrix->c;
	float d = pxGLCurrentMatrix->d;
	float tx = pxGLCurrentMatrix->tx;
	float ty = pxGLCurrentMatrix->ty;

	// If the old vertex is 0, then it is the first vertex being used... thus we
	// do not need to add points at the start if we were going to.
	if (oldVertexIndex == 0)
	{
		isStrip = false;
	}

	// This is set up for the bounding box of the item being drawn.
	PXGLAABB aabb = PXGLAABBReset;

	signed int nX;
	signed int nY;

	unsigned int usedPointCount = isStrip ? count + 2 : count;
	// Grab an array of vertices
	point = PXGLAskForVertices(usedPointCount);

	// For strips
	PXGLColoredTextureVertex *preFirstPoint;
	PXGLColoredTextureVertex *firstPoint;

	if (isStrip)
	{
		// If it is a strip, copy the last point (this won't happen if this is
		// the first object ever in this array)
		*point = *(point - 1);
		++point;

		// We will also want to copy our first point, so we are setting up
		// pointers to get that ready. The preFirstPoint is a pointer to the
		// value prior to the first value we are going to manipulate. The
		// firstPoint is the first point we will read and manipulate. After we
		// manipulate the point, we will copy it back into preFirstPoint. This
		// will create a degenerate triangle that gl will optimize out.
		preFirstPoint = point;
		++point;
		firstPoint = point;
	}

	if (isPointSizeArray)
	{
		pointSize = PXGLAskForPointSizes(count);
	}
	else
		pointSize = NULL;

	for (GLsizei index = 0; index < count; ++index, ++point)
	{
		PXGLDefineVertex(point,
						 pointSize,
						 &vertices,
						 &texCoords,
						 &colors,
						 &pointSizes,
						 a, b, c, d, tx, ty);
		nX = point->x;
		nY = point->y;

		vertices = currentVertex + vertexStride;
		currentVertex = vertices;

		if (isTextured)
		{
			texCoords = currentTexCoord + texStride;
			currentTexCoord = texCoords;
		}
		if (isColored)
		{
			// No matter what, we need to increment the pointer from the current
			// beginning point.
			colors = currentColor + colorStride;
			currentColor = colors;
		}
		if (isPointSizeArray)
		{
			++pointSize;

			pointSizes = currentPointSize + pointSizeStride;
			currentPointSize = pointSizes;
		}

		// Lets figure out the bounding box
		PXGLAABBExpandv(&aabb, nX, nY);
	}

	if (isStrip)
	{
		*preFirstPoint = *firstPoint;
	}

	PXGLUsedVertices(usedPointCount);
	if (isPointSizeArray)
	{
		PXGLUsedPointSizes(count);
	}

	// Updates the points and colors based upon the parents rotation and
	// position and yours, also updates bounding box of the display object!
	// pointer, start , end

	// Check to see if the bounding area is within the screen area, if not then
	// we don't need to draw it.  To resolve this, lets set the index back to
	// the old one, this way it negates us adding more on.

	if (!_PXGLRectContainsAABB(&pxGLRectClip, &aabb))
	{
		PXGLSetCurrentPointSizeIndex(oldPointSizeIndex);
		PXGLSetCurrentVertexIndex(oldVertexIndex);
		if (isPointSizeArray)
		{
			PXGLSetCurrentPointSizeIndex(oldPointSizeIndex);
		}
	}

	// We are adding a 1 pixel buffer to the bounding box
	PXGLAABBInflatev(&aabb, 1, 1);

	// then we are going to calculate the overall bounding box for the object
	// that was drawn.
	PXGLAABBUpdate(&pxGLAABB, &aabb);
}

/*
 * When PXGLDrawElements is called, it uses count sequential elements from each
 * enabled array to construct a sequence of geometric primitives, beginning
 * with element first. mode specifies what kind of primitives are constructed,
 * and how the array elements construct those primitives. If GL_VERTEX_ARRAY
 * is not enabled, no geometric primitives are generated.
 *
 * PXGLDrawElements batches similar draw calls together prior to sending the
 * information to gl.
 *
 * @param GLenum mode - Specifies what kind of primitives to render. Symbolic
 * constants GL_POINTS, GL_LINE_STRIP, GL_LINE_LOOP, GL_LINES,
 * GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, and GL_TRIANGLES are accepted.
 * @param GLsizei count - Specifies the number of elements to be rendered.
 * @param GLenum type - Specifies the type of the values in indices. Must be
 * GL_UNSIGNED_SHORT.
 * @param const GLvoid * ids - Specifies a pointer to the location where the
 * indices are stored.
 */
void PXGLDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid *ids)
{
	if (!pxGLVertexPointer.pointer || count == 0)
		return;

	const GLushort *indices = ids;

	PX_ENABLE_BIT(pxGLState.state, PX_GL_DRAW_ELEMENTS);
	PXGLSetupEnables();

	PXGLSetDrawMode(mode);

	PXGLColoredTextureVertex *point;
	GLushort *index;
	GLfloat *pointSize;

	GLsizei vertexStride = pxGLVertexPointer.stride;
	GLsizei texStride = pxGLTexCoordPointer.stride;
	GLsizei colorStride = pxGLColorPointer.stride;
	GLsizei pointSizeStride = pxGLPointSizePointer.stride;

	bool isTextured = PX_IS_BIT_ENABLED(pxGLState.clientState, PX_GL_TEXTURE_COORD_ARRAY);
	bool isColored = PX_IS_BIT_ENABLED(pxGLState.clientState, PX_GL_COLOR_ARRAY);
	bool isPointSizeArray = PX_IS_BIT_ENABLED(pxGLState.clientState, PX_GL_POINT_SIZE_ARRAY) && mode == GL_POINTS;
	bool isStrip = (mode == GL_TRIANGLE_STRIP);

	const void const *startVertex = pxGLVertexPointer.pointer;
	const GLfloat *vertices;

	const void const *startTex = isTextured ? pxGLTexCoordPointer.pointer : NULL;
	const GLfloat *texCoords;

	const void const *startColor = isColored ? pxGLColorPointer.pointer : NULL;
	const GLubyte *colors;

	const void const *startPointSizes = isPointSizeArray ? pxGLPointSizePointer.pointer : NULL;
	const GLfloat *pointSizes;

	GLuint eVal = 0; // HAS TO BE 'UNSIGNED SHORT' OR LARGER

	float a = pxGLCurrentMatrix->a;
	float b = pxGLCurrentMatrix->b;
	float c = pxGLCurrentMatrix->c;
	float d = pxGLCurrentMatrix->d;
	float tx = pxGLCurrentMatrix->tx;
	float ty = pxGLCurrentMatrix->ty;

	unsigned vertexIndex = 0;

	unsigned oldIndex = PXGLGetCurrentIndex();
	unsigned oldVertexIndex = PXGLGetCurrentVertexIndex();
	unsigned oldPointSizeIndex = PXGLGetCurrentPointSizeIndex();

	vertexIndex = oldVertexIndex;

	if (oldIndex == 0)
	{
		isStrip = false;
	}

	unsigned usedIndexCount = isStrip ? count + 2 : count;
	unsigned usedVertexCount = 0;

	// Grab a sequencial array of indices and vertices
	index = PXGLAskForIndices(usedIndexCount);
	point = PXGLAskForVertices(count);

	// For strips
	GLushort *preFirstIndex;
	GLushort *firstIndex;

	if (isStrip)
	{
		// If it is a strip, copy the last index (this won't happen if this is
		// the first object ever in this array)
		*index = *(index - 1);
		++index;

		preFirstIndex = index;
		++index;
		firstIndex = index;
	}

	if (isPointSizeArray)
	{
		pointSize = PXGLAskForPointSizes(count);
	}
	else
		pointSize = NULL;

	// These values are used for creating a bounding box for the object drawn.

	PXGLAABB aabb = PXGLAABBReset;

	int nX, nY;

	const GLushort *curIndex;
	GLsizei counter;

	// Create an arbitrary amount of buckets. We will expand this if needed.
	GLushort maxIndex = (count * 0.5f) + 1;//*indices;
	/*for (counter = 1, curIndex = indices + counter; counter < count; ++counter, ++curIndex)
	{
		if (maxIndex < *curIndex)
			maxIndex = *curIndex;
	}*/

	PXGLElementBucket *buckets = PXGLGetElementBuckets(maxIndex + 1);
	PXGLElementBucket *bucket;

	for (counter = 0, curIndex = indices + counter; counter < count; ++counter, ++curIndex, ++index)
	{
		// Get the next available point, this method needs to also change the
		// size of the array accordingly. If the array ever gets larger then
		// MAX_VERTICES, we should flush it. Keep in mind that if we do that
		// here, then offset and translation needs to change also.

		eVal = *curIndex;

		if (eVal > maxIndex)
		{
			maxIndex = eVal;
			// Grabbing the new array of buckets.
			// Note:	This will not mess up the previous array as it will be
			//			copied by realloc. We are also always getting the bucket
			//			from the starting array (aka this) so it will never be
			//			incorrect.
			buckets = PXGLGetElementBuckets(maxIndex + 1);
		}

		bucket = buckets + eVal;

		if (!(bucket->vertex))
		{
			++usedVertexCount;

			bucket->vertex = point;
			++point;
			if (isPointSizeArray)
			{
				bucket->pointSize = pointSize;
				++pointSize;
			}
			bucket->vertexIndex = vertexIndex;
			++vertexIndex;

			// Lets grab the next vertex, which is done by getting the actual
			// index value of the vertex held by eVal, then we can multiply it
			// by the stride to find the pointers location.
			vertices = startVertex + eVal * vertexStride;

			if (isTextured)
				texCoords = startTex + eVal * texStride;
			else
				texCoords = NULL;

			if (isColored)
				colors = startColor + eVal * colorStride;
			else
				colors = NULL;

			if (isPointSizeArray)
				pointSizes = startPointSizes + eVal * pointSizeStride;
			else
				pointSizes = NULL;

			PXGLDefineVertex(bucket->vertex,
							 bucket->pointSize,
							 &vertices,
							 &texCoords,
							 &colors,
							 &pointSizes,
							 a, b, c, d, tx, ty);

			nX = bucket->vertex->x;
			nY = bucket->vertex->y;

			// Lets figure out the bounding box
			PXGLAABBExpandv(&aabb, nX, nY);
		}

		*index = bucket->vertexIndex;
	}

	if (isStrip)
	{
		*preFirstIndex = *firstIndex;
	}

	PXGLUsedIndices(usedIndexCount);
	PXGLUsedVertices(usedVertexCount);

	if (isPointSizeArray)
	{
		PXGLUsedPointSizes(usedVertexCount);
	}

	// Updates the points and colors based upon the parents rotation and
	// position and yours, also updates bounding box of the display object!
	// pointer, start , end

	// Check to see if the bounding area is within the screen area, if not then
	// we don't need to draw it.  To resolve this, lets set the index back to
	// the old one, this way it negates us adding more on.
	if (!_PXGLRectContainsAABB(&pxGLRectClip, &aabb))
	{
		PXGLSetCurrentIndex(oldIndex);
		PXGLSetCurrentPointSizeIndex(oldPointSizeIndex);
		PXGLSetCurrentVertexIndex(oldVertexIndex);

		if (isPointSizeArray)
		{
			PXGLSetCurrentPointSizeIndex(oldPointSizeIndex);
		}
	}

	// We are adding a 1 pixel buffer to the bounding box
	PXGLAABBInflatev(&aabb, 1, 1);

	// then we are going to calculate the overall bounding box for the object
	// that was drawn.
	PXGLAABBUpdate(&pxGLAABB, &aabb);
}

void PXGLBlendFunc(GLenum sfactor, GLenum dfactor)
{
	pxGLState.blendSource = sfactor;
	pxGLState.blendDestination = dfactor;
}

/*
 * PXGLPopMatrix pops the current matrix stack, replacing the current matrix
 * with the one below it on the stack.
 */
void PXGLPopMatrix( )
{
	//PXDebugLog(@"PXGLPopMatrix has failed: There is no matrix to pop.");
	assert(pxGLCurrentMatrixIndex);
	
	pxGLCurrentMatrix = &pxGLMatrices[--pxGLCurrentMatrixIndex];
}

/*
 * PXGLPushMatrix pushes the current matrix stack down by one, duplicating the
 * current matrix. That is, after a PXGLPushMatrix call, the matrix on top of
 * the stack is identical to the one below it.
 */
void PXGLPushMatrix( )
{
	assert(pxGLCurrentMatrixIndex < PX_GL_MATRIX_STACK_SIZE - 1);

	PXGLMatrix *oldMatrix = pxGLCurrentMatrix;
	pxGLCurrentMatrix = &pxGLMatrices[++pxGLCurrentMatrixIndex];

	pxGLCurrentMatrix->a = oldMatrix->a;
	pxGLCurrentMatrix->b = oldMatrix->b;
	pxGLCurrentMatrix->c = oldMatrix->c;
	pxGLCurrentMatrix->d = oldMatrix->d;
	pxGLCurrentMatrix->tx = oldMatrix->tx;
	pxGLCurrentMatrix->ty = oldMatrix->ty;
}

/*
 * PXGLLoadIdentity replaces the current matrix with the identity matrix.
 */
void PXGLLoadIdentity( )
{
	PXGLMatrixIdentity(pxGLCurrentMatrix);
}

/*
 * PXGLTranslate translates the current matrix by the given values.
 *
 * @param GLfloat x - The x coordinate of the translation vector.
 * @param GLfloat y - The y coordinate of the translation vector.
 */
void PXGLTranslate(GLfloat x, GLfloat y)
{
	pxGLCurrentMatrix->tx += x;
	pxGLCurrentMatrix->ty += y;
}

/*
 * PXGLScale produces a nonuniform scaling along the x and y axes.
 *
 * @param GLfloat x - Scaling factor along the x axis.
 * @param GLfloat y - Scaling factor along the y axis.
 */
void PXGLScale(GLfloat x, GLfloat y)
{
	// Multiply the matrix by the scaling factors
	pxGLCurrentMatrix->a *= x;
	pxGLCurrentMatrix->d *= y;
	pxGLCurrentMatrix->tx *= x;
	pxGLCurrentMatrix->ty *= y;
}

/*
 * PXGLRotate produces a rotation matrix of angle degrees.  The current matrix
 * is multiplied by the rotation matrix with the product replacing the current
 * matrix.
 *
 * @param GLfloat angle - Specifies the angle of rotation, in degrees.
 */
void PXGLRotate(GLfloat angle)
{
	GLfloat sinVal = sinf(angle);
	GLfloat cosVal = cosf(angle);

	GLfloat a = pxGLCurrentMatrix->a;
	GLfloat b = pxGLCurrentMatrix->b;
	GLfloat c = pxGLCurrentMatrix->c;
	GLfloat d = pxGLCurrentMatrix->d;
	GLfloat tx = pxGLCurrentMatrix->tx;
	GLfloat ty = pxGLCurrentMatrix->ty;

	pxGLCurrentMatrix->a = a * cosVal - b * sinVal;
	pxGLCurrentMatrix->b = a * sinVal + b * cosVal;
	pxGLCurrentMatrix->c = c * cosVal - d * sinVal;
	pxGLCurrentMatrix->d = c * sinVal + d * cosVal;
	pxGLCurrentMatrix->tx = tx * cosVal - ty * sinVal;
	pxGLCurrentMatrix->ty = tx * sinVal + ty * cosVal;
}

/*
 * PXGLMultMatrix multplies the current matrix by the matrix given.
 *
 * @param PXGLMatrix * mat - The matrix to be multiplied with.
 */
void PXGLMultMatrix(PXGLMatrix *mat)
{
	PXGLMatrixMult(pxGLCurrentMatrix, pxGLCurrentMatrix, mat);
}

/*
 * PXGLMultMatrix multplies the current matrix by the matrix given.
 *
 * @param PXGLMatrix * mat - The matrix to be multiplied with.
 */
void PXGLAABBMult(PXGLAABB *aabb)
{
	PXGLMatrixConvertAABBv(pxGLCurrentMatrix,
						  &(aabb->xMin), &(aabb->yMin),
						  &(aabb->xMax), &(aabb->yMax));
}

/*
 * PXGLResetMatrixStack resets the matrix stack back to the first matrix, and
 * sets it to the identity.
 */
void PXGLResetMatrixStack( )
{
	pxGLCurrentMatrixIndex = 0;
	pxGLCurrentMatrix = pxGLMatrices;
	PXGLLoadIdentity( );
}

/*
 * This method loads our matrix into gl.
 */
void PXGLLoadMatrixToGL( )
{
	pxGLMatrix[0] = pxGLCurrentMatrix->a;
	pxGLMatrix[1] = pxGLCurrentMatrix->b;
	pxGLMatrix[4] = pxGLCurrentMatrix->c;
	pxGLMatrix[5] = pxGLCurrentMatrix->d;
	pxGLMatrix[12] = pxGLCurrentMatrix->tx;
	pxGLMatrix[13] = pxGLCurrentMatrix->ty;

	glLoadMatrixf(pxGLMatrix);
}

/*
 * PXGLPopColorTransform pops the color transform stack, replacing the current
 * color transform with the one below it on the stack.
 */
void PXGLPopColorTransform( )
{
	assert(pxGLCurrentColorIndex);

	pxGLCurrentColor = &pxGLColors[--pxGLCurrentColorIndex];

	GLubyte red   = (float)0xFF * pxGLCurrentColor->redMultiplier;
	GLubyte green = (float)0xFF * pxGLCurrentColor->greenMultiplier;
	GLubyte blue  = (float)0xFF * pxGLCurrentColor->blueMultiplier;
	GLubyte alpha = (float)0xFF * pxGLCurrentColor->alphaMultiplier;

	//If popping the transform leaves the colors the same as they were, then we
	//don't need to go any further.
	if (red == pxGLRed && green == pxGLGreen && blue == pxGLBlue && alpha == pxGLAlpha)
		return;

	//Set the current color
	pxGLRed   = red;
	pxGLGreen = green;
	pxGLBlue  = blue;
	pxGLAlpha = alpha;
}

/*
 * PXGLPushColorTransform pushes the current transform stack down by one,
 * duplicating the current transform. That is, after a PXGLPushMatrix call, the
 * transform on top of the stack is identical to the one below it.
 */
void PXGLPushColorTransform( )
{
	//PXDebugLog(@"PXGLPushColor has failed: Reached color transform capacity.");
	assert(pxGLCurrentColorIndex < PX_GL_COLOR_STACK_SIZE - 1);

	PXGLColorTransform *pxOldColor = pxGLCurrentColor;
	pxGLCurrentColor = &pxGLColors[++pxGLCurrentColorIndex];

	pxGLCurrentColor->redMultiplier   = pxOldColor->redMultiplier;
	pxGLCurrentColor->greenMultiplier = pxOldColor->greenMultiplier;
	pxGLCurrentColor->blueMultiplier  = pxOldColor->blueMultiplier;
	pxGLCurrentColor->alphaMultiplier = pxOldColor->alphaMultiplier;

	pxGLRed   = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->redMultiplier);
	pxGLGreen = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->greenMultiplier);
	pxGLBlue  = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->blueMultiplier);
	pxGLAlpha = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->alphaMultiplier);
}

/*
 * PXGLSetColorTransform sets the current transform to the one provided
 * multiplied by the parent color transform (if one exists).
 *
 * @param PXGLColorTransform * transform - The transform you wish to set.
 */
void PXGLSetColorTransform(PXGLColorTransform *transform)
{
	if (pxGLCurrentColorIndex != 0)
	{
		PXGLColorTransform *pxOldColor  = &pxGLColors[pxGLCurrentColorIndex - 1];
		pxGLCurrentColor->redMultiplier   = pxOldColor->redMultiplier;
		pxGLCurrentColor->greenMultiplier = pxOldColor->greenMultiplier;
		pxGLCurrentColor->blueMultiplier  = pxOldColor->blueMultiplier;
		pxGLCurrentColor->alphaMultiplier = pxOldColor->alphaMultiplier;
	}

	pxGLCurrentColor->redMultiplier   *= transform->redMultiplier;
	pxGLCurrentColor->greenMultiplier *= transform->greenMultiplier;
	pxGLCurrentColor->blueMultiplier  *= transform->blueMultiplier;
	pxGLCurrentColor->alphaMultiplier *= transform->alphaMultiplier;

	pxGLRed   = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->redMultiplier  );
	pxGLGreen = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->greenMultiplier);
	pxGLBlue  = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->blueMultiplier );
	pxGLAlpha = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->alphaMultiplier);
}

/*
 * PXGLLoadColorTransformIdentity sets the current color's transform to the
 * identity (multiplied by the parent if one exists).
 */
void PXGLLoadColorTransformIdentity( )
{
	if (pxGLCurrentColorIndex != 0)
	{
		PXGLColorTransform *pxOldColor = &pxGLColors[pxGLCurrentColorIndex - 1];

		pxGLCurrentColor->redMultiplier = pxOldColor->redMultiplier;
		pxGLCurrentColor->greenMultiplier = pxOldColor->greenMultiplier;
		pxGLCurrentColor->blueMultiplier = pxOldColor->blueMultiplier;
		pxGLCurrentColor->alphaMultiplier = pxOldColor->alphaMultiplier;

		pxGLRed   = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->redMultiplier  );
		pxGLGreen = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->greenMultiplier);
		pxGLBlue  = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->blueMultiplier );
		pxGLAlpha = PX_COLOR_FLOAT_TO_BYTE(pxGLCurrentColor->alphaMultiplier);
	}
	else
		PXGLColorTransformIdentity(pxGLCurrentColor);
}

/*
 * PXGLResetColorTransformStack resets the transform stack back to the first
 * transform, and sets it to the identity.
 */
void PXGLResetColorTransformStack( )
{
	pxGLCurrentColorIndex = 0;
	pxGLCurrentColor = pxGLColors;
	PXGLLoadColorTransformIdentity( );
	PXGLColor4ub(0xFF, 0xFF, 0xFF, 0xFF);
}

void PXGLMatrixMult(PXGLMatrix *store, PXGLMatrix *mat1, PXGLMatrix *mat2)
{
	GLfloat a2 = mat1->a;
	GLfloat b2 = mat1->b;
	GLfloat c2 = mat1->c;
	GLfloat d2 = mat1->d;
	GLfloat tx2 = mat1->tx;
	GLfloat ty2 = mat1->ty;

	GLfloat a1 = mat2->a;
	GLfloat b1 = mat2->b;
	GLfloat c1 = mat2->c;
	GLfloat d1 = mat2->d;
	GLfloat tx1 = mat2->tx;
	GLfloat ty1 = mat2->ty;

	store->a = a1 * a2 + b1 * c2;
	store->b = a1 * b2 + b1 * d2;
	store->c = c1 * a2 + d1 * c2;
	store->d = c1 * b2 + d1 * d2;
	store->tx = tx1 * a2 + ty1 * c2 + tx2;
	store->ty = tx1 * b2 + ty1 * d2 + ty2;
}

/*
 * PXGLMatrixIdentity sets the matrix given to the identity.
 *
 * @param PXGLMatrix * mat - Matrix to be transformed into the identity.
 */
void PXGLMatrixIdentity(PXGLMatrix *mat)
{
	mat->a = 1.0f; mat->c = 0.0f;
	mat->b = 0.0f; mat->d = 1.0f;
	mat->tx = mat->ty = 0.0f;
}

void PXGLMatrixInvert(PXGLMatrix *mat)
{
	float a = mat->a;
	float b = mat->b;
	float c = mat->c;
	float d = mat->d;
	float tx = mat->tx;
	float ty = mat->ty;

	float invBottom = 1.0f / (a * d - b * c);

	mat->a =  d * invBottom;
	mat->b = -b * invBottom;
	mat->c = -c * invBottom;
	mat->d =  a * invBottom;
	mat->tx =  (c * ty - d * tx) * invBottom;
	mat->ty = -(a * ty - b * tx) * invBottom;
}

/*
 * PXGLColorTransformIdentity sets the transform given to the identity.
 *
 * @param PXGLColorTransform * transform - Transform to be set to the identity.
 */
void PXGLColorTransformIdentity(PXGLColorTransform *transform)
{
	transform->redMultiplier   = 1.0f;
	transform->greenMultiplier = 1.0f;
	transform->blueMultiplier  = 1.0f;
	transform->alphaMultiplier = 1.0f;
}

PXInline_c void PXGLMatrixRotate(PXGLMatrix *mat, GLfloat radians)
{
	// Needs to exist
	assert(mat);

	GLfloat sinVal = sinf(radians);
	GLfloat cosVal = cosf(radians);

	GLfloat oldA = mat->a;
	GLfloat oldB = mat->b;
	GLfloat oldC = mat->c;
	GLfloat oldD = mat->d;
	GLfloat oldTX = mat->tx;
	GLfloat oldTY = mat->ty;

	mat->a = oldA * cosVal - oldB * sinVal;
	mat->b = oldA * sinVal + oldB * cosVal;
	mat->c = oldC * cosVal - oldD * sinVal;
	mat->d = oldC * sinVal + oldD * cosVal;
	mat->tx = oldTX * cosVal - oldTY * sinVal;
	mat->ty = oldTX * sinVal + oldTY * cosVal;
}
PXInline_c void PXGLMatrixScale(PXGLMatrix *mat, GLfloat x, GLfloat y)
{
	// Needs to exist
	assert(mat);

	mat->a *= x;
	mat->d *= y;
	mat->tx *= x;
	mat->ty *= y;
}
PXInline_c void PXGLMatrixTranslate(PXGLMatrix *mat, GLfloat x, GLfloat y)
{
	// Needs to exist
	assert(mat);

	mat->tx += x;
	mat->ty += y;
}
PXInline_c void PXGLMatrixTransform(PXGLMatrix *mat, GLfloat angle, GLfloat scaleX, GLfloat scaleY, GLfloat x, GLfloat y)
{
	// Needs to exist
	assert(mat);

	PXGLMatrixScale(mat, scaleX, scaleY);
	PXGLMatrixRotate(mat, angle);
	PXGLMatrixTranslate(mat, x, y);
}

void PXGLResetStates(PXGLState desiredState)
{
	//pxGLState = pxGLDefaultState;
	pxGLState = desiredState;
}

#pragma mark -
#pragma mark STATES
#pragma mark -

PXInline_c void PXGLSetupEnables()
{
	bool breakBatch = false;
//	bool clientStateNotEqual = pxGLClientState != pxGLClientStateInGL;
//	bool stateNotEqual = pxGLState != pxGLStateInGL;
//	bool blendModeNotEqual = pxGLBlendMode.asUInt != pxGLBlendModeInGL.asUInt;

	bool clientStateNotEqual = pxGLState.clientState != pxGLStateInGL.clientState;
	bool stateNotEqual = pxGLState.state != pxGLStateInGL.state;
	bool blendModeNotEqual = ((pxGLState.blendSource != pxGLStateInGL.blendSource) ||
							  (pxGLState.blendDestination != pxGLStateInGL.blendDestination));

	if (clientStateNotEqual)
	{
		breakBatch = true;

		//if (!PX_IS_BIT_ENABLED_IN_BOTH(pxGLClientState, pxGLClientStateInGL, PX_GL_COLOR_ARRAY))
		if (!PX_IS_BIT_ENABLED_IN_BOTH(pxGLState.clientState, pxGLStateInGL.clientState, PX_GL_COLOR_ARRAY))
		{
			breakBatch = false;
		}
	}

	if (stateNotEqual)
	{
		// Draw elements vs draw arrays is auto taken care of by this check, 
		breakBatch = true;
	}

	if (blendModeNotEqual)
	{
		breakBatch = true;
	}

	if (breakBatch)
	{
		PXGLFlushBuffer( );

#define PXGLCompareAndSetClientState(_px_state_, _gl_state_) \
{ \
	if (!PX_IS_BIT_ENABLED_IN_BOTH(pxGLState.clientState, pxGLStateInGL.clientState, _px_state_)) \
	{ \
		if (PX_IS_BIT_ENABLED(pxGLState.clientState, _px_state_)) \
			glEnableClientState(_gl_state_); \
		else \
			glDisableClientState(_gl_state_); \
	} \
}
#define PXGLCompareAndSetState(_px_state_, _gl_state_) \
{ \
	if (!PX_IS_BIT_ENABLED_IN_BOTH(pxGLState.state, pxGLStateInGL.state, _px_state_)) \
	{ \
		if (PX_IS_BIT_ENABLED(pxGLState.state, _px_state_)) \
			glEnable(_gl_state_); \
		else \
			glDisable(_gl_state_); \
	} \
}

		PXGLCompareAndSetClientState(PX_GL_POINT_SIZE_ARRAY, GL_POINT_SIZE_ARRAY_OES);
		PXGLCompareAndSetClientState(PX_GL_TEXTURE_COORD_ARRAY, GL_TEXTURE_COORD_ARRAY);
		PXGLCompareAndSetClientState(PX_GL_VERTEX_ARRAY, GL_VERTEX_ARRAY);

		PXGLCompareAndSetState(PX_GL_POINT_SPRITE, GL_POINT_SPRITE_OES);
		PXGLCompareAndSetState(PX_GL_LINE_SMOOTH, GL_LINE_SMOOTH);
		PXGLCompareAndSetState(PX_GL_POINT_SMOOTH, GL_POINT_SMOOTH);
		PXGLCompareAndSetState(PX_GL_TEXTURE_2D, GL_TEXTURE_2D);

		/*if (PX_IS_BIT_ENABLED_IN_BOTH(pxGLState, pxGLStateInGL, PX_GL_SHADE_MODEL_FLAT))
		{
			if (PX_IS_BIT_ENABLED(pxGLState, PX_GL_SHADE_MODEL_FLAT))
				glShadeModel(GL_FLAT);
			else
				glShadeModel(GL_SMOOTH);
		}*/

		if (PX_IS_BIT_ENABLED_IN_BOTH(pxGLState.state, pxGLStateInGL.state, PX_GL_SHADE_MODEL_FLAT))
		{
			if (PX_IS_BIT_ENABLED(pxGLState.state, PX_GL_SHADE_MODEL_FLAT))
				glShadeModel(GL_FLAT);
			else
				glShadeModel(GL_SMOOTH);
		}

		if (blendModeNotEqual)
		{
			glBlendFunc(pxGLState.blendSource, pxGLState.blendDestination);
			
			// glBlendFuncSeparateOES(pxGLState.blendSource, pxGLState.blendDestination,
			//					   GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		}
	}

	pxGLStateInGL = pxGLState;
}

PXInline_c PXGLState _PXGLDefaultState()
{
	return pxGLDefaultState;
}

PXInline_c void _PXGLStateEnable(PXGLState *state, GLenum cap)
{
	assert(state); // Must exist
	PX_ENABLE_BIT(state->state, PXGLGLStateToPXState(cap));
}
PXInline_c void _PXGLStateDisable(PXGLState *state, GLenum cap)
{
	assert(state); // Must exist
	PX_DISABLE_BIT(state->state, PXGLGLStateToPXState(cap));
}
PXInline_c void _PXGLStateEnableClientState(PXGLState *state, GLenum array)
{
	assert(state); // Must exist
	PX_ENABLE_BIT(state->clientState, PXGLGLClientStateToPXClientState(array));
}
PXInline_c void _PXGLStateDisableClientState(PXGLState *state, GLenum array)
{
	assert(state); // Must exist
	PX_DISABLE_BIT(state->clientState, PXGLGLClientStateToPXClientState(array));
}
//PXInline_c void _PXGLStateBindTexture(PXGLState *state, GLuint texture)
//{
//	assert(state);
//	state->texture = texture;
//}
PXInline_c void _PXGLStateBlendFunc(PXGLState *state, GLenum sfactor, GLenum dfactor)
{
	assert(state); // Must exist

	state->blendSource = sfactor;
	state->blendDestination = dfactor;
}

PXInline_c bool _PXGLStateIsEnabled(PXGLState *state, GLenum cap)
{
	assert(state); // Must exist

	switch (cap)
	{
		// CLIENT STATE
		case GL_COLOR_ARRAY:
			return PX_IS_BIT_ENABLED(state->clientState, PX_GL_COLOR_ARRAY);
		case GL_POINT_SIZE_ARRAY_OES:
			return PX_IS_BIT_ENABLED(state->clientState, PX_GL_POINT_SIZE_ARRAY);
		case GL_TEXTURE_COORD_ARRAY:
			return PX_IS_BIT_ENABLED(state->clientState, PX_GL_TEXTURE_COORD_ARRAY);
		case GL_VERTEX_ARRAY:
			return PX_IS_BIT_ENABLED(state->clientState, PX_GL_VERTEX_ARRAY);
		// STATE
		case GL_POINT_SPRITE_OES:
			return PX_IS_BIT_ENABLED(state->state, PX_GL_POINT_SPRITE);
		case GL_LINE_SMOOTH:
			return PX_IS_BIT_ENABLED(state->state, PX_GL_LINE_SMOOTH);
		case GL_POINT_SMOOTH:
			return PX_IS_BIT_ENABLED(state->state, PX_GL_POINT_SMOOTH);
		case GL_TEXTURE_2D:
			return PX_IS_BIT_ENABLED(state->state, PX_GL_TEXTURE_2D);
		default:
			return false;
	}

	return false;
}
PXInline_c void _PXGLStateGetIntegerv(PXGLState *state, GLenum pname, GLint *params)
{
	assert(state);	// Must exist
	assert(params);	// Must exist

	switch (pname)
	{
		case GL_BLEND_DST:
			*params = state->blendDestination;
			break;
		case GL_BLEND_SRC:
			*params = state->blendSource;
			break;
	}
}

PXInline GLuint PXGLGLStateToPXState(GLenum cap)
{
	switch (cap)
	{
	case GL_POINT_SPRITE_OES:
		return PX_GL_POINT_SPRITE;
	case GL_LINE_SMOOTH:
		return PX_GL_LINE_SMOOTH;
	case GL_POINT_SMOOTH:
		return PX_GL_POINT_SMOOTH;
	case GL_TEXTURE_2D:
		return PX_GL_TEXTURE_2D;
	}

	return 0;
}

PXInline GLenum PXGLPXStateToGLState(GLuint cap)
{
	switch (cap)
	{
	case PX_GL_POINT_SPRITE:
		return GL_POINT_SPRITE_OES;
	case PX_GL_LINE_SMOOTH:
		return GL_LINE_SMOOTH;
	case PX_GL_POINT_SMOOTH:
		return GL_POINT_SMOOTH;
	case PX_GL_TEXTURE_2D:
		return GL_TEXTURE_2D;
	}

	return 0;
}

PXInline GLuint PXGLGLClientStateToPXClientState(GLenum array)
{
	switch (array)
	{
	case GL_COLOR_ARRAY:
		return PX_GL_COLOR_ARRAY;
	case GL_POINT_SIZE_ARRAY_OES:
		return PX_GL_POINT_SIZE_ARRAY;
	case GL_TEXTURE_COORD_ARRAY:
		return PX_GL_TEXTURE_COORD_ARRAY;
	case GL_VERTEX_ARRAY:
		return PX_GL_VERTEX_ARRAY;
	}

	return 0;
}

PXInline GLuint PXGLPXClientStateToGLClientState(GLenum array)
{
	switch (array)
	{
	case PX_GL_COLOR_ARRAY:
		return GL_COLOR_ARRAY;
	case PX_GL_POINT_SIZE_ARRAY:
		return GL_POINT_SIZE_ARRAY_OES;
	case PX_GL_TEXTURE_COORD_ARRAY:
		return GL_TEXTURE_COORD_ARRAY;
	case PX_GL_VERTEX_ARRAY:
		return GL_VERTEX_ARRAY;
	}

	return 0;
}

PXInline GLuint PXSizeOfGLEnum(GLenum type)
{
	switch (type)
	{
	case GL_BYTE:
		return sizeof(GLbyte);
	case GL_UNSIGNED_BYTE:
		return sizeof(GLubyte);
	case GL_SHORT:
		return sizeof(GLshort);
	case GL_UNSIGNED_SHORT:
		return sizeof(GLushort);
	case GL_FLOAT:
		return sizeof(GLfloat);
	}

	return 0;
}

#pragma mark GLPrivate

// width and height passed in POINTS
// @param orientationEnabled
//		set to true when rendering to the screen. set to false when rendering
//		to an off-the-screen surface
void PXGLSetViewSize(unsigned width, unsigned height, float scaleFactor, bool orientationEnabled)
{
	pxGLScaleFactor = scaleFactor;
	pxGLOne_ScaleFactor = 1.0f / pxGLScaleFactor;
	pxGLWidthInPoints  = width;
	pxGLHeightInPoints = height;

	// in PIXELS
	glViewport(0.0f,									// x
			   0.0f,									// y
			   pxGLWidthInPoints  * pxGLScaleFactor,	// width
			   pxGLHeightInPoints * pxGLScaleFactor);	// height
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity( );

	// in POINTS
	glOrthof(0,						// xMin
			 pxGLWidthInPoints,		// xMax
			 pxGLHeightInPoints,	// yMin
			 0,						// yMax
			 -100.0f,				// zMin
			  100.0f);				// zMax
	glMatrixMode(GL_MODELVIEW);
}