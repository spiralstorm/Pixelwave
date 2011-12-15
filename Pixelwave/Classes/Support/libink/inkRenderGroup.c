//
//  inkRenderGroup.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkRenderGroup.h"

inkRenderGroup* inkRenderGroupCreate(INKenum glDrawMode, inkPresetGLData glData, void* userData, bool isStroke)
{
	inkRenderGroup* renderGroup = malloc(sizeof(inkRenderGroup));

	if (renderGroup != NULL)
	{
		renderGroup->vertices = inkArrayCreate(sizeof(inkVertex));

		if (renderGroup->vertices == NULL)
		{
			inkRenderGroupDestroy(renderGroup);
			return NULL;
		}

		renderGroup->glDrawMode = glDrawMode;
		renderGroup->glData = glData;
		renderGroup->userData = userData;
		renderGroup->isStroke = isStroke;
	}

	return renderGroup;
}

void inkRenderGroupDestroy(inkRenderGroup* renderGroup)
{
	if (renderGroup)
	{
		inkArrayDestroy(renderGroup->vertices);

		free(renderGroup);
	}
}

inkVertex* inkRenderGroupNextVertex(inkRenderGroup* renderGroup)
{
	if (renderGroup == NULL || renderGroup->vertices == NULL)
		return NULL;

	return (inkVertex*)inkArrayPush(renderGroup->vertices);
}
