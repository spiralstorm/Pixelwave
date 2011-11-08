//
//  PXGraphicsFillGenerator.h
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _PX_GRAPHICS_FILL_GENERATOR_H_
#define _PX_GRAPHICS_FILL_GENERATOR_H_

#include "PXHeaderUtils.h"
#include "PXArrayBuffer.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	PXArrayBuffer *vertices;
} PXGraphicsFillGenerator;

PXGraphicsFillGenerator *PXGraphicsFillGeneratorCreate(size_t vertexSize);
void PXGraphicsFillGeneratorDestroy(PXGraphicsFillGenerator *fill);

void PXGraphicsFillGeneratorMoveTo(PXGraphicsFillGenerator *fill, float x, float y);
void PXGraphicsFillGeneratorLineTo(PXGraphicsFillGenerator *fill, float x, float y);

#ifdef __cplusplus
}
#endif

#endif
