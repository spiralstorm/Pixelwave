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

- (id)initWithTop:(ushort)_top
		 andRight:(ushort)_right
		andBottom:(ushort)_bottom
		  andLeft:(ushort)_left
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

+ (PXTexturePadding *)texturePaddingWithTop:(ushort)top
								   andRight:(ushort)right
								  andBottom:(ushort)bottom
									andLeft:(ushort)left
{
	return [[[PXTexturePadding alloc] initWithTop:top
										 andRight:right
										andBottom:bottom
										  andLeft:left] autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[PXTexturePadding allocWithZone:zone] initWithTop:top
													 andRight:right
													andBottom:bottom
													  andLeft:left];
}

@end
