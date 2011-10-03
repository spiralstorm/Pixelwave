//
//  PKLineRenderer.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/28/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKLineRenderer.h"

#import "PKParticle.h"

#import "PXPooledObject.h"

#include "PXGLUtils.h"
#include "PXMathUtils.h"

@interface PKLineRendererPolygon : NSObject <PXPooledObject>
{
@public
	PXArrayBuffer *array;
}

- (void) updateFromParticle:(PKParticle *)particle limitCount:(int)limit;
- (void) render;

@end

@implementation PKLineRendererPolygon

- (id) init
{
	self = [super init];

	if (self)
	{
		array = PXArrayBufferCreate();
		PXArrayBufferSetElementSize(array, sizeof(PXGLColorVertex));
	}

	return self;
}

- (void) dealloc
{
	PXArrayBufferRelease(array);

	[super dealloc];
}

- (void) reset
{
	PXArrayBufferUpdateCount(array, 0);
}

- (void) updateFromParticle:(PKParticle *)particle limitCount:(int)limit
{
	if (limit == 0)
	{
		PXArrayBufferUpdateCount(array, 0);
		return;
	}

	if (PXMathIsZero(particle->energy) || particle->energy < 0.0f)
		return;

	unsigned int priorCount = PXArrayBufferCount(array);

	PXGLColorVertex *pt1 = (PXGLColorVertex *)PXArrayBufferNext(array);
	PXGLColorVertex *pt2 = (PXGLColorVertex *)PXArrayBufferNext(array);

	if (pt1 == NULL || pt2 == NULL)
	{
		PXArrayBufferUpdateCount(array, priorCount);
		return;
	}

	pt1->r = particle->r;
	pt1->g = particle->g;
	pt1->b = particle->b;
	pt1->a = particle->a;

	*pt2 = *pt1;

	float halfWidth = particle->scaleX * 0.5f;

	float cosVal = cosf(particle->rotation);
	float sinVal = sinf(particle->rotation);

	pt2->x = cosVal * halfWidth;
	pt2->y = sinVal * halfWidth;

	pt1->x = -pt2->x;
	pt1->y = -pt2->y;

	pt1->x += particle->x;
	pt1->y += particle->y;

	pt2->x += particle->x;
	pt2->y += particle->y;

	if (limit > 0)
	{
		// This is already done
		//limit <<= 1;

		// Add 2, because a limit of '1' should yield 1 line, which consists of
		// 4 points.
		limit += 2;

		priorCount += 2;

		if (limit < priorCount)
		{
			PXArrayBufferShiftLeft(array, priorCount - limit);
		}
	}
}

- (void) render
{
	unsigned int vertexCount = PXArrayBufferCount(array);

	if (vertexCount <= 2)
		return;

	PXGLColorVertex *firstVertex = (PXGLColorVertex *)PXArrayBufferElementAt(array, 0);

	PXGLVertexPointer(2, GL_FLOAT, sizeof(PXGLColorVertex), &(firstVertex->x));
	PXGLColorPointer(4, GL_UNSIGNED_BYTE, sizeof(PXGLColorVertex), &(firstVertex->r));
	PXGLDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
}

@end

PXLinkedList *pkLineRendererPolygons = nil;

@interface PKLineRenderer(Private)
+ (PKLineRendererPolygon *)newPolygon;
+ (void) releasePolygon:(PKLineRendererPolygon *)polygon;
- (PKLineRendererPolygon *)updateParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter;
@end

@implementation PKLineRenderer

- (id) init
{
	self = [super init];

	if (self)
	{
		if (pkLineRendererPolygons == nil)
		{
			pkLineRendererPolygons = [[PXLinkedList alloc] init];
		}
		else
			[pkLineRendererPolygons retain];

		_PXGLStateEnableClientState(&_glState, GL_COLOR_ARRAY);

		emitterToParticleStates = [[NSMutableDictionary alloc] init];

		self.segmentCount = 1;
	}

	return self;
}

- (void) dealloc
{
	// This must be done prior to releasing the line renderer pooled states.
	[self removeAllEmitters];

	if ([pkLineRendererPolygons retainCount] == 1)
	{
		[pkLineRendererPolygons release];
		pkLineRendererPolygons = nil;
	}
	else
		[pkLineRendererPolygons release];

	// Needs to be last.
	[emitterToParticleStates release];

	[super dealloc];
}

+ (PKLineRendererPolygon *)newPolygon
{
	PKLineRendererPolygon *val = nil;

	if ([pkLineRendererPolygons count] == 0)
	{
		val = [[PKLineRendererPolygon alloc] init];
	}
	else
	{
		val = [[pkLineRendererPolygons firstObject] retain];
		[pkLineRendererPolygons removeFirstObject];
	}

	return val;
}

+ (void) releasePolygon:(PKLineRendererPolygon *)val
{
	[val reset];
	[pkLineRendererPolygons addObject:val];
	[val release];
}

- (void) setSegmentCount:(int)segmentCount
{
	if (segmentCount == -1)
		pointCount = -1;
	else
		pointCount = segmentCount << 1;
}

- (int) segmentCount
{
	if (pointCount == -1)
		return -1;

	return pointCount >> 1;
}

- (void) addEmitter:(PKParticleEmitter *)emitter
{
	if (emitter == nil)
		return;

	NSMutableArray *polygons = [[PXLinkedList alloc] init];
	[emitterToParticleStates setObject:polygons forKey:emitter.name];
	[polygons release];

	[super addEmitter:emitter];
}

- (void) removeEmitter:(PKParticleEmitter *)emitter
{
	if (emitter == nil)
		return;

	[emitter retain];

	[super removeEmitter:emitter];

	NSMutableArray *polygons = [emitterToParticleStates objectForKey:emitter.name];
	PKLineRendererPolygon *polygon;

	for (polygon in polygons)
	{
		[PKLineRenderer releasePolygon:polygon];
	}

	[polygons removeAllObjects];

	[emitterToParticleStates removeObjectForKey:emitter.name];

	[emitter release];
}

- (void) particleEmitter:(PKParticleEmitter *)emitter didCreateParticle:(PKParticle *)particle
{
	NSMutableArray *currentParticlePolygons = [emitterToParticleStates objectForKey:emitter.name];

	if (currentParticlePolygons == nil)
		return;

	unsigned int identifier = particle->uid;
	unsigned int count = [currentParticlePolygons count];

	PKLineRendererPolygon *polygon;

	if (identifier >= count)
	{
		count = (identifier - count) + 1;

		for (unsigned int index = 0; index < count; ++index)
		{
			polygon = [PKLineRenderer newPolygon];
			[currentParticlePolygons addObject:polygon];
		}
	}
	else
	{
		polygon = [currentParticlePolygons objectAtIndex:identifier];
		[polygon reset];
	}
}

- (PKLineRendererPolygon *)updateParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter
{
	NSMutableArray *currentParticleStates = [emitterToParticleStates objectForKey:emitter.name];

	if (currentParticleStates == nil)
		return nil;

	PKLineRendererPolygon *polygon = [currentParticleStates objectAtIndex:particle->uid];

	[polygon updateFromParticle:particle limitCount:pointCount];

	return polygon;
}

- (void) _renderGL
{
	if (pointCount == 0)
		return;

	PKParticleEmitter *emitter;

	PXArrayBuffer *particles;
	PKParticle *particle;

	PKLineRendererPolygon *polygon;

	// Loop through each emitter drawing the display object with their particle
	// values.
	PXLinkedListForEach(emitters, emitter)
	{
		particles = emitter.particles;

		PXArrayBufferPtrForEach(particles, particle)
		{
			polygon = [self updateParticle:particle emitter:emitter];

			[polygon render];
		}
	}
}

+ (PKLineRenderer *)lineRenderer
{
	return [[[PKLineRenderer alloc] init] autorelease];
}

@end
