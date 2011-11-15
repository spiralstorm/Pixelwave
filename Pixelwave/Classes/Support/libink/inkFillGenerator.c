//
//  inkFillGenerator.c
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkFillGenerator.h"

void inkFillGeneratorAddVertex(inkFillInfo* fillInfo, inkPoint position)
{
	if (fillInfo == NULL || fillInfo->vertices == NULL)
		return;

	INKvertex* vertex = (INKvertex*)(inkArrayPush(fillInfo->vertices));

	vertex->x = (position.x);
	vertex->y = (position.y);

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

inkFillInfo* inkFillGeneratorCreate(void* fill, inkTessellator* tessellator)
{
	inkFillInfo* fillInfo = malloc(sizeof(inkFillInfo));

	if (fillInfo)
	{
		fillInfo->vertices = inkArrayCreate(sizeof(INKvertex));

		if (fillInfo->vertices == NULL)
		{
			inkFillGeneratorDestroy(fillInfo);
			return NULL;
		}

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
		inkArrayDestroy(fillInfo->vertices);

		free(fillInfo);
	}
}

void inkFillGeneratorMoveTo(inkFillInfo* fillInfo, inkPoint position)
{
	if (fillInfo == NULL)
		return;

	inkTessellatorBeginContour(fillInfo->tessellator);

	fillInfo->cursor = position;
	fillInfo->previous = position;

	inkFillGeneratorAddVertex(fillInfo, fillInfo->cursor);
}

void inkFillGeneratorLineTo(inkFillInfo* fillInfo, inkPoint position)
{
	if (fillInfo == NULL)
		return;

	inkFillGeneratorAddVertex(fillInfo, position);
	fillInfo->previous = position;
}

void inkFillGeneratorCurveTo(inkFillInfo* fillInfo, inkPoint control, inkPoint anchor)
{
	if (fillInfo == NULL)
		return;

	// TODO: Implement properly instead of just making lots of LineTos
	const unsigned int percision = 100;

	inkPoint nextPoint;
	inkPoint previousPoint = fillInfo->previous;

	float tIncrement = 1.0f / (float)(percision - 1);
	float t;
	float oneMinusT;

	float pWeight;
	float cWeight;
	float aWeight;

	unsigned int index;

	for (index = 0, t = 0.0f, oneMinusT = 1.0f; index < percision; ++index, t += tIncrement, oneMinusT -= tIncrement)
	{
		pWeight = oneMinusT * oneMinusT;
		cWeight = 2 * t * oneMinusT;
		aWeight = t * t;

		nextPoint = inkPointMake((previousPoint.x * pWeight) + (control.x * cWeight) + (anchor.x * aWeight),
								 (previousPoint.y * pWeight) + (control.y * cWeight) + (anchor.y * aWeight));

		inkFillGeneratorAddVertex(fillInfo, nextPoint);
	}
}

void inkFillGeneratorEnd(inkFillInfo* fillInfo)
{
	if (fillInfo == NULL || fillInfo->tessellator == NULL)
		return;

//	inkTessellator* tessellator = fillInfo->tessellator;

//	inkFillGeneratorAddVertex(fillInfo, fillInfo->cursor);

//	inkTessellatorExpandRenderGroup(tessellator, renderGroup);
	//inkRenderGroup *renderGroup = inkTessellatorMakeRenderGroup(fillInfo->vertices);
}
