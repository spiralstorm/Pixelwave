//
//  inkHeader.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_HEADER_H_
#define _INK_HEADER_H_

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
#define M_1_255		0.003921568627450980392367790557453522
#endif
#ifndef M_E
#define M_E			2.71828182845904523536028747135266250
#endif
#ifndef M_LOG2E
#define M_LOG2E		1.44269504088896340735992468100189214
#endif
#ifndef M_LOG10E
#define M_LOG10E	0.434294481903251827651128918916605082
#endif
#ifndef M_LN2
#define M_LN2		0.693147180559945309417232121458176568
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
#define M_PI_4		0.785398163397448309615660845819875721
#endif
#ifndef M_PI_180
#define M_PI_180	0.017453292519943295088124656649908317
#endif
#ifndef M_180_PI
#define M_180_PI	57.295779513082323110978455460440272873
#endif
#ifndef M_1_PI
#define M_1_PI		0.318309886183790671537767526745028724
#endif
#ifndef M_2_PI
#define M_2_PI		0.636619772367581343075535053490057448
#endif
#ifndef M_2_SQRTPI
#define M_2_SQRTPI	1.12837916709551257389615890312154517
#endif
#ifndef M_SQRT2
#define M_SQRT2		1.41421356237309504880168872420969808
#endif
#ifndef M_SQRT1_2
#define M_SQRT1_2	0.707106781186547524400844362104849039
#endif

#endif
