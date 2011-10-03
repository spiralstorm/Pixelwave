//
//  PKBurstFlow.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/14/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKBlastFlow.h"

@implementation PKBlastFlow

@synthesize count;

- (id) initWithCount:(unsigned int)_count
{
	self = [super init];

	if (self)
	{
		self.count = _count;
	}

	return self;
}

- (unsigned int) startWithEmitter:(PKParticleEmitter *)emitter
{
	completed = YES;

	return count;
}
- (unsigned int) updateWithEmitter:(PKParticleEmitter *)emitter deltaTime:(float)dt
{
	return 0;
}

- (BOOL) complete
{
	return completed;
}

+ (PKBlastFlow *)blastFlowWithCount:(unsigned int)count
{
	return [[[PKBlastFlow alloc] initWithCount:count] autorelease];
}

@end
