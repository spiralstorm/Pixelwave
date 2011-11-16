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
	if (fillInfo == NULL || fillInfo->currentVertices == NULL)
		return;

	INKvertex* vertex = (INKvertex*)inkArrayPush(fillInfo->currentVertices);

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

	//inkTessellatorAddPoint(fillInfo->tessellator, vertex);
}

inkFillInfo* inkFillGeneratorCreate(void* fill, inkTessellator* tessellator)
{
	inkFillInfo* fillInfo = malloc(sizeof(inkFillInfo));

	if (fillInfo)
	{
		fillInfo->fill = fill;
		fillInfo->tessellator = tessellator;

		fillInfo->vertexGroupList = inkArrayCreate(sizeof(inkArray *));
		//fillInfo->vertices = inkArrayCreate(sizeof(INKvertex));

		if (fillInfo->vertexGroupList == NULL)
		{
			inkFillGeneratorDestroy(fillInfo);
			return NULL;
		}

		fillInfo->currentVertices = NULL;
	}

	return fillInfo;
}

void inkFillGeneratorDestroy(inkFillInfo* fillInfo)
{
	if (fillInfo)
	{
		if (fillInfo->vertexGroupList != NULL)
		{
			inkArray* array;

			inkArrayPtrForEach(fillInfo->vertexGroupList, array)
			{
				inkArrayDestroy(array);
			}

			inkArrayDestroy(fillInfo->vertexGroupList);
		}

		free(fillInfo);
	}
}

void inkFillGeneratorMoveTo(inkFillInfo* fillInfo, inkPoint position)
{
	if (fillInfo == NULL || fillInfo->vertexGroupList == NULL)
		return;

	inkFillGeneratorEnd(fillInfo);

	inkArray* vertices = inkArrayCreate(sizeof(INKvertex));

	if (vertices == NULL)
		return;

	inkArray** verticesPtr = inkArrayPush(fillInfo->vertexGroupList);

	if (verticesPtr == NULL)
	{
		inkArrayDestroy(vertices);
		return;
	}

	*verticesPtr = vertices;
	fillInfo->currentVertices = vertices;

//	printf("\nFG moveTo(%f, %f)\n", position.x, position.y);
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
	if (fillInfo == NULL || fillInfo->tessellator == NULL || fillInfo->currentVertices == NULL)
		return;

	INKvertex *vertex;

	//printf("end\n");
	inkArrayForEach(fillInfo->currentVertices, vertex)
	{
	//	printf("vertex(%f, %f)\n", vertex->x, vertex->y);
		inkTessellatorAddPoint(fillInfo->tessellator, vertex);
	}

	inkTessellatorEndContour(fillInfo->tessellator);

	fillInfo->currentVertices = NULL;
}
