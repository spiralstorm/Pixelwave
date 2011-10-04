//
//  PointRendererSample.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/28/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PointRendererSample.h"

@implementation PointRendererSample

- (NSString *)description
{
	return @"Dots";
}

- (void) setup
{
	PKPointRenderer *renderer = [PKPointRenderer pointRendererWithSmoothing:YES];
	[self addRenderer:renderer];

	PKParticleEmitter *emitter = [PKParticleEmitter particleEmitter];

	emitter.x = halfStageSize.width;
	emitter.y = halfStageSize.height;

	emitter.flow = [PKPulseFlow pulseFlowWithCount:100 period:2.0f];

	[emitter addInitializer:[PKLifetimeInitializer lifetimeInitializerWithRange:PKRangeMake(1.0f, 5.0f)]];
	[emitter addInitializer:[PKPositionInitializer positionInitializerWithZone:[PKDiscZone discZoneWithOuterRadius:2.0f]]];
	[emitter addInitializer:[PKVelocityInitializer velocityInitializerWithZone:[PKDiscZone discZoneWithOuterRadius:128.0f innerRadius:48.0f]]];
	[emitter addInitializer:[PKColorInitializer colorInitializerWithMinColor:0x000000 maxColor:0xFFFFFF]];
	[emitter addInitializer:[PKBlendInitializer additiveBlendInitializer]];

	[emitter addAction:[PKAgeAction ageAction]];
	[emitter addAction:[PKMoveAction moveAction]];
	[emitter addAction:[PKRandomDriftAction randomDriftWithX:32.0f y:32.0f]];
	[emitter addAction:[PKScaleAction scaleActionWithStartScale:42.0f endScale:0.0f]];
	[emitter addAction:[PKFadeAction fadeAction]];

	[emitter start];

	[renderer addEmitter:emitter];
}

@end
