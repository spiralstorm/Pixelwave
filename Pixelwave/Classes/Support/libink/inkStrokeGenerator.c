//
//  inkStrokeGenerator.c
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkStrokeGenerator.h"

#include "inkTessellator.h"
#include "inkGLU.h"

void inkStrokeGeneratorEndConvert(void* generator);

inkStrokeGenerator* inkStrokeGeneratorCreate(inkTessellator* tessellator, inkArray *renderGroups, inkStroke* stroke)
{
	inkStrokeGenerator* strokeGenerator = malloc(sizeof(inkStrokeGenerator));

	if (strokeGenerator != NULL)
	{
		inkGenerator* generator = inkGeneratorCreate(tessellator, NULL);

		if (generator == NULL)
		{
			inkStrokeGeneratorDestroy(strokeGenerator);
			return NULL;
		}

		strokeGenerator->generator = generator;
		strokeGenerator->stroke = stroke;

		inkTessellatorBeginPolygon(tessellator, renderGroups);
	}
	
	return strokeGenerator;
}

void inkStrokeGeneratorDestroy(inkStrokeGenerator* strokeGenerator)
{
	if (strokeGenerator != NULL)
	{
		if (strokeGenerator->generator != NULL)
		{
			inkTessellatorEndPolygon(strokeGenerator->generator->tessellator);

			inkGeneratorDestroy(strokeGenerator->generator);
		}

		free(strokeGenerator);
	}
}

void inkStrokeGeneratorSetFill(inkStrokeGenerator* strokeGenerator, void* fill)
{
	if (strokeGenerator == NULL || strokeGenerator->generator == NULL)
		return;

	strokeGenerator->generator->fill = fill;
}

void inkStrokeGeneratorMoveTo(inkStrokeGenerator* strokeGenerator, inkPoint position)
{
	if (strokeGenerator == NULL)
		return;

	inkGeneratorMoveTo(strokeGenerator->generator, position, inkStrokeGeneratorEndConvert, strokeGenerator);
}

void inkStrokeGeneratorLineTo(inkStrokeGenerator* strokeGenerator, inkPoint position)
{
	if (strokeGenerator == NULL)
		return;

	inkGeneratorLineTo(strokeGenerator->generator, position);
}

void inkStrokeGeneratorCurveTo(inkStrokeGenerator* strokeGenerator, inkPoint control, inkPoint anchor)
{
	if (strokeGenerator == NULL)
		return;

	inkGeneratorCurveTo(strokeGenerator->generator, control, anchor);
}

void inkStrokeGeneratorEnd(inkStrokeGenerator* strokeGenerator)
{
	if (strokeGenerator == NULL || strokeGenerator->generator == NULL || strokeGenerator->generator->currentVertices == NULL || strokeGenerator->generator->tessellator == NULL || strokeGenerator->stroke == NULL)
	{
		return;
	}

	if (isnan(strokeGenerator->stroke->thickness))
		return;

	inkGenerator* generator = strokeGenerator->generator;
	inkTessellator* tessellator = generator->tessellator;

	inkTessellatorBegin(GL_LINE_LOOP, tessellator);
//	inkTessellatorBegin(GL_TRIANGLE_STRIP, tessellator);

	if (tessellator->currentRenderGroup != NULL && strokeGenerator->stroke != NULL)
	{
		tessellator->currentRenderGroup->glLineWidth = strokeGenerator->stroke->thickness;
	}

	void* fill = strokeGenerator->generator->fill;

	INKvertex* vertex;

	INKvertex vA;
	INKvertex vB;
	INKvertex vC;

	inkPoint inner;
	inkPoint outer;

	INKvertex vInner;
	INKvertex vOuter;

	float halfScalar = strokeGenerator->stroke->thickness * 0.5f;

	unsigned int count = inkArrayCount(generator->currentVertices);

	if (count <= 1)
		return;

	vC = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, 1)));

	if (count > 3)
	{
		vA = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 1)));
	}
	else if (count == 2)
	{
		vA = vC;
	}

	// TODO:	inkTessellatorVertex copies the vertex right now, make sure this
	//			will ALWAYS be the case, or this will fail.
	inkArrayForEach(generator->currentVertices, vertex)
	{
		vB = *vertex;

		inkPointBisectionTraverser(inkPointMake(vA.x, vA.y), inkPointMake(vB.x, vB.y), inkPointMake(vC.x, vC.y), halfScalar, &inner, &outer);

//		inkGeneratorInitVertex(&vInner, inner, fill);
		inkGeneratorInitVertex(&vOuter, outer, fill);

//		inkTessellatorVertex(&vInner, tessellator);
		inkTessellatorVertex(&vOuter, tessellator);
//		inkTessellatorVertex(vertex, tessellator);
		printf("line pt = (%f, %f)\n", outer.x, outer.y);
	}
	printf("\n");

	inkTessellatorEnd(tessellator);
	generator->currentVertices = NULL;
}

void inkStrokeGeneratorEndConvert(void* generator)
{
	inkStrokeGeneratorEnd((inkStrokeGenerator*)generator);
}
