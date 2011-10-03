//
//  PKColorChangeAction.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/13/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKColorChangeAction.h"

#import "PKParticle.h"

#include "PXPrivateUtils.h"

@implementation PKColorChangeAction

- (id) init
{
	return [self initWithStartColor:0xFFFFFF endColor:0xFFFFFF];
}

- (id) initWithStartColor:(unsigned int)_startColor endColor:(unsigned int)_endColor
{
	self = [super init];

	if (self)
	{
		self.startColor = _startColor;
		self.endColor = _endColor;
	}

	return self;
}

- (void) setStartColor:(unsigned int)color
{
	startColor.asUInt = color;
}

- (unsigned int) startColor
{
	return startColor.asUInt;
}

- (void) setEndColor:(unsigned int)color
{
	endColor.asUInt = color;
}

- (unsigned int) endColor
{
	return endColor.asUInt;
}

- (void) updateParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter deltaTime:(float)dt
{
	PKColor color;
	PKColorInterpolate(&color, &startColor, &endColor, 1.0f - particle->energy);

	particle->r = color.asARGB.r;
	particle->g = color.asARGB.g;
	particle->b = color.asARGB.b;
	particle->a = color.asARGB.a;
}

+ (PKColorChangeAction *)colorChangeActionWithStartColor:(unsigned int)startColor endColor:(unsigned int)endColor
{
	return [[[PKColorChangeAction alloc] initWithStartColor:startColor endColor:endColor] autorelease];
}

@end
