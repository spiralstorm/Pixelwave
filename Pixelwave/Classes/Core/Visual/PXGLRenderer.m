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

#include "PXGLRenderer.h"
#include "PXGLException.h"
#include "PXSettings.h"
#include "PXGLPrivate.h"

#import "PXDebug.h"
#import "PXPrivateUtils.h"
#include "PXGLStatePrivate.h"

#define PX_GL_RENDERER_MAX_VERTICES 0xFFFF
#define PX_GL_RENDERER_MAX_VERTICES_MINUS_2 0xFFFD

#define PX_GL_RENDERER_MIN_BUFFER_SIZE 16

#define PX_GL_RENDERER_SEND_CORRECTED_SIZE

//#define PX_RENDER_VBO

typedef struct
{
	unsigned size;
	unsigned maxSize;

	PXGLColoredTextureVertex *array;
} _PXGLVertexBuffer;

typedef struct
{
	unsigned size;
	unsigned maxSize;

	GLushort *array;
} _PXGLIndexBuffer;

typedef struct
{
	unsigned size;
	unsigned maxSize;

	GLfloat *array;
} _PXGLPointSizeBuffer;

typedef struct
{
	unsigned size;
	unsigned maxSize;
	
	PXGLElementBucket *array;
} _PXGLElementBucketBuffer;

PXGLColoredTextureVertex *pxGLVertexBufferCurrentObject = NULL;
GLushort *pxGLIndexBufferCurrentObject = NULL;
GLfloat *pxGLPointSizeBufferCurrentObject = NULL;
PXGLElementBucket *pxGLElementBucketBufferCurrentObject = NULL;

PXGLState pxGLDefaultState;
PXGLState pxGLState;
PXGLState pxGLStateInGL;

GLuint pxGLBufferVertexColorState = PX_GL_VERTEX_COLOR_RESET;

unsigned pxGLVertexBufferMaxSize = 0;
unsigned pxGLVertexOldBufferMaxSize = 0;

unsigned pxGLIndexBufferMaxSize = 0;
unsigned pxGLIndexOldBufferMaxSize = 0;

unsigned pxGLPointSizeBufferMaxSize = 0;
unsigned pxGLPointSizeOldBufferMaxSize = 0;

unsigned pxGLElementBucketBufferMaxSize = 0;
unsigned pxGLElementBucketOldBufferMaxSize = 0;

_PXGLVertexBuffer pxGLVertexBuffer;
_PXGLIndexBuffer pxGLIndexBuffer;
_PXGLPointSizeBuffer pxGLPointSizeBuffer;
_PXGLElementBucketBuffer pxGLElementBucketBuffer;

GLenum pxGLDrawMode = 0;

const GLubyte pxGLSizeOfIndex = sizeof(GLushort);
const GLubyte pxGLSizeOfPointSize = sizeof(GLfloat);
GLubyte pxGLIsColorArrayEnabled = false;
GLubyte pxGLDrawElements = false;

GLubyte pxGLBufferLastVertexRed   = 0xFF;
GLubyte pxGLBufferLastVertexGreen = 0xFF;
GLubyte pxGLBufferLastVertexBlue  = 0xFF;
GLubyte pxGLBufferLastVertexAlpha = 0xFF;

GLushort pxGLHadDrawnElements = false;
GLushort pxGLHadDrawnArrays = false;

#ifdef PX_DEBUG_MODE
int pxGLDrawCallCount = 0;
#endif

#ifdef PX_RENDER_VBO
GLuint PXGLBufferVertexID = 0;
unsigned PXGLLastMaxBufferVertexSize = 0;
GLuint PXGLBufferIndexID  = 0;
#endif

/*
 * This method initializes the buffer arrays.
 */
void PXGLRendererInit( )
{
	//Set the size to 0, set the max size to the minimum allowed size, and
	//allocate some memory.

	pxGLVertexBuffer.size = 0;
	pxGLVertexBuffer.maxSize = PX_GL_RENDERER_MIN_BUFFER_SIZE;
	pxGLVertexBuffer.array = malloc(sizeof(PXGLColoredTextureVertex) * pxGLVertexBuffer.maxSize);

	pxGLIndexBuffer.size = 0;
	pxGLIndexBuffer.maxSize = PX_GL_RENDERER_MIN_BUFFER_SIZE;
	pxGLIndexBuffer.array = malloc(pxGLSizeOfIndex * pxGLIndexBuffer.maxSize);

	pxGLPointSizeBuffer.size = 0;
	pxGLPointSizeBuffer.maxSize = PX_GL_RENDERER_MIN_BUFFER_SIZE;
	pxGLPointSizeBuffer.array = malloc(pxGLSizeOfPointSize * pxGLPointSizeBuffer.maxSize);

	pxGLElementBucketBuffer.size = 0;
	pxGLElementBucketBuffer.maxSize = PX_GL_RENDERER_MIN_BUFFER_SIZE;
	pxGLElementBucketBuffer.array = malloc(sizeof(PXGLElementBucket) * pxGLElementBucketBuffer.maxSize);

	pxGLVertexBufferCurrentObject = pxGLVertexBuffer.array;
	pxGLIndexBufferCurrentObject = pxGLIndexBuffer.array;
	pxGLPointSizeBufferCurrentObject = pxGLPointSizeBuffer.array;

#ifdef PX_RENDER_VBO
	glGenBuffers(1, &PXGLBufferVertexID);
	glGenBuffers(1, &PXGLBufferIndexID);
#endif
}

/*
 * This method frees the memory used by the buffers.
 */
void PXGLRendererDealloc( )
{
	//If the buffer arrays exist, we should free their memory.

	if (pxGLVertexBuffer.array)
	{
		free(pxGLVertexBuffer.array);
		pxGLVertexBuffer.array = NULL;
	}

	if (pxGLIndexBuffer.array)
	{
		free(pxGLIndexBuffer.array);
		pxGLIndexBuffer.array = NULL;
	}

	if (pxGLPointSizeBuffer.array)
	{
		free(pxGLPointSizeBuffer.array);
		pxGLPointSizeBuffer.array = NULL;
	}

	if (pxGLElementBucketBuffer.array)
	{
		free(pxGLElementBucketBuffer.array);
		pxGLElementBucketBuffer.array = NULL;
	}

#ifdef PX_RENDER_VBO
	if (PXGLBufferVertexID)
		glDeleteBuffers(1, &PXGLBufferVertexID);
	if (PXGLBufferIndexID)
		glDeleteBuffers(1, &PXGLBufferIndexID);
#endif
}

/*
 * This method sets the draw mode, switching modes will cause the buffer to be
 * flushed.  Line loops and strips will also cause the buffer to be flushed, as
 * they can not be combined with anything else.
 *
 * @param GLenum mode - Specifies what kind of primitives to render. Symbolic
 * constants GL_POINTS, GL_LINE_STRIP, GL_LINE_LOOP, GL_LINES,
 * GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, and GL_TRIANGLES are accepted.
 */
void PXGLSetDrawMode(GLenum mode)
{
	//Check to see if our mode has changed, or if we are equal to line loop or
	//strip; if so, then we need to flush the buffer and change modes.
	if (mode != pxGLDrawMode || mode == GL_LINE_LOOP || mode == GL_LINE_STRIP)
	{
		PXGLFlushBuffer();
		pxGLDrawMode = mode;
	}
}

/*
 * This method checks how frequently the color changes, which deterimines later
 * whether or not GLColor4ub or color GLColorPointer should be used.  One
 * should check if bufferVertexColorState is not equal to
 * PX_GL_VERTEX_COLOR_MULTIPLE prior to calling this function.
 *
 * @param GLubyte red   - The red value for the color [0,255]
 * @param GLubyte green - The green value for the color [0,255]
 * @param GLubyte blue  - The blue value for the color [0,255]
 * @param GLubyte alpha - The alpha value for the color [0,255]
 */
void PXGLSetBufferLastVertexColor(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha)
{
	//It should always be within this range.
	assert((pxGLBufferVertexColorState <= PX_GL_VERTEX_COLOR_MULTIPLE));

	//Check to see if the color has changed, if so increment the value.
	if (red   != pxGLBufferLastVertexRed   ||
		green != pxGLBufferLastVertexGreen ||
		blue  != pxGLBufferLastVertexBlue  ||
		alpha != pxGLBufferLastVertexAlpha ||
		pxGLBufferVertexColorState == PX_GL_VERTEX_COLOR_RESET)
	{
		++pxGLBufferVertexColorState;

		pxGLBufferLastVertexRed   = red;
		pxGLBufferLastVertexGreen = green;
		pxGLBufferLastVertexBlue  = blue;
		pxGLBufferLastVertexAlpha = alpha;
	}
}

/*
 * This method enables the color array if it is not enabeled already.
 */
void PXGLEnableColorArray( )
{
	//Check to see if the color array is enabled, if it is then we can just
	//return as our job is done.
	if (pxGLIsColorArrayEnabled)
		return;

	//Actually set the state in GL
	glEnableClientState(GL_COLOR_ARRAY);
	pxGLIsColorArrayEnabled = true;
}

/*
 * This method disables the color array if it is not disabled already.
 */
void PXGLDisableColorArray( )
{
	//Check to see if the color array is not enabled, if that is the case then
	//we can just return as our job is done.
	if (!pxGLIsColorArrayEnabled)
		return;

	//Actually set the state in GL
	glDisableClientState(GL_COLOR_ARRAY);
	pxGLIsColorArrayEnabled = false;
}

/*
 * This method simply returns the current size that the vertex buffer is at.
 *
 * @return - the current size that the vertex buffer is at.
 */
unsigned PXGLGetCurrentVertexIndex( )
{
	return pxGLVertexBuffer.size;
}

/*
 * This method sets the current vertex size (aka. its current indexed
 * position).
 *
 * @param unsigned index - The current indexed position.
 */
void PXGLSetCurrentVertexIndex(unsigned index)
{
	// The index should never be greater or equal to the max size, the max size
	// denotes the actual size that is allocated by the buffer array.
	assert(index < pxGLVertexBuffer.maxSize);

	pxGLVertexBuffer.size = index;
	pxGLVertexBufferCurrentObject = pxGLVertexBuffer.array + pxGLVertexBuffer.size;
}

/*
 * This method simply returns the current size that the index buffer is at.
 *
 * @return - the current size that the index buffer is at.
 */
unsigned PXGLGetCurrentIndex( )
{
	return pxGLIndexBuffer.size;
}

/*
 * This method sets the current index buffer size (aka. its current indexed
 * position).
 *
 * @param unsigned index - The current indexed position.
 */
void PXGLSetCurrentIndex(unsigned index)
{
	//The index should never be greater or equal to the max size, the max size
	//denotes the actual size that is allocated by the buffer array.
	assert(index < pxGLIndexBuffer.maxSize);

	pxGLIndexBuffer.size = index;
	pxGLIndexBufferCurrentObject = pxGLIndexBuffer.array + pxGLIndexBuffer.size;
}

/*
 * This method simply returns the current size that the point size buffer is
 * at.
 *
 * @return - the current size that the point size buffer is at.
 */
unsigned PXGLGetCurrentPointSizeIndex( )
{
	return pxGLPointSizeBuffer.size;
}

/*
 * This method sets the current point size buffer size (aka. its current
 * indexed position).
 *
 * @param unsigned index - The current indexed position.
 */
void PXGLSetCurrentPointSizeIndex(unsigned index)
{
	//The index should never be greater or equal to the max size, the max size
	//denotes the actual size that is allocated by the buffer array.
	assert(index < pxGLPointSizeBuffer.maxSize);

	pxGLPointSizeBuffer.size = index;
	pxGLPointSizeBufferCurrentObject = pxGLPointSizeBuffer.array + pxGLPointSizeBuffer.size;
}

/*
 * This method returns a pointer to the vertex at a given index.  If the index
 * is out of bounds then an assertion is thrown (in debug mode).
 *
 * @return - A pointer to the vertex at the given index.
 */
PXGLColoredTextureVertex *PXGLGetVertexAt(unsigned index)
{
	assert(pxGLVertexBuffer.size != 0 && index < pxGLVertexBuffer.size);

	return pxGLVertexBuffer.array + index;
}

/*
 * This method returns a pointer to the current vertex.  If the buffer is empty
 * this will assert so (in debug mode).
 *
 * @return - A pointer to the current vertex.
 */
PXGLColoredTextureVertex *PXGLCurrentVertex( )
{
	assert(pxGLVertexBuffer.size != 0);

	return pxGLVertexBufferCurrentObject - 1;
}

PXGLColoredTextureVertex *PXGLAskForVertices(unsigned count)
{
	while (pxGLVertexBuffer.size + count >= pxGLVertexBuffer.maxSize)
	{
		//Lets double the size of the array
		pxGLVertexBuffer.maxSize <<= 1;
		pxGLVertexBuffer.array = realloc(pxGLVertexBuffer.array, sizeof(PXGLColoredTextureVertex) * pxGLVertexBuffer.maxSize);
		pxGLVertexBufferCurrentObject = pxGLVertexBuffer.array + pxGLVertexBuffer.size;
	}

	// Lets return the next available vertex for use.
	return pxGLVertexBufferCurrentObject;
}

void PXGLUsedVertices(unsigned count)
{
	pxGLVertexBufferCurrentObject += count;
	pxGLVertexBuffer.size += count;
}

/*
 * This method returns a pointer to the index at a given index.  If the index
 * is out of bounds then an assertion is thrown (in debug mode).
 *
 * @return - A pointer to the index at the given index.
 */
GLushort *PXGLGetIndexAt(unsigned index)
{
	assert(pxGLIndexBuffer.size != 0 && index < pxGLIndexBuffer.size);

	return pxGLIndexBuffer.array + index;
}

/*
 * This method returns a pointer to the current index.  If the buffer is empty
 * this will assert so (in debug mode).
 *
 * @return - A pointer to the current index.
 */
GLushort *PXGLCurrentIndex( )
{
	assert(pxGLIndexBuffer.size != 0);

	return pxGLIndexBufferCurrentObject - 1;
}

GLushort *PXGLAskForIndices(unsigned count)
{
	while (pxGLIndexBuffer.size + count >= pxGLIndexBuffer.maxSize)
	{
		//Lets double the size of the array
		pxGLIndexBuffer.maxSize <<= 1;
		pxGLIndexBuffer.array = realloc(pxGLIndexBuffer.array, pxGLSizeOfIndex * pxGLIndexBuffer.maxSize);
		pxGLIndexBufferCurrentObject = pxGLIndexBuffer.array + pxGLIndexBuffer.size;
	}

	// Lets return the next available vertex for use.
	return pxGLIndexBufferCurrentObject;
}
void PXGLUsedIndices(unsigned count)
{
	pxGLIndexBufferCurrentObject += count;
	pxGLIndexBuffer.size += count;
}

/*
 * This method returns a pointer to the point size at a given index.  If the
 * index is out of bounds then an assertion is thrown (in debug mode).
 *
 * @return - A pointer to the point size at the given index.
 */
GLfloat *PXGLGetPointSizeAt(unsigned index)
{
	assert(pxGLPointSizeBuffer.size != 0 && index < pxGLPointSizeBuffer.size);

	return pxGLPointSizeBuffer.array + index;
}

/*
 * This method returns a pointer to the current point size.  If the buffer is
 * empty this will assert so (in debug mode).
 *
 * @return - A pointer to the current point size.
 */
GLfloat *PXGLCurrentPointSize( )
{
	assert(pxGLPointSizeBuffer.size != 0);

	return pxGLPointSizeBufferCurrentObject - 1;
}

GLfloat *PXGLAskForPointSizes(unsigned count)
{
	while (pxGLPointSizeBuffer.size + count >= pxGLPointSizeBuffer.maxSize)
	{
		//Lets double the size of the array
		pxGLPointSizeBuffer.maxSize <<= 1;
		pxGLPointSizeBuffer.array = realloc(pxGLPointSizeBuffer.array, pxGLSizeOfPointSize * pxGLPointSizeBuffer.maxSize);
		pxGLPointSizeBufferCurrentObject = pxGLPointSizeBuffer.array + pxGLPointSizeBuffer.size;
	}

	// Lets return the next available vertex for use.
	return pxGLPointSizeBufferCurrentObject;
}

void PXGLUsedPointSizes(unsigned count)
{
	pxGLPointSizeBufferCurrentObject += count;
	pxGLPointSizeBuffer.size += count;
}

PXGLElementBucket *PXGLGetElementBuckets(unsigned maxBucketVal)
{
	pxGLElementBucketBuffer.size = maxBucketVal;

	while (pxGLElementBucketBuffer.size >= pxGLElementBucketBuffer.maxSize)
	{
		//Lets double the size of the array
		pxGLElementBucketBuffer.maxSize <<= 1;
		pxGLElementBucketBuffer.array = realloc(pxGLElementBucketBuffer.array, sizeof(PXGLElementBucket) * pxGLElementBucketBuffer.maxSize);
	}

	if (pxGLElementBucketBufferMaxSize < pxGLElementBucketBuffer.size)
		pxGLElementBucketBufferMaxSize = pxGLElementBucketBuffer.size;

	memset(pxGLElementBucketBuffer.array, 0, sizeof(PXGLElementBucket) * pxGLElementBucketBuffer.size);

	// Lets return the next available vertex for use.
	return pxGLElementBucketBuffer.array;
}

/*
 * This method runs through all of the pre-render commands... which as of now
 * none exist.
 */
void PXGLRendererPreRender()
{
}

/*
 * This method flushes the buffer, incase anything is left in it at the end of
 * a render cycle.
 */
void PXGLRendererPostRender( )
{
	assert(pxGLVertexBuffer.array);

	//PXGLSetupEnables();
	// If the array isn't empty, then we need to draw what is left inside it.
	PXGLFlushBuffer( );
}

/*
 * This method consolidates the buffers, meaning if any of the buffers are less
 * then 1/4 of their max size, then it will reduce the size of the buffer to
 * half of it's normal size.
 */
void PXGLConsolidateBuffer()
{
	assert(pxGLVertexBuffer.array);

	//Check to see if the max size is less then then a quarter the size of the
	//previous max.  If it is then make the new size equal to double that of the
	//current max.
	if (pxGLHadDrawnArrays && pxGLVertexBufferMaxSize < (pxGLVertexOldBufferMaxSize >> 2))
	{
		int newMaxSize = pxGLVertexBuffer.maxSize >> 1;
		if (newMaxSize > PX_GL_RENDERER_MIN_BUFFER_SIZE)
		{
			pxGLVertexBuffer.maxSize = newMaxSize;
			pxGLVertexBuffer.array = realloc(pxGLVertexBuffer.array, sizeof(PXGLColoredTextureVertex) * pxGLVertexBuffer.maxSize);
			pxGLVertexBufferCurrentObject = pxGLVertexBuffer.array + pxGLVertexBuffer.size;
		}
	}

	//Lets check it for indices now.
	if (pxGLHadDrawnElements && pxGLIndexBufferMaxSize < (pxGLIndexOldBufferMaxSize >> 2))
	{
		int newMaxSize = pxGLIndexBuffer.maxSize >> 1;
		if (newMaxSize > PX_GL_RENDERER_MIN_BUFFER_SIZE)
		{
			pxGLIndexBuffer.maxSize = newMaxSize;
			pxGLIndexBuffer.array = realloc(pxGLIndexBuffer.array, pxGLSizeOfIndex * pxGLIndexBuffer.maxSize);
			pxGLIndexBufferCurrentObject = pxGLIndexBuffer.array + pxGLIndexBuffer.size;
		}
	}

	//Lets check it for point sizes now.
	if (pxGLPointSizeBufferMaxSize < (pxGLPointSizeOldBufferMaxSize >> 2))
	{
		int newMaxSize = pxGLPointSizeBuffer.maxSize >> 1;
		if (newMaxSize > PX_GL_RENDERER_MIN_BUFFER_SIZE)
		{
			pxGLPointSizeBuffer.maxSize = newMaxSize;
			pxGLPointSizeBuffer.array = realloc(pxGLPointSizeBuffer.array, pxGLSizeOfPointSize * pxGLPointSizeBuffer.maxSize);
			pxGLPointSizeBufferCurrentObject = pxGLPointSizeBuffer.array + pxGLPointSizeBuffer.size;
		}
	}

	if (pxGLHadDrawnElements && pxGLElementBucketBufferMaxSize < (pxGLElementBucketBufferMaxSize >> 2))
	{
		int newMaxSize = pxGLElementBucketBuffer.maxSize >> 1;
		if (newMaxSize > PX_GL_RENDERER_MIN_BUFFER_SIZE)
		{
			pxGLElementBucketBuffer.maxSize = newMaxSize;
			pxGLElementBucketBuffer.array = realloc(pxGLElementBucketBuffer.array, sizeof(PXGLElementBucket) * pxGLElementBucketBuffer.maxSize);
		}
	}

	//Set the old max to the new max.
	pxGLVertexOldBufferMaxSize = pxGLVertexBufferMaxSize;
	pxGLIndexOldBufferMaxSize = pxGLIndexBufferMaxSize;
	pxGLPointSizeOldBufferMaxSize = pxGLPointSizeBufferMaxSize;
	pxGLElementBucketOldBufferMaxSize = pxGLElementBucketBufferMaxSize;

	//Reset the max.
	pxGLVertexBufferMaxSize = 0;
	pxGLIndexBufferMaxSize = 0;
	pxGLPointSizeBufferMaxSize = 0;
	pxGLElementBucketBufferMaxSize = 0;

	//Set the variables to have yet been drawn.
	pxGLHadDrawnArrays = false;
	pxGLHadDrawnElements = false;
}

PXInline void PXGLDraw()
{
	// If the array is larger then max vertices, we should flush it in chunks.
	// This is best done by flushing up until MAX_VERTICES - 2, then again from
	// MAX_VERTICES - 2 until whatever happens next.  This could be
	// 2 * (MAX_VERTICES - 2) or size.  This needs to continue until it is empty

	// HAVE TO BE SIGNED
	int start;
	int amountToDraw = pxGLDrawElements ? pxGLIndexBuffer.size : pxGLVertexBuffer.size;

	if (pxGLDrawElements)
	{
		for (start = 0; amountToDraw > 0; start += PX_GL_RENDERER_MAX_VERTICES_MINUS_2, amountToDraw -= PX_GL_RENDERER_MAX_VERTICES_MINUS_2)
			glDrawElements(pxGLDrawMode, ((amountToDraw < PX_GL_RENDERER_MAX_VERTICES) ? amountToDraw : PX_GL_RENDERER_MAX_VERTICES), GL_UNSIGNED_SHORT, pxGLIndexBuffer.array + start);
	}
	else
	{
		for (start = 0; amountToDraw > 0; start += PX_GL_RENDERER_MAX_VERTICES_MINUS_2, amountToDraw -= PX_GL_RENDERER_MAX_VERTICES_MINUS_2)
			glDrawArrays(pxGLDrawMode, start, ((amountToDraw < PX_GL_RENDERER_MAX_VERTICES) ? amountToDraw : PX_GL_RENDERER_MAX_VERTICES));
	}
}

/*
 * This method flushes the buffer to GL, meaning that it takes whatever the
 * buffer status is right now, and calls the appropriate methods in gl to
 * display them.
 */
void PXGLFlushBufferToGL( )
{
	// Check to see if the color array is enabled, or if we are going to use a
	// color array anyway, if so... lets turn it on!
	if (pxGLBufferVertexColorState == PX_GL_VERTEX_COLOR_MULTIPLE ||
		PX_IS_BIT_ENABLED(pxGLStateInGL.clientState, PX_GL_COLOR_ARRAY))
		//PX_IS_BIT_ENABLED(pxGLClientStateInGL, PX_GL_COLOR_ARRAY))
	{
		PXGLEnableColorArray( );
	}
	else
	{
		PXGLDisableColorArray( );
		glColor4ub(pxGLBufferLastVertexRed,
				   pxGLBufferLastVertexGreen,
				   pxGLBufferLastVertexBlue,
				   pxGLBufferLastVertexAlpha);
	}

	// If the point size array is enabled, then lets set the pointer for it.
	if (PX_IS_BIT_ENABLED(pxGLStateInGL.clientState, PX_GL_POINT_SIZE_ARRAY))
	//if (PX_IS_BIT_ENABLED(pxGLClientStateInGL, PX_GL_POINT_SIZE_ARRAY))
		glPointSizePointerOES(GL_FLOAT, 0, pxGLPointSizeBuffer.array);

	// shorts even though it is actually a boolean, for alignment
	int isTextured = PX_IS_BIT_ENABLED(pxGLStateInGL.clientState, PX_GL_TEXTURE_COORD_ARRAY);
	//int isTextured = PX_IS_BIT_ENABLED(pxGLClientStateInGL, PX_GL_TEXTURE_COORD_ARRAY);

#ifdef PX_RENDER_VBO
	if (PXGLBufferVertexID)
	{
		glBindBuffer(GL_ARRAY_BUFFER, PXGLBufferVertexID);

	//	if (PXGLLastMaxBufferVertexSize != pxGLVertexBuffer.maxSize)
	//	{
	//		PXGLLastMaxBufferVertexSize = pxGLVertexBuffer.maxSize;
	//		glBufferData(GL_ARRAY_BUFFER, sizeof(PXGLColoredTextureVertex) * pxGLVertexBuffer.maxSize, pxGLVertexBuffer.array, GL_DYNAMIC_DRAW);
	//	}
	//	else
	//	{
	//		glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(PXGLColoredTextureVertex) * pxGLVertexBuffer.size, pxGLVertexBuffer.array);
	//	}
		glBufferData(GL_ARRAY_BUFFER, sizeof(PXGLColoredTextureVertex) * pxGLVertexBuffer.size, pxGLVertexBuffer.array, GL_DYNAMIC_DRAW);

		glVertexPointer(2, GL_FLOAT, sizeof(PXGLColoredTextureVertex), (GLvoid *)(0));
		if (pxGLIsColorArrayEnabled)
			glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(PXGLColoredTextureVertex), (GLvoid *)(sizeof(PXGLVertex)));
		if (isTextured)
			glTexCoordPointer(2, GL_FLOAT, sizeof(PXGLColoredTextureVertex), (GLvoid *)(sizeof(PXGLColorVertex)));

		if (pxGLDrawElements)
		{
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, PXGLBufferIndexID);
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(pxGLSizeOfIndex) * pxGLIndexBuffer.size, pxGLIndexBuffer.array, GL_DYNAMIC_DRAW);
			glDrawElements(pxGLDrawMode, pxGLIndexBuffer.size, GL_UNSIGNED_SHORT, (GLvoid *)(0));
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		}
		else
		{
			glDrawArrays(pxGLDrawMode, 0, pxGLVertexBuffer.size);
		}

		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}
#else
	// TODO Later:	Stop this dumb copying. Instead just use the correct chunks
	//				of memory. The reason this is not done now is due to the
	//				color array delima
#ifndef PX_GL_RENDERER_SEND_CORRECTED_SIZE
	glVertexPointer(2, GL_FLOAT, sizeof(PXGLColoredTextureVertex), &(pxGLVertexBuffer.array->x));
	if (isTextured)
		glTexCoordPointer(2, GL_FLOAT, sizeof(PXGLColoredTextureVertex), &(pxGLVertexBuffer.array->s));
	if (pxGLIsColorArrayEnabled)
		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(PXGLColoredTextureVertex), &(pxGLVertexBuffer.array->r));
	
	// Have to call draw here because we are using stack memory
	PXGLDraw( );
#else
	// If we are textured,, and color array is turned on, then we don't need to
	// manipulate the array.. we can just pass it to gl.
	if (isTextured && pxGLIsColorArrayEnabled)
	{
		glVertexPointer(2, GL_FLOAT, sizeof(PXGLColoredTextureVertex), &(pxGLVertexBuffer.array->x));
		glTexCoordPointer(2, GL_FLOAT, sizeof(PXGLColoredTextureVertex), &(pxGLVertexBuffer.array->s));
		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(PXGLColoredTextureVertex), &(pxGLVertexBuffer.array->r));

		// Have to call draw here because we are using stack memory
		PXGLDraw( );
	}
	// If we are textured, but not using a color array, then we are going to
	// store the data into a textured vertex struct.  This means we need to copy
	// the previous data before giving it to gl.
	else if (isTextured)
	{
		// Lets make an array of the same size, except of just textured vertex
		// type.
		PXGLTextureVertex vertices[pxGLVertexBuffer.size];

		PXGLTextureVertex *vertex = vertices;
		PXGLColoredTextureVertex *oldVertex = pxGLVertexBuffer.array;
		// Lets go through the old array, and copy the values.
		for (unsigned index = 0; index < pxGLVertexBuffer.size; ++index)
		{
			vertex->x = oldVertex->x;
			vertex->y = oldVertex->y;
			vertex->s = oldVertex->s;
			vertex->t = oldVertex->t;
			++vertex;
			++oldVertex;
		}

//		glEnable(GL_TEXTURE_2D);
//		glEnableClientState(GL_VERTEX_ARRAY);
//		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		// Lets pass the info onto gl
		glVertexPointer(2, GL_FLOAT, sizeof(PXGLTextureVertex), &(vertices->x));
		glTexCoordPointer(2, GL_FLOAT, sizeof(PXGLTextureVertex), &(vertices->s));

		// Have to call draw here because we are using stack memory
		PXGLDraw( );
	}
	// If the color array is turned on, but it isn't textured, then lets copy
	// the values into a colored vertex array prior to sending it to gl.
	else if (pxGLIsColorArrayEnabled)
	{
		PXGLColorVertex vertices[pxGLVertexBuffer.size];
		PXGLColorVertex *vertex = vertices;
		PXGLColoredTextureVertex *oldVertex = pxGLVertexBuffer.array;
		// Iterate through the array copying over the values to the new one.
		for (unsigned index = 0; index < pxGLVertexBuffer.size; ++index)
		{
			vertex->x = oldVertex->x;
			vertex->y = oldVertex->y;
			vertex->r = oldVertex->r;
			vertex->g = oldVertex->g;
			vertex->b = oldVertex->b;
			vertex->a = oldVertex->a;

			++vertex;
			++oldVertex;
		}

		glVertexPointer(2, GL_FLOAT, sizeof(PXGLColorVertex), &(vertices->x));
		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(PXGLColorVertex), &(vertices->r));

		//Have to call draw here because we are using stack memory
		PXGLDraw( );
	}
	//If the vertices aren't colored, and aren't textured, then lets just draw
	//the vertices.  Before sending the array to GL, lets copy it over.
	else
	{
		//Make an array of just vertices, this needs to be equal size of the
		//previous array.
		PXGLVertex vertices[pxGLVertexBuffer.size];
		PXGLVertex *vertex = vertices;
		PXGLColoredTextureVertex *oldVertex = pxGLVertexBuffer.array;

		for (unsigned index = 0; index < pxGLVertexBuffer.size; ++index)
		{
			vertex->x = oldVertex->x;
			vertex->y = oldVertex->y;
			++vertex;
			++oldVertex;
		}

		glVertexPointer(2, GL_FLOAT, sizeof(PXGLVertex), &(vertices->x));

		//Have to call draw here because we are using stack memory
		PXGLDraw( );
	}
#endif // PX_GL_RENDERER_SEND_CORRECTED_SIZE

#endif // PX_RENDER_VBO

#ifdef PX_DEBUG_MODE
	++pxGLDrawCallCount;
#endif
}

/*
 * This method flushes the buffer, if the buffer is empty then nothing occurs.
 */
void PXGLFlushBuffer( )
{
	//If the buffer is empty, lets just return.
	if (pxGLVertexBuffer.size == 0)
		return;

	//Lets check to see if we are going to draw elements, if so then we should
	//check to see if we have any indices, if not then we can simply return as
	//there is nothing to draw.
	pxGLDrawElements = PX_IS_BIT_ENABLED(pxGLStateInGL.state, PX_GL_DRAW_ELEMENTS);
	//pxGLDrawElements = PX_IS_BIT_ENABLED(pxGLStateInGL, PX_GL_DRAW_ELEMENTS);
	if (pxGLDrawElements && pxGLIndexBuffer.size == 0)
		return;

	//Flush the buffer to gl
	PXGLFlushBufferToGL( );

	//If the max size is less then the current size, lets set the max size to
	//the current size... then reset the size to 0.
	if (pxGLVertexBufferMaxSize < pxGLVertexBuffer.size)
		pxGLVertexBufferMaxSize = pxGLVertexBuffer.size;

	pxGLVertexBuffer.size = 0;
	pxGLVertexBufferCurrentObject = pxGLVertexBuffer.array;

	//If the max size is less then the current size, lets set the max size to
	//the current size... then reset the size to 0.
	if (pxGLIndexBufferMaxSize < pxGLIndexBuffer.size)
		pxGLIndexBufferMaxSize = pxGLIndexBuffer.size;

	pxGLIndexBuffer.size = 0;
	pxGLIndexBufferCurrentObject = pxGLIndexBuffer.array;

	//If the max size is less then the current size, lets set the max size to
	//the current size... then reset the size to 0.
	if (pxGLPointSizeBufferMaxSize < pxGLPointSizeBuffer.size)
		pxGLPointSizeBufferMaxSize = pxGLPointSizeBuffer.size;

	pxGLPointSizeBuffer.size = 0;
	pxGLPointSizeBufferCurrentObject = pxGLPointSizeBuffer.array;

	//Lets reset the colors to their max... aka white and visible.
	pxGLBufferLastVertexRed   = 0xFF;
	pxGLBufferLastVertexGreen = 0xFF;
	pxGLBufferLastVertexBlue  = 0xFF;
	pxGLBufferLastVertexAlpha = 0xFF;

	pxGLBufferVertexColorState = PX_GL_VERTEX_COLOR_RESET;

	if (pxGLDrawElements)
		pxGLHadDrawnElements = true;
	else
		pxGLHadDrawnArrays = true;
}

PXInline_c int PXGLGetDrawCountThenResetIt()
{
#ifdef PX_DEBUG_MODE
	int drawCount = pxGLDrawCallCount;
	pxGLDrawCallCount = 0;
	return drawCount;
#else
	return 0;
#endif
}
