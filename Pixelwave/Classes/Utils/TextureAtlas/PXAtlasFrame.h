//
//  PXAtlasFrame.h
//  TextureAtlasB
//
//  Created by Oz Michaeli on 4/10/11.
//  Copyright 2011 NA. All rights reserved.
//

@class PXTexture;
@class PXTextureData;
@class PXClipRect;
@class PXPoint;
@class PXTexturePadding;

@interface PXAtlasFrame : NSObject
{
@private
	PXTextureData *textureData;
	PXClipRect *clipRect;
	PXPoint *anchor;
	PXTexturePadding *padding;
}

/**
 *	The master atlas image within this frame's sub-image is
 *	located.
 */
@property (nonatomic, retain) PXTextureData *textureData;
/**
 *	The location and area of this frame's sub-image within
 *	the master atlas image.
 */
@property (nonatomic, copy) PXClipRect *clipRect;
/**
 *	The anchor point to be used when this frame is extracted from
 *	the texture atlas. The anchor point is defined in percent
 *	values within the sub-image's frame.
 */
@property (nonatomic, copy) PXPoint *anchor;
/**
 *	The amount of padding (in points) that should exist around the
 *	sub-image represented by this frame when extracted from the texture atlas.
 *
 *	This padding doesn't actually exist in the atlas image,
 *	but is used 'inflate' it, adding back any white-space it
 *	had before being added to the texture atlas.
 */
@property (nonatomic, copy) PXTexturePadding *padding;

// Initializers

- (id) initWithClipRect:(PXClipRect *)clipRect
		   textureData:(PXTextureData *)textureData;

- (id) initWithClipRect:(PXClipRect *)clipRect
		   textureData:(PXTextureData *)textureData
				anchor:(PXPoint *)anchor;

- (id) initWithClipRect:(PXClipRect *)clipRect
		   textureData:(PXTextureData *)textureData
				anchor:(PXPoint *)anchor
			   padding:(PXTexturePadding *)padding;

// Functionality

- (void) setToTexture:(PXTexture *)texture;

// Creation methods

+ (PXAtlasFrame *)atlasFrameWithClipRect:(PXClipRect *)clipRect
							 textureData:(PXTextureData *)textureData;

+ (PXAtlasFrame *)atlasFrameWithClipRect:(PXClipRect *)clipRect
							 textureData:(PXTextureData *)textureData
								 anchorX:(float)anchorX
								 anchorY:(float)anchorY;

@end
