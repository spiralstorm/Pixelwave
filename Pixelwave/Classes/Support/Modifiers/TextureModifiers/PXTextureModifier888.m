//
//  PXTextureModifier888.m
//  Pixelwave
//
//  Created by John Lattin on 4/29/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PXTextureModifier888.h"

#include "PXTextureFormatUtils.h"

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

	return newTextureInfo;
}

@end
