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

#import "PXAtlasFrame.h"

#import "PXTexture.h"
#import "PXTextureData.h"
#import "PXClipRect.h"
#import "PXTexturePadding.h"

#import "PXPoint.h"

#import "PXExceptionUtils.h"

/**
 * Represents a sub-image within a #PXTextureAtlas object.
 *
 * A PXAtlasFrame is a simple data object containing information about the sub-image such as its location within the master atlas image and how it should be translated, rotated, and padded before being displayed on the screen.
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
 * Initializes the PXAtlasFrame object with the given parameters.
 *
 * @param clipRect The position and area (in points) of the sub-image within the master atlas image.
 * @param textureData The PXTextureData within which this sub-image is contained.
 */
- (id) initWithClipRect:(PXClipRect *)_clipRect
			textureData:(PXTextureData *)_textureData
{
	return [self initWithClipRect:_clipRect
					  textureData:_textureData
						   anchor:nil];
}

/**
 * Initializes the PXAtlasFrame object with the given parameters.
 *
 * @param clipRect The position and area (in points) of the sub-image within the master atlas image.
 * @param textureData The PXTextureData within which this sub-image is contained.
 * @param anchor The anchor point to be assigned to this sub-image when extracted from the texture atlas. Pass `nil` for the default value (`{0, 0}`).
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
 * Initializes the PXAtlasFrame object with the given parameters.
 *
 * @param clipRect The position and area (in points) of the sub-image within the master atlas image.
 * @param textureData The PXTextureData within which this sub-image is contained.
 * @param anchor The anchor point to be assigned to this sub-image when extracted from the texture atlas. Pass `nil` for the default value (`{0, 0}`).
 * @param padding The amount of padding (white space) that should exists around the sub-image when extracted from the texture atlas.
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

#pragma mark -
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

#pragma mark -
#pragma mark Methods
#pragma mark -

/**
 * A utility method for quickly updating the given PXTexture object to represent this frame's sub-image.
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
 * A utility method for quicly creating a PXAtlasFrame object with the given parameters.
 *
 * @param clipRect The position and area (in points) of the sub-image within the master atlas image.
 * @param textureData The PXTextureData within which this sub-image is contained.
 *
 * @return An auto-released PXAtlasFrame object with the given parameters.
 */
+ (PXAtlasFrame *)atlasFrameWithClipRect:(PXClipRect *)clipRect
							 textureData:(PXTextureData *)textureData
{
	return [[[PXAtlasFrame alloc] initWithClipRect:clipRect
									   textureData:textureData] autorelease];
}

/**
 * A utility method for quicly creating a PXAtlasFrame object with the given parameters.
 *
 * @param clipRect The position and area (in points) of the sub-image within the master atlas image.
 * @param textureData The PXTextureData within which this sub-image is contained.
 * @param anchorX The anchorX amount (in percent) to be assigned to this sub-image when extracted from the texture atlas.
 * @param anchorY The anchorY amount (in percent) to be assigned to this sub-image when extracted from the texture atlas.
 *
 * @return An auto-released PXAtlasFrame object with the given parameters.
 */
+ (PXAtlasFrame *)atlasFrameWithClipRect:(PXClipRect *)clipRect
							 textureData:(PXTextureData *)textureData
								 anchorX:(float)anchorX
								 anchorY:(float)anchorY
{
	return [[[PXAtlasFrame alloc] initWithClipRect:clipRect
									   textureData:textureData
											anchor:[PXPoint pointWithX:anchorX y:anchorY]] autorelease];
}

@end
