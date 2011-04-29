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

#import "PXTextureModifierA8.h"
#include "PXTextureFormatUtils.h"

@implementation PXTextureModifierA8

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
	if (oldPixelFormat == PXTextureDataPixelFormat_A8)
	{
		// It is already done, no need to modify.
		return NULL;
	}

	unsigned short width  = oldTextureInfo->size.width;
	unsigned short height = oldTextureInfo->size.height;
	unsigned pixelCount = width * height;
	unsigned byteCount = pixelCount * sizeof(PXTF_A_8);

	PXParsedTextureData *newTextureInfo = PXParsedTextureDataCreate(byteCount);

	if (!newTextureInfo)
	{
		return NULL;
	}

	newTextureInfo->size = CGSizeMake(width, height);
	newTextureInfo->pixelFormat = PXTextureDataPixelFormat_A8;

	PXTF_A_8 *writePixels = newTextureInfo->bytes;

	switch (oldPixelFormat)
	{
		case PXTextureDataPixelFormat_RGBA8888:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGBA_8888, PXTF_A_8_From_RGBA_8888);
			break;
		case PXTextureDataPixelFormat_RGBA4444:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGBA_4444, PXTF_A_8_From_RGBA_4444);
			break;
		case PXTextureDataPixelFormat_RGB565:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGB_565, PXTF_A_8_From_RGB_565);
			break;
		case PXTextureDataPixelFormat_RGB888:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGB_888, PXTF_A_8_From_RGB_888);
			break;
		case PXTextureDataPixelFormat_RGBA5551:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGBA_5551, PXTF_A_8_From_RGBA_5551);
			break;
		case PXTextureDataPixelFormat_LA88:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_LA_88, PXTF_A_8_From_LA_88);
			break;
		case PXTextureDataPixelFormat_L8:
			//_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_L_8, PXTF_A_8_From_L_8);
			memcpy(writePixels, oldTextureInfo->bytes, byteCount);
			break;
		default:
			PXParsedTextureDataFree(newTextureInfo);
			newTextureInfo = NULL;
	}

	return newTextureInfo;
}

@end
