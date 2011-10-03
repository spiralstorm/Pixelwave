//
//  PKLineRenderer.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/28/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKParticleRendererBase.h"

#include "PXArrayBuffer.h"

@interface PKLineRenderer : PKParticleRendererBase
{
@protected
	NSMutableDictionary *emitterToParticleStates;

	int pointCount;
}

@property (nonatomic, assign) int segmentCount;

+ (PKLineRenderer *)lineRenderer;

@end
