//
//  AlphaPulse.m
//  PXParticles
//
//  Created by Oz Michaeli on 9/29/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "AlphaPulse.h"
#import "PKParticle.h"

@implementation AlphaPulse

- (void) updateParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter deltaTime:(float)dt
{
	if (particle->userData == NULL)
	{
		particle->userData = (void *)[PXMath randomIntInRangeFrom:21 to:35];
	}

	float delay = (int)particle->userData;

	float value = sinf(particle->energy * delay) * 0xFF;
	particle->a = fabsf(value);
}

+ (AlphaPulse *)alphaPulse
{
	return [[[AlphaPulse alloc] init] autorelease];
}

@end
