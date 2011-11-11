//
//  inkTessellator.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_TESSELLATOR_H_
#define _INK_TESSELLATOR_H_

#include "inkHeader.h"

#include "inkArray.h"
#include "inkRenderGroup.h"

typedef struct
{
	void *gluTessellator;

	inkRenderGroup *currentRenderGroup;
	inkArray *combineVertices;
} inkTessellator;

inkExtern inkTessellator *inkTessellatorCreate();
inkExtern void inkTessellatorDestroy(inkTessellator* tessellator);

inkExtern void inkTessellatorBeginPolygon(inkTessellator* tessellator);
inkExtern void inkTessellatorEndPolygon(inkTessellator* tessellator);
inkExtern void inkTessellatorBeginContour(inkTessellator* tessellator);
inkExtern void inkTessellatorEndContour(inkTessellator* tessellator);

inkExtern void inkTessellatorExpandRenderGroup(inkTessellator* tessellator, inkRenderGroup* renderGroup);

#endif
