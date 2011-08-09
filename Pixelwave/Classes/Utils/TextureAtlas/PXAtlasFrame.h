/*
 *  _____                       ___                                            
 * /\  _ `\  __                /\_ \                                           
 * \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
 *  \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
 *   \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
 *    \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
 *     \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
 *       
 *           www.pixelwave.org + www.spiralstormgames.com
 *                            ~;   
 *                           ,/|\.           
 *                         ,/  |\ \.                 Core Team: Oz Michaeli
 *                       ,/    | |  \                           John Lattin
 *                     ,/      | |   |
 *                   ,/        |/    |
 *                 ./__________|----'  .
 *            ,(   ___.....-,~-''-----/   ,(            ,~            ,(        
 * _.-~-.,.-'`  `_.\,.',.-'`  )_.-~-./.-'`  `_._,.',.-'`  )_.-~-.,.-'`  `_._._,.
 * 
 * Copyright (c) 2011 Spiralstorm Games http://www.spiralstormgames.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

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
 * The master atlas image within this frame's sub-image is
 * located.
 */
@property (nonatomic, retain) PXTextureData *textureData;
/**
 * The location and area of this frame's sub-image within
 * the master atlas image.
 */
@property (nonatomic, copy) PXClipRect *clipRect;
/**
 * The anchor point to be used when this frame is extracted from
 * the texture atlas. The anchor point is defined in percent
 * values within the sub-image's frame.
 */
@property (nonatomic, copy) PXPoint *anchor;
/**
 * The amount of padding (in points) that should exist around the
 * sub-image represented by this frame when extracted from the texture atlas.
 *
 * This padding doesn't actually exist in the atlas image,
 * but is used 'inflate' it, adding back any white-space it
 * had before being added to the texture atlas.
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
