//
//  PXTextureModifierPremultiplyAlpha.m
//  Pixelwave
//
//  Created by John Lattin on 10/5/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PXTextureModifierPremultiplyAlpha.h"

#include "PXTextureFormatUtils.h"
#include "PXPrivateUtils.h"

#define PXTextureModifierPremultiplyAlphaCopyWithFunc(_read_, _write_, _count_, _TYPE_, _FUNC_) \
{ \
	_TYPE_ *_curReadPixel_; \
	_TYPE_ *_curWritePixel_; \
	unsigned int _index_; \
\
	for (_index_ = 0, _curReadPixel_ = (_TYPE_ *)(_read_), _curWritePixel_ = (_TYPE_ *)(_write_); _index_ < _count_; ++_index_, ++_curReadPixel_, ++_curWritePixel_) \
	{ \
		*_curWritePixel_ = _FUNC_(*_curReadPixel_); \
	} \
}

PXInline PXTF_RGBA_8888 PXTextureModifierPremultiplyAlphaRGBA8888(PXTF_RGBA_8888 val);
PXInline PXTF_RGBA_4444 PXTextureModifierPremultiplyAlphaRGBA4444(PXTF_RGBA_4444 val);
PXInline PXTF_RGBA_5551 PXTextureModifierPremultiplyAlphaRGBA5551(PXTF_RGBA_5551 val);
PXInline PXTF_LA_88 PXTextureModifierPremultiplyAlphaLA88(PXTF_LA_88 val);
PXInline PXTF_A_8 PXTextureModifierPremultiplyAlphaA8(PXTF_A_8 val);

@implementation PXTextureModifierPremultiplyAlpha

- (PXParsedTextureData *)newModifiedTextureDataFromData:(PXParsedTextureData *)oldTextureInfo
{
	if (!oldTextureInfo)
	{
		return NULL;
	}

	PXTextureDataPixelFormat pixelFormat = oldTextureInfo->pixelFormat;

	// NOT SUPPORTED
	if (pixelFormat == PXTextureDataPixelFormat_RGB_PVRTC2  ||
		pixelFormat == PXTextureDataPixelFormat_RGB_PVRTC4  ||
		pixelFormat == PXTextureDataPixelFormat_RGBA_PVRTC2 ||
		pixelFormat == PXTextureDataPixelFormat_RGBA_PVRTC4)
	{
		return NULL;
	}

	unsigned short width  = oldTextureInfo->size.width;
	unsigned short height = oldTextureInfo->size.height;
	unsigned int pixelCount = width * height;
	unsigned int byteCount = oldTextureInfo->byteCount;

	PXParsedTextureData *newTextureInfo = PXParsedTextureDataCreate(byteCount);

	if (newTextureInfo == nil)
	{
		return NULL;
	}

	newTextureInfo->size = CGSizeMake(width, height);
	newTextureInfo->pixelFormat = pixelFormat;

	uint8_t *writePixels = (uint8_t *)(newTextureInfo->bytes);

	switch (pixelFormat)
	{
		case PXTextureDataPixelFormat_RGBA8888:
			PXTextureModifierPremultiplyAlphaCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGBA_8888, PXTextureModifierPremultiplyAlphaRGBA8888);
			break;
		case PXTextureDataPixelFormat_RGBA4444:
			PXTextureModifierPremultiplyAlphaCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGBA_4444, PXTextureModifierPremultiplyAlphaRGBA4444);
			break;
		case PXTextureDataPixelFormat_RGBA5551:
			PXTextureModifierPremultiplyAlphaCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_RGBA_5551, PXTextureModifierPremultiplyAlphaRGBA5551);
			break;
		case PXTextureDataPixelFormat_LA88:
			PXTextureModifierPremultiplyAlphaCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_LA_88, PXTextureModifierPremultiplyAlphaLA88);
			break;
		case PXTextureDataPixelFormat_A8:
			PXTextureModifierPremultiplyAlphaCopyWithFunc(oldTextureInfo->bytes, writePixels, pixelCount, PXTF_A_8, PXTextureModifierPremultiplyAlphaA8);
			break;
		case PXTextureDataPixelFormat_RGB565:
		case PXTextureDataPixelFormat_L8:
		case PXTextureDataPixelFormat_RGB888:
		default:
			PXParsedTextureDataFree(newTextureInfo);
			newTextureInfo = NULL;
	}

	return newTextureInfo;
}

@end

PXInline PXTF_RGBA_8888 PXTextureModifierPremultiplyAlphaRGBA8888(PXTF_RGBA_8888 val)
{
	float percent = PX_COLOR_BYTE_TO_FLOAT(val.alpha);
	return PXTF_RGBA_8888_Make(val.red * percent, val.green * percent, val.blue * percent, val.alpha);
}

PXInline PXTF_RGBA_4444 PXTextureModifierPremultiplyAlphaRGBA4444(PXTF_RGBA_4444 val)
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a = _PX4BitTo8Bit(_PXTF_4444_A(val));

	float percent = PX_COLOR_BYTE_TO_FLOAT(a);

	r = _PX4BitTo8Bit(_PXTF_4444_R(val)) * percent;
	g = _PX4BitTo8Bit(_PXTF_4444_G(val)) * percent;
	b = _PX4BitTo8Bit(_PXTF_4444_B(val)) * percent;

	return PXTF_RGBA_4444_Make(r, g, b, a);
}

PXInline PXTF_RGBA_5551 PXTextureModifierPremultiplyAlphaRGBA5551(PXTF_RGBA_5551 val)
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a = _PX1BitTo8Bit(_PXTF_5551_A(val));

	float percent = PX_COLOR_BYTE_TO_FLOAT(a);

	r = _PX5BitTo8Bit(_PXTF_5551_R(val)) * percent;
	g = _PX5BitTo8Bit(_PXTF_5551_G(val)) * percent;
	b = _PX5BitTo8Bit(_PXTF_5551_B(val)) * percent;

	return PXTF_RGBA_5551_Make(r, g, b, a);
}

PXInline PXTF_LA_88 PXTextureModifierPremultiplyAlphaLA88(PXTF_LA_88 val)
{
	float percent = PX_COLOR_BYTE_TO_FLOAT(val.alpha);
	return PXTF_LA_88_Make(val.luminance * percent, val.alpha);
}

PXInline PXTF_A_8 PXTextureModifierPremultiplyAlphaA8(PXTF_A_8 val)
{
	float percent = PX_COLOR_BYTE_TO_FLOAT(val);
	return PXTF_A_8_Make(val * percent);
}
