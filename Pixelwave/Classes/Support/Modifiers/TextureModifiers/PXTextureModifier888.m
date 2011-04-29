//
//  PXTextureModifier888.m
//  Pixelwave
//
//  Created by John Lattin on 4/29/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PXTextureModifier888.h"

#include "PXTextureFormatUtils.h"

// TODO: Check into getting this to work.
@implementation PXTextureModifier888

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
	if (oldPixelFormat == PXTextureDataPixelFormat_RGB888)
	{
		// It is already done, no need to modify.
		return NULL;
	}

	unsigned short width  = oldTextureInfo->size.width;
	unsigned short height = oldTextureInfo->size.height;
	unsigned pixelCount = width * height;
	unsigned byteCount = pixelCount * sizeof(PXTF_RGB_888);

	PXParsedTextureData *newTextureInfo = PXParsedTextureDataCreate(byteCount);

	if (!newTextureInfo)
	{
		return NULL;
	}

	newTextureInfo->size = CGSizeMake(width, height);
	newTextureInfo->pixelFormat = PXTextureDataPixelFormat_RGB888;

	PXTF_RGB_888 *writePixels = (PXTF_RGB_888 *)(newTextureInfo->bytes);

	switch (oldPixelFormat)
	{
		case PXTextureDataPixelFormat_RGBA8888:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGBA_8888, PXTF_RGB_888_From_RGBA_8888);
			break;
		case PXTextureDataPixelFormat_RGBA4444:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGBA_4444, PXTF_RGB_888_From_RGBA_4444);
			break;
		case PXTextureDataPixelFormat_RGB565:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGB_565, PXTF_RGB_888_From_RGB_565);
			break;
		case PXTextureDataPixelFormat_RGBA5551:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGBA_5551, PXTF_RGB_888_From_RGBA_5551);
			break;
		case PXTextureDataPixelFormat_LA88:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_LA_88, PXTF_RGB_888_From_LA_88);
			break;
		case PXTextureDataPixelFormat_L8:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_L_8, PXTF_RGB_888_From_L_8);
			break;
		case PXTextureDataPixelFormat_A8:
			_PXTextureFormatPixelsCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_A_8, PXTF_RGB_888_From_A_8);
			break;
		default:
			PXParsedTextureDataFree(newTextureInfo);
			newTextureInfo = NULL;
	}

	if (oldPixelFormat == PXTextureDataPixelFormat_RGBA8888)
	{
		unsigned index;

	//	unsigned char *byte;
	//	for (index = 0, byte = newTextureInfo->bytes; index < byteCount; ++index, ++byte)
	//	{
	//		*byte = 0xFF;
	//	}
		PXTF_RGBA_8888 *readPixel;
		PXTF_RGB_888 *writePixel;
		for (index = 0, writePixel = (PXTF_RGB_888 *)(newTextureInfo->bytes), readPixel = (PXTF_RGBA_8888 *)(oldTextureInfo->bytes);
			 index < pixelCount;
			 ++index, ++writePixel, ++readPixel)
		{
			PXTF_RGBA_8888 readVal = *readPixel;
			// TODO: look into why using this make function doesn't work, but setting the values directly does!
			PXTF_RGB_888 writeVal = PXTF_RGB_888_Make(readVal.red, readVal.green, readVal.blue);
	//		writeVal.red   = readVal.red;
	//		writeVal.green = readVal.green;
	//		writeVal.blue  = readVal.blue;
			*writePixel = writeVal;
		}
	}

	return newTextureInfo;
}

@end
