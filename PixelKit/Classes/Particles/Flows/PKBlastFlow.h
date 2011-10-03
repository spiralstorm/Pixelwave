//
//  PKBurstFlow.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/14/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKParticleFlowBase.h"

@interface PKBlastFlow : PKParticleFlowBase
{
@protected
	unsigned int count;

	BOOL completed;
}

@property (nonatomic, assign) unsigned int count;

- (id) initWithCount:(unsigned int)count;

+ (PKBlastFlow *)blastFlowWithCount:(unsigned int)count;

@end
