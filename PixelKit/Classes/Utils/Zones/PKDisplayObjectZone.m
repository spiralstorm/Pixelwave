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

#import "PKDisplayObjectZone.h"

#import "PXDisplayObject.h"
#import "PXStage.h"
#import "PXRectangle.h"

#include "PXMathUtils.h"

@implementation PKDisplayObjectZone

@synthesize displayObject;

- (id) initWithDisplayObject:(PXDisplayObject *)_displayObject
{
	self = [super init];

	if (self)
	{
		points = PXArrayBufferCreate();
		PXArrayBufferSetElementSize(points, sizeof(PXMathPoint));

		self.displayObject = _displayObject;
	}

	return self;
}

- (void) dealloc
{
	self.displayObject = nil;

	PXArrayBufferRelease(points);
	points = NULL;

	[super dealloc];
}

- (void) setDisplayObject:(PXDisplayObject *)_displayObject
{
	[_displayObject retain];
	[displayObject release];
	displayObject = _displayObject;

	PXArrayBufferUpdateCount(points, 0);
	area = 0.0f;

	if (displayObject)
	{
		PXRectangle *bounds = [displayObject boundsWithCoordinateSpace:displayObject];
		CGPoint start = CGPointMake(bounds.x, bounds.y);
		CGSize size = CGSizeMake(bounds.width, bounds.height);

		CGPoint offset;
		CGPoint checkPoint;
		PXMathPoint *point;

		float increment = 1.0f / [[PXStage mainStage] contentScaleFactor];

		for (offset.y = 0.0f, checkPoint.y = start.y; offset.y < size.height; offset.y += increment, checkPoint.y += increment)
		{
			for (offset.x = 0.0f, checkPoint.x = start.x; offset.x < size.width; offset.x += increment, checkPoint.x += increment)
			{
				if ([self containsX:checkPoint.x y:checkPoint.y])
				{
					point = PXArrayBufferNext(points);

					point->x = checkPoint.x;
					point->y = checkPoint.y;

					area += increment;
				}
			}
		}
	}
}

- (BOOL) containsX:(float)x y:(float)y
{
	return [displayObject hitTestPointWithX:x y:y shapeFlag:YES];
}

- (float) area
{
	return area;
}

- (CGPoint) randomPoint
{
	unsigned int count = PXArrayBufferCount(points);

	if (count == 0)
		return CGPointZero;

	unsigned int val = PXMathIntInRange(0, count);

	PXMathPoint *point = (PXMathPoint *)(PXArrayBufferElementAt(points, val));

	if (point == NULL)
		return CGPointZero;

	return CGPointMake(point->x, point->y);
}

+ (PKDisplayObjectZone *)displayObjectZoneWithDisplayObject:(PXDisplayObject *)displayObject
{
	return [[[PKDisplayObjectZone alloc] initWithDisplayObject:displayObject] autorelease];
}

@end
