//
//  PXGraphicsStrokeGenerator.c
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "PXGraphicsStrokeGenerator.h"

PXGraphicsStrokeGenerator *PXGraphicsStrokeGeneratorCreate(size_t vertexSize, PXLineScaleMode scaleMode, PXCapsStyle caps, PXJointStyle joints, float miterLimit, float thickness)
{
	if (vertexSize == 0)
		return NULL;

	PXGraphicsStrokeGenerator *stroke = malloc(sizeof(PXGraphicsStrokeGenerator));

	if (stroke)
	{
		stroke->vertices = PXArrayBufferCreatev(vertexSize);

		if (stroke->vertices == NULL)
		{
			PXGraphicsStrokeGeneratorDestroy(stroke);
			return NULL;
		}

		stroke->scaleMode = scaleMode;
		stroke->caps = caps;
		stroke->joints = joints;
		stroke->miterLimit = miterLimit;
		stroke->thickness = thickness;
	}

	return stroke;
}

void PXGraphicsStrokeGeneratorDestroy(PXGraphicsStrokeGenerator *stroke)
{
	if (stroke)
	{
		// Does NULL check for me
		PXArrayBufferRelease(stroke->vertices);

		free(stroke);
	}
}

void PXGraphicsStrokeGeneratorMoveTo(PXGraphicsStrokeGenerator *stroke, float x, float y)
{
	
}

void PXGraphicsStrokeGeneratorLineTo(PXGraphicsStrokeGenerator *stroke, float x, float y)
{
	
}
