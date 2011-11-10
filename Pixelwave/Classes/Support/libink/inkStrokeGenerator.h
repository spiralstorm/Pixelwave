//
//  inkStrokeGenerator.h
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_STROKE_GENERATOR_H_
#define _INK_STROKE_GENERATOR_H_

#include "inkHeader.h"
#include "inkArray.h"
#include "inkTypes.h"
#include "inkStroke.h"
#include "inkGeometry.h"

typedef struct
{
	inkArray *vertices;

	inkStroke *stroke;
} inkStrokeInfo;

inkExtern inkStrokeInfo *inkStrokeGeneratorCreate(size_t vertexSize, inkStroke *stroke);
inkExtern void inkStrokeGeneratorDestroy(inkStrokeInfo *strokeInfo);

inkExtern void inkStrokeGeneratorMoveTo(inkStrokeInfo *strokeInfo, inkPoint position);
inkExtern void inkStrokeGeneratorLineTo(inkStrokeInfo *strokeInfo, inkPoint position);
inkExtern void inkStrokeGeneratorEnd(inkStrokeInfo *strokeInfo);

#endif
