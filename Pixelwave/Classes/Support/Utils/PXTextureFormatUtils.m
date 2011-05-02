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

#define PXTF_ONE_6BIT 0.01587301f
#define PXTF_ONE_5BIT 0.03225806f
#define PXTF_ONE_4BIT 0.06666667f
#define PXTF_ONE_RGB  0.00130718f

#define PXTF_4444_R(_val_) ((_val_) >> 12)
#define PXTF_4444_G(_val_) ((_val_) >> 8)
#define PXTF_4444_B(_val_) ((_val_) >> 4)
#define PXTF_4444_A(_val_) (_val_)

#define PXTF_5551_R(_val_) ((_val_) >> 11)
#define PXTF_5551_G(_val_) ((_val_) >> 6)
#define PXTF_5551_B(_val_) ((_val_) >> 1)
#define PXTF_5551_A(_val_) (_val_)

#define PXTF_565_R(_val_) ((_val_) >> 11)
#define PXTF_565_G(_val_) ((_val_) >> 5)
#define PXTF_565_B(_val_) (_val_)

#pragma mark -
#pragma mark - Bit Changers
#pragma mark -

// 8 Bit
PXInline uint8_t PX8BitTo6Bit(uint8_t val)
{
	return (val >> 2) & 0x3F;
}
PXInline uint8_t PX8BitTo5Bit(uint8_t val)
{
	return (val >> 3) & 0x1F;
}
PXInline uint8_t PX8BitTo4Bit(uint8_t val)
{
	return (val >> 4) & 0x0F;
}
PXInline uint8_t PX8BitTo1Bit(uint8_t val)
{
	return (val >> 7) & 0x01;
}

// 6 Bit
PXInline uint8_t PX6BitTo8Bit(uint8_t val)
{
	return ((((float)(val & 0x3F)) * PXTF_ONE_6BIT) * 0xFF);
}
PXInline uint8_t PX6BitTo5Bit(uint8_t val)
{
	return ((val & 0x3F) >> 1) & 0x1F;
}
PXInline uint8_t PX6BitTo4Bit(uint8_t val)
{
	return ((val & 0x3F) >> 2) & 0x0F;
}
PXInline uint8_t PX6BitTo1Bit(uint8_t val)
{
	return ((val & 0x3F) >> 5) & 0x01;
}

// 5 Bit
PXInline uint8_t PX5BitTo8Bit(uint8_t val)
{
	return ((((float)(val & 0x1F)) * PXTF_ONE_5BIT) * 0xFF);
}
PXInline uint8_t PX5BitTo6Bit(uint8_t val)
{
	return ((((float)(val & 0x1F)) * PXTF_ONE_5BIT) * 0x3F);
}
PXInline uint8_t PX5BitTo4Bit(uint8_t val)
{
	return ((val & 0x3F) >> 1) & 0x0F;
}
PXInline uint8_t PX5BitTo1Bit(uint8_t val)
{
	return ((val & 0x3F) >> 4) & 0x01;
}

// 4 Bit
PXInline uint8_t PX4BitTo8Bit(uint8_t val)
{
	return ((((float)(val & 0x0F)) * PXTF_ONE_4BIT) * 0xFF);
}
PXInline uint8_t PX4BitTo6Bit(uint8_t val)
{
	return ((((float)(val & 0x0F)) * PXTF_ONE_4BIT) * 0x3F);
}
PXInline uint8_t PX4BitTo5Bit(uint8_t val)
{
	return ((((float)(val & 0x0F)) * PXTF_ONE_4BIT) * 0x1F);
}
PXInline uint8_t PX4BitTo1Bit(uint8_t val)
{
	return ((val & 0x0F) >> 3) & 0x01;
}

// 1 Bit
PXInline uint8_t PX1BitTo8Bit(uint8_t val)
{
	return ((val & 0x01) * 0xFF);
}
PXInline uint8_t PX1BitTo6Bit(uint8_t val)
{
	return ((val & 0x01) * 0x3F);
}
PXInline uint8_t PX1BitTo5Bit(uint8_t val)
{
	return ((val & 0x01) * 0x1F);
}
PXInline uint8_t PX1BitTo4Bit(uint8_t val)
{
	return ((val & 0x01) * 0x0F);
}

// Color Bits
PXInline uint8_t PX888BitsTo8Bit(uint8_t r, uint8_t g, uint8_t b)
{
	return ((float)((r + g + b) * PXTF_ONE_RGB)) * 0xFF;
}
PXInline uint8_t PX565BitsTo8Bit(uint8_t r, uint8_t g, uint8_t b)
{
	return ((float)(((r & 0x1F) + (g & 0x3F) + (b & 0x1F)) * PXTF_ONE_RGB)) * 0xFF;
}
PXInline uint8_t PX555BitsTo8Bit(uint8_t r, uint8_t g, uint8_t b)
{
	return ((float)(((r & 0x1F) + (g & 0x1F) + (b & 0x1F)) * PXTF_ONE_RGB)) * 0xFF;
}
PXInline uint8_t PX444BitsTo8Bit(uint8_t r, uint8_t g, uint8_t b)
{
	return ((float)(((r & 0x0F) + (g & 0x0F) + (b & 0x0F)) * PXTF_ONE_RGB)) * 0xFF;
}

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
	return PXTF_RGBA_8888_Make(PX4BitTo8Bit(PXTF_4444_R(val)),
							   PX4BitTo8Bit(PXTF_4444_B(val)),
							   PX4BitTo8Bit(PXTF_4444_G(val)),
							   PX4BitTo8Bit(PXTF_4444_A(val)));
}
PXInline_c PXTF_RGBA_8888 PXTF_RGBA_8888_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PXTF_RGBA_8888_Make(PX5BitTo8Bit(PXTF_5551_R(val)),
							   PX5BitTo8Bit(PXTF_5551_G(val)),
							   PX5BitTo8Bit(PXTF_5551_B(val)),
							   PX5BitTo8Bit(PXTF_5551_A(val)));
}
PXInline_c PXTF_RGBA_8888 PXTF_RGBA_8888_From_RGB_565(PXTF_RGB_565 val)
{
	return PXTF_RGBA_8888_Make(PX5BitTo8Bit(PXTF_565_R(val)),
							   PX6BitTo8Bit(PXTF_565_G(val)),
							   PX5BitTo8Bit(PXTF_565_B(val)),
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
	return PXTF_RGB_888_Make(PX4BitTo8Bit(PXTF_4444_R(val)),
							 PX4BitTo8Bit(PXTF_4444_G(val)),
							 PX4BitTo8Bit(PXTF_4444_B(val)));
}
PXInline_c PXTF_RGB_888 PXTF_RGB_888_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PXTF_RGB_888_Make(PX5BitTo8Bit(PXTF_5551_R(val)),
							 PX5BitTo8Bit(PXTF_5551_G(val)),
							 PX5BitTo8Bit(PXTF_5551_B(val)));
}
PXInline_c PXTF_RGB_888 PXTF_RGB_888_From_RGB_565(PXTF_RGB_565 val)
{
	return PXTF_RGB_888_Make(PX5BitTo8Bit(PXTF_565_R(val)),
							 PX6BitTo8Bit(PXTF_565_G(val)),
							 PX5BitTo8Bit(PXTF_565_B(val)));
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
	return PXTF_RGBA_4444_Make(PX8BitTo4Bit(val.red),
							   PX8BitTo4Bit(val.green),
							   PX8BitTo4Bit(val.blue),
							   PX8BitTo4Bit(val.alpha));
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGB_888(PXTF_RGB_888 val)
{
	return PXTF_RGBA_4444_Make(PX8BitTo4Bit(val.red),
							   PX8BitTo4Bit(val.green),
							   PX8BitTo4Bit(val.blue),
							   0x0F);
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PXTF_RGBA_4444_Make(PX5BitTo4Bit(PXTF_5551_R(val)),
							   PX5BitTo4Bit(PXTF_5551_G(val)),
							   PX5BitTo4Bit(PXTF_5551_B(val)),
							   PX5BitTo4Bit(PXTF_5551_A(val)));
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGB_565(PXTF_RGB_565 val)
{
	return PXTF_RGBA_4444_Make(PX5BitTo4Bit(PXTF_565_R(val)),
							   PX5BitTo4Bit(PXTF_565_G(val)),
							   PX5BitTo4Bit(PXTF_565_B(val)),
							   0x0F);
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_LA_88(PXTF_LA_88 val)
{
	uint8_t lum = PX8BitTo4Bit(val.luminance);
	return PXTF_RGBA_4444_Make(lum, lum, lum, PX8BitTo4Bit(val.alpha));
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_A_8(PXTF_A_8 val)
{
	return PXTF_RGBA_4444_Make(0x0F, 0x0F, 0x0F, PX8BitTo4Bit(val));
}
PXInline_c PXTF_RGBA_4444 PXTF_RGBA_4444_From_L_8(PXTF_L_8 val)
{
	uint8_t lum = PX8BitTo4Bit(val);
	return PXTF_RGBA_4444_Make(lum, lum, lum, 0x0F);
}

#pragma mark -
#pragma mark - To RGBA 5551
#pragma mark -

PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGBA_8888(PXTF_RGBA_8888 val)
{
	return PXTF_RGBA_5551_Make(PX8BitTo5Bit(val.red),
							   PX8BitTo5Bit(val.green),
							   PX8BitTo5Bit(val.blue),
							   PX8BitTo1Bit(val.alpha));
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGB_888(PXTF_RGB_888 val)
{
	return PXTF_RGBA_5551_Make(PX8BitTo5Bit(val.red),
							   PX8BitTo5Bit(val.green),
							   PX8BitTo5Bit(val.blue),
							   0x01);
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return PXTF_RGBA_5551_Make(PX4BitTo5Bit(PXTF_4444_R(val)),
							   PX4BitTo5Bit(PXTF_4444_G(val)),
							   PX4BitTo5Bit(PXTF_4444_B(val)),
							   PX4BitTo1Bit(PXTF_4444_A(val)));
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGB_565(PXTF_RGB_565 val)
{
	return PXTF_RGBA_5551_Make(PXTF_565_R(val),
							   PX6BitTo5Bit(PXTF_565_G(val)),
							   PXTF_565_B(val),
							   0x01);
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_LA_88(PXTF_LA_88 val)
{
	uint8_t lum = PX8BitTo5Bit(val.luminance);
	return PXTF_RGBA_5551_Make(lum, lum, lum, PX8BitTo5Bit(val.alpha));
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_A_8(PXTF_A_8 val)
{
	return PXTF_RGBA_5551_Make(0x1F, 0x1F, 0x1F, PX8BitTo5Bit(val));
}
PXInline_c PXTF_RGBA_5551 PXTF_RGBA_5551_From_L_8(PXTF_L_8 val)
{
	uint8_t lum = PX8BitTo5Bit(val);
	return PXTF_RGBA_5551_Make(lum, lum, lum, 0x1F);
}

#pragma mark -
#pragma mark - To RGBA 565
#pragma mark -

PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_RGBA_8888(PXTF_RGBA_8888 val)
{
	return PXTF_RGB_565_Make(PX8BitTo5Bit(val.red),
							 PX8BitTo6Bit(val.green),
							 PX8BitTo5Bit(val.blue));
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_RGB_888(PXTF_RGB_888 val)
{
	return PXTF_RGB_565_Make(PX8BitTo5Bit(val.red),
							 PX8BitTo6Bit(val.green),
							 PX8BitTo5Bit(val.blue));
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return PXTF_RGB_565_Make(PX4BitTo5Bit(PXTF_4444_R(val)),
							 PX4BitTo6Bit(PXTF_4444_G(val)),
							 PX4BitTo5Bit(PXTF_4444_B(val)));
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PXTF_RGB_565_Make(PXTF_5551_R(val),
							 PX5BitTo6Bit(PXTF_5551_G(val)),
							 PXTF_5551_B(val));
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_LA_88(PXTF_LA_88 val)
{
	uint8_t lum5 = PX8BitTo5Bit(val.luminance);
	return PXTF_RGB_565_Make(lum5, PX8BitTo6Bit(val.luminance), lum5);
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_A_8(PXTF_A_8 val)
{
	uint8_t alph5 = PX8BitTo5Bit(val);
	return PXTF_RGB_565_Make(alph5, alph5, alph5);
}
PXInline_c PXTF_RGB_565 PXTF_RGB_565_From_L_8(PXTF_L_8 val)
{
	uint8_t lum5 = PX8BitTo5Bit(val);
	return PXTF_RGB_565_Make(lum5, PX8BitTo6Bit(val), lum5);
}

#pragma mark -
#pragma mark - To LA 88
#pragma mark -

PXInline_c PXTF_LA_88 PXTF_LA_88_From_RGBA_8888(PXTF_RGBA_8888 val)
{
	return PXTF_LA_88_Make(PX888BitsTo8Bit(val.red, val.green, val.blue),
						   val.alpha);
}
PXInline_c PXTF_LA_88 PXTF_LA_88_From_RGB_888(PXTF_RGB_888 val)
{
	return PXTF_LA_88_Make(PX888BitsTo8Bit(val.red,
										   val.green,
										   val.blue),
						   0xFF);
}
PXInline_c PXTF_LA_88 PXTF_LA_88_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return PXTF_LA_88_Make(PX444BitsTo8Bit(PXTF_4444_R(val), PXTF_4444_G(val), PXTF_4444_B(val)),
						   PX4BitTo8Bit(PXTF_4444_A(val)));
}
PXInline_c PXTF_LA_88 PXTF_LA_88_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PXTF_LA_88_Make(PX555BitsTo8Bit(PXTF_5551_R(val), PXTF_5551_G(val), PXTF_5551_B(val)),
						   PX1BitTo8Bit(PXTF_5551_A(val)));
}
PXInline_c PXTF_LA_88 PXTF_LA_88_From_RGB_565(PXTF_RGB_565 val)
{
	return PXTF_LA_88_Make(PX565BitsTo8Bit(PXTF_565_R(val), PXTF_565_G(val), PXTF_565_B(val)),
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
	return PX4BitTo8Bit(PXTF_4444_A(val));
}
PXInline_c PXTF_A_8 PXTF_A_8_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PX1BitTo8Bit(PXTF_5551_A(val));
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
	return PX888BitsTo8Bit(val.red, val.green, val.blue);
}
PXInline_c PXTF_L_8 PXTF_L_8_From_RGB_888(PXTF_RGB_888 val)
{
	return PX888BitsTo8Bit(val.red, val.green, val.blue);
}
PXInline_c PXTF_L_8 PXTF_L_8_From_RGBA_4444(PXTF_RGBA_4444 val)
{
	return PX444BitsTo8Bit(PXTF_4444_R(val), PXTF_4444_G(val), PXTF_4444_B(val));
}
PXInline_c PXTF_L_8 PXTF_L_8_From_RGBA_5551(PXTF_RGBA_5551 val)
{
	return PX555BitsTo8Bit(PXTF_5551_R(val), PXTF_5551_G(val), PXTF_5551_B(val));
}
PXInline_c PXTF_L_8 PXTF_L_8_From_RGB_565(PXTF_RGB_565 val)
{
	return PX565BitsTo8Bit(PXTF_565_R(val), PXTF_565_G(val), PXTF_565_B(val));
}
PXInline_c PXTF_L_8 PXTF_L_8_From_LA_88(PXTF_LA_88 val)
{
	return val.luminance;
}
PXInline_c PXTF_L_8 PXTF_L_8_From_A_8(PXTF_A_8 val)
{
	return val;
}
