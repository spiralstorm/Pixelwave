//
//  inkFill.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkFill.h"

const inkSolidFill inkSolidFillDefault = _inkSolidFillDefault;
const inkBitmapFill inkBitmapFillDefault = _inkBitmapFillDefault;
const inkGradientFill inkGradientFillDefault = _inkGradientFillDefault;

inkBitmapInfo inkBitmapInfoMake(unsigned int glTextureName, unsigned int textureWidth, unsigned int textureHeight)
{
	inkBitmapInfo info;

	info.glTextureName = glTextureName;

	info.one_textureWidth  = 1.0f / (float)textureWidth;
	info.one_textureHeight = 1.0f / (float)textureHeight;

	return info;
}

inkSolidFill inkSolidFillMake(unsigned int color, float alpha)
{
	inkSolidFill fill;

	fill.fillType = inkFillType_Solid;

	fill.color = color;
	fill.alpha = alpha;

	return fill;
}

inkBitmapFill inkBitmapFillMake(inkMatrix matrix, inkBitmapInfo bitmapInfo, bool repeat, bool smooth)
{
	inkBitmapFill fill;

	fill.fillType = inkFillType_Bitmap;

	fill.matrix = matrix;
	fill.bitmapInfo = bitmapInfo;
	fill.repeat = repeat;
	fill.smooth = smooth;

	return fill;
}

inkGradientFill inkGradientFillMake(inkMatrix matrix, inkArray* colors, inkArray* alphas, inkArray* ratios, inkGradientType type, inkSpreadMethod spreadMethod, inkInterpolationMethod interpolationMethod, float focalPointRatio)
{
	inkGradientFill fill;

	fill.fillType = inkFillType_Gradient;

	fill.colors = colors;
	fill.alphas = alphas;
	fill.ratios = ratios;
	fill.type = type;
	fill.spreadMethod = spreadMethod;
	fill.interpolationMethod = interpolationMethod;
	fill.focalPointRatio = focalPointRatio;

	return fill;
}
