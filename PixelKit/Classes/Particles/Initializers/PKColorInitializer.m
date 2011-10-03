//
//  PKColorInitializer.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/13/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKColorInitializer.h"
#import "PKParticle.h"

#include "PXMathUtils.h"

@implementation PKColorInitializer

- (id) init
{
	return [self initWithMinColor:0xFFFFFF maxColor:0xFFFFFF];
}

- (id) initWithMinColor:(unsigned int)_minColor maxColor:(unsigned int)_maxColor
{
	self = [super init];

	if (self)
	{
		self.minColor = _minColor;
		self.maxColor = _maxColor;
	}

	return self;
}

- (void) setMinColor:(unsigned int)color
{
	minColor.asUInt = color;
}

- (unsigned int) minColor
{
	return minColor.asUInt;
}

- (void) setMaxColor:(unsigned int)color
{
	maxColor.asUInt = color;
}

- (unsigned int) maxColor
{
	return maxColor.asUInt;
}

- (void) initializeParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter
{
#define PKColorInitializerRandomizeColorFromVariance(_store_, _min_, _max_) \
{ \
	int __val__ = PXMathIntInRange(_min_, _max_); \
	PXMathClamp(__val__, 0x00, 0xFF); \
	_store_ = (__val__); \
}

	PKColorInitializerRandomizeColorFromVariance(particle->r, minColor.asARGB.r, maxColor.asARGB.r);
	PKColorInitializerRandomizeColorFromVariance(particle->g, minColor.asARGB.g, maxColor.asARGB.g);
	PKColorInitializerRandomizeColorFromVariance(particle->b, minColor.asARGB.b, maxColor.asARGB.b);
}

+ (PKColorInitializer *)colorInitializerWithMinColor:(unsigned int)minColor maxColor:(unsigned int)maxColor
{
	return [[[PKColorInitializer alloc] initWithMinColor:minColor maxColor:maxColor] autorelease];
}

@end
