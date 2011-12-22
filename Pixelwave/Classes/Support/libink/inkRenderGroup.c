//
//  inkRenderGroup.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkRenderGroup.h"

#include "inkGL.h"

inkRenderGroup* inkRenderGroupCreate(INKenum glDrawMode, inkPresetGLData glData, void* userData, bool isStroke)
{
	inkRenderGroup* renderGroup = malloc(sizeof(inkRenderGroup));

	if (renderGroup != NULL)
	{
		renderGroup->vertices = inkArrayCreate(sizeof(inkVertex));
		renderGroup->indices = NULL;

		if (renderGroup->vertices == NULL)
		{
			inkRenderGroupDestroy(renderGroup);
			return NULL;
		}

		renderGroup->glDrawMode = glDrawMode;
		renderGroup->glData = glData;
		renderGroup->userData = userData;
		renderGroup->isStroke = isStroke;
		renderGroup->glDrawType = inkDrawType_Arrays;
	}

	return renderGroup;
}

void inkRenderGroupDestroy(inkRenderGroup* renderGroup)
{
	if (renderGroup)
	{
		inkArrayDestroy(renderGroup->vertices);
		inkArrayDestroy(renderGroup->indices);

		free(renderGroup);
	}
}

inkVertex* inkRenderGroupNextVertex(inkRenderGroup* renderGroup)
{
	if (renderGroup == NULL || renderGroup->vertices == NULL)
		return NULL;

	return (inkVertex*)inkArrayPush(renderGroup->vertices);
}

inkInline bool inkRenderGroupAddNewVertex(inkArray* newArray, inkVertex vertex)
{
	inkVertex* newVertex = inkArrayPush(newArray);

	if (newVertex == NULL)
		return false;

	*newVertex = vertex;

	return true;
}

inkInline bool inkRenderGroupAddNewIndex(inkArray* indices, unsigned int index)
{
	unsigned int* indexPtr = inkArrayPush(indices);

	if (indexPtr == NULL)
		return false;

	*indexPtr = index;

	return true;
}

void inkRenderGroupConvertToStrips(inkRenderGroup* renderGroup)
{
	assert(renderGroup);

	if (renderGroup->glDrawMode == GL_TRIANGLE_STRIP)
		return;

	if (renderGroup->glDrawMode != GL_TRIANGLES && renderGroup->glDrawMode != GL_TRIANGLE_FAN)
	{
		inkArrayClear(renderGroup->vertices);
		return;
	}

	if (renderGroup->indices == NULL)
		renderGroup->indices = inkArrayCreate(sizeof(unsigned int));
	else
		inkArrayClear(renderGroup->indices);

	if (renderGroup->indices == NULL)
		return;

	inkArray* newVertices = inkArrayCreate(sizeof(inkVertex));
	if (newVertices == NULL)
		return;

	unsigned int vertexCount = inkArrayCount(renderGroup->vertices);

	switch(renderGroup->glDrawMode)
	{
		case GL_TRIANGLES:
		{
			inkVertex* vertex;

			int state = 0;
			unsigned int index;
			--vertexCount;

			inkArrayForEachv(renderGroup->vertices, vertex, index = 0, ++index)
			{
				if (index != 0 && index != vertexCount)
				{
					if (state == 0 || state == 2)
					{
						inkRenderGroupAddNewIndex(renderGroup->indices, index);
					//	inkRenderGroupAddNewVertex(newVertices, *vertex);
					}
				}

				inkRenderGroupAddNewIndex(renderGroup->indices, index);
				inkRenderGroupAddNewVertex(newVertices, *vertex);

				if (++state == 3)
					state = 0;
				//++index;
			}
		}
			break;
		case GL_TRIANGLE_FAN:
		{
		//	inkVertex startVertex;
		//	inkVertex lastVertex;
			inkVertex* vertex;

			unsigned int startIndex = 0;
			unsigned int lastIndex = 1;

			unsigned int index;

			inkArrayForEachv(renderGroup->vertices, vertex, index = 0, ++index)
			{
				/*if (index == 0)
				{
					startVertex = *vertex;
				}
				else if (index == 1)
				{
					lastVertex = *vertex;
				}*/
				if (index > 1)
				{
					inkRenderGroupAddNewIndex(renderGroup->indices, startIndex);
					inkRenderGroupAddNewIndex(renderGroup->indices, lastIndex);
					inkRenderGroupAddNewIndex(renderGroup->indices, index);
				//	inkRenderGroupAddNewVertex(newVertices, startVertex);
				//	inkRenderGroupAddNewVertex(newVertices, lastVertex);
				//	inkRenderGroupAddNewVertex(newVertices, *vertex);

				//	lastVertex = *vertex;
					lastIndex = index;
				}

				inkRenderGroupAddNewVertex(newVertices, *vertex);

				//++index;
			}
		}
			break;
		default:
			break;
	}

	renderGroup->glDrawMode = GL_TRIANGLE_STRIP;
	renderGroup->glDrawType = inkDrawType_Elements;

	inkArrayDestroy(renderGroup->vertices);
	renderGroup->vertices = newVertices;
}

void inkRenderGroupConvertToElements(inkRenderGroup* renderGroup)
{
	assert(renderGroup);

	if (renderGroup->glDrawType == inkDrawType_Elements)
		return;

	if (renderGroup->indices == NULL)
		renderGroup->indices = inkArrayCreate(sizeof(unsigned int));
	else
		inkArrayClear(renderGroup->indices);

	if (renderGroup->indices == NULL)
		return;

	inkArray* newVertices = inkArrayCreate(sizeof(inkVertex));
	if (newVertices == NULL)
		return;

	unsigned int index = 0;
	unsigned int counter = 0;
	unsigned int count;
	inkVertex* vertex;
	inkVertex* prev;
	bool unique = false;

	inkArrayForEach(renderGroup->vertices, vertex)
	{
		unique = true;

		count = inkArrayCount(newVertices);
		// TODO: Improve this, try looping backwards
		//index = 0;
		//inkArrayForEachv(newVertices, prev, index = 0, ++index)
		inkArrayForEachRevv(newVertices, prev, index = count - 1, --index)
		{
			if (inkVertexIsEqual(*prev, *vertex))
			{
				unique = false;
				break;
			}
			//++index;
		}

		if (unique == true)
		{
			inkRenderGroupAddNewVertex(newVertices, *vertex);
			index = counter;
			++counter;
		}

		inkRenderGroupAddNewIndex(renderGroup->indices, index);
	}

	renderGroup->glDrawType = inkDrawType_Elements;

	inkArrayDestroy(renderGroup->vertices);
	renderGroup->vertices = newVertices;
}
