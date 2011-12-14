//
//  inkGenerator.c
//  ink
//
//  Created by John Lattin on 11/16/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkGenerator.h"

#include "inkFill.h"

inkGenerator* inkGeneratorCreate(inkTessellator* tessellator, void* fill, inkMatrix matrix)
{
	inkGenerator* generator = malloc(sizeof(inkGenerator));

	if (generator != NULL)
	{
		generator->me = generator;

		generator->tessellator = tessellator;

		generator->vertexGroupList = inkArrayCreate(sizeof(inkArray *));

		if (generator->vertexGroupList == NULL)
		{
			inkGeneratorDestroy(generator);
			return NULL;
		}

		generator->currentVertices = NULL;
		generator->fill = fill;
		generator->matrix = matrix;
	}
	
	return generator;
}

void inkGeneratorDestroy(inkGenerator* generator)
{
	if (generator != NULL)
	{
		inkGeneratorRemoveAllVertices(generator);
		inkArrayDestroy(generator->vertexGroupList);

		free(generator);
	}
}

void inkGeneratorMoveTo(inkGenerator* generator, inkPoint position, inkGeneratorEndFunction endFunction, void *userData)
{
	if (generator == NULL || generator->vertexGroupList == NULL)
		return;

	if (endFunction != NULL)
		endFunction(userData);
	else
		inkGeneratorEnd(generator);

	inkArray* vertices = inkArrayCreate(sizeof(INKvertex));

	if (vertices == NULL)
		return;

	inkArray** verticesPtr = inkArrayPush(generator->vertexGroupList);

	if (verticesPtr == NULL)
	{
		inkArrayDestroy(vertices);
		return;
	}

	*verticesPtr = vertices;
	generator->currentVertices = vertices;

	generator->previous = position;

	inkGeneratorAddVertex(generator, generator->previous, generator->fill, generator->matrix);
}

void inkGeneratorLineTo(inkGenerator* generator, inkPoint position)
{
	if (generator == NULL)
		return;

	inkGeneratorAddVertex(generator, position, generator->fill, generator->matrix);
	generator->previous = position;
}

void inkGeneratorEnd(inkGenerator* generator)
{
	if (generator == NULL || generator->tessellator == NULL || generator->currentVertices == NULL)
		return;

	inkTessellatorBeginContour(generator->tessellator);

	INKvertex *vertex;

	inkArrayForEach(generator->currentVertices, vertex)
	{
		inkTessellatorAddPoint(generator->tessellator, vertex);
	}

	inkTessellatorEndContour(generator->tessellator);

	generator->currentVertices = NULL;
	generator->previous = inkPointZero;
}

void inkGeneratorInitVertex(inkGenerator* generator, INKvertex* vertex, inkPoint position, void* fill, inkMatrix glMatrix)
{
	if (generator == NULL || vertex == NULL)
		return;

	vertex->x = (position.x);
	vertex->y = (position.y);

	if (fill == NULL)
		return;

	inkFillType fillType = ((inkFill *)fill)->fillType;

	switch(fillType)
	{
		case inkFillType_Solid:
		{
			inkSolidFill* solidFill = (inkSolidFill *)fill;

			// TODO: Use a real color checker instead
			vertex->r = 0xFF & (solidFill->color >> 16);
			vertex->g = 0xFF & (solidFill->color >> 8);
			vertex->b = 0xFF & (solidFill->color);
			vertex->a = 0xFF * solidFill->alpha;
		}
			break;
		case inkFillType_Bitmap:
		{
			inkMatrix invMatrix = inkMatrixInvert(glMatrix);

			inkBitmapFill* bitmapFill = (inkBitmapFill *)fill;

			float angle = inkMatrixRotation(bitmapFill->matrix);
			inkSize scale = inkMatrixSize(bitmapFill->matrix);
			inkMatrix matrix = inkMatrixIdentity;

			matrix = inkMatrixTranslatef(matrix, -bitmapFill->matrix.tx, -bitmapFill->matrix.ty);
			matrix = inkMatrixScalef(matrix, 1.0f / scale.width, 1.0f / scale.height);
			matrix = inkMatrixRotate(matrix, angle);

			matrix = inkMatrixMultiply(invMatrix, matrix);
			inkPoint convertedPosition = inkMatrixTransformPoint(matrix, inkPointMake(position.x, position.y));

			vertex->s = convertedPosition.x * bitmapFill->bitmapInfo.one_textureWidth;
			vertex->t = convertedPosition.y * bitmapFill->bitmapInfo.one_textureHeight;
		}
			break;
		case inkFillType_Gradient:
			// TODO: Implement
			break;
		default:
			break;
	}
}

void inkGeneratorAddVertex(inkGenerator* generator, inkPoint position, void* fill, inkMatrix matrix)
{
	if (generator == NULL || generator->currentVertices == NULL)
		return;

	INKvertex* vertex = (INKvertex*)inkArrayPush(generator->currentVertices);

	inkGeneratorInitVertex(generator, vertex, position, fill, matrix);
}

void inkGeneratorRemoveAllVertices(inkGenerator* generator)
{
	if (generator == NULL)
		return;

	if (generator->vertexGroupList != NULL)
	{
		inkArray* array;

		inkArrayPtrForEach(generator->vertexGroupList, array)
		{
			inkArrayDestroy(array);
		}

		inkArrayClear(generator->vertexGroupList);
		generator->currentVertices = NULL;
	}
}

void inkGeneratorMultColor(inkGenerator* generator, float red, float green, float blue, float alpha)
{
	if (generator == NULL)
		return;

	inkArray* array;
	INKvertex* vertex;

	inkArrayPtrForEach(generator->vertexGroupList, array)
	{
		inkArrayForEach(array, vertex)
		{
			vertex->r *= red;
			vertex->g *= green;
			vertex->b *= blue;
			vertex->a *= alpha;
		}
	}
}
