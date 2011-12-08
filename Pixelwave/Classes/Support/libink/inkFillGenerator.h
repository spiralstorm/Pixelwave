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
#include "inkGenerator.h"

// Because inkGenerator is a pointer, you can't just cast a fill generator to a
// generator, you must grab the first argument and cast that instead.
typedef struct
{
	inkGenerator* generator; // Parent - must be first argument
} inkFillGenerator;

inkExtern inkFillGenerator* inkFillGeneratorCreate(inkTessellator* tessellator, inkArray* renderGroups, void* fill);
inkExtern void inkFillGeneratorDestroy(inkFillGenerator* generator);

inkExtern void inkFillGeneratorMoveTo(inkFillGenerator* generator, inkPoint position);
inkExtern void inkFillGeneratorLineTo(inkFillGenerator* generator, inkPoint position);
inkExtern void inkFillGeneratorEnd(inkFillGenerator* generator);

#endif
