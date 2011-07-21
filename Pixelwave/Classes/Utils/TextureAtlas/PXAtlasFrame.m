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

/**
 *	@ingroup Utils
 *
 *	Represents a sub-image within a PXTextureAtlas object.
 *	A PXAtlasFrame is a simple data object containing information
 *	about the sub-image such as its location within the master
 *	atlas image and how it should be translated, rotated, and
 *	padded before being displayed on the screen.
 */
@implementation PXAtlasFrame

@synthesize textureData, clipRect, anchor, padding;

- (id) init
{
	PXThrow(PXException, @"PXAtlasFrame must be initialized with a clipRect and textureData");
	
	[self release];
	return nil;
}

/**
 *	Initializes the PXAtlasFrame object with the given parameters.
 *
 *	@param clipRect
 *		The position and area (in points) of the sub-image within the master
 *		atlas image.
 *	@param textureData
 *		The PXTextureData within which this sub-image is contained.
 */
- (id) initWithClipRect:(PXClipRect *)_clipRect
			textureData:(PXTextureData *)_textureData
{
	return [self initWithClipRect:_clipRect
					  textureData:_textureData
						   anchor:nil];
}

/**
 *	Initializes the PXAtlasFrame object with the given parameters.
 *
 *	@param clipRect
 *		The position and area (in points) of the sub-image within the master
 *		atlas image.
 *	@param textureData
 *		The PXTextureData within which this sub-image is contained.
 *	@param anchor
 *		The anchor point to be assigned to this sub-image when extracted from the
 *		texture atlas. Pass <code>nil</code> for the default value (<code>{0, 0}</code>).
 */
- (id) initWithClipRect:(PXClipRect *)_clipRect
			textureData:(PXTextureData *)_textureData
				 anchor:(PXPoint *)_anchor
{
	return [self initWithClipRect:_clipRect
					  textureData:_textureData
						   anchor:_anchor
						  padding:nil];
}

/**
 *	Initializes the PXAtlasFrame object with the given parameters.
 *
 *	@param clipRect
 *		The position and area (in points) of the sub-image within the master
 *		atlas image.
 *	@param textureData
 *		The PXTextureData within which this sub-image is contained.
 *	@param anchor
 *		The anchor point to be assigned to this sub-image when extracted from the
 *		texture atlas. Pass <code>nil</code> for the default value (<code>{0, 0}</code>).
 *	@param padding
 *		The amount of padding (white space) that should exists around the sub-image
 *		when extracted from the texture atlas.
 */
- (id) initWithClipRect:(PXClipRect *)_clipRect
			textureData:(PXTextureData *)_textureData
				 anchor:(PXPoint *)_anchor
				padding:(PXTexturePadding *)_padding
{
	self = [super init];

	if (self)
	{	
		self.textureData = _textureData;
		self.clipRect = _clipRect;
		self.anchor = _anchor;
		self.padding = _padding;
	}
	
	return self;
}

- (void) dealloc
{
	[textureData release];
	textureData = nil;
	[clipRect release];
	clipRect = nil;

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

/**
 *	A utility method for quickly updating the
 *	given PXTexture object to represent
 *	this frame's sub-image.
 */
- (void) setToTexture:(PXTexture *)texture
{
	texture.textureData = textureData;
	texture.clipRect = clipRect;

	if (anchor)
	{
		[texture setAnchorWithX:anchor.x y:anchor.y];
	}
	
	if (padding)
	{
		texture.padding = padding;
	}
}

#pragma mark Utility Methods

/**
 *	A utility method for quicly creating a PXAtlasFrame
 *	object with the given parameters.
 *
 *	@param clipRect
 *		The position and area (in points) of the sub-image within the master
 *		atlas image.
 *	@param textureData
 *		The PXTextureData within which this sub-image is contained.
 *	@param anchor
 *		The anchor point to be assigned to this sub-image when extracted from the texture atlas.
 *		pass <code>nil</code> for the default value (<code>{0, 0}</code>).
 *	@param padding
 *		The amount of padding (white space) that should exists around the sub-image
 *		when extracted from the texture atlas.
 *
 *	@return
 *		An auto-released PXAtlasFrame object with the given parameters.
 */
+ (PXAtlasFrame *)atlasFrameWithClipRect:(PXClipRect *)clipRect
							 textureData:(PXTextureData *)textureData
{
	return [[[PXAtlasFrame alloc] initWithClipRect:clipRect
									   textureData:textureData] autorelease];
}

/**
 *	A utility method for quicly creating a PXAtlasFrame
 *	object with the given parameters.
 *
 *	@param clipRect
 *		The position and area (in points) of the sub-image within the master
 *		atlas image.
 *	@param textureData
 *		The PXTextureData within which this sub-image is contained.
 *	@param anchorX
 *		The anchorX amount (in percent) to be assigned to this sub-image
 *		when extracted from the texture atlas.
 *	@param anchorY
 *		The anchorY amount (in percent) to be assigned to this sub-image
 *		when extracted from the texture atlas.
 *
 *	@return
 *		An auto-released PXAtlasFrame object with the given parameters.
 */

+ (PXAtlasFrame *)atlasFrameWithClipRect:(PXClipRect *)clipRect
							 textureData:(PXTextureData *)textureData
								 anchorX:(float)anchorX
								 anchorY:(float)anchorY
{
	return [[[PXAtlasFrame alloc] initWithClipRect:clipRect
									   textureData:textureData
											anchor:[PXPoint pointWithX:anchorX
																  y:anchorY]] autorelease];
}

@end
