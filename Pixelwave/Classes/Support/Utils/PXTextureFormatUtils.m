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

#import "PXTextureFormatUtils.h"

#pragma mark -
#pragma mark - Make
#pragma mark -

PXInline_c PXTF_RGBA_8888 PXTF_RGBA_8888_Make(UInt8 red, UInt8 green, UInt8 blue, UInt8 alpha)
{
	PXTF_RGBA_8888 retVal;

	retVal.red   = red;
	retVal.green = green;
	retVal.blue  = blue;
	retVal.alpha = alpha;

	return retVal;
}
PXInline_c PXTF_RGB_888 PXTF_RGB_888_Make(UInt8 red, UInt8 green, UInt8 blue)
{
	PXTF_RGB_888 retVal;

	retVal.red   = red;
	retVal.green = green;
	retVal.blue  = blue;

	return retVal;
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_Make(UInt8 red, UInt8 green, UInt8 blue, UInt8 alpha)
{
	return (PXTF_RGBA_4444)(((red & 0x0F) << 12) | ((green & 0x0F) << 8) | ((blue & 0x0F) << 4) | (alpha & 0x0F));
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_Make(UInt8 red, UInt8 green, UInt8 blue, BOOL alpha)
{
	return (PXTF_RGBA_5551)(((red & 0x1F) << 11) | ((green & 0x1F) << 6) | ((blue & 0x1F) << 1) | alpha);
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_Make(UInt8 red, UInt8 green, UInt8 blue)
{
	return (PXTF_RGB_565)(((red & 0x1F) << 11) | ((green & 0x3F) << 5) | (blue & 0x1F));
}
PXInline_c PXTF_LA_88 PXTF_LA_88_Make(UInt8 luminance, UInt8 alpha)
{
	PXTF_LA_88 retVal;

	retVal.luminance = luminance;
	retVal.alpha = alpha;

	return retVal;
}
PXInline_c PXTF_A_8 PXTF_A_8_Make(UInt8 alpha)
{
	return alpha;
}
PXInline_c PXTF_L_8 PXTF_L_8_Make(UInt8 luminance)
{
	return luminance;
}

#pragma mark -
#pragma mark - To RGBA 8888
#pragma mark -

PXInline_c PXTF_RGBA_8888 PXTF_RGBA_8888_From_RGB_888(PXTF_RGB_888 val)
{
	return PXTF_RGBA_8888_Make(val.red, val.green, val.blue, 0xFF);
}
PXInline_c PXTF_RGBA_8888 PXTF_RGBA_8888_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return PXTF_RGBA_8888_Make(_PX4BitTo8Bit(_PXTF_4444_R(val)),
							   _PX4BitTo8Bit(_PXTF_4444_B(val)),
							   _PX4BitTo8Bit(_PXTF_4444_G(val)),
							   _PX4BitTo8Bit(_PXTF_4444_A(val)));
}
PXInline_c PXTF_RGBA_8888 PXTF_RGBA_8888_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PXTF_RGBA_8888_Make(_PX5BitTo8Bit(_PXTF_5551_R(val)),
							   _PX5BitTo8Bit(_PXTF_5551_G(val)),
							   _PX5BitTo8Bit(_PXTF_5551_B(val)),
							   _PX1BitTo8Bit(_PXTF_5551_A(val)));
}
PXInline_c PXTF_RGBA_8888 PXTF_RGBA_8888_From_RGB_565(PXTF_RGB_565 val)
{
	return PXTF_RGBA_8888_Make(_PX5BitTo8Bit(_PXTF_565_R(val)),
							   _PX6BitTo8Bit(_PXTF_565_G(val)),
							   _PX5BitTo8Bit(_PXTF_565_B(val)),
							   0xFF);
}
PXInline_c PXTF_RGBA_8888 PXTF_RGBA_8888_From_LA_88(PXTF_LA_88 val)
{
	return PXTF_RGBA_8888_Make(val.luminance,
							   val.luminance,
							   val.luminance,
							   val.alpha);
}
PXInline_c PXTF_RGBA_8888 PXTF_RGBA_8888_From_A_8(PXTF_A_8 val)
{
	return PXTF_RGBA_8888_Make(0xFF, 0xFF, 0xFF, val);
}
PXInline_c PXTF_RGBA_8888 PXTF_RGBA_8888_From_L_8(PXTF_L_8 val)
{
	return PXTF_RGBA_8888_Make(val, val, val, 0xFF);
}

#pragma mark -
#pragma mark - To RGB 888
#pragma mark -

PXInline_c PXTF_RGB_888 PXTF_RGB_888_From_RGBA_8888(PXTF_RGBA_8888 val)
{
	return PXTF_RGB_888_Make(val.red, val.green, val.blue);
}
PXInline_c PXTF_RGB_888 PXTF_RGB_888_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return PXTF_RGB_888_Make(_PX4BitTo8Bit(_PXTF_4444_R(val)),
							 _PX4BitTo8Bit(_PXTF_4444_G(val)),
							 _PX4BitTo8Bit(_PXTF_4444_B(val)));
}
PXInline_c PXTF_RGB_888 PXTF_RGB_888_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PXTF_RGB_888_Make(_PX5BitTo8Bit(_PXTF_5551_R(val)),
							 _PX5BitTo8Bit(_PXTF_5551_G(val)),
							 _PX5BitTo8Bit(_PXTF_5551_B(val)));
}
PXInline_c PXTF_RGB_888 PXTF_RGB_888_From_RGB_565(PXTF_RGB_565 val)
{
	return PXTF_RGB_888_Make(_PX5BitTo8Bit(_PXTF_565_R(val)),
							 _PX6BitTo8Bit(_PXTF_565_G(val)),
							 _PX5BitTo8Bit(_PXTF_565_B(val)));
}
PXInline_c PXTF_RGB_888 PXTF_RGB_888_From_LA_88(PXTF_LA_88 val)
{
	return PXTF_RGB_888_Make(val.luminance, val.luminance, val.luminance);
}
PXInline_c PXTF_RGB_888 PXTF_RGB_888_From_A_8(PXTF_A_8 val)
{
	return PXTF_RGB_888_Make(val, val, val);
}
PXInline_c PXTF_RGB_888 PXTF_RGB_888_From_L_8(PXTF_L_8 val)
{
	return PXTF_RGB_888_Make(val, val, val);
}

#pragma mark -
#pragma mark - To RGBA 4444
#pragma mark -

PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGBA_8888(PXTF_RGBA_8888 val)
{
	return PXTF_RGBA_4444_Make(_PX8BitTo4Bit(val.red),
							   _PX8BitTo4Bit(val.green),
							   _PX8BitTo4Bit(val.blue),
							   _PX8BitTo4Bit(val.alpha));
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGB_888(PXTF_RGB_888 val)
{
	return PXTF_RGBA_4444_Make(_PX8BitTo4Bit(val.red),
							   _PX8BitTo4Bit(val.green),
							   _PX8BitTo4Bit(val.blue),
							   0x0F);
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PXTF_RGBA_4444_Make(_PX5BitTo4Bit(_PXTF_5551_R(val)),
							   _PX5BitTo4Bit(_PXTF_5551_G(val)),
							   _PX5BitTo4Bit(_PXTF_5551_B(val)),
							   _PX5BitTo4Bit(_PXTF_5551_A(val)));
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGB_565(PXTF_RGB_565 val)
{
	return PXTF_RGBA_4444_Make(_PX5BitTo4Bit(_PXTF_565_R(val)),
							   _PX5BitTo4Bit(_PXTF_565_G(val)),
							   _PX5BitTo4Bit(_PXTF_565_B(val)),
							   0x0F);
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_LA_88(PXTF_LA_88 val)
{
	uint8_t lum = _PX8BitTo4Bit(val.luminance);
	return PXTF_RGBA_4444_Make(lum, lum, lum, _PX8BitTo4Bit(val.alpha));
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_A_8(PXTF_A_8 val)
{
	return PXTF_RGBA_4444_Make(0x0F, 0x0F, 0x0F, _PX8BitTo4Bit(val));
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_L_8(PXTF_L_8 val)
{
	uint8_t lum = _PX8BitTo4Bit(val);
	return PXTF_RGBA_4444_Make(lum, lum, lum, 0x0F);
}

#pragma mark -
#pragma mark - To RGBA 5551
#pragma mark -

PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGBA_8888(PXTF_RGBA_8888 val)
{
	return PXTF_RGBA_5551_Make(_PX8BitTo5Bit(val.red),
							   _PX8BitTo5Bit(val.green),
							   _PX8BitTo5Bit(val.blue),
							   _PX8BitTo1Bit(val.alpha));
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGB_888(PXTF_RGB_888 val)
{
	return PXTF_RGBA_5551_Make(_PX8BitTo5Bit(val.red),
							   _PX8BitTo5Bit(val.green),
							   _PX8BitTo5Bit(val.blue),
							   0x01);
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return PXTF_RGBA_5551_Make(_PX4BitTo5Bit(_PXTF_4444_R(val)),
							   _PX4BitTo5Bit(_PXTF_4444_G(val)),
							   _PX4BitTo5Bit(_PXTF_4444_B(val)),
							   _PX4BitTo1Bit(_PXTF_4444_A(val)));
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGB_565(PXTF_RGB_565 val)
{
	return PXTF_RGBA_5551_Make(_PXTF_565_R(val),
							   _PX6BitTo5Bit(_PXTF_565_G(val)),
							   _PXTF_565_B(val),
							   0x01);
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_LA_88(PXTF_LA_88 val)
{
	uint8_t lum = _PX8BitTo5Bit(val.luminance);
	return PXTF_RGBA_5551_Make(lum, lum, lum, _PX8BitTo5Bit(val.alpha));
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_A_8(PXTF_A_8 val)
{
	return PXTF_RGBA_5551_Make(0x1F, 0x1F, 0x1F, _PX8BitTo5Bit(val));
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_L_8(PXTF_L_8 val)
{
	uint8_t lum = _PX8BitTo5Bit(val);
	return PXTF_RGBA_5551_Make(lum, lum, lum, 0x1F);
}

#pragma mark -
#pragma mark - To RGBA 565
#pragma mark -

PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_RGBA_8888(PXTF_RGBA_8888 val)
{
	return PXTF_RGB_565_Make(_PX8BitTo5Bit(val.red),
							 _PX8BitTo6Bit(val.green),
							 _PX8BitTo5Bit(val.blue));
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_RGB_888(PXTF_RGB_888 val)
{
	return PXTF_RGB_565_Make(_PX8BitTo5Bit(val.red),
							 _PX8BitTo6Bit(val.green),
							 _PX8BitTo5Bit(val.blue));
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return PXTF_RGB_565_Make(_PX4BitTo5Bit(_PXTF_4444_R(val)),
							 _PX4BitTo6Bit(_PXTF_4444_G(val)),
							 _PX4BitTo5Bit(_PXTF_4444_B(val)));
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PXTF_RGB_565_Make(_PXTF_5551_R(val),
							 _PX5BitTo6Bit(_PXTF_5551_G(val)),
							 _PXTF_5551_B(val));
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_LA_88(PXTF_LA_88 val)
{
	uint8_t lum5 = _PX8BitTo5Bit(val.luminance);
	return PXTF_RGB_565_Make(lum5, _PX8BitTo6Bit(val.luminance), lum5);
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_A_8(PXTF_A_8 val)
{
	uint8_t alph5 = _PX8BitTo5Bit(val);
	return PXTF_RGB_565_Make(alph5, alph5, alph5);
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_L_8(PXTF_L_8 val)
{
	uint8_t lum5 = _PX8BitTo5Bit(val);
	return PXTF_RGB_565_Make(lum5, _PX8BitTo6Bit(val), lum5);
}

#pragma mark -
#pragma mark - To LA 88
#pragma mark -

PXInline_c PXTF_LA_88 PXTF_LA_88_From_RGBA_8888(PXTF_RGBA_8888 val)
{
	return PXTF_LA_88_Make(_PX888BitsTo8Bit(val.red, val.green, val.blue),
						   val.alpha);
}
PXInline_c PXTF_LA_88 PXTF_LA_88_From_RGB_888(PXTF_RGB_888 val)
{
	return PXTF_LA_88_Make(_PX888BitsTo8Bit(val.red,
										   val.green,
										   val.blue),
						   0xFF);
}
PXInline_c PXTF_LA_88 PXTF_LA_88_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return PXTF_LA_88_Make(_PX444BitsTo8Bit(_PXTF_4444_R(val), _PXTF_4444_G(val), _PXTF_4444_B(val)),
						   _PX4BitTo8Bit(_PXTF_4444_A(val)));
}
PXInline_c PXTF_LA_88 PXTF_LA_88_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PXTF_LA_88_Make(_PX555BitsTo8Bit(_PXTF_5551_R(val), _PXTF_5551_G(val), _PXTF_5551_B(val)),
						   _PX1BitTo8Bit(_PXTF_5551_A(val)));
}
PXInline_c PXTF_LA_88 PXTF_LA_88_From_RGB_565(PXTF_RGB_565 val)
{
	return PXTF_LA_88_Make(_PX565BitsTo8Bit(_PXTF_565_R(val), _PXTF_565_G(val), _PXTF_565_B(val)),
						   0xFF);
}
PXInline_c PXTF_LA_88 PXTF_LA_88_From_A_8(PXTF_A_8 val)
{
	return PXTF_LA_88_Make(0xFF, val);
}
PXInline_c PXTF_LA_88 PXTF_LA_88_From_L_8(PXTF_L_8 val)
{
	return PXTF_LA_88_Make(val, 0xFF);
}

#pragma mark -
#pragma mark - To A 8
#pragma mark -

PXInline_c PXTF_A_8 PXTF_A_8_From_RGBA_8888(PXTF_RGBA_8888 val)
{
	return val.alpha;
}
PXInline_c PXTF_A_8 PXTF_A_8_From_RGB_888(PXTF_RGB_888 val)
{
	return 0xFF;
}
PXInline_c PXTF_A_8 PXTF_A_8_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return _PX4BitTo8Bit(_PXTF_4444_A(val));
}
PXInline_c PXTF_A_8 PXTF_A_8_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return _PX1BitTo8Bit(_PXTF_5551_A(val));
}
PXInline_c PXTF_A_8 PXTF_A_8_From_RGB_565(PXTF_RGB_565 val)
{
	return 0xFF;
}
PXInline_c PXTF_A_8 PXTF_A_8_From_LA_88(PXTF_LA_88 val)
{
	return val.alpha;
}
PXInline_c PXTF_A_8 PXTF_A_8_From_L_8(PXTF_L_8 val)
{
	return val;
}

#pragma mark -
#pragma mark - To L 8
#pragma mark -

PXInline_c PXTF_L_8 PXTF_L_8_From_RGBA_8888(PXTF_RGBA_8888 val)
{
	return _PX888BitsTo8Bit(val.red, val.green, val.blue);
}
PXInline_c PXTF_L_8 PXTF_L_8_From_RGB_888(PXTF_RGB_888 val)
{
	return _PX888BitsTo8Bit(val.red, val.green, val.blue);
}
PXInline_c PXTF_L_8 PXTF_L_8_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return _PX444BitsTo8Bit(_PXTF_4444_R(val), _PXTF_4444_G(val), _PXTF_4444_B(val));
}
PXInline_c PXTF_L_8 PXTF_L_8_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return _PX555BitsTo8Bit(_PXTF_5551_R(val), _PXTF_5551_G(val), _PXTF_5551_B(val));
}
PXInline_c PXTF_L_8 PXTF_L_8_From_RGB_565(PXTF_RGB_565 val)
{
	return _PX565BitsTo8Bit(_PXTF_565_R(val), _PXTF_565_G(val), _PXTF_565_B(val));
}
PXInline_c PXTF_L_8 PXTF_L_8_From_LA_88(PXTF_LA_88 val)
{
	return val.luminance;
}
PXInline_c PXTF_L_8 PXTF_L_8_From_A_8(PXTF_A_8 val)
{
	return val;
}
