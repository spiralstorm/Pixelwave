//
//  PKLinearDragAction.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/20/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKParticleActionBase.h"

@interface PKLinearDragAction : PKParticleActionBase
{
@protected
	float drag;
}

@property (nonatomic, assign) float drag;

- (id) initWithDrag:(float)drag;

+ (PKLinearDragAction *)linearDragActionWithDrag:(float)drag;

@end
