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

#include "inkTypes.h"
#include "inkGeometry.h"

typedef struct
{
	void *gluTessellator;

	inkArray *renderGroups; // Weak
	inkRenderGroup *currentRenderGroup; // Weak
	inkArray *vertexPtrs;

	inkPresetGLData glData;
	void* userData;

	bool contourBegan;
	bool polygonBegan;
	bool isStroke;
} inkTessellator;

inkExtern inkTessellator *inkTessellatorCreate();
inkExtern void inkTessellatorDestroy(inkTessellator* tessellator);

inkExtern void inkTessellatorSetWindingRule(inkTessellator* tessellator, inkWindingRule windingRule);
inkExtern void inkTessellatorSetUserData(inkTessellator* tessellator, void* userData);

inkExtern inkPresetGLData inkTessellatorGetGLData(inkTessellator* tessellator);
inkExtern void inkTessellatorSetGLData(inkTessellator* tessellator, inkPresetGLData glData);

inkExtern void inkTessellatorSetIsStroke(inkTessellator* tessellator, bool isStroke);

inkExtern void inkTessellatorBeginPolygon(inkTessellator* tessellator, inkArray *renderGroups);
inkExtern void inkTessellatorEndPolygon(inkTessellator* tessellator);
inkExtern void inkTessellatorBeginContour(inkTessellator* tessellator);
inkExtern void inkTessellatorEndContour(inkTessellator* tessellator);

inkExtern void inkTessellatorAddPoint(inkTessellator* tessellator, inkVertex *vertex);

inkExtern void inkTessellatorBegin(INKenum type, inkTessellator* tessellator);
inkExtern void inkTessellatorEnd(inkTessellator* tessellator);
inkExtern void inkTessellatorVertex(void* vertex, inkTessellator* tessellator);
inkExtern void inkTessellatorError(INKenum error, inkTessellator*tessellator);
inkExtern void inkTessellatorCombine(double coords[3], inkVertex* vertexData[4], float weight[4], inkVertex** outData, inkTessellator* tessellator);

#endif
