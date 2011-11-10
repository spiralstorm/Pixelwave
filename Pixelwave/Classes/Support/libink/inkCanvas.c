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

inkCanvas* inkCreate()
{
	inkCanvas *canvas = malloc(sizeof(inkCanvas));

	if (canvas != NULL)
	{
		canvas->commandList = inkArrayCreate(sizeof(inkCommand));
		canvas->renderGroups = inkArrayCreate(sizeof(inkRenderGroup));

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
		if (canvas->commandList != NULL)
		{
			inkArrayDestroy(canvas->commandList);
		}

		if (canvas->renderGroups != NULL)
		{
			inkArrayDestroy(canvas->renderGroups);
		}

		free(canvas);
	}
}
