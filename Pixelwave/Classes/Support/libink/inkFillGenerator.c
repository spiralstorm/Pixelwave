//
//  inkFillGenerator.c
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkFillGenerator.h"

// TODO: Remove this
#include "PXGLUtils.h"

void inkFillGeneratorAddVertex(inkFillInfo* fillInfo, inkPoint position)
{
	/*if (fillInfo == NULL || fillInfo->vertices == NULL)
		return;

	INKvertex *vertex = (INKvertex*)(inkArrayPush(fillInfo->vertices));*/

	if (fillInfo == NULL || fillInfo->renderGroup == NULL || fillInfo->renderGroup->vertices == NULL)
		return;

	INKvertex *vertex = (INKvertex*)(inkArrayPush(fillInfo->renderGroup->vertices));

	vertex->x = position.x;
	vertex->y = position.y;

	// TODO: Do a real check for the type
	inkSolidFill *solidFill = (inkSolidFill *)fillInfo->fill;

	// TODO: Use a real color checker instead
	vertex->r = 0xFF & (solidFill->color >> 16);
	vertex->g = 0xFF & (solidFill->color >> 8);
	vertex->b = 0xFF & (solidFill->color);
	vertex->a = 0xFF * solidFill->alpha;
}

inkFillInfo* inkFillGeneratorCreate(inkRenderGroup *renderGroup, void* fill)
{
	if (renderGroup == NULL)
		return NULL;

	inkFillInfo *fillInfo = malloc(sizeof(inkFillInfo));

	if (fillInfo)
	{
		fillInfo->renderGroup = renderGroup;
		//fillInfo->vertices = inkArrayCreate(vertexSize);

		/*if (fillInfo->vertices == NULL)
		{
			inkFillGeneratorDestroy(fillInfo);
			return NULL;
		}*/

		fillInfo->fill = fill;
	}

	return fillInfo;
}

void inkFillGeneratorDestroy(inkFillInfo* fillInfo)
{
	if (fillInfo)
	{
		// Does NULL check for me so I don't have to.
	//	inkArrayDestroy(fillInfo->vertices);

		free(fillInfo);
	}
}

void inkFillGeneratorMoveTo(inkFillInfo* fillInfo, inkPoint position)
{
	inkFillGeneratorAddVertex(fillInfo, position);
}

void inkFillGeneratorLineTo(inkFillInfo* fillInfo, inkPoint position)
{
	inkFillGeneratorAddVertex(fillInfo, position);
}

void inkFillGeneratorEnd(inkFillInfo* fillInfo, inkTessellator* tessellator, inkRenderGroup* renderGroup)
{
	if (fillInfo == NULL || tessellator == NULL)
		return;

	inkTessellatorExpandRenderGroup(tessellator, renderGroup);
	//inkRenderGroup *renderGroup = inkTessellatorMakeRenderGroup(fillInfo->vertices);
}
