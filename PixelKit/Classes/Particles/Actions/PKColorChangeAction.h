//
//  PKColorChangeAction.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/13/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKParticleActionBase.h"

#import "PKColor.h"

@interface PKColorChangeAction : PKParticleActionBase
{
@private
	PKColor startColor;
	PKColor endColor;
}

@property (nonatomic, assign) unsigned int startColor;
@property (nonatomic, assign) unsigned int endColor;

- (id) initWithStartColor:(unsigned int)startColor endColor:(unsigned int)endColor;

+ (PKColorChangeAction *)colorChangeActionWithStartColor:(unsigned int)startColor endColor:(unsigned int)endColor;

@end
