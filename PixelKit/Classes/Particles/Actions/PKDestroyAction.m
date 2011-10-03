//
//  PKDestroyZoneAction.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/20/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKDestroyAction.h"

#import "PKZone.h"
#import "PKParticle.h"

@implementation PKDestroyAction

@synthesize zone;
@synthesize zoneIsSafe;

- (id) initWithZone:(id<PKZone>)_zone zoneIsSafe:(BOOL)_zoneIsSafe
{
	self = [super init];

	if (self)
	{
		self.zone = _zone;
		self.zoneIsSafe = _zoneIsSafe;
	}

	return self;
}

- (void) dealloc
{
	self.zone = nil;

	[super dealloc];
}

- (void) updateParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter deltaTime:(float)dt
{
	BOOL contains = [zone containsX:particle->x y:particle->y];

	if (contains != zoneIsSafe)
	{
		particle->isExpired = YES;
	}
}

+ (PKDestroyAction *)destroyActionWithZone:(id<PKZone>)zone zoneIsSafe:(BOOL)zoneIsSafe
{
	return [[[PKDestroyAction alloc] initWithZone:zone zoneIsSafe:zoneIsSafe] autorelease];
}

@end
