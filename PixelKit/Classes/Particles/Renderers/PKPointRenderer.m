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

#import "PKPointRenderer.h"

#include "PXGLUtils.h"

#import "PKParticle.h"

@interface PKPointRenderer(Private)
- (void) setCount:(unsigned int)count;

- (void) drawCurrentWithTextureData:(PXTextureData *)textureData
						  drawCount:(unsigned int)drawCount
						blendSource:(unsigned short)blendSource
				   blendDestination:(unsigned short)blendDestination;
@end

@implementation PKPointRenderer

@synthesize smoothing;

- (id) init
{
	return [self initWithSmoothing:YES];
}

- (id) initWithSmoothing:(BOOL)_smoothing
{
	self = [super init];
	
	if (self)
	{
		self.smoothing = _smoothing;

		_PXGLStateEnableClientState(&_glState, GL_POINT_SIZE_ARRAY_OES);
		_PXGLStateEnableClientState(&_glState, GL_COLOR_ARRAY);
		
		vertices = NULL;
		sizes = NULL;
	}
	
	return self;
}

- (void) dealloc
{
	// Free the memory, the set count method will take care of that.
	[self setCount:0];

	[super dealloc];
}

- (void) setCount:(unsigned int)count
{
	unsigned maxCount = PXMathNextPowerOfTwo(count);

	// If our current count is equal to the max count, then nothing has changed.
	if (maxCount == vertexCount)
		return;

	if (maxCount == 0)
	{
		// If there are 0, we should free our memory.
		if (vertices)
			free(vertices);
		vertices = NULL;

		if (sizes)
			free(sizes);
		sizes = NULL;
	}
	else if (!vertices)
	{
		// If the vertices don't exist, then we need to allocate.
		vertices = malloc(sizeof(PXGLColorVertex) * maxCount);
		sizes = malloc(sizeof(GLfloat) * maxCount);
	}
	else
	{
		// If they do, then we need to reallocate.
		vertices = realloc(vertices, sizeof(PXGLColorVertex) * maxCount);
		sizes = realloc(sizes, sizeof(GLfloat) * maxCount);
	}

	// Set the variable.
	vertexCount = maxCount;
}

- (void) _renderGL
{
	PKParticleEmitter *emitter;

	unsigned int maxCount = 0;
	unsigned int curCount = 0;
	unsigned int drawCount;

	// Loop through each emitter getting the count.
	PXLinkedListForEach(emitters, emitter)
	{
		curCount = PXArrayBufferCount(emitter.particles);
		maxCount = MAX(maxCount, curCount);
	}

	// If the max count is 0, then all emitters are empty, so we can return -
	// there is nothing to draw.
	if (maxCount == 0)
		return;

	// Set the count to the new max count (this will take care of redundancies).
	[self setCount:maxCount];
	
	if (vertices == nil || sizes == nil)
		return;

	PXGLColorVertex * const pointVertices = vertices;

	PXGLColorVertex *currentVertex;
	GLfloat *currentSize;

	// Set the pointers - these pointers won't change during the duration of
	// this call, so we can set it once and let the for loop only do necessary
	// actions.
	PXGLPointSizePointer(GL_FLOAT, 0, sizes);
	PXGLVertexPointer(2, GL_FLOAT, sizeof(PXGLColorVertex), &(pointVertices->x));
	PXGLColorPointer(4, GL_UNSIGNED_BYTE, sizeof(PXGLColorVertex), &(pointVertices->r));

	PXArrayBuffer *particles;
	PKParticle **particlePtr;
	PKParticle *particle;

	PXTextureData *textureData = nil;
	id graphic = nil;
	float scaleMult = 1.0f;

	unsigned short blendSource = 0;
	unsigned short blendDestination = 0;

	// Loop through each emitter drawing the display object with their particle
	// values.
	PXLinkedListForEach(emitters, emitter)
	{
		particles = emitter.particles;

		// If the emitter is empty, we can just continue.
		drawCount = PXArrayBufferCount(emitter.particles);
		if (drawCount == 0)
			continue;

		particles = emitter.particles;

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

		scaleMult = (textureData == nil) ? 1.0f : textureData.width;

		currentVertex = pointVertices;
		currentSize = sizes;
		drawCount = 0;

		PXArrayBufferPtrForEach(particles, particle)
		{
			if (particle->graphic != graphic || particle->blendSource != blendSource || particle->blendDestination != blendDestination)
			{
				if (drawCount > 0)
				{
					[self drawCurrentWithTextureData:textureData drawCount:drawCount blendSource:blendSource blendDestination:blendDestination];
				}

				drawCount = 0;
				currentVertex = pointVertices;
				currentSize = sizes;

				graphic = particle->graphic;
				blendSource = particle->blendSource;
				blendDestination = particle->blendDestination;

				if ([graphic isKindOfClass:[PXTextureData class]])
					textureData = graphic;
				else if ([graphic isKindOfClass:[PXTexture class]])
					textureData = ((PXTexture *)(graphic)).textureData;
				else
					textureData = nil;

				scaleMult = (textureData == nil) ? 1.0f : textureData.width;
			}

			// Loop through each particle copying it's data.
			currentVertex->x = particle->x;
			currentVertex->y = particle->y;

			currentVertex->r = particle->r;
			currentVertex->g = particle->g;
			currentVertex->b = particle->b;
			currentVertex->a = particle->a;

			*currentSize = particle->scaleX * scaleMult;

			// Increment the pointers.
			++currentVertex;
			++currentSize;
			++drawCount;
		}

		if (drawCount > 0)
		{
			[self drawCurrentWithTextureData:textureData drawCount:drawCount blendSource:blendSource blendDestination:blendDestination];
		}
	}
}

- (void) drawCurrentWithTextureData:(PXTextureData *)textureData
						  drawCount:(unsigned int)drawCount
						blendSource:(unsigned short)blendSource
				   blendDestination:(unsigned short)blendDestination
{
	// Set the blend function
	PXGLBlendFunc(blendSource, blendDestination);

	if (textureData != nil)
	{
		GLuint smoothingType;

		if (smoothing)
			smoothingType = GL_LINEAR;
		else
			smoothingType = GL_NEAREST;

		PXGLEnable(GL_TEXTURE_2D);
		PXGLEnable(GL_POINT_SPRITE_OES);

		// Bind the texture, and update the smoothing value.
		PXGLBindTexture(GL_TEXTURE_2D, textureData->_glName);
		if (smoothingType != textureData->_smoothingType)
		{
			PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, smoothingType);
			PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, smoothingType);
			textureData->_smoothingType = smoothingType;
		}

		// Set the texture enviroment for point sprites.
		PXGLTexEnvi(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
	}
	else
	{
		PXGLDisable(GL_TEXTURE_2D);
		PXGLDisable(GL_POINT_SPRITE_OES);

		// If smoothing is on, we should enable it.
		if (smoothing)
			PXGLEnable(GL_POINT_SMOOTH);
		else
			PXGLDisable(GL_POINT_SMOOTH);
	}

	// Draw the points!
	PXGLDrawArrays(GL_POINTS, 0, drawCount);

	if (textureData != nil)
	{
		PXGLTexEnvi(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_FALSE);
	}
}

- (BOOL) isCapableOfRenderingGraphicOfType:(Class)graphicType
{
	return ((graphicType == [PXTextureData class]) || (graphicType == [PXTexture class]) || (graphicType == nil));
}

+ (PKPointRenderer *)pointRenderer
{
	return [[[PKPointRenderer alloc] init] autorelease];
}

+ (PKPointRenderer *)pointRendererWithSmoothing:(BOOL)smoothing
{
	return [[[PKPointRenderer alloc] initWithSmoothing:smoothing] autorelease];
}

@end
