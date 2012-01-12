//
//  Fire.m
//  Particles
//
//  Created by Oz Michaeli on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Fire.h"

@implementation Fire

- (id)init
{
    self = [super init];
    if (self) {
		PXTextureData *image = [PXTextureData textureDataWithContentsOfFile:@"FireParticle.png"];	
			
		self.flow = [PKSteadyFlow steadyFlowWithRate:60];
		
		[self addInitializer:[PKLifetimeInitializer lifetimeInitializerWithRange:PKRangeMake(2, 3)]];
		[self addInitializer:[PKVelocityInitializer velocityInitializerWithZone:[PKDiscSectorZone discSectorZoneWithOuterRadius:20.0f innerRadius:10.0f angleRange:PKRangeMake(0.0f, 180.0f)]]];
		[self addInitializer:[PKPositionInitializer positionInitializerWithZone:[PKDiscZone discZoneWithOuterRadius:3.0f]]];
		[self addInitializer:[PKSharedGraphicInitializer sharedGraphicInitializerWithGraphic:image]];
		
		[self addAction:[PKAgeAction ageAction]];
		[self addAction:[PKMoveAction moveAction]];
		[self addAction:[PKLinearDragAction linearDragActionWithDrag:1.0f]];
		[self addAction:[PKAccelerateAction accelerateActionWithX:0 y:-40]];
		[self addAction:[PKColorChangeAction colorChangeActionWithStartColor:0xFFFFCC00 endColor:0x00CC0000]];
		[self addAction:[PKRotateToDirectionAction rotateToDirectionAction]];
		[self addAction:[PKScaleAction scaleActionWithStartScale:1.0f endScale:1.5f]];

    }
    
    return self;
}

@end
