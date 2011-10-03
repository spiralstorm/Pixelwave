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

#import "PKDiscSectorZone.h"
#import "PXMathUtils.h"

@implementation PKDiscSectorZone

- (id) initWithCenter:(CGPoint)_center outerRadius:(float)_outerRadius innerRadius:(float)_innerRadius
{
	return [self initWithCenter:_center outerRadius:_outerRadius innerRadius:_innerRadius angleRange:PKRangeMake(0.0f, 360.0f)];
}

- (id) initWithOuterRadius:(float)_outerRadius
			   innerRadius:(float)_innerRadius
				angleRange:(PKRange)_angleRange
{
	return [self initWithCenter:CGPointMake(0.0f, 0.0f) outerRadius:_outerRadius innerRadius:_innerRadius angleRange:_angleRange];
}

- (id) initWithCenter:(CGPoint)_center
		  outerRadius:(float)_outerRadius
		  innerRadius:(float)_innerRadius
		   angleRange:(PKRange)_angleRange
{
	self = [super initWithCenter:_center outerRadius:_outerRadius innerRadius:_innerRadius];

	if (self)
	{
		self.angleRange = _angleRange;
	}

	return self;
}

- (void) setAngleRange:(PKRange)range
{
	range = PKRangeMake(PXMathToRad(range.start), PXMathToRad(range.end));

	// Force min to be the minimum value, and max to be the maximum value.
	angleRange.start = fminf(range.start, range.end);
	angleRange.end = fmaxf(range.start, range.end);
}

- (PKRange) angleRange
{
	return PKRangeMake(PXMathToDeg(angleRange.start), PXMathToDeg(angleRange.end));
}

- (BOOL) containsX:(float)x y:(float)y
{
	x -= center.x;
	y -= center.y;

	float dSq = x * x + y * y;

	if (dSq > outerRadiusSq || dSq < innerRadiusSq)
	{
		return NO;
	}

	// Check the angle
	float angle = atan2f(y, x);

	return angle <= angleRange.end && angle >= angleRange.start;
}

- (float) area
{
	// Min is guaranteed to be less than or equal to max, thus the subtraction
	// will always yield 0 or greater.
	return (outerRadiusSq - innerRadiusSq) * (angleRange.end - angleRange.start) * 0.5f;
}

- (CGPoint) randomPoint
{
	// Random radius + Random angle
	float rndRadius = PXMathFloatInRange(innerRadius, outerRadius);
	float rndAngle = PKRangeRandom(angleRange);

	return CGPointMake(center.x + cosf(rndAngle) * rndRadius,
					   center.y + sinf(rndAngle) * rndRadius);
}

+ (PKDiscSectorZone *)discSectorZoneWithCenter:(CGPoint)center
								   outerRadius:(float)outerRadius
								   innerRadius:(float)innerRadius
									angleRange:(PKRange)angleRange
{
	return [[[PKDiscSectorZone alloc] initWithCenter:center outerRadius:outerRadius innerRadius:innerRadius angleRange:angleRange] autorelease];
}

+ (PKDiscSectorZone *)discSectorZoneWithOuterRadius:(float)outerRadius
										innerRadius:(float)innerRadius
										 angleRange:(PKRange)angleRange
{
	return [[[PKDiscSectorZone alloc] initWithCenter:CGPointMake(0.0f, 0.0f) outerRadius:outerRadius innerRadius:innerRadius angleRange:angleRange] autorelease];
}

@end
