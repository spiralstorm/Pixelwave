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

#import "PXHeaderUtils.h"
#import "PKInterpolater.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
} PKRGBABE;

typedef struct
{
	unsigned char a;
	unsigned char b;
	unsigned char g;
	unsigned char r;
} PKRGBA;

typedef PKRGBA PKRGBALE;

typedef struct
{
	unsigned char a;
	unsigned char r;
	unsigned char g;
	unsigned char b;
} PKARGBBE;

typedef struct
{
	unsigned char b;
	unsigned char g;
	unsigned char r;
	unsigned char a;
} PKARGB;

typedef PKARGB PKARGBLE;

typedef union
{
	PKRGBA asRGBA;
	PKARGB asARGB;

	int asInt;
	unsigned asUInt;
} PKColor;

typedef PKColor PKColorLE;

typedef union
{
	PKRGBABE asRGBA;
	PKARGBBE asARGB;
	
	int asInt;
	unsigned asUInt;
} PKColorBE;

#pragma mark -
#pragma mark Declerations
#pragma mark -

PXInline PKColor PKColorMake(unsigned int hex);
PXInline PKColor PKColorMakeRGBA(unsigned char red,
								 unsigned char green,
								 unsigned char blue,
								 unsigned char alpha);
PXInline PKColor PKColorMakeARGB(unsigned char alpha,
								 unsigned char red,
								 unsigned char green,
								 unsigned char blue);

PXInline PKColor PKColorRGBAToARGB(PKColor color);
PXInline PKColor PKColorARGBToRGBA(PKColor color);

PXInline PKColorBE PKColorLEtoBE(PKColorLE color);
PXInline PKColorLE PKColorBEtoLE(PKColorBE color);

PXInline void PKColorInterpolate(void *retVal, void *from, void *to, float percent);

#pragma mark -
#pragma mark Implementations
#pragma mark -

PXInline PKColor PKColorMake(unsigned int hex)
{
	PKColor retVal;

	retVal.asUInt = hex;

	return retVal;
}

PXInline PKColor PKColorMakeRGBA(unsigned char red, unsigned char green, unsigned char blue, unsigned char alpha)
{
	PKColor retVal;

	retVal.asRGBA.r = red;
	retVal.asRGBA.g = green;
	retVal.asRGBA.b = blue;
	retVal.asRGBA.a = alpha;

	return retVal;
}

PXInline PKColor PKColorMakeARGB(unsigned char alpha, unsigned char red, unsigned char green, unsigned char blue)
{
	PKColor retVal;

	retVal.asARGB.r = red;
	retVal.asARGB.g = green;
	retVal.asARGB.b = blue;
	retVal.asARGB.a = alpha;

	return retVal;
}

PXInline PKColor PKColorRGBAToARGB(PKColor color)
{
	return PKColorMakeRGBA(color.asRGBA.r, color.asRGBA.g, color.asRGBA.b, color.asRGBA.a);
}

PXInline PKColor PKColorARGBToRGBA(PKColor color)
{
	return PKColorMakeARGB(color.asRGBA.a, color.asRGBA.r, color.asRGBA.g, color.asRGBA.b);
}

PXInline PKColorBE PKColorLEtoBE(PKColorLE le)
{
	PKColorBE be;

	be.asRGBA.r = le.asRGBA.r;
	be.asRGBA.g = le.asRGBA.g;
	be.asRGBA.b = le.asRGBA.b;
	be.asRGBA.a = le.asRGBA.a;

	return be;
}

PXInline PKColorLE PKColorBEtoLE(PKColorBE be)
{
	PKColorLE le;

	le.asRGBA.r = be.asRGBA.r;
	le.asRGBA.g = be.asRGBA.g;
	le.asRGBA.b = be.asRGBA.b;
	le.asRGBA.a = be.asRGBA.a;

	return le;
}

PXInline void PKColorInterpolate(void *retVal, void *from, void *to, float percent)
{
	// Must have a return, a from and a to value
	assert(retVal);
	assert(from);
	assert(to);

	PKColor *colorRet  = (PKColor *)retVal;
	PKColor *colorFrom = (PKColor *)from;
	PKColor *colorTo   = (PKColor *)to;

	*colorRet = PKColorMakeRGBA(PK_INTERPOLATE(colorFrom->asRGBA.r, colorTo->asRGBA.r, percent),
								PK_INTERPOLATE(colorFrom->asRGBA.g, colorTo->asRGBA.g, percent),
								PK_INTERPOLATE(colorFrom->asRGBA.b, colorTo->asRGBA.b, percent),
								PK_INTERPOLATE(colorFrom->asRGBA.a, colorTo->asRGBA.a, percent));
}

#ifdef __cplusplus
}
#endif

#endif

