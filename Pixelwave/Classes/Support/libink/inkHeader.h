//
//  inkHeader.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_HEADER_H_
#define _INK_HEADER_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <float.h>
#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>
#include <assert.h>
#include <string.h>
#include <math.h>
#include <stdio.h>
#include <setjmp.h>
#include <limits.h>
#include <stdio.h>
#include <ctype.h>
#include <stdarg.h>

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
#define inkExtern extern "C"
#else
#define inkExtern extern
#endif

//#define inkInline static inline
//#define inkAlwaysInline  __attribute__((always_inline))

#ifdef __cplusplus
#define inkInline extern "C" static inline
#else
#define inkInline static inline
#endif

#define inkUniqueVarConcat(_name_, _line_) _name_ ## _line_
#define inkLikeName(_name_, _line_) inkUniqueVarConcat(_name_, _line_)
#define inkUniqueVar(_name_) inkLikeName(_name_,__LINE__)

//#define inkUniqueVar(_name_) _name_ ## __LINE__

#define inkNotUsed(_val_) ((void)(_val_))

#ifndef M_1_255
#define M_1_255		0.00392156862745098039236779055745352
#endif
#ifndef M_1_3
#define M_1_3		0.33333333333333333333333333333333333
#endif
#ifndef M_2_3
#define M_2_3		0.66666666666666666666666666666666667
#endif
#ifndef M_1_6
#define M_1_6		0.16666666666666666666666666666666667
#endif
#ifndef M_5_6
#define M_5_6		0.83333333333333333333333333333333333
#endif
#ifndef M_1_360
#define M_1_360		0.00277777777777777777777777777777777
#endif
#ifndef M_E
#define M_E			2.71828182845904523536028747135266250
#endif
#ifndef M_LOG2E
#define M_LOG2E		1.44269504088896340735992468100189214
#endif
#ifndef M_LOG10E
#define M_LOG10E	0.43429448190325182765112891891660508
#endif
#ifndef M_LN2
#define M_LN2		0.69314718055994530941723212145817657
#endif
#ifndef M_LN10
#define M_LN10		2.30258509299404568401799145468436421
#endif
#ifndef M_TAU
#define M_TAU		6.28318530717958623199592693708837032
#endif
#ifndef M_PI
#define M_PI		3.14159265358979323846264338327950288
#endif
#ifndef M_PI_2
#define M_PI_2		1.57079632679489661923132169163975144
#endif
#ifndef M_PI_4
#define M_PI_4		0.78539816339744830961566084581987572
#endif
#ifndef M_PI_180
#define M_PI_180	0.01745329251994329508812465664990832
#endif
#ifndef M_180_PI
#define M_180_PI	57.2957795130823231109784554604402729
#endif
#ifndef M_1_PI
#define M_1_PI		0.31830988618379067153776752674502872
#endif
#ifndef M_2_PI
#define M_2_PI		0.63661977236758134307553505349005745
#endif
#ifndef M_2_SQRTPI
#define M_2_SQRTPI	1.12837916709551257389615890312154517
#endif
#ifndef M_SQRT2
#define M_SQRT2		1.41421356237309504880168872420969808
#endif
#ifndef M_SQRT1_2
#define M_SQRT1_2	0.70710678118654752440084436210484904
#endif

#endif
