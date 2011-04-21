/*
 *  PXHeaderUtils.h
 *  Pixelwave
 *
 *  Created by John Lattin on 4/21/11.
 *  Copyright 2011 Spiralstorm Games. All rights reserved.
 *
 */

#ifndef _PX_HEADER_UTILS_H_
#define _PX_HEADER_UTILS_H_

#ifdef __cplusplus
#define PXExtern extern "C"
#else
#define PXExtern extern
#endif

//#import <CoreGraphics/CGBase.h>
//CGPointMake
//#define PXInline_h static
//#define PXInline_c static inline

#define PXInline static inline
#define PXInline_h
#define PXInline_c inline
#define PXAlwaysInline  __attribute__((always_inline))

#define PX_LINENAME_CONCAT(_name_, _line_) _name_ ## _line_
#define PX_LINENAME(_name_, _line_) PX_LINENAME_CONCAT(_name_, _line_)
#define PX_UNIQUE_VAR(_name_) PX_LINENAME(_name_,__LINE__)

#endif
