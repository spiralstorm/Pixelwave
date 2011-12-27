//
//  inkGenerator.c
//  ink
//
//  Created by John Lattin on 11/16/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkGenerator.h"

#include "inkFill.h"

inkGenerator* inkGeneratorCreate(inkTessellator* tessellator, void* fill, inkMatrix invGLMatrix)
{
	inkGenerator* generator = malloc(sizeof(inkGenerator));

	if (generator != NULL)
	{
		generator->me = generator;

		generator->tessellator = tessellator;

		generator->vertexGroupList = inkArrayCreate(sizeof(inkArray *));
		generator->isCurveGroupList = inkArrayCreate(sizeof(inkArray *));

		if (generator->vertexGroupList == NULL || generator->isCurveGroupList == NULL)
		{
			inkGeneratorDestroy(generator);
			return NULL;
		}

		generator->currentVertices = NULL;
		generator->currentIsCurveGroup = NULL;
		generator->fill = fill;
		generator->invGLMatrix = invGLMatrix;
	}
	
	return generator;
}

void inkGeneratorDestroy(inkGenerator* generator)
{
	if (generator != NULL)
	{
		inkGeneratorRemoveAllVertices(generator);
		inkArrayDestroy(generator->vertexGroupList);
		inkArrayDestroy(generator->isCurveGroupList);

		free(generator);
	}
}

void inkGeneratorMoveTo(inkGenerator* generator, inkPoint position, inkGeneratorEndFunction endFunction, void *userData)
{
	if (generator == NULL || generator->vertexGroupList == NULL || generator->isCurveGroupList == NULL)
		return;

	if (endFunction != NULL)
		endFunction(userData);
	else
		inkGeneratorEnd(generator);

	unsigned int vertexGroupListCount = inkArrayCount(generator->vertexGroupList);
	unsigned int isCurveGroupListCount = inkArrayCount(generator->isCurveGroupList);

	inkArray** verticesPtr = NULL;
	inkArray** isCurvePtr = NULL;
	inkArray* vertices = inkArrayCreate(sizeof(inkVertex));
	inkArray* isCurves = inkArrayCreate(sizeof(bool));

	if (vertices == NULL || isCurves == NULL)
		goto errorCleanup;

	verticesPtr = inkArrayPush(generator->vertexGroupList);
	isCurvePtr = inkArrayPush(generator->isCurveGroupList);

	if (verticesPtr == NULL || isCurvePtr == NULL)
		goto errorCleanup;

	*verticesPtr = vertices;
	generator->currentVertices = vertices;

	*isCurvePtr = isCurves;
	generator->currentIsCurveGroup = isCurves;

	generator->previous = position;

	inkGeneratorAddVertex(generator, generator->previous, generator->fill, generator->invGLMatrix, false);

	return;

errorCleanup:
	if (vertices != NULL)
		inkArrayDestroy(vertices);
	if (isCurves != NULL)
		inkArrayDestroy(isCurves);

	inkArrayUpdateCount(generator->vertexGroupList, vertexGroupListCount);
	inkArrayUpdateCount(generator->isCurveGroupList, isCurveGroupListCount);
}

void inkGeneratorLineTo(inkGenerator* generator, inkPoint position, bool isCurve)
{
	if (generator == NULL)
		return;

	inkGeneratorAddVertex(generator, position, generator->fill, generator->invGLMatrix, isCurve);
	generator->previous = position;
}

void inkGeneratorEnd(inkGenerator* generator)
{
	if (generator == NULL || generator->tessellator == NULL || generator->currentVertices == NULL)
		return;

	inkTessellatorBeginContour(generator->tessellator);

	inkVertex *vertex;

	inkArrayForEach(generator->currentVertices, vertex)
	{
		inkTessellatorAddPoint(generator->tessellator, vertex);
	}

	inkTessellatorEndContour(generator->tessellator);

	generator->currentVertices = NULL;
	generator->previous = inkPointZero;
}

inkPoint inkGeneratorConvertPositionFromMatrix(inkPoint position, inkMatrix convMatrix, inkMatrix invGLMatrix)
{
	float angle = inkMatrixRotation(convMatrix);
	inkSize scale = inkMatrixSize(convMatrix);
	inkMatrix matrix = inkMatrixIdentity;

	matrix = inkMatrixTranslatef(matrix, -convMatrix.tx, -convMatrix.ty);
	matrix = inkMatrixScalef(matrix, 1.0f / scale.width, 1.0f / scale.height);
	matrix = inkMatrixRotate(matrix, angle);

	matrix = inkMatrixMultiply(invGLMatrix, matrix);

	return inkMatrixTransformPoint(matrix, inkPointMake(position.x, position.y));
}

void inkGeneratorInitVertex(inkGenerator* generator, inkVertex* vertex, inkPoint position, void* fill, inkMatrix invGLMatrix)
{
	if (generator == NULL || vertex == NULL)
		return;

	vertex->pos = position;

	if (fill == NULL)
		return;

	inkFillType fillType = ((inkFill *)fill)->fillType;

	switch(fillType)
	{
		case inkFillType_Solid:
		{
			inkSolidFill* solidFill = (inkSolidFill *)fill;

			// TODO: Use a real color checker instead
			vertex->color.r = 0xFF & (solidFill->color >> 16);
			vertex->color.g = 0xFF & (solidFill->color >> 8);
			vertex->color.b = 0xFF & (solidFill->color);
			vertex->color.a = 0xFF * solidFill->alpha;
		}
			break;
		case inkFillType_Bitmap:
		{
			inkBitmapFill* bitmapFill = (inkBitmapFill *)fill;

			inkPoint convertedPosition = inkGeneratorConvertPositionFromMatrix(position, bitmapFill->matrix, invGLMatrix);

			vertex->tex.x = convertedPosition.x * bitmapFill->bitmapInfo.one_textureWidth;
			vertex->tex.y = convertedPosition.y * bitmapFill->bitmapInfo.one_textureHeight;
		}
			break;
		case inkFillType_Gradient:
		{
			inkGradientFill* gradientFill = (inkGradientFill *)fill;
		//	position = inkMatrixTransformPoint(invGLMatrix, position);
		//	inkPoint convertedPosition = inkMatrixTransformPoint(gradientFill->matrix, position);

			position = inkMatrixTransformPoint(invGLMatrix, position);
			inkPoint convertedPosition = inkMatrixTransformPoint(gradientFill->matrix, position);

		//	inkPoint convertedPosition = inkGeneratorConvertPositionFromMatrix(position, gradientFill->matrix, invGLMatrix);

			//inkPoint convertedPosition = inkMatrixTransformPoint(inkMatrixMultiply(invGLMatrix, gradientFill->matrix), position);
			//inkPoint convertedPosition = inkGeneratorConvertPositionFromMatrix(position, gradientFill->matrix, invGLMatrix);

			//printf("Converted [(%3.4f, %3.4f)] (%3.4f, %3.4f) into (%3.4f, %3.4f)\n", oldPoint.x, oldPoint.y, position.x, position.y, convertedPosition.x, convertedPosition.y);
			vertex->color = inkGradientColor(gradientFill, convertedPosition);
			//vertex->color = inkColorLinen;
		}
			break;
		default:
			break;
	}
}

void inkGeneratorAddVertex(inkGenerator* generator, inkPoint position, void* fill, inkMatrix matrix, bool isCurve)
{
	if (generator == NULL || generator->currentVertices == NULL)
		return;

	inkVertex* vertex = (inkVertex*)inkArrayPush(generator->currentVertices);
	bool* isCurvePtr = (bool*)inkArrayPush(generator->currentIsCurveGroup);
	if (isCurvePtr != NULL)
		*isCurvePtr = isCurve;

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

	if (generator->isCurveGroupList != NULL)
	{
		inkArray* array;

		inkArrayPtrForEach(generator->isCurveGroupList, array)
		{
			inkArrayDestroy(array);
		}

		inkArrayClear(generator->isCurveGroupList);
		generator->currentIsCurveGroup = NULL;
	}
}

void inkGeneratorMultColor(inkGenerator* generator, float red, float green, float blue, float alpha)
{
	if (generator == NULL)
		return;

	inkArray* array;
	inkVertex* vertex;

	inkArrayPtrForEach(generator->vertexGroupList, array)
	{
		inkArrayForEach(array, vertex)
		{
			vertex->color.r *= red;
			vertex->color.g *= green;
			vertex->color.b *= blue;
			vertex->color.a *= alpha;
		}
	}
}
