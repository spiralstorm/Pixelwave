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
		renderGroup->indices = inkArrayCreate(sizeof(GLuint));

		if (renderGroup->vertices == NULL || renderGroup->indices == NULL)
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

void inkRenderGroupConvertToStrips(inkRenderGroup* renderGroup)
{
//	return;
	if (renderGroup == NULL)
		return;

	if (renderGroup->glDrawMode == GL_TRIANGLE_STRIP)
		return;

	if (renderGroup->glDrawMode != GL_TRIANGLES && renderGroup->glDrawMode != GL_TRIANGLE_FAN)
	{
	//	inkArrayClear(renderGroup->vertices);
		return;
	}

	inkArray* newVertices = inkArrayCreate(sizeof(inkVertex));
	if (newVertices == NULL)
		return;

	switch(renderGroup->glDrawMode)
	{
		case GL_TRIANGLES:
		{
			inkVertex* vertex;

			int index = 0;

			inkArrayForEach(renderGroup->vertices, vertex)
			{
				if (index == 0 || index == 2)
					inkRenderGroupAddNewVertex(newVertices, *vertex);
				inkRenderGroupAddNewVertex(newVertices, *vertex);

				if (++index == 3)
					index = 0;
			}
		}
			break;
		case GL_TRIANGLE_FAN:
		{
			inkVertex startVertex;
			inkVertex lastVertex;
			inkVertex* vertex;
			
			int index = 0;
			
			inkArrayForEach(renderGroup->vertices, vertex)
			{
				if (index == 0)
					startVertex = *vertex;
				else if (index == 1)
					lastVertex = *vertex;
				else
				{
					inkRenderGroupAddNewVertex(newVertices, startVertex);
					inkRenderGroupAddNewVertex(newVertices, lastVertex);
					inkRenderGroupAddNewVertex(newVertices, *vertex);

					lastVertex = *vertex;
				}

				++index;
			}
		}
			break;
		default:
			break;
	}

	renderGroup->glDrawMode = GL_TRIANGLE_STRIP;

	inkArrayDestroy(renderGroup->vertices);
	renderGroup->vertices = newVertices;
}
