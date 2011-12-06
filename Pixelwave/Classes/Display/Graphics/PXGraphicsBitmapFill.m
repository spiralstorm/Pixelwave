//
//  PXGraphicsBitmapFill.m
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsBitmapFill.h"

#import "PXGraphics.h"

@implementation PXGraphicsBitmapFill

@synthesize textureData;
@synthesize matrix;

@synthesize repeat;
@synthesize smooth;

- (id) init
{
	return [self initWithTextureData:nil];
}

- (id) initWithTextureData:(PXTextureData *)_textureData
{
	return [self initWithTextureData:_textureData matrix:nil];
}

- (id) initWithTextureData:(PXTextureData *)_textureData matrix:(PXMatrix *)_matrix
{
	return [self initWithTextureData:_textureData matrix:_matrix repeat:YES];
}

- (id) initWithTextureData:(PXTextureData *)_textureData matrix:(PXMatrix *)_matrix repeat:(BOOL)_repeat
{
	return [self initWithTextureData:_textureData matrix:_matrix repeat:_repeat smooth:NO];
}

- (id) initWithTextureData:(PXTextureData *)_textureData matrix:(PXMatrix *)_matrix repeat:(BOOL)_repeat smooth:(BOOL)_smooth
{
	self = [super init];

	if (self)
	{
		self.textureData = _textureData;
		self.matrix = _matrix;
		self.repeat = _repeat;
		self.smooth = _smooth;
	}

	return self;
}

- (void) dealloc
{
	self.textureData = nil;
	self.matrix = nil;

	[super dealloc];
}

- (void) _sendToGraphics:(PXGraphics *)graphics
{
	[graphics beginFillWithTextureData:textureData matrix:matrix repeat:repeat smooth:smooth];
}

- (void) _sendToGraphicsAsStroke:(PXGraphics *)graphics
{
	[graphics lineStyleWithTextureData:textureData matrix:matrix repeat:repeat smooth:smooth];
}

@end
