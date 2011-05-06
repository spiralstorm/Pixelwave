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

#include "PXColorUtils.h"
#include "PXPrivateUtils.h"

PXInline_c void PXColorRGBToHex(unsigned r, unsigned g, unsigned b, int *hex)
{
	(*hex) = (r << 16) + (g << 8) + b;
}

PXInline_c void PXColorHexToRGB( unsigned hex, PXColor3 *color)
{
	color->r = (hex & 0xff0000) >> 16;
	color->g = (hex & 0x00ff00) >> 8;
	color->b = (hex & 0x0000ff);
}

PXInline_c void PXColorHexToRGBf(unsigned hex, PXColor3f *color)
{
	color->r = PX_COLOR_BYTE_TO_FLOAT((hex & 0xff0000) >> 16);
	color->g = PX_COLOR_BYTE_TO_FLOAT((hex & 0x00ff00) >> 8);
	color->b = PX_COLOR_BYTE_TO_FLOAT((hex & 0x0000ff));
}

PXInline_c void PXColorHexToARGB( unsigned hex, PXColor4 *color)
{
	color->a = ((hex & 0xff000000) >> 24);
	color->r = ((hex & 0x00ff0000) >> 16);
	color->g = ((hex & 0x0000ff00) >> 8);
	color->b = ((hex & 0x000000ff));
}

PXInline_c bool PXColorsAreEqual(PXColor4f *color1, PXColor4f *color2)
{
	if (color1->r != color2->r)
		return false;

	if (color1->g != color2->g)
		return false;

	if (color1->b != color2->b)
		return false;

	if (color1->a != color2->a)
		return false;

	return true;
}

PXInline_c PXRGBA PXRGBAMake(unsigned char red, unsigned char green, unsigned char blue, unsigned char alpha)
{
	PXRGBA rgba;

	rgba.r = red;
	rgba.g = green;
	rgba.b = blue;
	rgba.a = alpha;

	return rgba;
}
PXInline_c PXHSV PXHSVMake(float hue, float saturation, float value)
{
	PXHSV hsv;

	hsv.h = hue;
	hsv.s = saturation;
	hsv.v = value;

	return hsv;
}
PXInline_c PXHSL PXHSLMake(float hue, float saturation, float lightness)
{
	PXHSL hsl;

	hsl.h = hue;
	hsl.s = saturation;
	hsl.l = lightness;

	return hsl;
}

PXInline_c PXRGBA PXHSVToRGBA(PXHSV hsv)
{
	PXRGBA rgba;

	// TODO Later: implement.

	return rgba;
}
PXInline_c PXRGBA PXHSLToRGBA(PXHSL hsl)
{
	PXRGBA rgba;

	// TODO Later: implement.

	return rgba;
}
PXInline_c PXHSV PXRGBAToHSV(PXRGBA rgba)
{
	PXHSV hsv;

	// TODO Later: implement.

	return hsv;
}
PXInline_c PXHSV PXHSLToHSV(PXHSL hsl)
{
	PXHSV hsv;

	// TODO Later: implement.

	return hsv;
}
PXInline_c PXHSL PXRGBAToHSL(PXRGBA rgba)
{
	PXHSL hsl;

	// TODO Later: implement.

	return hsl;
}
PXInline_c PXHSL PXHSVToHSL(PXHSV hsv)
{
	PXHSL hsl;

	// TODO Later: implement.

	return hsl;
}
