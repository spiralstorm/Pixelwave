//
//  PKAlphaInitializer.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/13/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKAlphaInitializer.h"

#import "PKParticle.h"

@implementation PKAlphaInitializer

@synthesize range;

- (id) init
{
	return [self initWithRange:PKRangeMake(0.0f, 0.0f)];
}

- (id) initWithRange:(PKRange)_range
{
	self = [super init];

	if (self)
	{
		self.range = _range;
	}

	return self;
}

- (void) initializeParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter
{
	particle->a = PKRangeRandom(range);
}

+ (PKAlphaInitializer *)alphaInitlializerWithRange:(PKRange)range
{
	return [[[PKAlphaInitializer alloc] initWithRange:range] autorelease];
}

@end
