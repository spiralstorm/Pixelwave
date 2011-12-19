//
//  inkColor.c
//  ink
//
//  Created by John Lattin on 12/16/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkColor.h"

#include "inkGeometry.h"

const inkColor inkColorIndianRed                    = {0xCD, 0x5C, 0x5C, 0xFF};
const inkColor inkColorLightCoral                   = {0xF0, 0x80, 0x80, 0xFF};
const inkColor inkColorSalmon                       = {0xFA, 0x80, 0x72, 0xFF};
const inkColor inkColorDarkSalmon                   = {0xE9, 0x96, 0x7A, 0xFF};
const inkColor inkColorLightSalmon                  = {0xFF, 0xA0, 0x7A, 0xFF};
const inkColor inkColorCrimson                      = {0xDC, 0x14, 0x3C, 0xFF};
const inkColor inkColorRed                          = {0xFF, 0x00, 0x00, 0xFF};
const inkColor inkColorFireBrick                    = {0xB2, 0x22, 0x22, 0xFF};
const inkColor inkColorDarkRed                      = {0x8B, 0x00, 0x00, 0xFF};
const inkColor inkColorPink                         = {0xFF, 0xC0, 0xCB, 0xFF};
const inkColor inkColorLightPink                    = {0xFF, 0xB6, 0xC1, 0xFF};
const inkColor inkColorHotPink                      = {0xFF, 0x69, 0xB4, 0xFF};
const inkColor inkColorDeepPink                     = {0xFF, 0x14, 0x93, 0xFF};
const inkColor inkColorMediumVioletRed              = {0xC7, 0x15, 0x85, 0xFF};
const inkColor inkColorPaleVioletRed                = {0xDB, 0x70, 0x93, 0xFF};
const inkColor inkColorCoral                        = {0xFF, 0x7F, 0x50, 0xFF};
const inkColor inkColorTomato                       = {0xFF, 0x63, 0x47, 0xFF};
const inkColor inkColorOrangeRed                    = {0xFF, 0x45, 0x00, 0xFF};
const inkColor inkColorDarkOrange                   = {0xFF, 0x8C, 0x00, 0xFF};
const inkColor inkColorOrange                       = {0xFF, 0xA5, 0x00, 0xFF};
const inkColor inkColorGold                         = {0xFF, 0xD7, 0x00, 0xFF};
const inkColor inkColorYellow                       = {0xFF, 0xFF, 0x00, 0xFF};
const inkColor inkColorLightYellow                  = {0xFF, 0xFF, 0xE0, 0xFF};
const inkColor inkColorLemonChiffon                 = {0xFF, 0xFA, 0xCD, 0xFF};
const inkColor inkColorLightGoldenrodYellow         = {0xFA, 0xFA, 0xD2, 0xFF};
const inkColor inkColorPapayaWhip                   = {0xFF, 0xEF, 0xD5, 0xFF};
const inkColor inkColorMoccasin                     = {0xFF, 0xE4, 0xB5, 0xFF};
const inkColor inkColorPeachPuff                    = {0xFF, 0xDA, 0xB9, 0xFF};
const inkColor inkColorPaleGoldenrod                = {0xEE, 0xE8, 0xAA, 0xFF};
const inkColor inkColorKhaki                        = {0xF0, 0xE6, 0x8C, 0xFF};
const inkColor inkColorDarkKhaki                    = {0xBD, 0xB7, 0x6B, 0xFF};
const inkColor inkColorLavender                     = {0xE6, 0xE6, 0xFA, 0xFF};
const inkColor inkColorThistle                      = {0xD8, 0xBF, 0xD8, 0xFF};
const inkColor inkColorPlum                         = {0xDD, 0xA0, 0xDD, 0xFF};
const inkColor inkColorViolet                       = {0xEE, 0x82, 0xEE, 0xFF};
const inkColor inkColorOrchid                       = {0xDA, 0x70, 0xD6, 0xFF};
const inkColor inkColorFuchsia                      = {0xFF, 0x00, 0xFF, 0xFF};
const inkColor inkColorMagenta                      = {0xFF, 0x00, 0xFF, 0xFF};
const inkColor inkColorMediumOrchid                 = {0xBA, 0x55, 0xD3, 0xFF};
const inkColor inkColorMediumPurple                 = {0x93, 0x70, 0xDB, 0xFF};
const inkColor inkColorAmethyst                     = {0x99, 0x66, 0xCC, 0xFF};
const inkColor inkColorBlueViolet                   = {0x8A, 0x2B, 0xE2, 0xFF};
const inkColor inkColorDarkViolet                   = {0x94, 0x00, 0xD3, 0xFF};
const inkColor inkColorDarkOrchid                   = {0x99, 0x32, 0xCC, 0xFF};
const inkColor inkColorDarkMagenta                  = {0x8B, 0x00, 0x8B, 0xFF};
const inkColor inkColorPurple                       = {0x80, 0x00, 0x80, 0xFF};
const inkColor inkColorIndigo                       = {0x4B, 0x00, 0x82, 0xFF};
const inkColor inkColorSlateBlue                    = {0x6A, 0x5A, 0xCD, 0xFF};
const inkColor inkColorDarkSlateBlue                = {0x48, 0x3D, 0x8B, 0xFF};
const inkColor inkColorMediumSlateBlue              = {0x7B, 0x68, 0xEE, 0xFF};
const inkColor inkColorGreenYellow                  = {0xAD, 0xFF, 0x2F, 0xFF};
const inkColor inkColorChartreuse                   = {0x7F, 0xFF, 0x00, 0xFF};
const inkColor inkColorLawnGreen                    = {0x7C, 0xFC, 0x00, 0xFF};
const inkColor inkColorLime                         = {0x00, 0xFF, 0x00, 0xFF};
const inkColor inkColorLimeGreen                    = {0x32, 0xCD, 0x32, 0xFF};
const inkColor inkColorPaleGreen                    = {0x98, 0xFB, 0x98, 0xFF};
const inkColor inkColorLightGreen                   = {0x90, 0xEE, 0x90, 0xFF};
const inkColor inkColorMediumSpringGreen            = {0x00, 0xFA, 0x9A, 0xFF};
const inkColor inkColorSpringGreen                  = {0x00, 0xFF, 0x7F, 0xFF};
const inkColor inkColorMediumSeaGreen               = {0x3C, 0xB3, 0x71, 0xFF};
const inkColor inkColorSeaGreen                     = {0x2E, 0x8B, 0x57, 0xFF};
const inkColor inkColorForestGreen                  = {0x22, 0x8B, 0x22, 0xFF};
const inkColor inkColorGreen                        = {0x00, 0x80, 0x00, 0xFF};
const inkColor inkColorDarkGreen                    = {0x00, 0x64, 0x00, 0xFF};
const inkColor inkColorYellowGreen                  = {0x9A, 0xCD, 0x32, 0xFF};
const inkColor inkColorOliveDrab                    = {0x6B, 0x8E, 0x23, 0xFF};
const inkColor inkColorOlive                        = {0x80, 0x80, 0x00, 0xFF};
const inkColor inkColorDarkOliveGreen               = {0x55, 0x6B, 0x2F, 0xFF};
const inkColor inkColorMediumAquamarine             = {0x66, 0xCD, 0xAA, 0xFF};
const inkColor inkColorDarkSeaGreen                 = {0x8F, 0xBC, 0x8F, 0xFF};
const inkColor inkColorLightSeaGreen                = {0x20, 0xB2, 0xAA, 0xFF};
const inkColor inkColorDarkCyan                     = {0x00, 0x8B, 0x8B, 0xFF};
const inkColor inkColorTeal                         = {0x00, 0x80, 0x80, 0xFF};
const inkColor inkColorAqua                         = {0x00, 0xFF, 0xFF, 0xFF};
const inkColor inkColorCyan                         = {0x00, 0xFF, 0xFF, 0xFF};
const inkColor inkColorLightCyan                    = {0xE0, 0xFF, 0xFF, 0xFF};
const inkColor inkColorPaleTurquoise                = {0xAF, 0xEE, 0xEE, 0xFF};
const inkColor inkColorAquamarine                   = {0x7F, 0xFF, 0xD4, 0xFF};
const inkColor inkColorTurquoise                    = {0x40, 0xE0, 0xD0, 0xFF};
const inkColor inkColorMediumTurquoise              = {0x48, 0xD1, 0xCC, 0xFF};
const inkColor inkColorDarkTurquoise                = {0x00, 0xCE, 0xD1, 0xFF};
const inkColor inkColorCadetBlue                    = {0x5F, 0x9E, 0xA0, 0xFF};
const inkColor inkColorSteelBlue                    = {0x46, 0x82, 0xB4, 0xFF};
const inkColor inkColorLightSteelBlue               = {0xB0, 0xC4, 0xDE, 0xFF};
const inkColor inkColorPowderBlue                   = {0xB0, 0xE0, 0xE6, 0xFF};
const inkColor inkColorLightBlue                    = {0xAD, 0xD8, 0xE6, 0xFF};
const inkColor inkColorSkyBlue                      = {0x87, 0xCE, 0xEB, 0xFF};
const inkColor inkColorLightSkyBlue                 = {0x87, 0xCE, 0xFA, 0xFF};
const inkColor inkColorDeepSkyBlue                  = {0x00, 0xBF, 0xFF, 0xFF};
const inkColor inkColorDodgerBlue                   = {0x1E, 0x90, 0xFF, 0xFF};
const inkColor inkColorCornflowerBlue               = {0x64, 0x95, 0xED, 0xFF};
const inkColor inkColorRoyalBlue                    = {0x41, 0x69, 0xE1, 0xFF};
const inkColor inkColorBlue                         = {0x00, 0x00, 0xFF, 0xFF};
const inkColor inkColorMediumBlue                   = {0x00, 0x00, 0xCD, 0xFF};
const inkColor inkColorDarkBlue                     = {0x00, 0x00, 0x8B, 0xFF};
const inkColor inkColorNavy                         = {0x00, 0x00, 0x80, 0xFF};
const inkColor inkColorMidnightBlue                 = {0x19, 0x19, 0x70, 0xFF};
const inkColor inkColorCornsilk                     = {0xFF, 0xF8, 0xDC, 0xFF};
const inkColor inkColorBlanchedAlmond               = {0xFF, 0xEB, 0xCD, 0xFF};
const inkColor inkColorBisque                       = {0xFF, 0xE4, 0xC4, 0xFF};
const inkColor inkColorNavajoWhite                  = {0xFF, 0xDE, 0xAD, 0xFF};
const inkColor inkColorWheat                        = {0xF5, 0xDE, 0xB3, 0xFF};
const inkColor inkColorBurlyWood                    = {0xDE, 0xB8, 0x87, 0xFF};
const inkColor inkColorTan                          = {0xD2, 0xB4, 0x8C, 0xFF};
const inkColor inkColorRosyBrown                    = {0xBC, 0x8F, 0x8F, 0xFF};
const inkColor inkColorSandyBrown                   = {0xF4, 0xA4, 0x60, 0xFF};
const inkColor inkColorGoldenrod                    = {0xDA, 0xA5, 0x20, 0xFF};
const inkColor inkColorDarkGoldenrod                = {0xB8, 0x86, 0x0B, 0xFF};
const inkColor inkColorPeru                         = {0xCD, 0x85, 0x3F, 0xFF};
const inkColor inkColorChocolate                    = {0xD2, 0x69, 0x1E, 0xFF};
const inkColor inkColorSaddleBrown                  = {0x8B, 0x45, 0x13, 0xFF};
const inkColor inkColorSienna                       = {0xA0, 0x52, 0x2D, 0xFF};
const inkColor inkColorBrown                        = {0xA5, 0x2A, 0x2A, 0xFF};
const inkColor inkColorMaroon                       = {0x80, 0x00, 0x00, 0xFF};
const inkColor inkColorWhite                        = {0xFF, 0xFF, 0xFF, 0xFF};
const inkColor inkColorSnow                         = {0xFF, 0xFA, 0xFA, 0xFF};
const inkColor inkColorHoneydew                     = {0xF0, 0xFF, 0xF0, 0xFF};
const inkColor inkColorMintCream                    = {0xF5, 0xFF, 0xFA, 0xFF};
const inkColor inkColorAzure                        = {0xF0, 0xFF, 0xFF, 0xFF};
const inkColor inkColorAliceBlue                    = {0xF0, 0xF8, 0xFF, 0xFF};
const inkColor inkColorGhostWhite                   = {0xF8, 0xF8, 0xFF, 0xFF};
const inkColor inkColorWhiteSmoke                   = {0xF5, 0xF5, 0xF5, 0xFF};
const inkColor inkColorSeashell                     = {0xFF, 0xF5, 0xEE, 0xFF};
const inkColor inkColorBeige                        = {0xF5, 0xF5, 0xDC, 0xFF};
const inkColor inkColorOldLace                      = {0xFD, 0xF5, 0xE6, 0xFF};
const inkColor inkColorFloralWhite                  = {0xFF, 0xFA, 0xF0, 0xFF};
const inkColor inkColorIvory                        = {0xFF, 0xFF, 0xF0, 0xFF};
const inkColor inkColorAntiqueWhite                 = {0xFA, 0xEB, 0xD7, 0xFF};
const inkColor inkColorLinen                        = {0xFA, 0xF0, 0xE6, 0xFF};
const inkColor inkColorLavenderBlush                = {0xFF, 0xF0, 0xF5, 0xFF};
const inkColor inkColorMistyRose                    = {0xFF, 0xE4, 0xE1, 0xFF};
const inkColor inkColorGainsboro                    = {0xDC, 0xDC, 0xDC, 0xFF};
const inkColor inkColorLightGrey                    = {0xD3, 0xD3, 0xD3, 0xFF};
const inkColor inkColorSilver                       = {0xC0, 0xC0, 0xC0, 0xFF};
const inkColor inkColorDarkGray                     = {0xA9, 0xA9, 0xA9, 0xFF};
const inkColor inkColorGray                         = {0x80, 0x80, 0x80, 0xFF};
const inkColor inkColorDimGray                      = {0x69, 0x69, 0x69, 0xFF};
const inkColor inkColorLightSlateGray               = {0x77, 0x88, 0x99, 0xFF};
const inkColor inkColorSlateGray                    = {0x70, 0x80, 0x90, 0xFF};
const inkColor inkColorDarkSlateGray                = {0x2F, 0x4F, 0x4F, 0xFF};
const inkColor inkColorBlack                        = {0x00, 0x00, 0x00, 0xFF};

inkColor inkColorInterpolate(inkColor colorA, inkColor colorB, float percent)
{
	return inkColorMake(lroundf(colorA.r + ((colorB.r - colorA.r) * percent)),
						lroundf(colorA.g + ((colorB.g - colorA.g) * percent)),
						lroundf(colorA.b + ((colorB.b - colorA.b) * percent)),
						lroundf(colorA.a + ((colorB.a - colorA.a) * percent)));
}

inkColor inkColorHSVInterpolate(inkColor colorA, inkColor colorB, float percent)
{
	inkColorHSV hsvA = inkColorHSVFromColor(colorA);
	inkColorHSV hsvB = inkColorHSVFromColor(colorB);

	float hDiff = hsvB.h - hsvA.h;
	if (hDiff > 0.5f)
		hDiff -= 1.0f;

	inkColorHSV inter = inkColorHSVMake(inkRepeatf(hsvA.h + (hDiff * percent)),
										inkClampf(hsvA.s + ((hsvB.s - hsvA.s) * percent)),
										inkClampf(hsvA.v + ((hsvB.v - hsvA.v) * percent)));

	inkColor color = inkColorFromHSV(inter);

	color.a = lroundf(colorA.a + ((colorB.a - colorA.a) * percent));

	return color;
}

/*inkColor inkColorHSVInterpolate(inkColor colorA, inkColor colorB, float percent)
{
	//percent = 1.0f - percent;
	float alt = 1.0f - percent;

    double x0 = colorA.r;
    double y0 = colorA.g;
    double z0 = colorA.b;

    double x1 = colorB.r;
    double y1 = colorB.g;
    double z1 = colorB.a;

    double mag0 = sqrt(x0 * x0 + y0 * y0 + z0 * z0);
    double mag1 = sqrt(x1 * x1 + y1 * y1 + z1 * z1);

    double r = alt * x0 + percent * x1;
    double g = alt * y0 + percent * y1;
    double b = alt * z0 + percent * z1;

	if (r != 0.0 || g != 0.0 || b != 0.0)
	{
		double mag  = alt * mag0 + percent * mag1;
		double scale = mag / sqrt(r * r + g * g + b * b);

		r *= scale;
		g *= scale;
		b *= scale;
	}

	double a = colorA.a + ((colorB.a - colorA.a) * percent);

	if (r < 0) r = 0; if (r > 0xFF) r = 0xFF;
	if (g < 0) g = 0; if (g > 0xFF) g = 0xFF;
	if (b < 0) b = 0; if (b > 0xFF) b = 0xFF;
	if (a < 0) a = 0; if (a > 0xFF) a = 0xFF;

    return inkColorMake(r, g, b, a);
}*/

inkColor inkColorFromHSV(inkColorHSV hsv)
{
	double hsvH = hsv.h * 6.0;
	int hi = floorf(hsvH);
	double f = hsvH - (double)hi;

	double p = hsv.v * (1.0 - hsv.s);
	double q = hsv.v * (1.0 - (f * hsv.s));
	double t = hsv.v * (1.0 - ((1.0 - f) * hsv.s));

	inkColorTransform ct;

	switch (hi)
	{
		case 0:
			ct = inkColorTransformMake(hsv.v, t, p, 1.0);
			break;
		case 1:
			ct = inkColorTransformMake(q, hsv.v, p, 1.0);
			break;
		case 2:
			ct = inkColorTransformMake(p, hsv.v, t, 1.0);
			break;
		case 3:
			ct = inkColorTransformMake(p, q, hsv.v, 1.0);
			break;
		case 4:
			ct = inkColorTransformMake(t, p, hsv.v, 1.0);
			break;
		case 5:
			ct = inkColorTransformMake(hsv.v, p, q, 1.0);
			break;
		default:
			ct = inkColorTransformMake(0.0f, 0.0f, 0.0f, 1.0f);
			break;
	}

	return inkColorFromTransform(ct);
}

inkColorHSV inkColorHSVFromColor(inkColor color)
{
	return inkColorHSVFromTransform(inkColorTransformFromColor(color));
}

inkColorHSV inkColorHSVFromTransform(inkColorTransform transform)
{
	float minC = fminf(transform.r, fminf(transform.g, transform.b));
	float maxC = fmaxf(transform.r, fmaxf(transform.g, transform.b));
	float delta = maxC - minC;

	if (maxC == 0.0)
		return inkColorHSVMake(0.0f, 0.0f, 0.0f);

	inkColorHSV hsv;
	hsv.v = maxC;
	hsv.s = delta / maxC;

	if (inkIsEqualf(transform.r, maxC))
		hsv.h = ( transform.g - transform.b ) / delta;		// between yellow & magenta
	else if (inkIsEqualf(transform.g, maxC))
		hsv.h = 2 + ( transform.b - transform.r ) / delta;	// between cyan & yellow
	else
		hsv.h = 4 + ( transform.r - transform.g ) / delta;	// between magenta & cyan

	hsv.h *= M_1_6;

	while (hsv.h < 0.0f)
		hsv.h += 1.0f;

	return hsv;

	/*inkColorHSV hsv;

	double rgb_min;
	double rgb_max;

	rgb_min = fminf(transform.r, fminf(transform.g, transform.b));
	rgb_max = fmaxf(transform.r, fmaxf(transform.g, transform.b));

	hsv.v = rgb_max;

	if (hsv.v == 0)
	{
		hsv.h = hsv.s = 0;
		return hsv;
	}

	float one_hsvV = 1.0f / hsv.v;

	transform.r *= one_hsvV;
	transform.g *= one_hsvV;
	transform.b *= one_hsvV;

	rgb_min = fminf(transform.r, fminf(transform.g, transform.b));
	rgb_max = fmaxf(transform.r, fmaxf(transform.g, transform.b));

	hsv.s = rgb_max - rgb_min;

	if (hsv.s == 0.0)
	{
		hsv.h = 0.0;

		return hsv;
	}

	// Normalize saturation to 1
	double one_maxMinusMin = 1.0 / (rgb_max - rgb_min);
	transform.r = (transform.r - rgb_min) * one_maxMinusMin;
	transform.g = (transform.g - rgb_min) * one_maxMinusMin;
	transform.b = (transform.b - rgb_min) * one_maxMinusMin;

	rgb_min = fminf(transform.r, fminf(transform.g, transform.b));
	rgb_max = fmaxf(transform.r, fmaxf(transform.g, transform.b));

	// Compute hue
	if (rgb_max == transform.r)
	{
		hsv.h = M_1_6 * (transform.g - transform.b);

		if (hsv.h < 0.0)
		{
			hsv.h += 1.0;
		}
	}
	else if (rgb_max == transform.g)
	{
		hsv.h = M_1_3 + M_1_6 * (transform.b - transform.r);
	}
	else
	{
		hsv.h = M_2_3 + M_1_6 * (transform.r - transform.g);
	}

	hsv.h = inkClampf(hsv.h);
	hsv.s = inkClampf(hsv.s);
	hsv.v = inkClampf(hsv.v);

	return hsv;*/
}
