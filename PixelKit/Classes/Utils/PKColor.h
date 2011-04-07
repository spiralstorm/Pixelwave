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

#ifndef _PK_COLOR_H_
#define _PK_COLOR_H_

#import "PXPrivateUtils.h"

#define PK_INTERPOLATE(_from_, _to_, _percent_) (_from_ + ((_to_ - _from_) * _percent_))

#ifdef __cplusplus
extern "C" {
#endif

/*#define PK_COLOR_TO_HEX(_alpha_, _red_, _green_, _blue_) (((_alpha_) << 24) | ((_red_) << 16) | ((_green_) << 8) | (_blue_))
#define PK_COLOR_FROM_HEX(_hex_, _alpha_, _red_, _green_, _blue_)\
{\
	(_alpha_) = 0xFF & ((_hex_) >> 24);\
	(_red_)   = 0xFF & ((_hex_) >> 16);\
	(_green_) = 0xFF & ((_hex_) >> 8);\
	(_blue_)  = 0xFF & (_hex_);\
}*/

typedef struct
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
} PKRGBA;

typedef struct
{
	unsigned char a;
	unsigned char r;
	unsigned char g;
	unsigned char b;
} PKARGB;

typedef union
{
	PKRGBA asRGBA;
	PKARGB asARGB;

	int asInt;
	unsigned asUInt;
} PKColor;

#pragma mark -
#pragma mark Declerations
#pragma mark -

PX_INLINE PKColor PKColorMakeRGBA(unsigned char red,
									unsigned char green,
									unsigned char blue,
									unsigned char alpha);
PX_INLINE PKColor PKColorMakeARGB(unsigned char alpha,
									unsigned char red,
									unsigned char green,
									unsigned char blue);

PX_INLINE PKColor PKColorRGBAToARGB(PKColor color);
PX_INLINE PKColor PKColorARGBToRGBA(PKColor color);
PX_INLINE PKColor PKColorInterpolate(PKColor from, PKColor to, float percent);

#pragma mark -
#pragma mark Implementations
#pragma mark -

PX_INLINE PKColor PKColorMakeRGBA(unsigned char red, unsigned char green, unsigned char blue, unsigned char alpha)
{
	PKColor retVal;

	retVal.asRGBA.r = red;
	retVal.asRGBA.g = green;
	retVal.asRGBA.b = blue;
	retVal.asRGBA.a = alpha;

	return retVal;
}

PX_INLINE PKColor PKColorMakeARGB(unsigned char alpha, unsigned char red, unsigned char green, unsigned char blue)
{
	PKColor retVal;

	retVal.asARGB.r = red;
	retVal.asARGB.g = green;
	retVal.asARGB.b = blue;
	retVal.asARGB.a = alpha;

	return retVal;
}

PX_INLINE PKColor PKColorRGBAToARGB(PKColor color)
{
	return PKColorMakeRGBA(color.asRGBA.r, color.asRGBA.g, color.asRGBA.b, color.asRGBA.a);
}

PX_INLINE PKColor PKColorARGBToRGBA(PKColor color)
{
	return PKColorMakeARGB(color.asRGBA.a, color.asRGBA.r, color.asRGBA.g, color.asRGBA.b);
}

PX_INLINE PKColor PKColorInterpolate(PKColor from, PKColor to, float percent)
{
	return PKColorMakeRGBA(PK_INTERPOLATE(from.asRGBA.r, to.asRGBA.r, percent),
						   PK_INTERPOLATE(from.asRGBA.g, to.asRGBA.g, percent),
						   PK_INTERPOLATE(from.asRGBA.b, to.asRGBA.b, percent),
						   PK_INTERPOLATE(from.asRGBA.a, to.asRGBA.a, percent));
}

#ifdef __cplusplus
}
#endif

#endif

