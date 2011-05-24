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

#ifndef _PX_PRIVATE_UTILS_H_
#define _PX_PRIVATE_UTILS_H_

#include "PXHeaderUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef float			PXGLfloat;
typedef unsigned char   PXGLubyte;

#pragma mark -
#pragma mark Macros
#pragma mark -

#define PX_IS_BIT_ENABLED(_var_, _flag_)	(((_var_) & (_flag_)) == (_flag_))
#define PX_IS_BIT_ENABLED_IN_BOTH(_var1_, _var2_, _flag_)	(PX_IS_BIT_ENABLED(_var1_, _flag_) && PX_IS_BIT_ENABLED(_var2_, _flag_))
#define PX_ENABLE_BIT(_var_, _flag_)		((_var_) |= (_flag_))
#define PX_DISABLE_BIT(_var_, _flag_)		((_var_) &= (~_flag_))
#define PX_COLOR_ONE_DIV_255 (0.00392156863f)
#define PX_COLOR_BYTE_TO_FLOAT(_color_) ((PXGLfloat)(_color_)  * PX_COLOR_ONE_DIV_255)
#define PX_COLOR_FLOAT_TO_BYTE(_color_) ((PXGLubyte)((_color_) * 0xFF))
#define PX_BOOL_TO_STRING(_var_) ((_var_) ? @"YES" : @"NO")

#pragma mark -
#pragma mark Declerations
#pragma mark -

PXInline void PXSwap(int *val0, int *val1) PXAlwaysInline;
PXInline void PXSwapf(float *val0, float *val1) PXAlwaysInline;
PXInline void PXSwapv(void *val0, void *val1, size_t size) PXAlwaysInline;

PXInline void *PXStridedMemcpy(void *dest, void *src, size_t size, size_t len, size_t destStride, size_t srcStride);

#pragma mark -
#pragma mark Implementations
#pragma mark -

PXInline void PXSwap(int *val0, int *val1)
{
	*val0 ^= *val1;
	*val1 ^= *val0;
	*val0 ^= *val1;
}
PXInline void PXSwapf(float *val0, float *val1)
{
	PXSwap((int *)(val0), (int *)(val1));
}
PXInline void PXSwapv(void *val0, void *val1, size_t size)
{
//	void *temp = alloca(size);
//
//	temp = memcpy(temp, val0, size);
//	val0 = memcpy(val0, val1, size);
//	val1 = memcpy(val1, temp, size);

	size_t index;
	unsigned char *byte0;
	unsigned char *byte1;
	for (index = 0, byte0 = (unsigned char *)val0, byte1 = (unsigned char *)val1; index < size; ++index, ++byte0, ++byte1)
	{
		*byte0 ^= *byte1;
		*byte1 ^= *byte0;
		*byte0 ^= *byte1;
	}
}

void *PXStridedMemcpy(void *dest, void *src, size_t size, size_t len, size_t destStride, size_t srcStride)
{
	if (destStride == srcStride == 0)
	{
		size_t totalBytes = size * len;
		return memcpy(dest, src, totalBytes);
	}

	unsigned index;
	unsigned char *destData;
	unsigned char *srcData;

	for (index = 0, destData = (unsigned char *)dest, srcData = (unsigned char *)src; index < len; ++index, destData += destStride, srcData += srcStride)
	{
		memcpy(destData, srcData, size);
	}

	return dest;
}

#ifdef __cplusplus
}
#endif

#endif //_PX_PRIVATE_UTILS_H_
