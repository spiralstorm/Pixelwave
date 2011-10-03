//
//  PKAlphaInitializer.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/13/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKParticleInitializerBase.h"
#import "PKRange.h"

@interface PKAlphaInitializer : PKParticleInitializerBase
{
@protected
	PKRange range;
}

@property (nonatomic, assign) PKRange range;

- (id)initWithRange:(PKRange)range;

+ (PKAlphaInitializer *)alphaInitlializerWithRange:(PKRange)range;

@end
