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

#ifndef _PX_TEXTURE_FORMAT_UTILS_H_
#define _PX_TEXTURE_FORMAT_UTILS_H_

#import "PXHeaderUtils.h"

#define _PXTextureFormatPixelsCopyWithFunc(_read_, _write_, _count_, _TYPE_, _FUNC_) \
{ \
	_TYPE_ *_curReadPixel_; \
	unsigned _index_; \
\
	for (_index_ = 0, _curReadPixel_ = (_TYPE_ *)(_read_); _index_ < _count_; ++_index_, ++_curReadPixel_) \
	{ \
		*_write_ = _FUNC_(*_curReadPixel_); \
		++_write_; \
	} \
}

#define _PXTF_ONE_6BIT 0.01587301f
#define _PXTF_ONE_5BIT 0.03225806f
#define _PXTF_ONE_4BIT 0.06666667f
#define _PXTF_ONE_RGB  0.00130718f

#define _PXTF_4444_R(_val_) ((_val_) >> 12)
#define _PXTF_4444_G(_val_) ((_val_) >> 8)
#define _PXTF_4444_B(_val_) ((_val_) >> 4)
#define _PXTF_4444_A(_val_) (_val_)

#define _PXTF_5551_R(_val_) ((_val_) >> 11)
#define _PXTF_5551_G(_val_) ((_val_) >> 6)
#define _PXTF_5551_B(_val_) ((_val_) >> 1)
#define _PXTF_5551_A(_val_) (_val_)

#define _PXTF_565_R(_val_) ((_val_) >> 11)
#define _PXTF_565_G(_val_) ((_val_) >> 5)
#define _PXTF_565_B(_val_) (_val_)

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark -
#pragma mark - Define
#pragma mark -

typedef struct
{
	UInt8 red;
	UInt8 green;
	UInt8 blue;
	UInt8 alpha;
} _PXTF_RGBA8888;

typedef struct
{
	UInt8 red;
	UInt8 green;
	UInt8 blue;
} _PXTF_RGB888;

typedef struct
{
	UInt8 luminance;
	UInt8 alpha;
} _PXTF_LA;

typedef _PXTF_RGBA8888			PXTF_RGBA_8888;
typedef _PXTF_RGB888			PXTF_RGB_888;
typedef UInt16					PXTF_RGBA_4444;
typedef UInt16					PXTF_RGBA_5551;
typedef UInt16					PXTF_RGB_565;
typedef _PXTF_LA				PXTF_LA_88;
typedef UInt8					PXTF_A_8;
typedef UInt8					PXTF_L_8;

#pragma mark -
#pragma mark - Make
#pragma mark -

PXInline_h PXTF_RGBA_8888 PXTF_RGBA_8888_Make(UInt8 red, UInt8 green, UInt8 blue, UInt8 alpha);
PXInline_h PXTF_RGB_888 PXTF_RGB_888_Make(UInt8 red, UInt8 green, UInt8 blue);
PXInline_h PXTF_RGBA_4444 PXTF_RGBA_4444_Make(UInt8 red, UInt8 green, UInt8 blue, UInt8 alpha);
PXInline_h PXTF_RGBA_5551 PXTF_RGBA_5551_Make(UInt8 red, UInt8 green, UInt8 blue, BOOL alpha);
PXInline_h PXTF_RGB_565 PXTF_RGB_565_Make(UInt8 red, UInt8 green, UInt8 blue);
PXInline_h PXTF_LA_88 PXTF_LA_88_Make(UInt8 luminance, UInt8 alpha);
PXInline_h PXTF_A_8 PXTF_A_8_Make(UInt8 alpha);
PXInline_h PXTF_L_8 PXTF_L_8_Make(UInt8 luminance);

#pragma mark -
#pragma mark - To RGBA 8888
#pragma mark -

PXInline_h PXTF_RGBA_8888 PXTF_RGBA_8888_From_RGB_888(PXTF_RGB_888 val);
PXInline_h PXTF_RGBA_8888 PXTF_RGBA_8888_From_RGBA_4444(PXTF_RGBA_4444 val);
PXInline_h PXTF_RGBA_8888 PXTF_RGBA_8888_From_RGBA_5551(PXTF_RGBA_5551 val);
PXInline_h PXTF_RGBA_8888 PXTF_RGBA_8888_From_RGB_565(PXTF_RGB_565 val);
PXInline_h PXTF_RGBA_8888 PXTF_RGBA_8888_From_LA_88(PXTF_LA_88 val);
PXInline_h PXTF_RGBA_8888 PXTF_RGBA_8888_From_A_8(PXTF_A_8 val);
PXInline_h PXTF_RGBA_8888 PXTF_RGBA_8888_From_L_8(PXTF_L_8 val);

#pragma mark -
#pragma mark - To RGB 888
#pragma mark -

PXInline_h PXTF_RGB_888 PXTF_RGB_888_From_RGBA_8888(PXTF_RGBA_8888 val);
PXInline_h PXTF_RGB_888 PXTF_RGB_888_From_RGBA_4444(PXTF_RGBA_4444 val);
PXInline_h PXTF_RGB_888 PXTF_RGB_888_From_RGBA_5551(PXTF_RGBA_5551 val);
PXInline_h PXTF_RGB_888 PXTF_RGB_888_From_RGB_565(PXTF_RGB_565 val);
PXInline_h PXTF_RGB_888 PXTF_RGB_888_From_LA_88(PXTF_LA_88 val);
PXInline_h PXTF_RGB_888 PXTF_RGB_888_From_A_8(PXTF_A_8 val);
PXInline_h PXTF_RGB_888 PXTF_RGB_888_From_L_8(PXTF_L_8 val);

#pragma mark -
#pragma mark - To RGBA 4444
#pragma mark -

PXInline_h PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGBA_8888(PXTF_RGBA_8888 val);
PXInline_h PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGB_888(PXTF_RGB_888 val);
PXInline_h PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGBA_5551(PXTF_RGBA_5551 val);
PXInline_h PXTF_RGBA_4444 PXTF_RGBA_4444_From_RGB_565(PXTF_RGB_565 val);
PXInline_h PXTF_RGBA_4444 PXTF_RGBA_4444_From_LA_88(PXTF_LA_88 val);
PXInline_h PXTF_RGBA_4444 PXTF_RGBA_4444_From_A_8(PXTF_A_8 val);
PXInline_h PXTF_RGBA_4444 PXTF_RGBA_4444_From_L_8(PXTF_L_8 val);

#pragma mark -
#pragma mark - To RGBA 5551
#pragma mark -

PXInline_h PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGBA_8888(PXTF_RGBA_8888 val);
PXInline_h PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGB_888(PXTF_RGB_888 val);
PXInline_h PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGBA_4444(PXTF_RGBA_4444 val);
PXInline_h PXTF_RGBA_5551 PXTF_RGBA_5551_From_RGB_565(PXTF_RGB_565 val);
PXInline_h PXTF_RGBA_5551 PXTF_RGBA_5551_From_LA_88(PXTF_LA_88 val);
PXInline_h PXTF_RGBA_5551 PXTF_RGBA_5551_From_A_8(PXTF_A_8 val);
PXInline_h PXTF_RGBA_5551 PXTF_RGBA_5551_From_L_8(PXTF_L_8 val);

#pragma mark -
#pragma mark - To RGBA 565
#pragma mark -

PXInline_h PXTF_RGB_565 PXTF_RGB_565_From_RGBA_8888(PXTF_RGBA_8888 val);
PXInline_h PXTF_RGB_565 PXTF_RGB_565_From_RGB_888(PXTF_RGB_888 val);
PXInline_h PXTF_RGB_565 PXTF_RGB_565_From_RGBA_4444(PXTF_RGBA_4444 val);
PXInline_h PXTF_RGB_565 PXTF_RGB_565_From_RGBA_5551(PXTF_RGBA_5551 val);
PXInline_h PXTF_RGB_565 PXTF_RGB_565_From_LA_88(PXTF_LA_88 val);
PXInline_h PXTF_RGB_565 PXTF_RGB_565_From_A_8(PXTF_A_8 val);
PXInline_h PXTF_RGB_565 PXTF_RGB_565_From_L_8(PXTF_L_8 val);

#pragma mark -
#pragma mark - To LA 88
#pragma mark -

PXInline_h PXTF_LA_88 PXTF_LA_88_From_RGBA_8888(PXTF_RGBA_8888 val);
PXInline_h PXTF_LA_88 PXTF_LA_88_From_RGB_888(PXTF_RGB_888 val);
PXInline_h PXTF_LA_88 PXTF_LA_88_From_RGBA_4444(PXTF_RGBA_4444 val);
PXInline_h PXTF_LA_88 PXTF_LA_88_From_RGBA_5551(PXTF_RGBA_5551 val);
PXInline_h PXTF_LA_88 PXTF_LA_88_From_RGB_565(PXTF_RGB_565 val);
PXInline_h PXTF_LA_88 PXTF_LA_88_From_A_8(PXTF_A_8 val);
PXInline_h PXTF_LA_88 PXTF_LA_88_From_L_8(PXTF_L_8 val);

#pragma mark -
#pragma mark - To A 8
#pragma mark -

PXInline_h PXTF_A_8 PXTF_A_8_From_RGBA_8888(PXTF_RGBA_8888 val);
PXInline_h PXTF_A_8 PXTF_A_8_From_RGB_888(PXTF_RGB_888 val);
PXInline_h PXTF_A_8 PXTF_A_8_From_RGBA_4444(PXTF_RGBA_4444 val);
PXInline_h PXTF_A_8 PXTF_A_8_From_RGBA_5551(PXTF_RGBA_5551 val);
PXInline_h PXTF_A_8 PXTF_A_8_From_RGB_565(PXTF_RGB_565 val);
PXInline_h PXTF_A_8 PXTF_A_8_From_LA_88(PXTF_LA_88 val);
PXInline_h PXTF_A_8 PXTF_A_8_From_L_8(PXTF_L_8 val);

#pragma mark -
#pragma mark - To L 8
#pragma mark -

PXInline_h PXTF_L_8 PXTF_L_8_From_RGBA_8888(PXTF_RGBA_8888 val);
PXInline_h PXTF_L_8 PXTF_L_8_From_RGB_888(PXTF_RGB_888 val);
PXInline_h PXTF_L_8 PXTF_L_8_From_RGBA_4444(PXTF_RGBA_4444 val);
PXInline_h PXTF_L_8 PXTF_L_8_From_RGBA_5551(PXTF_RGBA_5551 val);
PXInline_h PXTF_L_8 PXTF_L_8_From_RGB_565(PXTF_RGB_565 val);
PXInline_h PXTF_L_8 PXTF_L_8_From_LA_88(PXTF_LA_88 val);
PXInline_h PXTF_L_8 PXTF_L_8_From_A_8(PXTF_A_8 val);

#pragma mark -
#pragma mark - Bit Changers
#pragma mark -

// 8 Bit
PXInline uint8_t _PX8BitTo6Bit(uint8_t val)
{
	return (val >> 2) & 0x3F;
}
PXInline uint8_t _PX8BitTo5Bit(uint8_t val)
{
	return (val >> 3) & 0x1F;
}
PXInline uint8_t _PX8BitTo4Bit(uint8_t val)
{
	return (val >> 4) & 0x0F;
}
PXInline uint8_t _PX8BitTo1Bit(uint8_t val)
{
	return (val >> 7) & 0x01;
}

// 6 Bit
PXInline uint8_t _PX6BitTo8Bit(uint8_t val)
{
	return ((((float)(val & 0x3F)) * _PXTF_ONE_6BIT) * 0xFF);
}
PXInline uint8_t _PX6BitTo5Bit(uint8_t val)
{
	return ((val & 0x3F) >> 1) & 0x1F;
}
PXInline uint8_t _PX6BitTo4Bit(uint8_t val)
{
	return ((val & 0x3F) >> 2) & 0x0F;
}
PXInline uint8_t _PX6BitTo1Bit(uint8_t val)
{
	return ((val & 0x3F) >> 5) & 0x01;
}

// 5 Bit
PXInline uint8_t _PX5BitTo8Bit(uint8_t val)
{
	return ((((float)(val & 0x1F)) * _PXTF_ONE_5BIT) * 0xFF);
}
PXInline uint8_t _PX5BitTo6Bit(uint8_t val)
{
	return ((((float)(val & 0x1F)) * _PXTF_ONE_5BIT) * 0x3F);
}
PXInline uint8_t _PX5BitTo4Bit(uint8_t val)
{
	return ((val & 0x3F) >> 1) & 0x0F;
}
PXInline uint8_t _PX5BitTo1Bit(uint8_t val)
{
	return ((val & 0x3F) >> 4) & 0x01;
}

// 4 Bit
PXInline uint8_t _PX4BitTo8Bit(uint8_t val)
{
	return ((((float)(val & 0x0F)) * _PXTF_ONE_4BIT) * 0xFF);
}
PXInline uint8_t _PX4BitTo6Bit(uint8_t val)
{
	return ((((float)(val & 0x0F)) * _PXTF_ONE_4BIT) * 0x3F);
}
PXInline uint8_t _PX4BitTo5Bit(uint8_t val)
{
	return ((((float)(val & 0x0F)) * _PXTF_ONE_4BIT) * 0x1F);
}
PXInline uint8_t _PX4BitTo1Bit(uint8_t val)
{
	return ((val & 0x0F) >> 3) & 0x01;
}

// 1 Bit
PXInline uint8_t _PX1BitTo8Bit(uint8_t val)
{
	return ((val & 0x01) * 0xFF);
}
PXInline uint8_t _PX1BitTo6Bit(uint8_t val)
{
	return ((val & 0x01) * 0x3F);
}
PXInline uint8_t _PX1BitTo5Bit(uint8_t val)
{
	return ((val & 0x01) * 0x1F);
}
PXInline uint8_t _PX1BitTo4Bit(uint8_t val)
{
	return ((val & 0x01) * 0x0F);
}

// Color Bits
PXInline uint8_t _PX888BitsTo8Bit(uint8_t r, uint8_t g, uint8_t b)
{
	return ((float)((r + g + b) * _PXTF_ONE_RGB)) * 0xFF;
}
PXInline uint8_t _PX565BitsTo8Bit(uint8_t r, uint8_t g, uint8_t b)
{
	return ((float)(((r & 0x1F) + (g & 0x3F) + (b & 0x1F)) * _PXTF_ONE_RGB)) * 0xFF;
}
PXInline uint8_t _PX555BitsTo8Bit(uint8_t r, uint8_t g, uint8_t b)
{
	return ((float)(((r & 0x1F) + (g & 0x1F) + (b & 0x1F)) * _PXTF_ONE_RGB)) * 0xFF;
}
PXInline uint8_t _PX444BitsTo8Bit(uint8_t r, uint8_t g, uint8_t b)
{
	return ((float)(((r & 0x0F) + (g & 0x0F) + (b & 0x0F)) * _PXTF_ONE_RGB)) * 0xFF;
}

#ifdef __cplusplus
}
#endif

#endif
