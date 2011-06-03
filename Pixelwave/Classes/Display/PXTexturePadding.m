//
//  PXTexturePadding.m
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PXTexturePadding.h"

@implementation PXTexturePadding

#pragma mark -
#pragma mark init/dealloc
#pragma mark -

- (id) init
{
	return [self initWithTop:0.0f right:0.0f bottom:0.0f left:0.0f];
}

- (id) initWithTop:(float)top right:(float)right bottom:(float)bottom left:(float)left
{
	return [self _initWithPadding:_PXTexturePaddingMake(top, right, bottom, left)];
}

- (id) _initWithPadding:(_PXTexturePadding)_padding
{
	self = [super init];

	if (self)
	{
		padding = _padding;
	}

	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	return [[PXTexturePadding allocWithZone:zone] _initWithPadding:padding];
}

#pragma mark -
#pragma mark properties
#pragma mark -

- (float) top
{
	return padding.top;
}
- (void) setTop:(float)top
{
	padding.top = MAX(0.0f, top);
}
- (float) right
{
	return padding.right;
}
- (void) setRight:(float)right
{
	padding.right = MAX(0.0f, right);
}
- (float) bottom
{
	return padding.bottom;
}
- (void) setBottom:(float)bottom
{
	padding.bottom = MAX(0.0f, bottom);
}
- (float) left
{
	return padding.left;
}
- (void) setLeft:(float)left
{
	padding.left = MAX(0.0f, left);
}

- (void) setTop:(float)top right:(float)right bottom:(float)bottom left:(float)left
{
	padding = _PXTexturePaddingMake(top, right, bottom, left);
}

#pragma mark -
#pragma mark static methods
#pragma mark -

+ (PXTexturePadding *)texturePaddingWithTop:(float)top right:(float)right bottom:(float)bottom left:(float)left
{
	return [[[PXTexturePadding alloc] _initWithPadding:_PXTexturePaddingMake(top, right, bottom, left)] autorelease];
}

@end

#pragma mark -
#pragma mark c methods
#pragma mark -

_PXTexturePadding _PXTexturePaddingMake(float top, float right, float bottom, float left)
{
	_PXTexturePadding retVal;

	retVal.top    = top;
	retVal.right  = right;
	retVal.bottom = bottom;
	retVal.left   = left;

	return retVal;
}
