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

typedef struct
{
	inkArray *vertices;

	INKenum glDrawMode;
} inkRenderGroup;

inkExtern inkRenderGroup* inkRenderGroupCreate(size_t vertexSize, INKenum glDrawMode);
inkExtern inkRenderGroup* inkRenderGroupCreateWithVertices(inkArray *vertices, INKenum glDrawMode);
inkExtern void inkRenderGroupDestroy(inkRenderGroup *group);

#endif
