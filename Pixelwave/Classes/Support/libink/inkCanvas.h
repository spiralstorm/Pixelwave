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

	inkPoint cursor;
	inkRect bounds;

	float pixelHint;
} inkCanvas;

inkExtern inkCanvas* inkCreate();
inkExtern void inkDestroy(inkCanvas* canvas);

inkExtern inkArray* inkRenderGroups(inkCanvas* canvas);
inkExtern inkPoint inkCursor(inkCanvas* canvas);
inkExtern inkRect inkBounds(inkCanvas* canvas);

inkExtern void inkSetPixelHint(inkCanvas* canvas, float pixelHint);
inkExtern float inkPixelHint(inkCanvas* canvas);

inkExtern void inkAddCommand(inkCanvas* canvas, inkCommandType type, void* data);
inkExtern void inkRemoveAllCommands(inkCanvas* canvas);

inkExtern void inkRemoveAllRenderGroups(inkCanvas* canvas);

// Will be NULL unless a canvas has been created
inkExtern inkTessellator* inkGetFillTessellator();
inkExtern inkTessellator* inkGetStrokeTessellator();

#endif
