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
	inkArray* vertices;
	inkArray* indices;

	// GL_TRIANGLE_STRIP, ... etc
	INKenum glDrawMode;

	inkDrawType glDrawType;

	inkPresetGLData glData;

	inkMatrix invGLMatrix;

	void *userData;
	bool isStroke;
} inkRenderGroup;

inkExtern inkRenderGroup* inkRenderGroupCreate(INKenum glDrawMode, inkPresetGLData glData, void* userData, inkMatrix invGLMatrix, bool isStroke);
inkExtern void inkRenderGroupDestroy(inkRenderGroup* group);

inkExtern inkVertex *inkRenderGroupNextVertex(inkRenderGroup* group);

inkExtern void inkRenderGroupConvertToStrips(inkRenderGroup* group);
inkExtern void inkRenderGroupConvertToElements(inkRenderGroup* group);

#endif
