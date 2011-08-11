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

#import "PXPNGTextureParser.h"

#import "PXGL.h"

#import "png.h"
#import <stdio.h>

#import "PXTextureData.h"

#import "PXExceptionUtils.h"

#import "PXDebug.h"
#import "PXMathUtils.h"

// 1 byte = 8 bits, 8 bits * 8 (header bytes) = 64 bits.
typedef u_int64_t _PXPNGHeader;

typedef struct
{
	void *bytes;
	void *curByte;
	
	unsigned byteCount;
	unsigned bytePos;
} PXPNGByteData;

void PXPNGTextureParserLoadPNGFromBytes(png_structp pngPtr, png_bytep bytePtr, png_size_t byteCount);

@interface PXPNGTextureParser(Private)
+ (BOOL) isPNGFromHeader:(_PXPNGHeader)header;

- (void) makePNGStruct:(png_structp *)pngPtr infoStruct:(png_infop *)infoPtr;
- (BOOL) unpackPNGFromPNG:(png_structp *)pngPtr info:(png_infop *)infoPtr;
@end

@implementation PXPNGTextureParser

// This method never gets called
/*
- (id) init
{
 self = [super init];
	if (self)
	{
		vPngPtr  = NULL;
		vInfoPtr = NULL;
	}

	return self;
}
*/

- (void) dealloc
{
	// Lets free the memory for the image, if and only if we used any

	[super dealloc];
}

- (BOOL) isModifiable
{
	return YES;
}

+ (BOOL) isPNGFromHeader:(_PXPNGHeader)header
{
	// Lets make sure that the header of the png file is correct, if it is not
	// then it most likely isn't actually a png file
	void *voip = &header;
	png_bytep bytes = voip;

	if (png_sig_cmp(bytes, 0, sizeof(_PXPNGHeader)))
	{
		return NO;
	}

	return YES;
}

- (void) makePNGStruct:(png_structp *)pngPtr infoStruct:(png_infop *)infoPtr
{
	*pngPtr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if (!*pngPtr)
	{
		PXThrow(PXException, @"PNG - Unable to allocate enough memory to begin reading.");

		return;
	}

	*infoPtr = png_create_info_struct(*pngPtr);
	if (!*infoPtr)
	{
		png_destroy_read_struct(pngPtr, (png_infopp)NULL, (png_infopp)NULL);
		PXThrow(PXException, @"PNG - Unable to allocate enough memory to begin reading.");

		// This is done for me...
		//*pngPtr = NULL;
		return;
	}

	if (setjmp(png_jmpbuf(*pngPtr)))
	{
		png_destroy_read_struct(pngPtr, infoPtr, (png_infopp)NULL);
		PXThrow(PXException, @"PNG - Error occured, PNG long jumped away!");

		// This is done for me...
		//*pngPtr  = NULL;
		//*infoPtr = NULL;
		return;
	}
}

- (BOOL) unpackPNGFromPNG:(png_structp *)pngPtr info:(png_infop *)infoPtr
{
	int bit_depth;
	int color_type;
	int interlace_type;
	int compression_type;
	int filter_type;

	png_set_sig_bytes(*pngPtr, 8);

	png_read_info(*pngPtr, *infoPtr);
	png_uint_32 png_width;
	png_uint_32 png_height;
	png_get_IHDR(*pngPtr, *infoPtr, &png_width, &png_height, &bit_depth,
				 &color_type, &interlace_type, &compression_type, &filter_type);

	unsigned short _width = png_width;
	unsigned short _height = png_height;

	png_set_strip_16(*pngPtr);

//	int preColorType = color_type;
	int preChannels = png_get_channels(*pngPtr, *infoPtr);

//	NSLog(@"preChannels = %d, color_type = %d, compression_type = %d, filter_type = %d, BIT DEPTH = %d\n",
//		  preChannels,
//		  preColorType,
//		  compression_type,
//		  filter_type,
//		  bit_depth);

	BOOL forceOneChannel = NO;

// This is not accurate, in fact, the color_type needs to be ALPHA for only
// alpha, which is rare if at all.
//	if (preChannels == 1 && preColorType == PNG_COLOR_TYPE_PALETTE)
//	{
//		forceOneChannel = YES;
//		png_set_rgb_to_gray(*pngPtr, 1, 0, 0);
//		png_set_swap_alpha(*pngPtr);
//	}

	// expand paletted colors into true RGB triplets
	if (color_type == PNG_COLOR_TYPE_PALETTE)
	{
		png_set_expand(*pngPtr);
	}

	// expand grayscale images to the full 8 bits from 1, 2, or 4 bits/pixel
	//if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
	if (preChannels == 1 && bit_depth < 8)
	{
		png_set_expand(*pngPtr);
	}

	// expand paletted or RGB images with transparency to full alpha channels
	// so the data will be available as RGBA quartets
	if (png_get_valid(*pngPtr, *infoPtr, PNG_INFO_tRNS))
	{
		png_set_expand(*pngPtr);
	}

	png_read_update_info(*pngPtr, *infoPtr);

	if (setjmp(png_jmpbuf(*pngPtr)))
	{
		PXThrow(PXException, @"PNG - Error occured, PNG long jumped away!");
		png_destroy_read_struct(pngPtr, infoPtr, (png_infopp)NULL);

		return NO;
	}

	//Lets allocate enough memory to store the image into rows (scan lines)
	//then grab the image data.
	unsigned int row = 0;
	png_bytep row_pointers[_height];
	unsigned rowBytes = png_get_rowbytes(*pngPtr, *infoPtr);

	for (row = 0; row < _height; row++)
	{
		row_pointers[row] = malloc(rowBytes);
	}
	
	png_read_image(*pngPtr, row_pointers);

	//We need to convert the image to a power of 2 by power of 2 image, so
	//lets increase the size until it fits.  We only need to do this if the
	//image isn't already a power of 2 in size.

	const unsigned texWidth  = PXMathNextPowerOfTwo(_width);
	const unsigned texHeight = PXMathNextPowerOfTwo(_height);

	//If the image used red, green, blue and alpha then we need to allocate
	//4 bytes for each pixel, however if it only uses red, green and blue then
	//we only need to allocate 3 bytes.
	//Lets also grab the difference in width (bytes) so we can properly transfer
	//the data later
	// -------------------- Changed from info->color_type

	const int readChannels = png_get_channels(*pngPtr, *infoPtr);
	const int drawChannels = forceOneChannel ? 1 : readChannels;

	const unsigned drawWidthInBytes = drawChannels * texWidth;
	const unsigned readWidthInBytes = readChannels * _width;

//	NSLog (@"channel count = [said=%d, have=%d], color_type = %d\n", readChannels, drawChannels, color_type);

//	unsigned glFormat;

	switch (drawChannels)
	{
		case 1:
			if (color_type == PNG_COLOR_TYPE_GRAY)
			{
//				glFormat = GL_LUMINANCE;
				textureInfo->pixelFormat = PXTextureDataPixelFormat_L8;
			}
			else
			{
//				glFormat = GL_ALPHA;
				textureInfo->pixelFormat = PXTextureDataPixelFormat_A8;
			}
			break;
		case 2:
//			glFormat = GL_LUMINANCE_ALPHA;
			textureInfo->pixelFormat = PXTextureDataPixelFormat_LA88;
			break;
		case 3:
//			glFormat = GL_RGB;
			textureInfo->pixelFormat = PXTextureDataPixelFormat_RGB888;
			break;
		case 4:
		default:
//			glFormat = GL_RGBA;
			textureInfo->pixelFormat = PXTextureDataPixelFormat_RGBA8888;
			break;
	}

	textureInfo->byteCount = sizeof(GLubyte) * drawWidthInBytes * texHeight;
	textureInfo->bytes = malloc(textureInfo->byteCount);

	// If we couldn't allocate enough memory then lets free what we have used
	// and return unsuccessful
	if (!textureInfo->bytes)
	{
		png_read_end(*pngPtr, *infoPtr);
		png_destroy_read_struct(pngPtr, infoPtr, (png_infopp)NULL);

		for (row = 0; row < _height; ++row)
		{
			free(row_pointers[row]);
		}

		PXThrow(PXException, @"PNG - Couldn't allocate enough memory for the picture");

		return NO;
	}

	// Loop through each of the rows and grab each pixel for the image
	// Should we 0 out the excess width and height?

	GLubyte *drawBytePtr = (GLubyte *)(textureInfo->bytes);
	png_byte *readBytePtr = NULL;

	int rowIndex = 0;

	// This was a big change, instead of iterating through each byte ourselves
	// and coping it, we now let memcpy copy a row at a time for us!
	if (drawChannels == readChannels)
	{
		for (rowIndex = 0; rowIndex < _height; ++rowIndex)
		{
			// Double pointer, so can't quite increment.
			readBytePtr = row_pointers[rowIndex];

			// Copy the row into the larger texture.
			memcpy(drawBytePtr, readBytePtr, readWidthInBytes);

			// This could be done at the end of the for loop; I put it here for
			// clarification.  The draw pointer is incremented by it's width, so
			// that it goes down to the next row for copying.
			drawBytePtr += drawWidthInBytes;
		}
	}
	else
	{
		const int memCpyChannels = MIN(readChannels, drawChannels);
		const float readDiv = readWidthInBytes / readChannels;
		const float drawDiv = drawWidthInBytes / drawChannels;
		const int memCpyCount = MIN(readDiv, drawDiv);
		void *drawBytePtrBefore;
		int colIndex;

		for (rowIndex = 0; rowIndex < _height; ++rowIndex)
		{
			// Double pointer, so can't quite increment.
			readBytePtr = row_pointers[rowIndex];
			drawBytePtrBefore = drawBytePtr;

			for (colIndex = 0; colIndex < memCpyCount; ++colIndex)
			{
				memcpy(drawBytePtr, readBytePtr, memCpyChannels);
				readBytePtr += readChannels;
				drawBytePtr += drawChannels;
			}

			drawBytePtr = drawBytePtrBefore;
			// This could be done at the end of the for loop; I put it here for
			// clarification.  The draw pointer is incremented by it's width, so
			// that it goes down to the next row for copying.
			drawBytePtr += drawWidthInBytes;
		}
	}

	textureInfo->size = CGSizeMake(texWidth, texHeight);
	contentSize = CGSizeMake(_width, _height);

	//Lets make it into an opengl texture, and store it to video memory.

	//Lets free the memory libpng used.
	png_read_end(*pngPtr, *infoPtr);
	png_destroy_read_struct(pngPtr, infoPtr, (png_infopp)NULL);

	//Lets free the memory we used for the rows
	for (row = 0; row < _height; ++row)
	{
		free(row_pointers[row]);
	}

	//Lets return successful
	return YES;
}

#pragma mark Protected Methods

//////////////////////////////////////
// Protected method implementations //
//////////////////////////////////////

- (BOOL) _parse
{
	// Set the image data to null for now, this way if something happens
	// and we do not load the iamge, then we know not to free any memory for it.

	int byteCount = [data length];
	void *bytes = (void *)[data bytes];

	if (byteCount < sizeof(_PXPNGHeader))
	{
		PXThrow(PXException, @"PNG File had incorrect header.");

		return NO;
	}

	_PXPNGHeader *chunks = bytes;
	_PXPNGHeader header = *chunks;
	if (![PXPNGTextureParser isPNGFromHeader:header])
	{
		PXThrow(PXException, @"PNG File had incorrect header.");

		return NO;
	}

	png_structp *pngPtr = (png_structp *)(&vPngPtr);
	png_infop *infoPtr = (png_infop *)(&vInfoPtr);
	[self makePNGStruct:pngPtr infoStruct:infoPtr];

	if (!vPngPtr || !vInfoPtr)
	{
		return NO;
	}

	PXPNGByteData byteData;

	byteData.bytes = bytes;
	byteData.bytePos = sizeof(_PXPNGHeader);
	byteData.curByte = bytes + byteData.bytePos;
	byteData.byteCount = byteCount;

	png_set_read_fn(*pngPtr, &byteData, PXPNGTextureParserLoadPNGFromBytes);

	if (!vPngPtr || !vInfoPtr)
	{
		return NO;
	}

	return [self unpackPNGFromPNG:pngPtr info:infoPtr];
}

+ (BOOL) isApplicableForData:(NSData *)data origin:(NSString *)origin
{
	if (!data)
	{
		return NO;
	}

	int byteCount = [data length];
	const void *bytes = (void *)[data bytes];

	if (byteCount < sizeof(_PXPNGHeader))
	{
		return NO;
	}

	const _PXPNGHeader *chunks = bytes;
	const _PXPNGHeader header = *chunks;

	return [PXPNGTextureParser isPNGFromHeader:header];
}
+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	[extensions addObject:@"png"];
}

@end

void PXPNGTextureParserLoadPNGFromBytes(png_structp pngPtr, png_bytep bytePtr, png_size_t byteCount)
{
	PXPNGByteData *byteData = (PXPNGByteData *)(png_get_io_ptr(pngPtr));

	if (byteData->bytePos + byteCount > byteData->byteCount)
	{
		return;
	}

	png_voidp curPtr = byteData->curByte;

	memcpy(bytePtr, curPtr, byteCount);

	byteData->bytePos += byteCount;
	byteData->curByte += byteCount;
}
