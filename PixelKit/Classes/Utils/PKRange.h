//
//  PKRange.h
//  PixelKit
//
//  Created by Spiralstorm Games on 9/7/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _PK_RANGE_H_
#define _PK_RANGE_H_

#import "PXHeaderUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	float min;
	float max;
} PKRange;

#pragma mark -
#pragma mark Declerations
#pragma mark -

PXInline PKRange PKRangeMake(float min, float max);
PXInline PKRange PKRangeMakeFromVariance(float mid, float variance);
PXInline PKRange PKRangeZero();
PXInline PKRange PKRangeMax();
PXInline float PKRangeRandom(PKRange range);
PXInline bool PKRangeContains(PKRange range, float value);

#pragma mark -
#pragma mark Implementations
#pragma mark -

PXInline PKRange PKRangeMake(float min, float max)
{
	PKRange value;

	value.min = MIN(min, max);
	value.max = MAX(min, max);

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
	if (PXMathIsEqual(range.lower, range.upper))
		return range.lower;

	return PXMathFloatInRange(range.lower, range.upper);
}

PXInline bool PKRangeContains(PKRange range, float value)
{
	if (value < range.lower)
		return false;
	if (value > range.upper)
		return false;

	return true;
}

#ifdef __cplusplus
}
#endif

#endif
