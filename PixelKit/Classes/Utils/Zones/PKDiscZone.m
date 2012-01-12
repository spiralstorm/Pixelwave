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

#import "PKDiscZone.h"
#import "PXMathUtils.h"

@implementation PKDiscZone

@synthesize center, innerRadius, outerRadius;

- (id)init
{
	return [self initWithCenter:CGPointMake(0.0f, 0.0f) outerRadius:0.0f innerRadius:0.0f];
}

- (id) initWithCenter:(CGPoint)_center outerRadius:(float)_outerRadius innerRadius:(float)_innerRadius
{
	self = [super init];

	if (self)
	{
		center = _center;

		self.outerRadius = _outerRadius;
		self.innerRadius = _innerRadius;
	}

	return self;
}

- (id) initWithOuterRadius:(float)_outerRadius innerRadius:(float)_innerRadius
{
	return [self initWithCenter:CGPointMake(0.0f, 0.0f) outerRadius:_outerRadius innerRadius:_innerRadius];
}

- (id) initWithOuterRadius:(float)_outerRadius
{
	return [self initWithCenter:CGPointMake(0.0f, 0.0f) outerRadius:_outerRadius innerRadius:0.0f];
}

- (void) setInnerRadius:(float)value
{
	innerRadius = value;
	innerRadiusSq = value * value;
}

- (void) setOuterRadius:(float)value
{
	outerRadius = value;
	outerRadiusSq = value * value;
}

- (BOOL) containsX:(float)x y:(float)y
{
	x -= center.x;
	y -= center.y;

	float dSq = (x * x) + (y * y);

	return (dSq <= outerRadiusSq) && (dSq >= innerRadiusSq);
}

- (float) area
{
	return M_PI * (outerRadiusSq - innerRadiusSq);
}

- (CGPoint) randomPoint
{
	// Random radius + Random angle
	float rndRadius = PXMathFloatInRange(innerRadius, outerRadius);
	float rndAngle = PXMathFloatInRange(-M_PI, M_PI);

	return CGPointMake(center.x + cosf(rndAngle) * rndRadius,
					   center.y + sinf(rndAngle) * rndRadius);
}

+ (PKDiscZone *)discZoneWithCenter:(CGPoint)center outerRadius:(float)outerRadius innerRadius:(float)innerRadius
{
	return [[[PKDiscZone alloc] initWithCenter:center outerRadius:outerRadius innerRadius:innerRadius] autorelease];
}

+ (PKDiscZone *)discZoneWithOuterRadius:(float)outerRadius innerRadius:(float)innerRadius
{
	return [[[PKDiscZone alloc] initWithCenter:CGPointMake(0.0f, 0.0f) outerRadius:outerRadius innerRadius:innerRadius] autorelease];
}

+ (PKDiscZone *)discZoneWithOuterRadius:(float)outerRadius
{
	return [[[PKDiscZone alloc] initWithCenter:CGPointMake(0.0f, 0.0f) outerRadius:outerRadius innerRadius:0.0f] autorelease];
}

@end
