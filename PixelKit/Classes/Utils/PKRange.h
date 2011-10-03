//
//  PKRange.h
//  PixelKit
//
//  Created by Spiralstorm Games on 9/7/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

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
