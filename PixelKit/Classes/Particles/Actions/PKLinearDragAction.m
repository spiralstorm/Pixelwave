//
//  PKLinearDragAction.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/20/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKLinearDragAction.h"

#import "PKParticle.h"

@implementation PKLinearDragAction

@synthesize drag;

- (id) initWithDrag:(float)_drag
{
	self = [super init];

	if (self)
	{
		drag = _drag;
	}

	return self;
}

- (void) updateParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter deltaTime:(float)dt
{
	// TODO Later: Add a division of 'mass' to scale

	float scale = 1.0f - (drag * dt);

	if (scale <= 0.0f)
	{
		particle->velocityX = 0.0f;
		particle->velocityY = 0.0f;
	}
	else
	{
		particle->velocityX *= scale;
		particle->velocityY *= scale;
	}
}

+ (PKLinearDragAction *)linearDragActionWithDrag:(float)drag
{
	return [[[PKLinearDragAction alloc] initWithDrag:drag] autorelease];
}

@end
