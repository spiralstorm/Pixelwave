//
//  PKLineZone.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/13/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKLineZone.h"

#include "PXMathUtils.h"

@implementation PKLineZone

@synthesize start;
@synthesize end;

- (id) initWithStart:(CGPoint)_start end:(CGPoint)_end
{
	self = [super init];

	if (self)
	{
		start = _start;
		end = _end;
	}

	return self;
}

- (BOOL) containsX:(float)x y:(float)y
{
	PXMathLine line = PXMathLineMake(start.x, start.y, end.x, end.y);
	PXMathPoint point = PXMathPointMake(x, y);

	return PXMathIsPointInLine(&point, &line);
}

- (float) area
{
	// Really want the quantity of pixels that the line consumes. If we return 0
	// as a line contains 0 area, then this would never get chosen in a multi
	// zone

	PXMathPoint point1 = PXMathPointMake(start.x, start.y);
	PXMathPoint point2 = PXMathPointMake(end.x, end.y);

	return PXMathPointDist(point1, point2);
}

- (CGPoint) randomPoint
{
	CGPoint delta = CGPointMake(end.x - start.x, end.y - start.y);
	float mul = PXMathRandom();

	return CGPointMake(start.x + (delta.x * mul), start.y + (delta.y * mul));
}

+ (PKLineZone *)lineZoneWithStart:(CGPoint)start end:(CGPoint)end
{
	return [[[PKLineZone alloc] initWithStart:start end:end] autorelease];
}

@end
