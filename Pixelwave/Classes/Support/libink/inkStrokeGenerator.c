//
//  inkStrokeGenerator.c
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkStrokeGenerator.h"

inkStrokeInfo *inkStrokeGeneratorCreate(size_t vertexSize, inkStroke* stroke)
{
	if (vertexSize == 0)
		return NULL;

	inkStrokeInfo *strokeInfo = malloc(sizeof(inkStrokeInfo));

	if (strokeInfo)
	{
		strokeInfo->vertices = inkArrayCreate(vertexSize);

		if (strokeInfo->vertices == NULL)
		{
			inkStrokeGeneratorDestroy(strokeInfo);
			return NULL;
		}

		strokeInfo->stroke = stroke;
	}

	return strokeInfo;
}

void inkStrokeGeneratorDestroy(inkStrokeInfo* strokeInfo)
{
	if (strokeInfo != NULL)
	{
		// Does NULL check for me
		inkArrayDestroy(strokeInfo->vertices);

		free(strokeInfo);
	}
}

void inkStrokeGeneratorMoveTo(inkStrokeInfo* strokeInfo, inkPoint position)
{
	// TODO: Implement
}

void inkStrokeGeneratorLineTo(inkStrokeInfo* strokeInfo, inkPoint position)
{
	// TODO: Implement
}

void inkStrokeGeneratorEnd(inkStrokeInfo* strokeInfo)
{
	// TODO: Implement
}
