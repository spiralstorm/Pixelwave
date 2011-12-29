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

#include "inkObject.h"

inkTessellator* inkSharedFillTesselator = NULL;
unsigned int inkSharedFillTessellatorUseCount = 0;

inkTessellator* inkSharedStrokeTesselator = NULL;
unsigned int inkSharedStrokeTessellatorUseCount = 0;

inkCanvas* inkCreate()
{
	inkCanvas *canvas = malloc(sizeof(inkCanvas));

	if (canvas != NULL)
	{
		canvas->commandList = inkArrayCreate(sizeof(inkCommand*));
		canvas->renderGroups = inkArrayCreate(sizeof(inkRenderGroup*));
		canvas->matrixStack = inkArrayCreate(sizeof(inkMatrix));
		canvas->destroyUponClear = inkArrayCreate(sizeof(inkObject*));
		canvas->fillTessellator = inkTessellatorCreate();
		canvas->strokeTessellator = inkTessellatorCreate();

		if (canvas->commandList == NULL || canvas->renderGroups == NULL || canvas->matrixStack == NULL || canvas->destroyUponClear == NULL || canvas->fillTessellator == NULL || canvas->strokeTessellator == NULL)
		{
			inkDestroy(canvas);
			return NULL;
		}

		inkTessellatorSetIsStroke(canvas->fillTessellator, false);
		inkTessellatorSetIsStroke(canvas->strokeTessellator, true);

		canvas->matrix = inkMatrixIdentity;
		canvas->cursor = inkPointZero;
		canvas->bounds = inkRectZero;
		canvas->boundsWithStroke = inkRectZero;
		canvas->previousControl = inkPointZero;
		canvas->totalLength = 0.0f;

		inkSetConvertTrianglesIntoStrips(canvas, false);
		inkSetIncompleteDrawStrategies(canvas, inkIncompleteDrawStrategy_Fade, inkIncompleteDrawStrategy_Full, 0.0f);
		inkSetMaxLength(canvas, FLT_MAX);
		inkSetCurveMultiplier(canvas, 0.2f);
		//inkSetCurveMultiplier(canvas, 0.01f);
		inkSetPixelsPerPoint(canvas, 1.0f);
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

		inkArrayDestroy(canvas->matrixStack);

		inkTessellatorDestroy(canvas->fillTessellator);
		inkTessellatorDestroy(canvas->strokeTessellator);

		inkFreeCachedMemory(canvas);
		inkArrayDestroy(canvas->destroyUponClear);

		free(canvas);
	}
}

inkArray* inkRenderGroups(inkCanvas* canvas)
{
	assert(canvas != NULL);

	return canvas->renderGroups;
}

inkPoint inkCursor(inkCanvas* canvas)
{
	assert(canvas != NULL);

	return canvas->cursor;
}

inkRect inkBounds(inkCanvas* canvas)
{
	return inkBoundsv(canvas, false);
}

inkRect inkBoundsv(inkCanvas* canvas, bool withStroke)
{
	assert(canvas != NULL);

	if (withStroke)
		return canvas->boundsWithStroke;

	return canvas->bounds;
}

void inkSetCurveMultiplier(inkCanvas* canvas, float curveMultiplier)
{
	assert(canvas != NULL);

	curveMultiplier = fabsf(curveMultiplier);
	if (inkIsZerof(curveMultiplier))
		curveMultiplier = 0.01f;

	canvas->curveMultiplier = curveMultiplier;
}

float inkCurveMultiplier(inkCanvas* canvas)
{
	assert(canvas != NULL);

	return canvas->curveMultiplier;
}

float inkGetTotalLength(inkCanvas* canvas)
{
	assert(canvas != NULL);

	return canvas->totalLength;
}

void inkSetMaxLength(inkCanvas* canvas, float length)
{
	assert(canvas != NULL);

	canvas->maxLength = fabsf(length);
}

float inkGetMaxLength(inkCanvas* canvas)
{
	assert(canvas != NULL);

	return canvas->maxLength;
}

void inkSetIncompleteDrawStrategies(inkCanvas* canvas, inkIncompleteDrawStrategy incompleteFillStrategy, inkIncompleteDrawStrategy incompleteStrokeStrategy, float overDrawAllowance)
{
	assert(canvas != NULL);

	canvas->incompleteFillStrategy = incompleteFillStrategy;
	canvas->incompleteStrokeStrategy = incompleteStrokeStrategy;
	canvas->overDrawAllowance = overDrawAllowance;
}

void inkSetPixelsPerPoint(inkCanvas* canvas, float pixelsPerPoint)
{
	assert(canvas != NULL);

	pixelsPerPoint = fabsf(pixelsPerPoint);
	if (pixelsPerPoint <= 0.0f)
		return;

	canvas->pixelsPerPoint = pixelsPerPoint;
	canvas->one_pixelsPerPoint = 1.0f / pixelsPerPoint;
}

float inkGetPixelsPerPoint(inkCanvas* canvas)
{
	assert(canvas != NULL);

	return canvas->pixelsPerPoint;
}

void inkAddCommand(inkCanvas* canvas, inkCommandType type, void* data)
{
	assert(canvas != NULL);

	inkCommand *command = inkCommandCreate(type, data);

	if (command != NULL)
	{
		inkCommand** commandPtr = (inkCommand**)inkArrayPush(canvas->commandList);

		if (commandPtr != NULL)
			*commandPtr = command;
		else
			inkCommandDestroy(command);
	}
}

void inkRemoveAllCommands(inkCanvas* canvas)
{
	assert(canvas != NULL);

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
	assert(canvas != NULL);

	if (canvas->renderGroups != NULL)
	{
		inkRenderGroup* renderGroup;

		inkArrayPtrForEach(canvas->renderGroups, renderGroup)
		{
			inkRenderGroupDestroy(renderGroup);
		}

		inkArrayClear(canvas->renderGroups);
	}

	canvas->totalLength = 0.0f;
}

bool inkFreeUponClear(inkCanvas* canvas, void* holder, inkDestroyFunction func)
{
	assert(canvas != NULL);

	unsigned int previousCount = inkArrayCount(canvas->destroyUponClear);
	inkObject** objPtr = inkArrayPush(canvas->destroyUponClear);
	if (objPtr == NULL)
		return false;

	*objPtr = inkObjectCreate(holder, func);

	if (*objPtr == NULL)
	{
		inkArrayUpdateCount(canvas->destroyUponClear, previousCount);
		return false;
	}

	return true;
}

void inkFreeCachedMemory(inkCanvas* canvas)
{
	assert(canvas != NULL);

	inkObject* obj;

	inkArrayPtrForEach(canvas->destroyUponClear, obj)
	{
		inkObjectRelease(obj);
	}

	inkArrayClear(canvas->destroyUponClear);
}

void inkSetConvertTrianglesIntoStrips(inkCanvas* canvas, bool convertTrianglesIntoStrips)
{
	assert(canvas != NULL);

	canvas->convertTrianglesIntoStrips = convertTrianglesIntoStrips;
}

bool inkGetConvertTrianglesIntoStrips(inkCanvas* canvas)
{
	assert(canvas != NULL);

	return canvas->convertTrianglesIntoStrips;
}
