//
//  PXGraphicsFillGenerator.c
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "PXGraphicsFillGenerator.h"

PXGraphicsFillGenerator *PXGraphicsFillGeneratorCreate(size_t vertexSize)
{
	if (vertexSize == 0)
		return NULL;

	PXGraphicsFillGenerator *fill = malloc(sizeof(PXGraphicsFillGenerator));

	if (fill)
	{
		fill->vertices = PXArrayBufferCreatev(vertexSize);

		if (fill->vertices == NULL)
		{
			PXGraphicsFillGeneratorDestroy(fill);
			return NULL;
		}
	}

	return fill;
}

void PXGraphicsFillGeneratorDestroy(PXGraphicsFillGenerator *fill)
{
	if (fill)
	{
		// Does NULL check for me
		PXArrayBufferRelease(fill->vertices);

		free(fill);
	}
}

void PXGraphicsFillGeneratorMoveTo(PXGraphicsFillGenerator *fill, float x, float y)
{
}

void PXGraphicsFillGeneratorLineTo(PXGraphicsFillGenerator *fill, float x, float y)
{
}
