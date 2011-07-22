/*
 *  PKInterpolater.h
 *  PixelKit
 *
 *  Created by John Lattin on 4/12/11.
 *  Copyright 2011 Spiralstorm Games. All rights reserved.
 *
 */

#ifndef _PK_INTERPOLATOR_H_
#define _PK_INTERPOLATOR_H_

#include "PXHeaderUtils.h"

#define PK_INTERPOLATE(_from_, _to_, _percent_) ((_from_) + (((_to_) - (_from_)) * (_percent_)))

#ifdef __cplusplus
extern "C" {
#endif

PXInline void PKInterpolate(void *retVal, void *from, void *to, float percent)
{
	// Must have a return, a from and a to value
	assert(retVal);
	assert(from);
	assert(to);

	*((float *)retVal) = PK_INTERPOLATE(*((float *)(from)), *((float *)(to)), percent);
}

#ifdef __cplusplus
}
#endif

#endif
