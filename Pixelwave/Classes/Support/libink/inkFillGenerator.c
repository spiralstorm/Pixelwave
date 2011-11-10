//
//  inkFillGenerator.c
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkFillGenerator.h"

inkFillInfo *inkFillGeneratorCreate(size_t vertexSize, void *fill)
{
	if (vertexSize == 0)
		return NULL;

	inkFillInfo *fillInfo = malloc(sizeof(inkFillInfo));

	if (fillInfo)
	{
		fillInfo->vertices = inkArrayCreate(vertexSize);

		if (fillInfo->vertices == NULL)
		{
			inkFillGeneratorDestroy(fillInfo);
			return NULL;
		}

		fillInfo->fill = fill;
	}

	return fillInfo;
}

void inkFillGeneratorDestroy(inkFillInfo *fillInfo)
{
	if (fillInfo)
	{
		// Does NULL check for me
		inkArrayDestroy(fillInfo->vertices);

		free(fillInfo);
	}
}

void inkFillGeneratorMoveTo(inkFillInfo *fillInfo, inkPoint position)
{
	// TODO: Implement
}

void inkFillGeneratorLineTo(inkFillInfo *fillInfo, inkPoint position)
{
	// TODO: Implement
}

void inkStrokeGeneratorEnd(inkFillInfo *fillInfo)
{
	// TODO: Implement
}
