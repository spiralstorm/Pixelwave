//
//  inkFill.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkFill.h"

static const inkSolidFill inkSolidFillDefault = _inkSolidFillDefault;
static const inkBitmapFill inkBitmapFillDefault = _inkBitmapFillDefault;
static const inkGradientFill inkGradientFillDefault = _inkGradientFillDefault;

inkExtern inkSolidFill inkSolidFillMake(unsigned int color, float alpha)
{
	inkSolidFill fill;

	fill.fillType = inkFillType_Solid;

	fill.color = color;
	fill.alpha = alpha;

	return fill;
}

inkExtern inkBitmapFill inkBitmapFillMake(inkMatrix matrix, bool repeat, bool smooth)
{
	inkBitmapFill fill;

	fill.fillType = inkFillType_Bitmap;

	fill.matrix = matrix;
	fill.repeat = repeat;
	fill.smooth = smooth;

	return fill;
}

inkExtern inkGradientFill inkGradientFillMake(inkMatrix matrix, inkArray* colors, inkArray* alphas, inkArray* ratios, inkGradientType type, inkSpreadMethod spreadMethod, inkInterpolationMethod interpolationMethod, float focalPointRatio)
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
