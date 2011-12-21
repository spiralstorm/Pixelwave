//
//  inkCanvas.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_CANVAS_H_
#define _INK_CANVAS_H_

#include "inkHeader.h"
#include "inkArray.h"

#include "inkTypes.h"
#include "inkTessellator.h"
#include "inkRenderGroup.h"

#include "inkGeometry.h"

typedef struct
{
	inkArray* commandList;
	inkArray* renderGroups;

	inkTessellator* fillTessellator;
	inkTessellator* strokeTessellator;

	inkMatrix matrix;
	inkArray* matrixStack;

	inkArray* destroyUponClear;

	inkPoint cursor;
	inkRect bounds;
	inkRect boundsWithStroke;

	inkPoint previousControl;

	float curveMultiplier;
	float totalLength;
	float maxLength;

	float pixelsPerPoint;
	float one_pixelsPerPoint;
	float overDrawAllowance;

	bool convertTrianglesIntoStrips;

	inkIncompleteDrawStrategy incompleteFillStrategy;
	inkIncompleteDrawStrategy incompleteStrokeStrategy;
} inkCanvas;

inkExtern inkCanvas* inkCreate();
inkExtern void inkDestroy(inkCanvas* canvas);

inkExtern inkArray* inkRenderGroups(inkCanvas* canvas);
inkExtern inkPoint inkCursor(inkCanvas* canvas);
inkExtern inkRect inkBounds(inkCanvas* canvas);
inkExtern inkRect inkBoundsv(inkCanvas* canvas, bool withStroke);

inkExtern void inkSetCurveMultiplier(inkCanvas* canvas, float curveMultiplier);
inkExtern float inkCurveMultiplier(inkCanvas* canvas);

inkExtern float inkTotalLength(inkCanvas* canvas);
inkExtern void inkSetMaxLength(inkCanvas* canvas, float length);
inkExtern float inkMaxLength(inkCanvas* canvas);

inkExtern void inkSetIncompleteDrawStrategies(inkCanvas* canvas, inkIncompleteDrawStrategy incompleteFillStrategy, inkIncompleteDrawStrategy incompleteStrokeStrategy, float overDrawAllowance);

inkExtern void inkSetPixelsPerPoint(inkCanvas* canvas, float pixelHint);
inkExtern float inkPixelsPerPoint(inkCanvas* canvas);

inkExtern void inkAddCommand(inkCanvas* canvas, inkCommandType type, void* data);
inkExtern void inkRemoveAllCommands(inkCanvas* canvas);

inkExtern void inkRemoveAllRenderGroups(inkCanvas* canvas);

inkExtern bool inkAddMemoryToFreeUponClear(inkCanvas* canvas, void* holder, inkDestroyFunction func);
inkExtern void inkFreeCachedMemory(inkCanvas* canvas);

inkExtern void inkSetConvertTrianglesIntoStrips(inkCanvas* canvas, bool convertTrianglesIntoStrips);
inkExtern bool inkGetConvertTrianglesIntoStrips(inkCanvas* canvas);

#endif
