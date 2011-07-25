//
//  PXTexturePadding.m
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PXTexturePadding.h"

/**
 *	@ingroup Display
 *
 *	A simple object representing the white-space (if any)
 *	to be included around a PXTexture.
 */
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
	self = [super init];
	
	if (self)
	{
		_padding = _PXTexturePaddingMake(top, right, bottom, left);
	}
	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	return [[PXTexturePadding allocWithZone:zone] initWithTop:_padding.top
														right:_padding.right
													   bottom:_padding.bottom
														 left:_padding.left];
}

#pragma mark -
#pragma mark properties
#pragma mark -

- (float) top
{
	return _padding.top;
}
- (void) setTop:(float)top
{
	_padding.top = MAX(0.0f, top);
}
- (float) right
{
	return _padding.right;
}
- (void) setRight:(float)right
{
	_padding.right = MAX(0.0f, right);
}
- (float) bottom
{
	return _padding.bottom;
}
- (void) setBottom:(float)bottom
{
	_padding.bottom = MAX(0.0f, bottom);
}
- (float) left
{
	return _padding.left;
}
- (void) setLeft:(float)left
{
	_padding.left = MAX(0.0f, left);
}

- (void) setTop:(float)top right:(float)right bottom:(float)bottom left:(float)left
{
	_padding = _PXTexturePaddingMake(top, right, bottom, left);
}

#pragma mark -
#pragma mark static methods
#pragma mark -

+ (PXTexturePadding *)texturePaddingWithTop:(float)top right:(float)right bottom:(float)bottom left:(float)left
{
	return [[[PXTexturePadding alloc] initWithTop:top right:right bottom:bottom left:left] autorelease];
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
