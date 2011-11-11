//
//  inkFillGenerator.h
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_FILL_GENERATOR_H_
#define _INK_FILL_GENERATOR_H_

#include "inkHeader.h"
#include "inkArray.h"
#include "inkGeometry.h"
#include "inkFill.h"
#include "inkTessellator.h"
#include "inkRenderGroup.h"

typedef struct
{
	// TODO: Change to render group instead?
	//inkArray* vertices;

	inkRenderGroup *renderGroup;

	void* fill;
} inkFillInfo;

inkExtern inkFillInfo* inkFillGeneratorCreate(inkRenderGroup *renderGroup, void* fill);
inkExtern void inkFillGeneratorDestroy(inkFillInfo* fillInfo);

inkExtern void inkFillGeneratorMoveTo(inkFillInfo* fillInfo, inkPoint position);
inkExtern void inkFillGeneratorLineTo(inkFillInfo* fillInfo, inkPoint position);
inkExtern void inkFillGeneratorEnd(inkFillInfo* fillInfo, inkTessellator* tessellator, inkRenderGroup* renderGroup);

#endif
