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

#ifndef _PK_RANGE_H_
#define _PK_RANGE_H_

#include "PXHeaderUtils.h"
#include "PXMathUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	float start;
	float end;
} PKRange;

#pragma mark -
#pragma mark Declerations
#pragma mark -

PXInline PKRange PKRangeMake(float start, float end);
PXInline PKRange PKRangeMakeFromVariance(float mid, float variance);
PXInline PKRange PKRangeZero();
PXInline PKRange PKRangeMax();
PXInline float PKRangeRandom(PKRange range);
PXInline bool PKRangeContains(PKRange range, float value);

#pragma mark -
#pragma mark Implementations
#pragma mark -

PXInline PKRange PKRangeMake(float start, float end)
{
	PKRange value;

	value.start = start;
	value.end = end;

	return value;
}

PXInline PKRange PKRangeMakeFromVariance(float mid, float variance)
{
	return PKRangeMake(mid - variance, mid + variance);
}

PXInline PKRange PKRangeZero()
{
	return PKRangeMake(0.0f, 0.0f);
}

PXInline PKRange PKRangeMax()
{
	return PKRangeMake(-MAXFLOAT, MAXFLOAT);
}

PXInline float PKRangeRandom(PKRange range)
{
	if (PXMathIsEqual(range.start, range.end))
		return range.start;

	return PXMathFloatInRange(range.start, range.end);
}

PXInline bool PKRangeContains(PKRange range, float value)
{
	if (value < range.start)
		return false;
	if (value > range.end)
		return false;

	return true;
}

#ifdef __cplusplus
}
#endif

#endif
