//
//  inkRenderGroup.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkRenderGroup.h"

inkRenderGroup* inkRenderGroupCreate(INKenum glDrawMode, unsigned int glTextureName)
{
	inkRenderGroup* renderGroup = malloc(sizeof(inkRenderGroup));

	if (renderGroup != NULL)
	{
		renderGroup->glDrawMode = glDrawMode;
		renderGroup->glTextureName = glTextureName;
		renderGroup->glLineWidth = 0.0f;
		renderGroup->vertices = inkArrayCreate(sizeof(INKvertex));

		if (renderGroup->vertices == NULL)
		{
			inkRenderGroupDestroy(renderGroup);
			return NULL;
		}
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

INKvertex* inkRenderGroupNextVertex(inkRenderGroup* renderGroup)
{
	if (renderGroup == NULL || renderGroup->vertices == NULL)
		return NULL;

	return (INKvertex *)inkArrayPush(renderGroup->vertices);
}
