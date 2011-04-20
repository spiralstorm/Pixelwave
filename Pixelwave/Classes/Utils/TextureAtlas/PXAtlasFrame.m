//
//  PXAtlasFrame.m
//  TextureAtlasB
//
//  Created by Oz Michaeli on 4/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PXAtlasFrame.h"

#import "PXTexture.h"
#import "PXTextureData.h"
#import "PXClipRect.h"
#import "PXTexturePadding.h"

#import "PXPoint.h"

#import "PXExceptionUtils.h"

@implementation PXAtlasFrame

@synthesize textureData, clipRect, anchor, padding;

- (id) init
{
	PXThrow(PXException, @"PXAtlasFrame must be initialized with a clipRect and textureData");
	
	[self release];
	return nil;
}

- (id) initWithClipRect:(PXClipRect *)_clipRect
			textureData:(PXTextureData *)_textureData
{
	return [self initWithClipRect:_clipRect
					  textureData:_textureData
						   anchor:nil];
}

- (id) initWithClipRect:(PXClipRect *)_clipRect
			textureData:(PXTextureData *)_textureData
				 anchor:(PXPoint *)_anchor
{
	return [self initWithClipRect:_clipRect
					  textureData:_textureData
						   anchor:_anchor
						  padding:nil];
}

- (id) initWithClipRect:(PXClipRect *)_clipRect
			textureData:(PXTextureData *)_textureData
				 anchor:(PXPoint *)_anchor
				padding:(PXTexturePadding *)_padding
{
	self = [super init];
	if (self)
	{
		textureData = nil;
		clipRect = nil;
		anchor = nil;
		
		self.textureData = _textureData;
		self.clipRect = _clipRect;
		self.anchor = _anchor;
		self.padding = _padding;
	}
	
	return self;
}

- (void) dealloc
{
	[textureData release]; textureData = nil;
	[clipRect release]; clipRect = nil;
	self.anchor = nil;
	self.padding = nil;
	
	[super dealloc];
}

#pragma mark Properties
#pragma mark -

- (void) setTextureData:(PXTextureData *)val
{
	if (val == nil)
	{
		PXThrowNilParam(textureData);
		return;
	}
	
	[val retain];
	[textureData release];
	
	textureData = val;
}

- (void) setClipRect:(PXClipRect *)val
{
	if (val == nil)
	{
		PXThrowNilParam(clipRect);
		return;
	}
	
	val = [val copy];
	[clipRect release];
	
	clipRect = val;
}
- (PXClipRect *)clipRect
{
	return [[clipRect copy] autorelease];
}

#pragma mark Methods
#pragma mark -

- (void) setToTexture:(PXTexture *)texture
{
	texture.textureData = textureData;
	texture.clipRect = clipRect;
	if (anchor)
	{
		[texture setAnchorWithX:anchor.x andY:anchor.y];
	}
	
	if (padding)
	{
		texture.padding = padding;
	}
}

#pragma mark Utility Methods

+ (PXAtlasFrame *)atlasFrameWithClipRect:(PXClipRect *)clipRect
							 textureData:(PXTextureData *)textureData
{
	return [[[PXAtlasFrame alloc] initWithClipRect:clipRect
									   textureData:textureData] autorelease];
}

+ (PXAtlasFrame *)atlasFrameWithClipRect:(PXClipRect *)clipRect
							 textureData:(PXTextureData *)textureData
								 anchorX:(float)anchorX
								 anchorY:(float)anchorY
{
	return [[[PXAtlasFrame alloc] initWithClipRect:clipRect
									   textureData:textureData
											anchor:[PXPoint pointWithX:anchorX
																  andY:anchorY]] autorelease];
}

@end
