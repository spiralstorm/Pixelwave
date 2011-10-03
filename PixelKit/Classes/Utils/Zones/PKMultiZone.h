//
//  PKMultiZone.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/13/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKZone.h"

@class PXLinkedList;

@interface PKMultiZone : NSObject<PKZone>
{
@protected
	PXLinkedList *zones;

@protected
	PXLinkedList *zoneStack;
}

@property (nonatomic, readonly) unsigned int zoneCount;

- (id<PKZone>)addZone:(id<PKZone>)zone;

- (BOOL) containsZone:(id<PKZone>)zone;

- (void) removeZone:(id<PKZone>)zone;
- (void) removeAllZones;

@end
