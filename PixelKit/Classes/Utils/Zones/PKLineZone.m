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
