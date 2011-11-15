//
//  inkCanvas.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkCanvas.h"

#include "inkCommand.h"
#include "inkRenderGroup.h"

#include <stdio.h>

inkTessellator* inkSharedTesselator = NULL;
unsigned int inkSharedTessellatorUseCount = 0;

inkCanvas* inkCreate()
{
	inkCanvas *canvas = malloc(sizeof(inkCanvas));

	if (canvas != NULL)
	{
		if (inkSharedTesselator == NULL)
		{
			inkSharedTesselator = inkTessellatorCreate();
			++inkSharedTessellatorUseCount;
		}

		canvas->commandList = inkArrayCreate(sizeof(inkCommand*));
		canvas->renderGroups = inkArrayCreate(sizeof(inkRenderGroup*));

		if (canvas->commandList == NULL || canvas->renderGroups == NULL)
		{
			inkDestroy(canvas);
			return NULL;
		}
	}

	return canvas;
}

void inkDestroy(inkCanvas* canvas)
{
	if (canvas != NULL)
	{
		if (inkSharedTesselator != NULL)
		{
			if (inkSharedTessellatorUseCount != 0)
				--inkSharedTessellatorUseCount;

			if (inkSharedTessellatorUseCount == 0)
			{
				inkTessellatorDestroy(inkSharedTesselator);
				inkSharedTesselator = NULL;
			}
		}

		inkRemoveAllCommands(canvas);
		inkArrayDestroy(canvas->commandList);

		inkRemoveAllRenderGroups(canvas);
		inkArrayDestroy(canvas->renderGroups);

		free(canvas);
	}
}

inkArray* inkRenderGroups(inkCanvas* canvas)
{
	if (canvas == NULL)
		return NULL;

	return canvas->renderGroups;
}

void inkAddCommand(inkCanvas* canvas, inkCommandType type, void* data)
{
	if (canvas == NULL)
		return;

	inkCommand *command = inkCommandCreate(type, data);

	if (command != NULL)
	{
		inkCommand** commandPtr = (inkCommand**)inkArrayPush(canvas->commandList);

		*commandPtr = command;
	}
}

void inkRemoveAllCommands(inkCanvas* canvas)
{
	if (canvas == NULL)
		return;

	if (canvas->commandList != NULL)
	{
		inkCommand* command;

		inkArrayPtrForEach(canvas->commandList, command)
		{
			inkCommandDestroy(command);
		}

		inkArrayClear(canvas->commandList);
	}
}

/*void inkAddRenderGroup(inkCanvas* canvas, inkArray* vertices, INKenum glMode)
{
	if (canvas == NULL)
		return;

	inkRenderGroup** renderGroup = (inkRenderGroup**)inkArrayPush(canvas->renderGroups);

	*renderGroup = inkRenderGroupCreateWithVertices(vertices, glMode);
}*/

inkRenderGroup* inkPushRenderGroup(inkCanvas* canvas)
{
	if (canvas == NULL)
		return NULL;

	inkRenderGroup* renderGroup = inkRenderGroupCreate(0);

	if (renderGroup != NULL)
	{
		inkRenderGroup** renderGroupPtr = (inkRenderGroup**)inkArrayPush(canvas->renderGroups);

		*renderGroupPtr = renderGroup;
	}

	return renderGroup;
}

void inkRemoveAllRenderGroups(inkCanvas* canvas)
{
	if (canvas == NULL)
		return;

	if (canvas->renderGroups != NULL)
	{
		inkRenderGroup* renderGroup;
		
		inkArrayPtrForEach(canvas->renderGroups, renderGroup)
		{
			inkRenderGroupDestroy(renderGroup);
		}

		inkArrayClear(canvas->renderGroups);
	}
}

// We use a shared tessellator because the 'rasterization' step, where
// tessellation is done, should ONLY ever happen on the main thread

inkInline inkTessellator *inkGetTessellator()
{
	return inkSharedTesselator;
}
