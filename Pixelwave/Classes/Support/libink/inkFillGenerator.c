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
	if (fillInfo == NULL || fillInfo->renderGroup == NULL || fillInfo->renderGroup->vertices == NULL)
		return;

	INKvertex* vertex = (INKvertex*)(inkArrayPush(fillInfo->renderGroup->vertices));

	vertex->x = position.x;
	vertex->y = position.y;

	inkFillType fillType = *((inkFillType *)fillInfo->fill);

	switch(fillType)
	{
		case inkFillType_Solid:
		{
			inkSolidFill* solidFill = (inkSolidFill *)fillInfo->fill;

			// TODO: Use a real color checker instead
			vertex->r = 0xFF & (solidFill->color >> 16);
			vertex->g = 0xFF & (solidFill->color >> 8);
			vertex->b = 0xFF & (solidFill->color);
			vertex->a = 0xFF * solidFill->alpha;
		}
			break;
		case inkFillType_Bitmap:
			// TODO: Implement
			break;
		case inkFillType_Gradient:
			// TODO: Implement
			break;
		default:
			break;
	}

	inkTessellatorAddPoint(fillInfo->tessellator, vertex);
}

inkFillInfo* inkFillGeneratorCreate(inkRenderGroup* renderGroup, void* fill, inkTessellator* tessellator)
{
	if (renderGroup == NULL)
		return NULL;

	inkFillInfo* fillInfo = malloc(sizeof(inkFillInfo));

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
		fillInfo->tessellator = tessellator;
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
	if (fillInfo == NULL)
		return;

	printf("begin contour\n");
	inkTessellatorBeginContour(fillInfo->tessellator);

	fillInfo->cursor = position;

	inkFillGeneratorAddVertex(fillInfo, fillInfo->cursor);
}

void inkFillGeneratorLineTo(inkFillInfo* fillInfo, inkPoint position)
{
	inkFillGeneratorAddVertex(fillInfo, position);
}

void inkFillGeneratorEnd(inkFillInfo* fillInfo, inkRenderGroup* renderGroup)
{
	if (fillInfo == NULL || fillInfo->tessellator == NULL)
		return;

//	inkTessellator* tessellator = fillInfo->tessellator;

//	inkFillGeneratorAddVertex(fillInfo, fillInfo->cursor);

//	inkTessellatorExpandRenderGroup(tessellator, renderGroup);
	//inkRenderGroup *renderGroup = inkTessellatorMakeRenderGroup(fillInfo->vertices);
}
