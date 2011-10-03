//
//  PKDiscZone.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/12/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKElipticalDiscZone.h"

#include "PXMathUtils.h"

@implementation PKElipticalDiscZone

@synthesize x;
@synthesize y;

@synthesize innerWidth;
@synthesize innerHeight;

@synthesize outerWidth;
@synthesize outerHeight;

- (id) initWithX:(float)_x y:(float)_y innerWidth:(float)_innerWidth innerHeight:(float)_innerHeight outerWidth:(float)_outerWidth outerHeight:(float)_outerHeight
{
	self = [super init];

	if (self)
	{
		x = _x;
		y = _y;

		self.innerWidth = _innerWidth;
		self.outerWidth = _outerWidth;
		self.innerHeight = _innerHeight;
		self.outerHeight = _outerHeight;
	}

	return self;
}

- (BOOL) containsX:(float)_x y:(float)_y
{
	CGPoint delta = CGPointMake(x - _x, y - _y);
	CGPoint deltaSq = CGPointMake(delta.x * delta.x, delta.y * delta.y);

	// Contained in outer
	CGPoint outerRadi = CGPointMake(outerWidth * 0.5f, outerHeight * 0.5f);
	CGPoint outerRadiSq = CGPointMake(outerRadi.x * outerRadi.x, outerRadi.y * outerRadi.y);

	BOOL containsInOuter = (deltaSq.x / outerRadiSq.x) + (deltaSq.y / outerRadiSq.y) < 1.0f;

	// Contained in inner
	CGPoint innerRadi = CGPointMake(outerWidth * 0.5f, outerHeight * 0.5f);
	CGPoint innerRadiSq = CGPointMake(innerRadi.x * innerRadi.x, innerRadi.y * innerRadi.y);

	BOOL containsInInner = (deltaSq.x / innerRadiSq.x) + (deltaSq.y / innerRadiSq.y) < 1.0f;

	return (containsInOuter == YES) && (containsInInner == NO);
}

- (float) area
{
	return M_PI_4 * ((outerWidth * outerHeight) - (innerWidth * innerHeight));
}

- (CGPoint) randomPoint
{
	float angle = PXMathFloatInRange(-M_PI, M_PI);
	CGPoint innerRadi = CGPointMake(innerWidth * 0.5f, innerHeight * 0.5f);
	CGPoint outerRadi = CGPointMake(outerWidth * 0.5f, outerHeight * 0.5f);

	float sinVal = sinf(angle);
	float cosVal = cosf(angle);

	CGPoint innerDistance = CGPointMake(sinVal * innerRadi.x, cosVal * innerRadi.y);
	CGPoint outerDistance = CGPointMake(sinVal * outerRadi.x, cosVal * outerRadi.y);

	CGPoint deltaRadi = CGPointMake(outerDistance.x - innerDistance.x, outerDistance.y - innerDistance.y);

	CGPoint mul = CGPointMake(PXMathRandom(), PXMathRandom());

	return CGPointMake(innerDistance.x + x + (deltaRadi.x * mul.x), innerDistance.y + y + (deltaRadi.y * mul.y));
}

+ (PKElipticalDiscZone *)ellipticalDiscZoneWithX:(float)x y:(float)y innerWidth:(float)innerWidth innerHeight:(float)innerHeight outerWidth:(float)outerWidth outerHeight:(float)outerHeight
{
	return [[[PKElipticalDiscZone alloc] initWithX:x y:y innerWidth:innerWidth innerHeight:innerHeight outerWidth:outerWidth outerHeight:outerHeight] autorelease];
}

@end
