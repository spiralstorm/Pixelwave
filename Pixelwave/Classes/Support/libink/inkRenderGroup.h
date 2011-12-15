//
//  inkRenderGroup.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_RENDER_GROUP_H_
#define _INK_RENDER_GROUP_H_

#include "inkHeader.h"
#include "inkTypes.h"
#include "inkArray.h"
#include "inkGeometry.h"

typedef struct
{
	inkArray *vertices;

	INKenum glDrawMode;

	inkPresetGLData glData;

	void *userData;
	bool isStroke;
} inkRenderGroup;

inkExtern inkRenderGroup* inkRenderGroupCreate(INKenum glDrawMode, inkPresetGLData glData, void* userData, bool isStroke);
inkExtern void inkRenderGroupDestroy(inkRenderGroup* group);

inkExtern inkVertex *inkRenderGroupNextVertex(inkRenderGroup* group);

#endif
