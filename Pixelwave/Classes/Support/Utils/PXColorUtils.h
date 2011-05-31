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

#ifndef _PX_COLOR_UTILS_H_
#define _PX_COLOR_UTILS_H_

#import "PXHeaderUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	//unsigned char _padding;
} PXColor3;

typedef struct
{
	float r;
	float g;
	float b;
} PXColor3f;

typedef struct sPXColor4f
{
	float r;
	float g;
	float b;
	float a;
} PXColor4f;

typedef struct sPXColor4
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
} PXColor4;

typedef struct
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
} PXRGBA;

typedef struct
{
	float h;
	float s;
	float v;
} PXHSV;

typedef struct
{
	float h;
	float s;
	float l;
} PXHSL;

//

PXInline_h void PXColorRGBToHex(unsigned r, unsigned g, unsigned b, int *hex);
PXInline_h void PXColorHexToRGB(unsigned hex, PXColor3 *color);
PXInline_h void PXColorHexToRGBf(unsigned hex, PXColor3f *color);
PXInline_h void PXColorHexToARGB(unsigned hex, PXColor4 *color);

PXInline_h bool PXColorsAreEqual(PXColor4f *color1, PXColor4f *color2);

PXInline_h PXRGBA PXRGBAMake(unsigned char red, unsigned char green, unsigned char blue, unsigned char alpha);
PXInline_h PXHSV PXHSVMake(float hue, float saturation, float value);
PXInline_h PXHSL PXHSLMake(float hue, float saturation, float lightness);

PXInline_h PXRGBA PXHSVToRGBA(PXHSV hsv);
PXInline_h PXRGBA PXHSLToRGBA(PXHSL hsl);
PXInline_h PXHSV PXRGBAToHSV(PXRGBA rgba);
PXInline_h PXHSV PXHSLToHSV(PXHSL hsl);
PXInline_h PXHSL PXRGBAToHSL(PXRGBA rgba);
PXInline_h PXHSL PXHSVToHSL(PXHSV hsv);

// TODO Later: Make a PXColor class (similar to the structure of PXMath).
typedef enum
{
	PXColor_IndianRed                      = 0xCD5C5C,
	PXColor_LightCoral                     = 0xF08080,
	PXColor_Salmon                         = 0xFA8072,
	PXColor_DarkSalmon                     = 0xE9967A,
	PXColor_LightSalmon                    = 0xFFA07A,
	PXColor_Crimson                        = 0xDC143C,
	PXColor_Red                            = 0xFF0000,
	PXColor_FireBrick                      = 0xB22222,
	PXColor_DarkRed                        = 0x8B0000,
	PXColor_Pink                           = 0xFFC0CB,
	PXColor_LightPink                      = 0xFFB6C1,
	PXColor_HotPink                        = 0xFF69B4,
	PXColor_DeepPink                       = 0xFF1493,
	PXColor_MediumVioletRed                = 0xC71585,
	PXColor_PaleVioletRed                  = 0xDB7093,
	PXColor_Coral                          = 0xFF7F50,
	PXColor_Tomato                         = 0xFF6347,
	PXColor_OrangeRed                      = 0xFF4500,
	PXColor_DarkOrange                     = 0xFF8C00,
	PXColor_Orange                         = 0xFFA500,
	PXColor_Gold                           = 0xFFD700,
	PXColor_Yellow                         = 0xFFFF00,
	PXColor_LightYellow                    = 0xFFFFE0,
	PXColor_LemonChiffon                   = 0xFFFACD,
	PXColor_LightGoldenrodYellow           = 0xFAFAD2,
	PXColor_PapayaWhip                     = 0xFFEFD5,
	PXColor_Moccasin                       = 0xFFE4B5,
	PXColor_PeachPuff                      = 0xFFDAB9,
	PXColor_PaleGoldenrod                  = 0xEEE8AA,
	PXColor_Khaki                          = 0xF0E68C,
	PXColor_DarkKhaki                      = 0xBDB76B,
	PXColor_Lavender                       = 0xE6E6FA,
	PXColor_Thistle                        = 0xD8BFD8,
	PXColor_Plum                           = 0xDDA0DD,
	PXColor_Violet                         = 0xEE82EE,
	PXColor_Orchid                         = 0xDA70D6,
	PXColor_Fuchsia                        = 0xFF00FF,
	PXColor_Magenta                        = 0xFF00FF,
	PXColor_MediumOrchid                   = 0xBA55D3,
	PXColor_MediumPurple                   = 0x9370DB,
	PXColor_Amethyst                       = 0x9966CC,
	PXColor_BlueViolet                     = 0x8A2BE2,
	PXColor_DarkViolet                     = 0x9400D3,
	PXColor_DarkOrchid                     = 0x9932CC,
	PXColor_DarkMagenta                    = 0x8B008B,
	PXColor_Purple                         = 0x800080,
	PXColor_Indigo                         = 0x4B0082,
	PXColor_SlateBlue                      = 0x6A5ACD,
	PXColor_DarkSlateBlue                  = 0x483D8B,
	PXColor_MediumSlateBlue                = 0x7B68EE,
	PXColor_GreenYellow                    = 0xADFF2F,
	PXColor_Chartreuse                     = 0x7FFF00,
	PXColor_LawnGreen                      = 0x7CFC00,
	PXColor_Lime                           = 0x00FF00,
	PXColor_LimeGreen                      = 0x32CD32,
	PXColor_PaleGreen                      = 0x98FB98,
	PXColor_LightGreen                     = 0x90EE90,
	PXColor_MediumSpringGreen              = 0x00FA9A,
	PXColor_SpringGreen                    = 0x00FF7F,
	PXColor_MediumSeaGreen                 = 0x3CB371,
	PXColor_SeaGreen                       = 0x2E8B57,
	PXColor_ForestGreen                    = 0x228B22,
	PXColor_Green                          = 0x008000,
	PXColor_DarkGreen                      = 0x006400,
	PXColor_YellowGreen                    = 0x9ACD32,
	PXColor_OliveDrab                      = 0x6B8E23,
	PXColor_Olive                          = 0x808000,
	PXColor_DarkOliveGreen                 = 0x556B2F,
	PXColor_MediumAquamarine               = 0x66CDAA,
	PXColor_DarkSeaGreen                   = 0x8FBC8F,
	PXColor_LightSeaGreen                  = 0x20B2AA,
	PXColor_DarkCyan                       = 0x008B8B,
	PXColor_Teal                           = 0x008080,
	PXColor_Aqua                           = 0x00FFFF,
	PXColor_Cyan                           = 0x00FFFF,
	PXColor_LightCyan                      = 0xE0FFFF,
	PXColor_PaleTurquoise                  = 0xAFEEEE,
	PXColor_Aquamarine                     = 0x7FFFD4,
	PXColor_Turquoise                      = 0x40E0D0,
	PXColor_MediumTurquoise                = 0x48D1CC,
	PXColor_DarkTurquoise                  = 0x00CED1,
	PXColor_CadetBlue                      = 0x5F9EA0,
	PXColor_SteelBlue                      = 0x4682B4,
	PXColor_LightSteelBlue                 = 0xB0C4DE,
	PXColor_PowderBlue                     = 0xB0E0E6,
	PXColor_LightBlue                      = 0xADD8E6,
	PXColor_SkyBlue                        = 0x87CEEB,
	PXColor_LightSkyBlue                   = 0x87CEFA,
	PXColor_DeepSkyBlue                    = 0x00BFFF,
	PXColor_DodgerBlue                     = 0x1E90FF,
	PXColor_CornflowerBlue                 = 0x6495ED,
	PXColor_RoyalBlue                      = 0x4169E1,
	PXColor_Blue                           = 0x0000FF,
	PXColor_MediumBlue                     = 0x0000CD,
	PXColor_DarkBlue                       = 0x00008B,
	PXColor_Navy                           = 0x000080,
	PXColor_MidnightBlue                   = 0x191970,
	PXColor_Cornsilk                       = 0xFFF8DC,
	PXColor_BlanchedAlmond                 = 0xFFEBCD,
	PXColor_Bisque                         = 0xFFE4C4,
	PXColor_NavajoWhite                    = 0xFFDEAD,
	PXColor_Wheat                          = 0xF5DEB3,
	PXColor_BurlyWood                      = 0xDEB887,
	PXColor_Tan                            = 0xD2B48C,
	PXColor_RosyBrown                      = 0xBC8F8F,
	PXColor_SandyBrown                     = 0xF4A460,
	PXColor_Goldenrod                      = 0xDAA520,
	PXColor_DarkGoldenrod                  = 0xB8860B,
	PXColor_Peru                           = 0xCD853F,
	PXColor_Chocolate                      = 0xD2691E,
	PXColor_SaddleBrown                    = 0x8B4513,
	PXColor_Sienna                         = 0xA0522D,
	PXColor_Brown                          = 0xA52A2A,
	PXColor_Maroon                         = 0x800000,
	PXColor_White                          = 0xFFFFFF,
	PXColor_Snow                           = 0xFFFAFA,
	PXColor_Honeydew                       = 0xF0FFF0,
	PXColor_MintCream                      = 0xF5FFFA,
	PXColor_Azure                          = 0xF0FFFF,
	PXColor_AliceBlue                      = 0xF0F8FF,
	PXColor_GhostWhite                     = 0xF8F8FF,
	PXColor_WhiteSmoke                     = 0xF5F5F5,
	PXColor_Seashell                       = 0xFFF5EE,
	PXColor_Beige                          = 0xF5F5DC,
	PXColor_OldLace                        = 0xFDF5E6,
	PXColor_FloralWhite                    = 0xFFFAF0,
	PXColor_Ivory                          = 0xFFFFF0,
	PXColor_AntiqueWhite                   = 0xFAEBD7,
	PXColor_Linen                          = 0xFAF0E6,
	PXColor_LavenderBlush                  = 0xFFF0F5,
	PXColor_MistyRose                      = 0xFFE4E1,
	PXColor_Gainsboro                      = 0xDCDCDC,
	PXColor_LightGrey                      = 0xD3D3D3,
	PXColor_Silver                         = 0xC0C0C0,
	PXColor_DarkGray                       = 0xA9A9A9,
	PXColor_Gray                           = 0x808080,
	PXColor_DimGray                        = 0x696969,
	PXColor_LightSlateGray                 = 0x778899,
	PXColor_SlateGray                      = 0x708090,
	PXColor_DarkSlateGray                  = 0x2F4F4F,
	PXColor_Black                          = 0x000000
} PXColor;

#ifdef __cplusplus
}
#endif
	
#endif
