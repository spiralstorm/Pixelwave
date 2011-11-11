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

inkCanvas* inkCreate()
{
	inkCanvas *canvas = malloc(sizeof(inkCanvas));

	if (canvas != NULL)
	{
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

	inkCommand** command = (inkCommand**)inkArrayPush(canvas->commandList);

	*command = inkCommandCreate(type, data);

//	printf("adding command: %d\n", type);

//	printf("total commands: %d\n", inkArrayCount(canvas->commandList));
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
	}
}

void inkAddRenderGroup(inkCanvas* canvas, inkArray* vertices, INKenum glMode)
{
	if (canvas == NULL)
		return;

	inkRenderGroup** renderGroup = (inkRenderGroup**)inkArrayPush(canvas->renderGroups);

	*renderGroup = inkRenderGroupCreate(vertices, glMode);
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
	}
}
