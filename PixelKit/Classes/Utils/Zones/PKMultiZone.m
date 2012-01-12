/*
 *  _____                       ___                                            
 * /\  _ `\  __                /\_ \                                           
 * \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
 *  \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
 *   \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
 *    \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
 *     \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
 *       
 *           www.pixelwave.org + www.spiralstormgames.com
 *                            ~;   
 *                           ,/|\.           
 *                         ,/  |\ \.                 Core Team: Oz Michaeli
 *                       ,/    | |  \                           John Lattin
 *                     ,/      | |   |
 *                   ,/        |/    |
 *                 ./__________|----'  .
 *            ,(   ___.....-,~-''-----/   ,(            ,~            ,(        
 * _.-~-.,.-'`  `_.\,.',.-'`  )_.-~-./.-'`  `_._,.',.-'`  )_.-~-.,.-'`  `_._._,.
 * 
 * Copyright (c) 2011 Spiralstorm Games http://www.spiralstormgames.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

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
