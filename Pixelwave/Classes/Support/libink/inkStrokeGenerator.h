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

#include "inkStroke.h"
#include "inkGeometry.h"

#include "inkTessellator.h"
#include "inkGenerator.h"

#include "inkCanvas.h"

// Because inkGenerator is a pointer, you can't just cast a stroke generator to
// a generator, you must grab the first argument and cast that instead.

typedef struct
{
	inkGenerator* generator; // Parent - must be first argument

	inkStroke* stroke;

	inkArray* rasterizeGroups;
	inkCanvas* canvas;
} inkStrokeGenerator;

inkExtern inkStrokeGenerator *inkStrokeGeneratorCreate(inkTessellator* tessellator, inkCanvas* canvas, inkArray *renderGroups, inkStroke* stroke);
inkExtern void inkStrokeGeneratorDestroy(inkStrokeGenerator* generator);

inkExtern void inkStrokeGeneratorSetFill(inkStrokeGenerator* generator, void* fill);

inkExtern void inkStrokeGeneratorMoveTo(inkStrokeGenerator* generator, inkPoint position);
inkExtern void inkStrokeGeneratorLineTo(inkStrokeGenerator* generator, inkPoint position);
inkExtern void inkStrokeGeneratorEnd(inkStrokeGenerator* generator);

#endif
