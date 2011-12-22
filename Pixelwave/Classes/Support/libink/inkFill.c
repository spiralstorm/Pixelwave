//
//  inkFill.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkFill.h"

#include "inkGLU.h"

#ifndef GL_CLAMP_TO_EDGE
#define GL_CLAMP_TO_EDGE GL_REPEAT
#endif

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

inkGradientFill inkGradientFillMake(inkMatrix matrix, inkArray* colors, inkArray* ratios, inkGradientType type, inkSpreadMethod spreadMethod, inkInterpolationMethod interpolationMethod, float focalPointRatio)
{
	inkGradientFill fill;

	fill.fillType = inkFillType_Gradient;

	fill.colors = colors;
	fill.ratios = ratios;
	fill.type = type;
	fill.spreadMethod = spreadMethod;
	fill.interpolationMethod = interpolationMethod;
	fill.focalPointRatio = focalPointRatio;

	return fill;
}

inkExtern inkPresetGLData inkFillUpdateGLData(void* fill, inkPresetGLData glData)
{
	if (fill == NULL)
		return glData;

	inkFillType fillType = ((inkFill*)fill)->fillType;

	if (fillType != inkFillType_Bitmap)
	{
		glData.textureName = 0;
		return glData;
	}

	glData.textureName = ((inkBitmapFill*)fill)->bitmapInfo.glTextureName;

	glData.magFilter = ((inkBitmapFill*)fill)->smooth ? GL_LINEAR : GL_NEAREST;
	glData.minFilter = ((inkBitmapFill*)fill)->smooth ? GL_LINEAR : GL_NEAREST;
	glData.wrapS = ((inkBitmapFill*)fill)->repeat ? GL_REPEAT : GL_CLAMP_TO_EDGE;
	glData.wrapT = ((inkBitmapFill*)fill)->repeat ? GL_REPEAT : GL_CLAMP_TO_EDGE;

	return glData;
}

inkColor inkGradientColor(inkGradientFill* fill, inkPoint position)
{
	if (fill == NULL)
		return inkColorMake(0xFF, 0xFF, 0xFF, 0xFF);

	if (fill->colors == NULL)
		return inkColorMake(0xFF, 0xFF, 0xFF, 0xFF);

	unsigned int count = inkArrayCount(fill->colors);

	if (count == 0)
		return inkColorMake(0xFF, 0xFF, 0xFF, 0xFF);

	if (count == 1)
	{
		return *((inkColor*)inkArrayElementAt(fill->colors, 0));
	}

	if (fill->type == inkGradientType_Radial)
	{
		position = inkPointAdd(position, inkPointMake(-0.5f, -0.5f));
		float dist = inkPointDistanceFromZero(position);
		position.x = dist * 2.0f;
	}

	switch(fill->spreadMethod)
	{
		case inkSpreadMethod_Pad:
			position.x = inkClampf(position.x);
			position.y = inkClampf(position.y);
			break;
		case inkSpreadMethod_Reflect:
			position.x = inkReflectf(position.x);
			position.y = inkReflectf(position.y);
			break;
		case inkSpreadMethod_Repeat:
			position.x = inkRepeatf(position.x);
			position.y = inkRepeatf(position.y);
			break;
	}

	if (inkIsEqualf(position.x, 1.0f))
	{
		return *((inkColor*)inkArrayElementAt(fill->colors, count - 1));
	}

	if (inkIsEqualf(position.x, 0.0f))
	{
		return *((inkColor*)inkArrayElementAt(fill->colors, 0));
	}

	unsigned int prevIndex = 0;
	unsigned int index;
	float curPercent = 0.0f;
	float lastPercent = 1.0f;
	float* percentPtr;
	inkArrayForEachv(fill->ratios, percentPtr, index = 0, ++index)
	{
		curPercent = *percentPtr;

		if (position.x < curPercent || inkIsEqualf(position.x, curPercent))
			break;

		lastPercent = curPercent;
		prevIndex = index;
		//++index;
	}

	if (index == count)
		index = count - 1;

	float percentDiff = (curPercent - lastPercent);

	if (inkIsZerof(percentDiff) == false)
		position.x = fabsf(position.x - lastPercent) / fabsf(percentDiff);

	inkColor colorA = *((inkColor*)inkArrayElementAt(fill->colors, prevIndex));
	inkColor colorB = *((inkColor*)inkArrayElementAt(fill->colors, index));
	float percent = inkClampf(position.x);

	if (fill->interpolationMethod == inkInterpolationMethod_LinearRGB)
		return inkColorHSVInterpolate(colorA, colorB, percent);

	return inkColorInterpolate(colorA, colorB, percent);
}
