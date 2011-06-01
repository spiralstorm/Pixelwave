//
//  PXTexturePadding.m
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PXTexturePadding.h"

@implementation PXTexturePadding

@synthesize top, right, bottom, left;

- (id) init
{
	return [self initWithTop:0.0f right:0.0f bottom:0.0f left:0.0f];
}

- (id) initWithTop:(float)_top
			right:(float)_right
		   bottom:(float)_bottom
			 left:(float)_left
{
	self = [super init];
	if (self)
	{
		top = _top;
		right = _right;
		bottom = _bottom;
		left = _left;
	}
	
	return self;
}

- (void) setTop:(float)_top
		  right:(float)_right
		 bottom:(float)_bottom
		   left:(float)_left
{
	top = _top;
	right = _right;
	bottom = _bottom;
	left = _left;
}

- (id) copyWithZone:(NSZone *)zone
{
	return [[PXTexturePadding allocWithZone:zone] initWithTop:top
														right:right
													   bottom:bottom
														 left:left];
}

+ (PXTexturePadding *)texturePaddingWithTop:(float)top
									  right:(float)right
									 bottom:(float)bottom
									   left:(float)left
{
	return [[[PXTexturePadding alloc] initWithTop:top
											right:right
										   bottom:bottom
											 left:left] autorelease];
}

@end
