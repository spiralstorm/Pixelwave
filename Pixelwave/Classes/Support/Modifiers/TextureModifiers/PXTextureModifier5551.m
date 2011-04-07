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

#import "PXTextureModifier5551.h"

@implementation PXTextureModifier5551

// TODO: Clean up this entire method, it could be a lot more trim.
// TODO: Test each different type.
- (PXParsedTextureData *)newModifiedTextureDataFromData:(PXParsedTextureData *)oldTextureInfo
{
	if (!oldTextureInfo)
	{
		return NULL;
	}

	PXTextureDataPixelFormat oldPixelFormat = oldTextureInfo->pixelFormat;

	// NOT SUPPORTED
	if (oldPixelFormat == PXTextureDataPixelFormat_RGB_PVRTC2  ||
		oldPixelFormat == PXTextureDataPixelFormat_RGB_PVRTC4  ||
		oldPixelFormat == PXTextureDataPixelFormat_RGBA_PVRTC2 ||
		oldPixelFormat == PXTextureDataPixelFormat_RGBA_PVRTC4)
	{
		return NULL;
	}
	if (oldPixelFormat == PXTextureDataPixelFormat_RGBA5551)
	{
		// It is already done, no need to modify.
		return NULL;
	}

	unsigned short width  = oldTextureInfo->size.width;
	unsigned short height = oldTextureInfo->size.height;
	unsigned byteCount = width * height * 2;

	PXParsedTextureData *newTextureInfo = PXParsedTextureDataCreate(byteCount);

	if (!newTextureInfo)
	{
		return NULL;
	}

	newTextureInfo->size = CGSizeMake(width, height);

	newTextureInfo->pixelFormat = PXTextureDataPixelFormat_RGBA5551;

	unsigned short *writePixels = (unsigned short *)(newTextureInfo->bytes);
	unsigned short *curWritePixel;
	unsigned index = 0;
	unsigned pixelCount = byteCount >> 1;

	if (oldPixelFormat == PXTextureDataPixelFormat_RGBA8888)
	{
		unsigned char *readBytes = (unsigned char *)(oldTextureInfo->bytes);
		unsigned char *curReadByte = readBytes;

		unsigned char red;
		unsigned char green;
		unsigned char blue;
		unsigned char alpha;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			red   = ((*curReadByte) >> 3); ++curReadByte;
			green = ((*curReadByte) >> 3); ++curReadByte;
			blue  = ((*curReadByte) >> 3); ++curReadByte;
			alpha = ((*curReadByte) > 127) ? 1 : 0; ++curReadByte;

			// Lets turn it into rrrrrgggggbbbbba, by shifting we are putting the
			// bits into the proper position
			*curWritePixel = (red << 11) | (green << 6) | (blue << 1) | alpha;
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_RGBA4444)
	{
		unsigned char *readBytes = (unsigned char *)(oldTextureInfo->bytes);
		unsigned char *curReadByte = readBytes;

		unsigned char val1;
		unsigned char val2;

		unsigned char red;
		unsigned char green;
		unsigned char blue;
		unsigned char alpha;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			val1 = (*curReadByte); ++curReadByte;
			val2 = (*curReadByte); ++curReadByte;

			red   = ((val1 >> 4) & 0xF) << 1;
			green = ((val1) & 0xF) << 1;
			blue  = ((val2 >> 4) & 0xF) << 1;
			alpha = ((((val2) & 0xF) << 1) < 127) ? 1 : 0;

			// Lets turn it into rrrrrgggggbbbbba, by shifting we are putting the
			// bits into the proper position
			*curWritePixel = (red << 11) | (green << 6) | (blue << 1) | alpha;
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_RGB565)
	{
		unsigned short *readBytes = (unsigned short *)(oldTextureInfo->bytes);
		unsigned short *curReadByte = readBytes;

		unsigned short val;

		unsigned char red;
		unsigned char green;
		unsigned char blue;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			val = (*curReadByte); ++curReadByte;

			red   = ((val >> 11) & 0x1F);
			green = ((val >> 5) & 0x3F) >> 1;
			blue  = ((val) & 0x1F);

			// Lets turn it into rrrrrgggggbbbbba, by shifting we are putting the
			// bits into the proper position
			*curWritePixel = (red << 11) | (green << 6) | (blue << 1) | 1;
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_RGB888)
	{
		unsigned char *readBytes = (unsigned char *)(oldTextureInfo->bytes);
		unsigned char *curReadByte = readBytes;

		unsigned char red;
		unsigned char green;
		unsigned char blue;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			red   = ((*curReadByte) >> 3); ++curReadByte;
			green = ((*curReadByte) >> 3); ++curReadByte;
			blue  = ((*curReadByte) >> 3); ++curReadByte;

			// Lets turn it into rrrrrgggggbbbbba, by shifting we are putting the
			// bits into the proper position
			*curWritePixel = (red << 11) | (green << 6) | (blue << 1) | 1;
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_L8)
	{
		unsigned char *readBytes = (unsigned char *)(oldTextureInfo->bytes);
		unsigned char *curReadByte = readBytes;

		unsigned char val;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			val = ((*curReadByte) >> 3); ++curReadByte;

			// Lets turn it into rrrrrgggggbbbbba, by shifting we are putting the
			// bits into the proper position
			*curWritePixel = (val << 11) | (val << 6) | (val << 1) | 1;
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_A8)
	{
		unsigned char *readBytes = (unsigned char *)(oldTextureInfo->bytes);
		unsigned char *curReadByte = readBytes;

		const unsigned short fillVal = 65534;
		unsigned char alpha;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			alpha = ((*curReadByte) > 127) ? 1 : 0; ++curReadByte;

			// Lets turn it into rrrrrgggggbbbbba, by shifting we are putting the
			// bits into the proper position
			*curWritePixel = fillVal | alpha;
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_LA88)
	{
		unsigned char *readBytes = (unsigned char *)(oldTextureInfo->bytes);
		unsigned char *curReadByte = readBytes;

		unsigned char val;
		unsigned char alpha;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			val = ((*curReadByte) >> 3); ++curReadByte;
			alpha = ((*curReadByte) > 127) ? 1 : 0; ++curReadByte;
			
			// Lets turn it into rrrrrgggggbbbbba, by shifting we are putting the
			// bits into the proper position
			*curWritePixel = (val << 11) | (val << 6) | (val << 1) | alpha;
		}
	}
	else
	{
		// Gave me an unkown format.
		return NULL;
	}

	return newTextureInfo;
}

@end
