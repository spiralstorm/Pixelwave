//
//  DesignerSample.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/19/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "DesignerSample.h"

@implementation DesignerSample

- (NSString *)description
{
	return @"Firewall";
}

- (void) setup
{
	// By default premultiply alpha is set to YES, this way it matches particle
	// designer
	//PKParticleEffect *effect = [PKParticleEffect particleEffectWithContentsOfFile:@"Firewall.pex" premultiplyAlpha:NO];
	PKParticleEffect *effect = [PKParticleEffect particleEffectWithContentsOfFile:@"Firewall.pex"];

	PKParticleEmitter *emitter = nil;
	PKQuadRenderer *renderer = (PKQuadRenderer *)[effect spawnRendererContainingEmitter:&emitter];

	[self addRenderer:renderer];
	[emitter start];
}

@end
