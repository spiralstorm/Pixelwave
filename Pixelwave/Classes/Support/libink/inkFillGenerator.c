//
//  inkFillGenerator.c
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkFillGenerator.h"

inkFillGenerator *inkFillGeneratorCreate(size_t vertexSize)
{
	if (vertexSize == 0)
		return NULL;

	inkFillGenerator *fill = malloc(sizeof(inkFillGenerator));

	if (fill)
	{
		fill->vertices = PXArrayBufferCreatev(vertexSize);

		if (fill->vertices == NULL)
		{
			inkFillGeneratorDestroy(fill);
			return NULL;
		}
	}

	return fill;
}

void inkFillGeneratorDestroy(inkFillGenerator *fill)
{
	if (fill)
	{
		// Does NULL check for me
		PXArrayBufferRelease(fill->vertices);

		free(fill);
	}
}

void inkFillGeneratorMoveTo(inkFillGenerator *fill, float x, float y)
{
}

void inkFillGeneratorLineTo(inkFillGenerator *fill, float x, float y)
{
}
