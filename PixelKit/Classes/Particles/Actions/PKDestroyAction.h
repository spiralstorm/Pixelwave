//
//  PKDestroyZoneAction.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/20/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKParticleActionBase.h"

@protocol PKZone;

@interface PKDestroyAction : PKParticleActionBase
{
@protected
	id<PKZone> zone;

	BOOL zoneIsSafe;
}

@property (nonatomic, retain) id<PKZone> zone;

@property (nonatomic, assign) BOOL zoneIsSafe;

- (id) initWithZone:(id<PKZone>)zone zoneIsSafe:(BOOL)zoneIsSafe;

+ (PKDestroyAction *)destroyActionWithZone:(id<PKZone>)zone zoneIsSafe:(BOOL)zoneIsSafe;

@end
