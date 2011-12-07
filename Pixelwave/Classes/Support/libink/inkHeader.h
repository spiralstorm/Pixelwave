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

#ifdef __cplusplus
#define inkExtern extern "C"
#else
#define inkExtern extern
#endif

#define inkInline static inline
#define inkAlwaysInline  __attribute__((always_inline))

#define inkUniqueVarConcat(_name_, _line_) _name_ ## _line_
#define inkLikeName(_name_, _line_) inkUniqueVarConcat(_name_, _line_)
#define inkUniqueVar(_name_) inkLikeName(_name_,__LINE__)

//#define inkUniqueVar(_name_) _name_ ## __LINE__

#define inkNotUsed(_val_) ((void)(_val_))

#endif
