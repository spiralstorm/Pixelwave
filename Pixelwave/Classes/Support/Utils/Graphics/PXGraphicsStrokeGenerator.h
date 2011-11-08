//
//  PXGraphicsStrokeGenerator.h
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _PX_GRAPHICS_STROKE_GENERATOR_H_
#define _PX_GRAPHICS_STROKE_GENERATOR_H_

#include "PXHeaderUtils.h"
#include "PXArrayBuffer.h"
#include "PXGraphicsUtilTypes.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	PXArrayBuffer *vertices;

	PXLineScaleMode scaleMode;
	PXCapsStyle caps;
	PXJointStyle joints;

	float miterLimit;
	float thickness;
} PXGraphicsStrokeGenerator;

PXGraphicsStrokeGenerator *PXGraphicsStrokeGeneratorCreate(size_t vertexSize, PXLineScaleMode scaleMode, PXCapsStyle caps, PXJointStyle joints, float miterLimit, float thickness);
void PXGraphicsStrokeGeneratorDestroy(PXGraphicsStrokeGenerator *stroke);

void PXGraphicsStrokeGeneratorMoveTo(PXGraphicsStrokeGenerator *stroke, float x, float y);
void PXGraphicsStrokeGeneratorLineTo(PXGraphicsStrokeGenerator *stroke, float x, float y);

#ifdef __cplusplus
}
#endif

#endif
