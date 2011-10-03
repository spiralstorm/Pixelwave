//
//  PKColorInitializer.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/13/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKParticleInitializerBase.h"

#import "PKColor.h"

@interface PKColorInitializer : PKParticleInitializerBase
{
@protected
	PKColor minColor;
	PKColor maxColor;
}

@property (nonatomic, assign) unsigned int minColor;
@property (nonatomic, assign) unsigned int maxColor;

- (id) initWithMinColor:(unsigned int)minColor maxColor:(unsigned int)maxColor;

+ (PKColorInitializer *)colorInitializerWithMinColor:(unsigned int)minColor maxColor:(unsigned int)maxColor;

@end
