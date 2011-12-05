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

inkTessellator* inkSharedFillTesselator = NULL;
unsigned int inkSharedFillTessellatorUseCount = 0;

inkTessellator* inkSharedStrokeTesselator = NULL;
unsigned int inkSharedStrokeTessellatorUseCount = 0;

inkCanvas* inkCreate()
{
	inkCanvas *canvas = malloc(sizeof(inkCanvas));

	if (canvas != NULL)
	{
		if (inkSharedFillTesselator == NULL)
		{
			inkSharedFillTesselator = inkTessellatorCreate();
			++inkSharedFillTessellatorUseCount;
		}
		if (inkSharedStrokeTesselator == NULL)
		{
			inkSharedStrokeTesselator = inkTessellatorCreate();
			++inkSharedStrokeTessellatorUseCount;
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
		if (inkSharedFillTesselator != NULL)
		{
			if (inkSharedFillTessellatorUseCount != 0)
				--inkSharedFillTessellatorUseCount;

			if (inkSharedFillTessellatorUseCount == 0)
			{
				inkTessellatorDestroy(inkSharedFillTesselator);
				inkSharedFillTesselator = NULL;
			}
		}
		if (inkSharedStrokeTesselator != NULL)
		{
			if (inkSharedStrokeTessellatorUseCount != 0)
				--inkSharedStrokeTessellatorUseCount;
			
			if (inkSharedStrokeTessellatorUseCount == 0)
			{
				inkTessellatorDestroy(inkSharedStrokeTesselator);
				inkSharedStrokeTesselator = NULL;
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

inkPoint inkCursor(inkCanvas* canvas)
{
	if (canvas == NULL)
		return inkPointZero;

	return canvas->cursor;
}

void inkAddCommand(inkCanvas* canvas, inkCommandType type, void* data)
{
	if (canvas == NULL)
		return;

	inkCommand *command = inkCommandCreate(type, data);

	if (command != NULL)
	{
		inkCommand** commandPtr = (inkCommand**)inkArrayPush(canvas->commandList);

		if (commandPtr != NULL)
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

inkTessellator* inkGetFillTessellator()
{
	return inkSharedFillTesselator;
}

inkTessellator* inkGetStrokeTessellator()
{
	return inkSharedStrokeTesselator;
}
