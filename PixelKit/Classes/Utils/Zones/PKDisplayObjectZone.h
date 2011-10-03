//
//  PKDisplayObjectZone.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/20/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKZone.h"

#include "PXArrayBuffer.h"

@class PXDisplayObject;

@interface PKDisplayObjectZone : NSObject<PKZone>
{
@protected
	PXDisplayObject *displayObject;

	PXArrayBuffer *points;

	float area;
}

@property (nonatomic, retain) PXDisplayObject *displayObject;

- (id) initWithDisplayObject:(PXDisplayObject *)displayObject;

+ (PKDisplayObjectZone *)displayObjectZoneWithDisplayObject:(PXDisplayObject *)displayObject;

@end
