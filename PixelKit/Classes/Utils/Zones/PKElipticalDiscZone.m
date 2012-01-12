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
