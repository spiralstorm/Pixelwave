//
//  inkStrokeGenerator.c
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkStrokeGenerator.h"

inkStrokeGenerator *inkStrokeGeneratorCreate(size_t vertexSize, PXLineScaleMode scaleMode, PXCapsStyle caps, PXJointStyle joints, float miterLimit, float thickness)
{
	if (vertexSize == 0)
		return NULL;

	inkStrokeGenerator *stroke = malloc(sizeof(inkStrokeGenerator));

	if (stroke)
	{
		stroke->vertices = PXArrayBufferCreatev(vertexSize);

		if (stroke->vertices == NULL)
		{
			inkStrokeGeneratorDestroy(stroke);
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

void inkStrokeGeneratorDestroy(inkStrokeGenerator *stroke)
{
	if (stroke)
	{
		// Does NULL check for me
		PXArrayBufferRelease(stroke->vertices);

		free(stroke);
	}
}

void inkStrokeGeneratorMoveTo(inkStrokeGenerator *stroke, float x, float y)
{
	
}

void inkStrokeGeneratorLineTo(inkStrokeGenerator *stroke, float x, float y)
{
	
}
