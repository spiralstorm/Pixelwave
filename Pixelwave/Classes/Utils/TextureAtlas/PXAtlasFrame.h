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
	PXPoint *anchor;
	PXClipRect *clipRect;
}

@property (nonatomic, retain) PXTextureData *textureData;
@property (nonatomic, copy) PXClipRect *clipRect;
@property (nonatomic, copy) PXPoint *anchor;
@property (nonatomic, copy) PXTexturePadding *padding;

// Initializers

- (id)initWithClipRect:(PXClipRect *)clipRect
		   textureData:(PXTextureData *)textureData;

- (id)initWithClipRect:(PXClipRect *)clipRect
		   textureData:(PXTextureData *)textureData
				anchor:(PXPoint *)anchor;

- (id)initWithClipRect:(PXClipRect *)clipRect
		   textureData:(PXTextureData *)textureData
				anchor:(PXPoint *)anchor
			   padding:(PXTexturePadding *)padding;

// Functionality

- (void)setToTexture:(PXTexture *)texture;

// Utility

+ (PXAtlasFrame *)atlasFrameWithClipRect:(PXClipRect *)clipRect
							 textureData:(PXTextureData *)textureData;

+ (PXAtlasFrame *)atlasFrameWithClipRect:(PXClipRect *)clipRect
							 textureData:(PXTextureData *)textureData
								 anchorX:(float)anchorX
								 anchorY:(float)anchorY;

@end
