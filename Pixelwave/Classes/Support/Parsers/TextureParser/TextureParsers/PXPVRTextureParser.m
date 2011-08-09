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

#import "PXGL.h"

#import "PXTextureData.h"
#import "PXPVRTextureParser.h"

#import "PXExceptionUtils.h"

typedef enum
{
	PVRTCType_2 = 24,
	PVRTCType_4
} PVRTCType;

typedef struct _PVRTexHeader
{
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
} PVRTexHeader;

#define PVR_TEXTURE_FLAG_TYPE_MASK      0xFF

@implementation PXPVRTextureParser

/*
- (id) init
{
 self = [super init];
	if (self)
	{
	}

	return self;
}
*/

- (void) dealloc
{
	[imageData removeAllObjects];
	[imageData release];
	imageData = nil;

	[super dealloc];
}

- (BOOL) isModifiable
{
	return NO;
}

+ (BOOL) isApplicableForData:(NSData *)data origin:(NSString *)origin
{
	if (!data)
	{
		return NO;
	}

	PVRTexHeader *header = (PVRTexHeader *)[data bytes];
	uint32_t pvrTag = CFSwapInt32LittleToHost(header->pvrTag);
	static char gPVRTexIdentifier[4] = "PVR!";

	if (gPVRTexIdentifier[0] != ((pvrTag >> 0) & 0xff) ||
	    gPVRTexIdentifier[1] != ((pvrTag >> 8) & 0xff) ||
	    gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
	    gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff))
	{
		return NO;
	}

	return YES;
}
+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	[extensions addObject:@"pvr"];
	[extensions addObject:@"pvrtc"];
}

////PVR///////////////////////////////////////////////////////////
//Copied from PVRTexture sample
//Loads PVR files - have headers and possibly nested mimmaps

- (BOOL) unpackPVR
{
	BOOL success = FALSE;

	PVRTexHeader *header = NULL;

	uint32_t flags;
	uint32_t pvrTag;
	uint32_t dataLength = 0;
	uint32_t dataOffset = 0;
	uint32_t dataSize = 0;
	uint32_t blockSize = 0;
	uint32_t widthBlocks = 0;
	uint32_t heightBlocks = 0;
	uint32_t width = 0;
	uint32_t height = 0;
	uint32_t bpp = 4;
	uint8_t *bytes = NULL;
	uint32_t formatFlags;

	uint textureWidth;
	uint textureHeight;

	BOOL hasAlpha = FALSE;

	//GLenum _internalFormat;

	header = (PVRTexHeader *)[data bytes];

	pvrTag = CFSwapInt32LittleToHost(header->pvrTag);

	static char gPVRTexIdentifier[4] = "PVR!";

	if (gPVRTexIdentifier[0] != ((pvrTag >> 0) & 0xFF) ||
	    gPVRTexIdentifier[1] != ((pvrTag >> 8) & 0xFF) ||
	    gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xFF) ||
	    gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xFF))
	{
		return FALSE;
	}

	flags = CFSwapInt32LittleToHost(header->flags);
	formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;

	if (formatFlags == PVRTCType_2 || formatFlags == PVRTCType_4)
	{
		[imageData removeAllObjects];

		if (CFSwapInt32LittleToHost(header->bitmaskAlpha))
			hasAlpha = TRUE;
		else
			hasAlpha = FALSE;

		if (formatFlags == PVRTCType_4)
		{
			if (hasAlpha)
				internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
			else
				internalFormat = GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
		}
		else if (formatFlags == PVRTCType_2)
		{
			if (hasAlpha)
				internalFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
			else
				internalFormat = GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
		}

		textureWidth  = width = CFSwapInt32LittleToHost(header->width);
		textureHeight = height = CFSwapInt32LittleToHost(header->height);

		dataLength = CFSwapInt32LittleToHost(header->dataLength);

		bytes = ((uint8_t *)[data bytes]) + sizeof(PVRTexHeader);

		// Calculate the data size for each texture level and respect the minimum number of blocks
		while (dataOffset < dataLength)
		{
			if (formatFlags == PVRTCType_4)
			{
				blockSize = 16; // (4 * 4) Pixel by pixel block size for 4bpp
				widthBlocks  = width >> 2; // divide by 4
				heightBlocks = height >> 2; // divide by 4
				bpp = 4;
			}
			else
			{
				blockSize = 32; // (8 * 4) Pixel by pixel block size for 2bpp
				widthBlocks  = width >> 3; // divide by 8
				heightBlocks = height >> 2; // divide by 4
				bpp = 2;
			}

			// Clamp to minimum number of blocks
			if (widthBlocks < 2)
			{
				widthBlocks = 2;
			}
			
			if (heightBlocks < 2)
			{
				heightBlocks = 2;
			}

			dataSize = widthBlocks * heightBlocks * ((blockSize * bpp) >> 3); // divide by 8

			[imageData addObject:[NSData dataWithBytes:bytes + dataOffset length:dataSize]];

			dataOffset += dataSize;

			width  = MAX(width  >> 1, 1);
			height = MAX(height >> 1, 1);
		}

		success = TRUE;
	}

	if ([imageData count] == 0)
	{
		return NO;
	}

	if (success)
	{
		// SET THE VARIABLES
		int pixelF = 0;

		if (internalFormat == GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG)
		{
			pixelF = PXTextureDataPixelFormat_RGBA_PVRTC4;
		}
		else if (internalFormat == GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG)
		{
			pixelF = PXTextureDataPixelFormat_RGB_PVRTC4;
		}
		else if (internalFormat == GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG)
		{
			pixelF = PXTextureDataPixelFormat_RGBA_PVRTC2;
		}
		else if (internalFormat == GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG)
		{
			pixelF = PXTextureDataPixelFormat_RGB_PVRTC2;
		}

		textureInfo->pixelFormat = pixelF;
		textureInfo->size = CGSizeMake(textureWidth, textureHeight);
		contentSize = CGSizeMake(textureWidth, textureHeight);
//		hasAlphaChannel = hasAlpha;
	}

	return success;
}

#pragma mark Protected Methods

//////////////////////////////////////
// Protected method implementations //
//////////////////////////////////////

- (BOOL) _parse
{
	// TODO: Figure out a way to find this info out instead of just guessing
	internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;

	if (data != nil)
	{
		imageData = [[NSMutableArray alloc] initWithCapacity:10];

		if ([self unpackPVR])
		{
			return YES;
		}
		else
		{
			//Error unpacking
		}
	}
	else
	{
		//Error loading
	}

	//There was an error, go back

	[imageData release];
	imageData = nil;

	return NO;
}

- (BOOL) _initializeTexture:(GLuint)texName
{	
	int width = textureInfo->size.width;
	int height = textureInfo->size.height;
	NSData *imgDataSection;
	GLenum err;

	int mipmapsCount = [imageData count];

	NSAssert(mipmapsCount > 0, @"This PVR file has no images in it");

	int i;
	for (i = 0; i < mipmapsCount; i++)
	{
		imgDataSection = [imageData objectAtIndex:i];
		glCompressedTexImage2D(GL_TEXTURE_2D,
							   i, internalFormat, width, height,
							   0, [imgDataSection length], [imgDataSection bytes]);

		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			NSString *desc = [NSString stringWithFormat:@"Error uploading compressed texture level: %d. glError: 0x%04X", i, err];
			PXThrow(PXGLException, desc);
			desc = nil;

			return NO;
		}

		width = MAX(width >> 1, 1);
		height = MAX(height >> 1, 1);
	}

	return YES;
}

@end
