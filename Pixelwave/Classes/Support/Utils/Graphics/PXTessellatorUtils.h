//
//  PXTessellatorUtils.h
//  Pixelwave
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _PX_TESSELLATOR_UTILS_H_
#define _PX_TESSELLATOR_UTILS_H_

#include "PXHeaderUtils.h"

#ifdef __cplusplus
//extern "C" {
#endif

typedef struct
{
	void *tessellator;
} PXTessellator;

PXTessellator *PXTessellatorCreate();
void PXTessellatorDestroy(PXTessellator *tessellator);

#ifdef __cplusplus
}
#endif

#endif