//
//  PKDisplayObjectZone.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/20/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

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
