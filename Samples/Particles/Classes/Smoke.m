//
//  Smoke.m
//  Particles
//
//  Created by Oz Michaeli on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Smoke.h"

@implementation Smoke

- (id)init
{
    self = [super init];
    if (self) {
		PXTextureData *image = [PXTextureData textureDataWithContentsOfFile:@"dot.png"];
		
		self.flow = [PKSteadyFlow steadyFlowWithRate:10];
		
		[self addInitializer:[PKLifetimeInitializer lifetimeInitializerWithRange:PKRangeMake(11, 12)]];
		[self addInitializer:[PKVelocityInitializer velocityInitializerWithZone:[PKDiscSectorZone discSectorZoneWithOuterRadius:40.0f innerRadius:30.0f angleRange:PKRangeMake(-102.857f, -77.143f)]]];
		[self addInitializer:[PKSharedGraphicInitializer sharedGraphicInitializerWithGraphic:image]];
		[self addInitializer:[PKPositionInitializer positionInitializerWithZone:[PKDiscZone discZoneWithOuterRadius:3.0f]]];
		
		[self addAction:[PKAgeAction ageAction]];
		[self addAction:[PKMoveAction moveAction]];
		[self addAction:[PKLinearDragAction linearDragActionWithDrag:0.001f]];
		[self addAction:[PKScaleAction scaleActionWithStartScale:1.0f * (12.0f / 64.0f)
														   endScale:15.0f * (12.0f / 64.0f)]];
		[self addAction:[PKFadeAction fadeActionWithStart:0.15f end:0.0f]];
		[self addAction:[PKRandomDriftAction randomDriftWithX:15.0f y:15.0f]];
    }
    
    return self;
}

@end
