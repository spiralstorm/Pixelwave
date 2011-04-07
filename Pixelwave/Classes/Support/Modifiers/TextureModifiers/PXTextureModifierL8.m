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

#import "PXTextureModifierL8.h"

@implementation PXTextureModifierL8

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
	if (oldPixelFormat == PXTextureDataPixelFormat_L8)
	{
		// It is already done, no need to modify.
		return NULL;
	}

	unsigned short width  = oldTextureInfo->size.width;
	unsigned short height = oldTextureInfo->size.height;
	unsigned byteCount = width * height;

	PXParsedTextureData *newTextureInfo = PXParsedTextureDataCreate(byteCount);

	if (!newTextureInfo)
	{
		return NULL;
	}

	newTextureInfo->size = CGSizeMake(width, height);

	newTextureInfo->pixelFormat = PXTextureDataPixelFormat_L8;

	unsigned char *writePixels = newTextureInfo->bytes;
	unsigned char *curWritePixel = writePixels;

	unsigned char *readBytes = (unsigned char *)(oldTextureInfo->bytes);
	unsigned char *curReadByte = readBytes;

	unsigned index = 0;
	unsigned pixelCount = byteCount;

	if (oldPixelFormat == PXTextureDataPixelFormat_RGBA8888)
	{
		unsigned char red;
		unsigned char green;
		unsigned char blue;

		const float one_maxAmount = 1.0f / (0xFF * 3.0f);
		float amount;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			red   = *curReadByte; ++curReadByte;
			green = *curReadByte; ++curReadByte;
			blue  = *curReadByte;
			curReadByte += 2;

			amount = (red + green + blue) * one_maxAmount;
			*curWritePixel = amount * 0xFF;
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_RGBA4444)
	{
		unsigned char red;
		unsigned char green;
		unsigned char blue;

		const float one_maxAmount = 0xF * 3.0f;
		float amount;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			red   = (*curReadByte >> 4) & 0xF;
			green = (*curReadByte) & 0xF;
			++curReadByte;

			blue  = (*curReadByte >> 4) & 0xF;
			++curReadByte;

			amount = (red + green + blue) * one_maxAmount;
			*curWritePixel = amount * 0xFF;
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_RGB565)
	{
		unsigned short val;

		unsigned char red;
		unsigned char green;
		unsigned char blue;

		float one_maxAmount = 1.0f / (float)(0x1F + 0x1F + 0x3F);
		float amount;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			val = (curReadByte[0] + curReadByte[1]);
			curReadByte += 2;

			red   = ((val >> 11) & 0x1F);
			green = ((val >> 5) & 0x3F);
			blue  = ((val) & 0x1F);

			amount = (red + green + blue) * one_maxAmount;
			*curWritePixel = (unsigned char)((amount * 0xFF));
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_RGB888)
	{
		unsigned char red;
		unsigned char green;
		unsigned char blue;

		float one_maxAmount = 1.0f / (0xFF * 3);
		float amount;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			red   = (*curReadByte); ++curReadByte;
			green = (*curReadByte); ++curReadByte;
			blue  = (*curReadByte); ++curReadByte;

			amount = (red + green + blue) * one_maxAmount;

			*curWritePixel = (unsigned char)((amount * 0xFF));
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_RGBA5551)
	{
		unsigned short combinedBytes;

		unsigned char red;
		unsigned char green;
		unsigned char blue;

		float one_maxAmount = 1.0f / (0x1F * 3.0f);
		float amount;

		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			combinedBytes = (curReadByte[0] << 8 | curReadByte[1]);
			curReadByte += 2;

			// rrrrrgggggbbbbba
			red   = ((combinedBytes >> 11) & 0x1F);
			green = ((combinedBytes >>  6) & 0x1F);
			blue  = ((combinedBytes >>  1) & 0x1F);

			amount = (red + green + blue) * one_maxAmount;
			*curWritePixel = (unsigned char)((amount * 0xFF));
		}
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_A8)
	{
		memcpy(curWritePixel, oldTextureInfo->bytes, pixelCount);
	}
	else if (oldPixelFormat == PXTextureDataPixelFormat_LA88)
	{
		for (index = 0, curWritePixel = writePixels;
			 index < pixelCount;
			 ++index, ++curWritePixel)
		{
			*curWritePixel = *curReadByte;
			curReadByte += 2;
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
