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

typedef struct
{
	inkArray* commandList;
	inkArray* renderGroups;
} inkCanvas;

inkExtern inkTessellator* inkSharedTesselator;

inkExtern inkCanvas* inkCreate();
inkExtern void inkDestroy(inkCanvas* canvas);

inkExtern inkArray* inkRenderGroups(inkCanvas* canvas);

inkExtern void inkAddCommand(inkCanvas* canvas, inkCommandType type, void* data);
inkExtern void inkRemoveAllCommands(inkCanvas* canvas);

//inkExtern void inkAddRenderGroup(inkCanvas* canvas, inkArray* vertices, INKenum glMode);
inkExtern inkRenderGroup* inkPushRenderGroup(inkCanvas* canvas);
inkExtern void inkRemoveAllRenderGroups(inkCanvas* canvas);

// Will be NULL unless a canvas has been created
inkInline inkTessellator *inkGetTessellator();

#endif
