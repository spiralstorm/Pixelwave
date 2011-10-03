//
//  PKMultiZone.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/13/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKMultiZone.h"

#import "PXLinkedList.h"

#include "PXMathUtils.h"

@implementation PKMultiZone

- (id) init
{
	self = [super init];

	if (self)
	{
		zones = [[PXLinkedList alloc] init];
	}

	return self;
}

- (void) dealloc
{
	[zones release];

	[super dealloc];
}

- (unsigned int) zoneCount
{
	return [zones count];
}

- (id<PKZone>)addZone:(id<PKZone>)zone
{
	[zones addObject:zone];

	return zone;
}

- (BOOL) containsZone:(id<PKZone>)zone
{
	return [zones containsObject:zone];
}

- (void) removeZone:(id<PKZone>)zone
{
	[zones removeObject:zone];
}

- (void) removeAllZones
{
	[zones removeAllObjects];
}

- (BOOL) containsX:(float)x y:(float)y
{
	for (id<PKZone> zone in zones)
	{
		if ([zone containsX:x y:y] == YES)
			return YES;
	}

	return NO;
}

- (float) area
{
	float totalArea = 0.0f;

	for (id<PKZone> zone in zones)
	{
		totalArea += [zone area];
	}

	return totalArea;
}

- (CGPoint) randomPoint
{
	unsigned int count = [zones count];

	if (count == 0)
		return CGPointZero;

	float areas[count];

	float areaAccum = 0.0f;

	float *curArea = areas;
	for (id<PKZone> zone in zones)
	{
		*curArea = zone.area;
		areaAccum += *curArea;
	//	NSLog (@"curArea = %f (%f)\n", *curArea, areaAccum);
		++curArea;
	}
	//NSLog(@"\n");

	float chosenArea = PXMathFloatInRange(0, areaAccum);

	areaAccum = 0.0f;
	curArea = areas;
	for (id<PKZone> zone in zones)
	{
		areaAccum += *curArea;
		++curArea;

		if (chosenArea <= roundf(areaAccum))
			return [zone randomPoint];
	}

	return [[zones lastObject] randomPoint];
}

@end
