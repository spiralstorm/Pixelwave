//
//  inkGenerator.h
//  ink
//
//  Created by John Lattin on 11/16/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_GENERATOR_H_
#define _INK_GENERATOR_H_

#include "inkTessellator.h"
#include "inkGeometry.h"
#include "inkArray.h"

typedef void (*inkGeneratorEndFunction)(void *);

typedef struct
{
	inkTessellator* tessellator;

	inkArray* vertexGroupList;
	inkArray* currentVertices;

	inkPoint previous;

	void* fill;
} inkGenerator;

inkExtern inkGenerator* inkGeneratorCreate(inkTessellator* tessellator, void* fill);
inkExtern void inkGeneratorDestroy(inkGenerator* generator);

inkExtern void inkGeneratorMoveTo(inkGenerator* generator, inkPoint position, inkGeneratorEndFunction endFunction, void *userData);
inkExtern void inkGeneratorLineTo(inkGenerator* generator, inkPoint position);
inkExtern void inkGeneratorCurveTo(inkGenerator* generator, inkPoint control, inkPoint anchor);
inkExtern void inkGeneratorEnd(inkGenerator* generator);

inkExtern void inkGeneratorAddVertex(inkGenerator* generator, inkPoint position);

#endif
