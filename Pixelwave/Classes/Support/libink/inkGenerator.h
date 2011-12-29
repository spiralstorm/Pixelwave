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

typedef struct _inkGenerator
{
	// This is a pointer back to myself. Why is this here? Well, when you cast a
	// fill or stroke generator to a generator, because they keep a pointer back
	// to the normal generator then you must use the first argument to grab the
	// correct value. Well, if I have a pointer as my first value back to
	// myself, then the first value is uniformed across all structure types.
	struct _inkGenerator* me;

	inkMatrix invGLMatrix;

	inkTessellator* tessellator;

	inkArray* vertexGroupList;
	inkArray* currentVertices;

	inkArray* isCurveGroupList;
	inkArray* currentIsCurveGroup;

	inkPoint previous;

	void* fill;
} inkGenerator;

inkExtern inkGenerator* inkGeneratorCreate(inkTessellator* tessellator, void* fill, inkMatrix invGLMatrix);
inkExtern void inkGeneratorDestroy(inkGenerator* generator);

inkExtern void inkGeneratorMoveTo(inkGenerator* generator, inkPoint position, inkGeneratorEndFunction endFunction, void *userData);
inkExtern void inkGeneratorLineTo(inkGenerator* generator, inkPoint position, bool isCurve);
inkExtern void inkGeneratorEnd(inkGenerator* generator);

inkExtern void inkGeneratorInitVertex(inkGenerator* generator, inkVertex* vertex, inkPoint position, void* fill, inkMatrix invGLMatrix);
inkExtern void inkGeneratorAddVertex(inkGenerator* generator, inkPoint position, void* fill, inkMatrix matrix, bool isCurve);
inkExtern void inkGeneratorRemoveAllVertices(inkGenerator* generator);

inkExtern void inkGeneratorMultColor(inkGenerator* generator, float red, float green, float blue, float alpha);

#endif
