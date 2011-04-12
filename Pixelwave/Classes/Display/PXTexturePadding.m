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

- (id)initWithTop:(short)_top
			right:(short)_right
		   bottom:(short)_bottom
			 left:(short)_left
{
	if(self = [super init])
	{
		top = _top;
		right = _right;
		bottom = _bottom;
		left = _left;
	}
	
	return self;
}

- (void)setTop:(short)_top
		 right:(short)_right
		bottom:(short)_bottom
		  left:(short)_left
{
	top = _top;
	right = _right;
	bottom = _bottom;
	left = _left;
}

+ (PXTexturePadding *)texturePaddingWithTop:(short)top
									  right:(short)right
									 bottom:(short)bottom
									   left:(short)left
{
	return [[[PXTexturePadding alloc] initWithTop:top
											right:right
										   bottom:bottom
											 left:left] autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[PXTexturePadding allocWithZone:zone] initWithTop:top
														right:right
													   bottom:bottom
														 left:left];
}

@end
