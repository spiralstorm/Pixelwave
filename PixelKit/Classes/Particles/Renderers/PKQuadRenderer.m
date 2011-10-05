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

#import "PKQuadRenderer.h"

#import "PKParticleEmitter.h"
#import "PKParticle.h"

#import "PXLinkedList.h"
#import "PXTextureData.h"

#include "PXMathUtils.h"

#include "PKColor.h"
#include "PXPrivateUtils.h"

#pragma mark -
#pragma mark C Structures
#pragma mark -

typedef struct
{
	PXMathPoint position;
	GLubyte r, g, b, a;
	GLfloat s, t;
} PKQuadParticleVertex;

typedef struct
{
	PKQuadParticleVertex topLeft;
	PKQuadParticleVertex bottomLeft;
	PKQuadParticleVertex topRight;
	PKQuadParticleVertex bottomRight;
} PKQuadParticleVertexQuad;

typedef struct
{
	PKQuadParticleVertex _topLetCopy;
	PKQuadParticleVertexQuad quad;
	PKQuadParticleVertex _bottomRightCopy;
} PKQuadParticleLinkedQuad;

#pragma mark -
#pragma mark C Declarations
#pragma mark -

PXInline PKQuadParticleVertex PKQuadParticleVertexMake(GLfloat x, GLfloat y, GLubyte r, GLubyte g, GLubyte b, GLubyte a, GLfloat s, GLfloat t);
PXInline PKQuadParticleVertexQuad PKQuadParticleVertexQuadMake(PKParticle *particle, CGSize halfSize);
PXInline PKQuadParticleLinkedQuad PKQuadParticleLinkedQuadMake(PKParticle *particle, CGSize halfSize);

@interface PKQuadRenderer(Private)
- (void) setCount:(unsigned int)count;

- (void) drawCurrentWithTextureData:(PXTextureData *)textureData
					  linkeVertices:(PKQuadParticleLinkedQuad * const)linkVertices
						  drawCount:(unsigned int)drawCount
						blendSource:(unsigned short)blendSource
				   blendDestination:(unsigned short)blendDestination;
@end

//#define PKQuadRendererCustom

@implementation PKQuadRenderer

- (id) init
{
	return [self initWithSmoothing:NO];
}

- (id) initWithSmoothing:(BOOL)smoothing
{
	self = [super init];

	if (self)
	{
#ifdef PKQuadRendererCustom
		_renderMode = PXRenderMode_Custom;
#else
		// Color array will always be on
		_PXGLStateEnableClientState(&_glState, GL_COLOR_ARRAY);
#endif

		vertices = NULL;

		self.smoothing = smoothing;
	}

	return self;
}

- (void) dealloc
{
	// Free the memory, the set count method will take care of that.
	[self setCount:0];

	[super dealloc];
}

- (void) setSmoothing:(BOOL)smoothing
{
	if (smoothing)
		smoothingType = GL_LINEAR;
	else
		smoothingType = GL_NEAREST;
}

- (BOOL) smoothing
{
	return (smoothingType == GL_LINEAR);
}

- (void) setCount:(unsigned int)count
{
	unsigned int maxCount = PXMathNextPowerOfTwo(count);

	// If our current count is equal to the max count, then nothing has changed.
	if (maxCount == vertexCount)
		return;

	if (maxCount == 0)
	{
		// If there are 0, we should free our memory.
		if (vertices)
			free(vertices);
		vertices = NULL;
	}
	else if (!vertices)
	{
		// If the vertices don't exist, then we need to allocate.
		vertices = malloc(sizeof(PKQuadParticleLinkedQuad) * maxCount);
	}
	else
	{
		// If they do, then we need to reallocate.
		vertices = realloc(vertices, sizeof(PKQuadParticleLinkedQuad) * maxCount);
	}

	// Set the variable.
	vertexCount = maxCount;
}

- (void) _renderGL
{
	PKParticleEmitter *emitter;

	unsigned int maxCount = 0;
	unsigned int curCount = 0;
	unsigned int drawCount = 0;

	PXLinkedListForEach(emitters, emitter)
	{
		// Loop through each emitter grabbing the count of how many particles it
		// has.
		curCount = PXArrayBufferCount(emitter.particles);
		maxCount = MAX(maxCount, curCount);
	}

	// If the max count is zero, then no emitters have any particles.
	if (maxCount == 0)
		return;

	// Set the count to the new max count (this will take care of redundancies).
	[self setCount:maxCount];

	PKParticle **particlePtr;
	PKParticle *particle;
	PXArrayBuffer *particles;

	PKQuadParticleLinkedQuad * const linkVertices = vertices;
	PKQuadParticleLinkedQuad *currentVertex;

	id graphic = nil;
	PXTextureData *textureData = nil;
	unsigned short blendSource = 0;
	unsigned short blendDestination = 0;

	CGSize halfSize = CGSizeZero;

#ifdef PKQuadRendererCustom
	glEnableClientState(GL_COLOR_ARRAY);
	glVertexPointer(2, GL_FLOAT, sizeof(PKQuadParticleVertex), &(linkVertices->_topLetCopy.position.x));
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(PKQuadParticleVertex), &(linkVertices->_topLetCopy.r));
	glTexCoordPointer(2, GL_FLOAT, sizeof(PKQuadParticleVertex), &(linkVertices->_topLetCopy.s));
#else
	PXGLVertexPointer(2, GL_FLOAT, sizeof(PKQuadParticleVertex), &(linkVertices->_topLetCopy.position.x));
	PXGLColorPointer(4, GL_UNSIGNED_BYTE, sizeof(PKQuadParticleVertex), &(linkVertices->_topLetCopy.r));
	PXGLTexCoordPointer(2, GL_FLOAT, sizeof(PKQuadParticleVertex), &(linkVertices->_topLetCopy.s));
#endif

	PXLinkedListForEach(emitters, emitter)
	{
		particles = emitter.particles;

		drawCount = PXArrayBufferCount(particles);
		// If this emitter has no particles, continue!
		if (drawCount == 0)
			continue;

		particlePtr = particles->array;
		particle = *particlePtr;
		graphic = particle->graphic;
		blendSource = particle->blendSource;
		blendDestination = particle->blendDestination;

		if ([graphic isKindOfClass:[PXTextureData class]])
			textureData = graphic;
		else if ([graphic isKindOfClass:[PXTexture class]])
			textureData = ((PXTexture *)(graphic)).textureData;
		else
			textureData = nil;

		halfSize = (textureData == nil) ? CGSizeMake(0.5f, 0.5f) : CGSizeMake(textureData.width * 0.5f, textureData.height * 0.5f);
 
		// Our vertex count is 6 * the number of particles - 2. Meaning,
		// Quads + degenerate triangels in between and no extra in front or the
		// end.

		drawCount = 0;
		currentVertex = linkVertices;

		PXArrayBufferPtrForEach(particles, particle)
		{
			// Loop through each particle and make a 'linked quad' for it.
			if (particle->graphic != graphic || particle->blendSource != blendSource || particle->blendDestination != blendDestination)
			{
				if (drawCount > 0)
				{
					[self drawCurrentWithTextureData:textureData linkeVertices:linkVertices drawCount:(drawCount - 2) blendSource:blendSource blendDestination:blendDestination];
				}

				drawCount = 0;
				currentVertex = linkVertices;

				graphic = particle->graphic;
				blendSource = particle->blendSource;
				blendDestination = particle->blendDestination;

				if ([graphic isKindOfClass:[PXTextureData class]])
					textureData = graphic;
				else if ([graphic isKindOfClass:[PXTexture class]])
					textureData = ((PXTexture *)(graphic)).textureData;
				else
					textureData = nil;

				halfSize = (textureData == nil) ? CGSizeMake(0.5f, 0.5f) : CGSizeMake(textureData.width * 0.5f, textureData.height * 0.5f);
			}

			*currentVertex = PKQuadParticleLinkedQuadMake(particle, halfSize);
			++currentVertex;
			drawCount += 6;
		}

		if (drawCount > 0)
		{
			[self drawCurrentWithTextureData:textureData linkeVertices:linkVertices drawCount:(drawCount - 2) blendSource:blendSource blendDestination:blendDestination];
		}
	}
}

- (void) drawCurrentWithTextureData:(PXTextureData *)textureData
					  linkeVertices:(PKQuadParticleLinkedQuad * const)linkVertices
						  drawCount:(unsigned int)drawCount
						blendSource:(unsigned short)blendSource
				   blendDestination:(unsigned short)blendDestination
{
#ifdef PKQuadRendererCustom
	glBlendFunc(blendSource, blendDestination);

	if (textureData == nil)
	{
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	else
	{
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);

		// Bind the texture, and update the smoothing value.
		glBindTexture(GL_TEXTURE_2D, textureData->_glName);
		if (smoothingType != textureData->_smoothingType)
		{
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, smoothingType);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, smoothingType);
			textureData->_smoothingType = smoothingType;
		}
	}

	// Draw the quads!
	glDrawArrays(GL_TRIANGLE_STRIP, 1, drawCount);
#else
	// Set the blend function
	PXGLBlendFunc(blendSource, blendDestination);

	if (textureData == nil)
	{
		PXGLDisable(GL_TEXTURE_2D);
		PXGLDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	else
	{
		PXGLEnable(GL_TEXTURE_2D);
		PXGLEnableClientState(GL_TEXTURE_COORD_ARRAY);

		// Bind the texture, and update the smoothing value.
		PXGLBindTexture(GL_TEXTURE_2D, textureData->_glName);
		if (smoothingType != textureData->_smoothingType)
		{
			PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, smoothingType);
			PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, smoothingType);
			textureData->_smoothingType = smoothingType;
		}
	}

	// Draw the quads!
	PXGLDrawArrays(GL_TRIANGLE_STRIP, 1, drawCount);
#endif
}

- (BOOL) isCapableOfRenderingGraphicOfType:(Class)graphicType
{
	return ((graphicType == [PXTextureData class]) || (graphicType == [PXTexture class]) || (graphicType == nil));
}

+ (PKQuadRenderer *)quadRendererWithSmoothing:(BOOL)smoothing
{
	return [[[PKQuadRenderer alloc] initWithSmoothing:smoothing] autorelease];
}

@end

#pragma mark -
#pragma mark C Implementations
#pragma mark -

PXInline PKQuadParticleVertex PKQuadParticleVertexMake(GLfloat x, GLfloat y, GLubyte r, GLubyte g, GLubyte b, GLubyte a, GLfloat s, GLfloat t)
{
	PKQuadParticleVertex retVal;

	retVal.position = PXMathPointMake(x, y);

	retVal.r = r;
	retVal.g = g;
	retVal.b = b;
	retVal.a = a;

	retVal.s = s;
	retVal.t = t;

	return retVal;
}

PXInline PKQuadParticleVertexQuad PKQuadParticleVertexQuadMake(PKParticle *particle, CGSize halfSize)
{
	PKQuadParticleVertexQuad retVal;

	GLfloat x = particle->x;
	GLfloat y = particle->y;

	GLfloat width_2  = halfSize.width  * particle->scaleX;
	GLfloat height_2 = halfSize.height * particle->scaleY;

	GLfloat xMin = x - width_2;
	GLfloat yMin = y - height_2;
	GLfloat xMax = x + width_2;
	GLfloat yMax = y + height_2;

	retVal.topLeft		= PKQuadParticleVertexMake(xMin, yMin, particle->r, particle->g, particle->b, particle->a, particle->sMin, particle->tMin);
	retVal.bottomLeft	= PKQuadParticleVertexMake(xMin, yMax, particle->r, particle->g, particle->b, particle->a, particle->sMin, particle->tMax);
	retVal.topRight		= PKQuadParticleVertexMake(xMax, yMin, particle->r, particle->g, particle->b, particle->a, particle->sMax, particle->tMin);
	retVal.bottomRight	= PKQuadParticleVertexMake(xMax, yMax, particle->r, particle->g, particle->b, particle->a, particle->sMax, particle->tMax);

	if (!PXMathIsZero(particle->rotation))
	{
		GLfloat rotation = -(particle->rotation);

#define PKQuadParticleVertexPointTranfsorm(_pt_, _tx_, _ty_, _cos_, _sin_) \
	PXMathPointMake( (_pt_).x * (_cos_) + (_pt_).y * (_sin_) + (_tx_), \
					-(_pt_).x * (_sin_) + (_pt_).y * (_cos_) + (_ty_))
		GLfloat sinVal = sinf(rotation);
		GLfloat cosVal = cosf(rotation);

		PXMathPoint pt;
		pt = PXMathPointMake(retVal.topLeft.position.x - x, retVal.topLeft.position.y - y);
		retVal.topLeft.position     = PKQuadParticleVertexPointTranfsorm(pt, x, y, cosVal, sinVal);
		pt = PXMathPointMake(retVal.bottomLeft.position.x - x, retVal.bottomLeft.position.y - y);
		retVal.bottomLeft.position  = PKQuadParticleVertexPointTranfsorm(pt, x, y, cosVal, sinVal);
		pt = PXMathPointMake(retVal.topRight.position.x - x, retVal.topRight.position.y - y);
		retVal.topRight.position    = PKQuadParticleVertexPointTranfsorm(pt, x, y, cosVal, sinVal);
		pt = PXMathPointMake(retVal.bottomRight.position.x - x, retVal.bottomRight.position.y - y);
		retVal.bottomRight.position = PKQuadParticleVertexPointTranfsorm(pt, x, y, cosVal, sinVal);
	}

	return retVal;
}

PXInline PKQuadParticleLinkedQuad PKQuadParticleLinkedQuadMake(PKParticle *particle, CGSize halfSize)
{
	PKQuadParticleLinkedQuad retVal;

	retVal.quad = PKQuadParticleVertexQuadMake(particle, halfSize);
	retVal._topLetCopy = retVal.quad.topLeft;
	retVal._bottomRightCopy = retVal.quad.bottomRight;

	return retVal;
}
