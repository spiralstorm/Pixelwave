//
//  inkColor.h
//  ink
//
//  Created by John Lattin on 12/16/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_COLOR_H_
#define _INK_COLOR_H_

#include "inkHeader.h"

typedef struct
{
	unsigned char r, g, b, a;
} inkColor;

typedef struct
{
	// All 0.0 to 1.0
	float h, s, v;
} inkColorHSV;

typedef struct
{
	float r, g, b, a;
} inkColorTransform;

typedef inkColor (*inkColorInterpolator)(inkColor colorA, inkColor colorB, float percent);

inkInline inkColor inkColorMake(unsigned char r, unsigned char g, unsigned char b, unsigned char a);
inkInline inkColor inkColorFromTransform(inkColorTransform transform);
inkInline inkColor inkColorApplyTransform(inkColor color, inkColorTransform transform);
inkInline inkColorTransform inkColorTransformMake(float r, float g, float b, float a);
inkInline inkColorTransform inkColorTransformFromColor(inkColor color);
inkInline inkColorHSV inkColorHSVMake(float h, float s, float v);
inkInline bool inkColorIsEqual(inkColor colorA, inkColor colorB);

inkExtern inkColor inkColorInterpolate(inkColor colorA, inkColor colorB, float percent);
inkExtern inkColor inkColorHSVInterpolate(inkColor colorA, inkColor colorB, float percent);

inkExtern inkColor inkColorFromHSV(inkColorHSV hsv);
inkExtern inkColorTransform inkColorTransformFromHSV(inkColorHSV hsv);

inkExtern inkColorHSV inkColorHSVFromColor(inkColor color);
inkExtern inkColorHSV inkColorHSVFromTransform(inkColorTransform transform);

inkExtern const inkColor inkColorIndianRed;
inkExtern const inkColor inkColorLightCoral;
inkExtern const inkColor inkColorSalmon;
inkExtern const inkColor inkColorDarkSalmon;
inkExtern const inkColor inkColorLightSalmon;
inkExtern const inkColor inkColorCrimson;
inkExtern const inkColor inkColorRed;
inkExtern const inkColor inkColorFireBrick;
inkExtern const inkColor inkColorDarkRed;
inkExtern const inkColor inkColorPink;
inkExtern const inkColor inkColorLightPink;
inkExtern const inkColor inkColorHotPink;
inkExtern const inkColor inkColorDeepPink;
inkExtern const inkColor inkColorMediumVioletRed;
inkExtern const inkColor inkColorPaleVioletRed;
inkExtern const inkColor inkColorCoral;
inkExtern const inkColor inkColorTomato;
inkExtern const inkColor inkColorOrangeRed;
inkExtern const inkColor inkColorDarkOrange;
inkExtern const inkColor inkColorOrange;
inkExtern const inkColor inkColorGold;
inkExtern const inkColor inkColorYellow;
inkExtern const inkColor inkColorLightYellow;
inkExtern const inkColor inkColorLemonChiffon;
inkExtern const inkColor inkColorLightGoldenrodYellow;
inkExtern const inkColor inkColorPapayaWhip;
inkExtern const inkColor inkColorMoccasin;
inkExtern const inkColor inkColorPeachPuff;
inkExtern const inkColor inkColorPaleGoldenrod;
inkExtern const inkColor inkColorKhaki;
inkExtern const inkColor inkColorDarkKhaki;
inkExtern const inkColor inkColorLavender;
inkExtern const inkColor inkColorThistle;
inkExtern const inkColor inkColorPlum;
inkExtern const inkColor inkColorViolet;
inkExtern const inkColor inkColorOrchid;
inkExtern const inkColor inkColorFuchsia;
inkExtern const inkColor inkColorMagenta;
inkExtern const inkColor inkColorMediumOrchid;
inkExtern const inkColor inkColorMediumPurple;
inkExtern const inkColor inkColorAmethyst;
inkExtern const inkColor inkColorBlueViolet;
inkExtern const inkColor inkColorDarkViolet;
inkExtern const inkColor inkColorDarkOrchid;
inkExtern const inkColor inkColorDarkMagenta;
inkExtern const inkColor inkColorPurple;
inkExtern const inkColor inkColorIndigo;
inkExtern const inkColor inkColorSlateBlue;
inkExtern const inkColor inkColorDarkSlateBlue;
inkExtern const inkColor inkColorMediumSlateBlue;
inkExtern const inkColor inkColorGreenYellow;
inkExtern const inkColor inkColorChartreuse;
inkExtern const inkColor inkColorLawnGreen;
inkExtern const inkColor inkColorLime;
inkExtern const inkColor inkColorLimeGreen;
inkExtern const inkColor inkColorPaleGreen;
inkExtern const inkColor inkColorLightGreen;
inkExtern const inkColor inkColorMediumSpringGreen;
inkExtern const inkColor inkColorSpringGreen;
inkExtern const inkColor inkColorMediumSeaGreen;
inkExtern const inkColor inkColorSeaGreen;
inkExtern const inkColor inkColorForestGreen;
inkExtern const inkColor inkColorGreen;
inkExtern const inkColor inkColorDarkGreen;
inkExtern const inkColor inkColorYellowGreen;
inkExtern const inkColor inkColorOliveDrab;
inkExtern const inkColor inkColorOlive;
inkExtern const inkColor inkColorDarkOliveGreen;
inkExtern const inkColor inkColorMediumAquamarine;
inkExtern const inkColor inkColorDarkSeaGreen;
inkExtern const inkColor inkColorLightSeaGreen;
inkExtern const inkColor inkColorDarkCyan;
inkExtern const inkColor inkColorTeal;
inkExtern const inkColor inkColorAqua;
inkExtern const inkColor inkColorCyan;
inkExtern const inkColor inkColorLightCyan;
inkExtern const inkColor inkColorPaleTurquoise;
inkExtern const inkColor inkColorAquamarine;
inkExtern const inkColor inkColorTurquoise;
inkExtern const inkColor inkColorMediumTurquoise;
inkExtern const inkColor inkColorDarkTurquoise;
inkExtern const inkColor inkColorCadetBlue;
inkExtern const inkColor inkColorSteelBlue;
inkExtern const inkColor inkColorLightSteelBlue;
inkExtern const inkColor inkColorPowderBlue;
inkExtern const inkColor inkColorLightBlue;
inkExtern const inkColor inkColorSkyBlue;
inkExtern const inkColor inkColorLightSkyBlue;
inkExtern const inkColor inkColorDeepSkyBlue;
inkExtern const inkColor inkColorDodgerBlue;
inkExtern const inkColor inkColorCornflowerBlue;
inkExtern const inkColor inkColorRoyalBlue;
inkExtern const inkColor inkColorBlue;
inkExtern const inkColor inkColorMediumBlue;
inkExtern const inkColor inkColorDarkBlue;
inkExtern const inkColor inkColorNavy;
inkExtern const inkColor inkColorMidnightBlue;
inkExtern const inkColor inkColorCornsilk;
inkExtern const inkColor inkColorBlanchedAlmond;
inkExtern const inkColor inkColorBisque;
inkExtern const inkColor inkColorNavajoWhite;
inkExtern const inkColor inkColorWheat;
inkExtern const inkColor inkColorBurlyWood;
inkExtern const inkColor inkColorTan;
inkExtern const inkColor inkColorRosyBrown;
inkExtern const inkColor inkColorSandyBrown;
inkExtern const inkColor inkColorGoldenrod;
inkExtern const inkColor inkColorDarkGoldenrod;
inkExtern const inkColor inkColorPeru;
inkExtern const inkColor inkColorChocolate;
inkExtern const inkColor inkColorSaddleBrown;
inkExtern const inkColor inkColorSienna;
inkExtern const inkColor inkColorBrown;
inkExtern const inkColor inkColorMaroon;
inkExtern const inkColor inkColorWhite;
inkExtern const inkColor inkColorSnow;
inkExtern const inkColor inkColorHoneydew;
inkExtern const inkColor inkColorMintCream;
inkExtern const inkColor inkColorAzure;
inkExtern const inkColor inkColorAliceBlue;
inkExtern const inkColor inkColorGhostWhite;
inkExtern const inkColor inkColorWhiteSmoke;
inkExtern const inkColor inkColorSeashell;
inkExtern const inkColor inkColorBeige;
inkExtern const inkColor inkColorOldLace;
inkExtern const inkColor inkColorFloralWhite;
inkExtern const inkColor inkColorIvory;
inkExtern const inkColor inkColorAntiqueWhite;
inkExtern const inkColor inkColorLinen;
inkExtern const inkColor inkColorLavenderBlush;
inkExtern const inkColor inkColorMistyRose;
inkExtern const inkColor inkColorGainsboro;
inkExtern const inkColor inkColorLightGrey;
inkExtern const inkColor inkColorSilver;
inkExtern const inkColor inkColorDarkGray;
inkExtern const inkColor inkColorGray;
inkExtern const inkColor inkColorDimGray;
inkExtern const inkColor inkColorLightSlateGray;
inkExtern const inkColor inkColorSlateGray;
inkExtern const inkColor inkColorDarkSlateGray;
inkExtern const inkColor inkColorBlack;

inkInline inkColor inkColorMake(unsigned char r, unsigned char g, unsigned char b, unsigned char a)
{
	inkColor color;

	color.r = r;
	color.g = g;
	color.b = b;
	color.a = a;

	return color;
}

inkInline inkColorTransform inkColorTransformMake(float r, float g, float b, float a)
{
	inkColorTransform transform;

	transform.r = r;
	transform.g = g;
	transform.b = b;
	transform.a = a;

	return transform;
}

inkInline inkColorHSV inkColorHSVMake(float h, float s, float v)
{
	inkColorHSV hsv;

	hsv.h = h;
	hsv.s = s;
	hsv.v = v;

	return hsv;
}

inkInline inkColor inkColorFromTransform(inkColorTransform transform)
{
	return inkColorMake(lroundf(0xFF * transform.r), lroundf(0xFF * transform.g), lroundf(0xFF * transform.b), lroundf(0xFF * transform.a));
}

inkInline inkColorTransform inkColorTransformFromColor(inkColor color)
{
	return inkColorTransformMake(M_1_255 * color.r, M_1_255 * color.g, M_1_255 * color.b, M_1_255 * color.a);
}

inkInline inkColor inkColorApplyTransform(inkColor color, inkColorTransform transform)
{
	return inkColorMake(color.r * transform.r, color.g * transform.g, color.b * transform.b, color.a * transform.a);
}

inkInline bool inkColorIsEqual(inkColor colorA, inkColor colorB)
{
	return (colorA.r == colorB.r) && (colorA.g == colorB.g) && (colorA.b == colorB.b) && (colorA.a == colorB.a);
}

#endif
