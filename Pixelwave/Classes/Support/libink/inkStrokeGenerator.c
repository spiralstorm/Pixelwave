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

#include "inkFill.h"

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

inkInline inkLine inkStrokeGeneratorAddBisect(inkTessellator* tessellator, inkLine* previousLine, INKvertex vA, INKvertex vB, INKvertex vC, float halfScalar, void* fill)
{
	inkPoint inner;
	inkPoint outer;

	INKvertex vInner;
	INKvertex vOuter;

	//inkLineBisectionTraverser(inkPointMake(vA.x, vA.y), inkPointMake(vB.x, vB.y), halfScalar, &inner, &outer);
	//inkTriangleBisectionTraverser(inkPointMake(vA.x, vA.y), inkPointMake(vB.x, vB.y), inkPointMake(vC.x, vC.y), halfScalar, &inner, &outer);

	//if (previousLine != NULL)
	{
		inkGeneratorInitVertex(&vInner, inner, fill);
		inkGeneratorInitVertex(&vOuter, outer, fill);

		inkTessellatorVertex(&vInner, tessellator);
		inkTessellatorVertex(&vOuter, tessellator);

		printf(":: inner (%f, %f), outer (%f, %f)\n", inner.x, inner.y, outer.x, outer.y);
	}

	return inkLineMake(inner, outer);
}

inkInline inkBox inkStrokeGeneratorAdd(inkTessellator* tessellator, inkBox* previousBox, INKvertex vA, INKvertex vB, float halfScalar, void* fill)
{
	inkBox box = inkLineExpandToBox(inkLineMakev(vA.x, vA.y, vB.x, vB.y), halfScalar);
	//inkLineBisectionTraverser(inkPointMake(vA.x, vA.y), inkPointMake(vB.x, vB.y), halfScalar, &inner, &outer);
	//inkTriangleBisectionTraverser(inkPointMake(vA.x, vA.y), inkPointMake(vB.x, vB.y), inkPointMake(vC.x, vC.y), halfScalar, &inner, &outer);

//	INKvertex vC;
//	INKvertex vD;
	if (previousBox != NULL)
	{
	/*	inkTessellatorBegin(GL_LINE_LOOP, tessellator);
		inkGeneratorInitVertex(&vA, box.pointA, fill);
		inkGeneratorInitVertex(&vB, box.pointB, fill);
		inkGeneratorInitVertex(&vC, box.pointC, fill);
		inkGeneratorInitVertex(&vD, box.pointD, fill);

		inkTessellatorVertex(&vA, tessellator);
		inkTessellatorVertex(&vB, tessellator);
		inkTessellatorVertex(&vC, tessellator);
		inkTessellatorVertex(&vD, tessellator);
		inkTessellatorEnd(tessellator);

		inkTessellatorBegin(GL_POINTS, tessellator);*/
		// previousA -> now D
		// previousB -> now C

		inkLine linePreviousAD = inkLineMake(previousBox->pointA, previousBox->pointD);
		inkLine linePreviousBC = inkLineMake(previousBox->pointB, previousBox->pointC);
		inkLine lineAD = inkLineMake(box.pointA, box.pointD);
		inkLine lineBC = inkLineMake(box.pointB, box.pointC);

		inkPoint innerIntersection;
		inkPoint outerIntersection;

		innerIntersection = inkLineIntersection(lineAD, linePreviousAD);

		if (isnan(innerIntersection.x))
		{
			// TODO:	Handle a straight (or parallel) line at some point in
			//			the future.

			// NOTE:	This only needs to be done by either AD or BC
		}

		outerIntersection = inkLineIntersection(lineBC, linePreviousBC);

		// Is our inner really our outer?
		if (inkIsPointInLine(innerIntersection, lineAD))
		{
		//	inkPoint tempPoint = innerIntersection;
		//	innerIntersection = outerIntersection;
		//	outerIntersection = tempPoint;
		//	lineADIsInner = true;
		}

		inkGeneratorInitVertex(&vA, innerIntersection, fill);
		inkGeneratorInitVertex(&vB, outerIntersection, fill);

		inkTessellatorVertex(&vA, tessellator);
		inkTessellatorVertex(&vB, tessellator);
/*
	//	if (lineADIsInner == true)
	//		inkGeneratorInitVertex(&vA, intersectAD, fill);
	//	else
	//		inkGeneratorInitVertex(&vA, intersectBC, fill);

		inkSolidFill solidFill;
#define inkDrawPointsPlease(p, color)\
	solidFill = inkSolidFillMake(color, 1.0f);\
	inkGeneratorInitVertex(&vA, p, &solidFill);\
	inkTessellatorVertex(&vA, tessellator);

		inkDrawPointsPlease(previousBox->pointA, 0x0000FF);
		inkDrawPointsPlease(previousBox->pointB, 0x0000BB);
		inkDrawPointsPlease(previousBox->pointC, 0x000099);
		inkDrawPointsPlease(previousBox->pointD, 0x000066);

		inkDrawPointsPlease(box.pointA, 0x00FF00);
		inkDrawPointsPlease(box.pointB, 0x00BB00);
		inkDrawPointsPlease(box.pointC, 0x009900);
		inkDrawPointsPlease(box.pointD, 0x006600);

		inkDrawPointsPlease(intersectAD, 0xFFFFFF);
		inkDrawPointsPlease(intersectBC, 0x000000);

		inkTessellatorEnd(tessellator);*/
	}
	
	return box;
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

	inkTessellatorBegin(GL_TRIANGLE_STRIP, tessellator);

	INKvertex* vertex;

	void* fill = strokeGenerator->generator->fill;

	INKvertex vA;
	INKvertex vB;

	inkBox previousBox;
	inkBox* previousBoxPtr = NULL;

	float halfScalar = strokeGenerator->stroke->thickness * 0.5f;

	unsigned int count = inkArrayCount(generator->currentVertices);

	if (count <= 1)
		return;

	// TODO:	Make this work for a line, right now it will crash
	vA = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 2)));
	vB = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 1)));

	previousBox = inkStrokeGeneratorAdd(tessellator, previousBoxPtr, vA, vB, halfScalar, fill);
	previousBoxPtr = &previousBox;

	vA = vB;

	// TODO:	inkTessellatorVertex copies the vertex right now, make sure this
	//			will ALWAYS be the case, or this will fail.
	inkArrayForEach(generator->currentVertices, vertex)
	{
		vB = *vertex;

		previousBox = inkStrokeGeneratorAdd(tessellator, previousBoxPtr, vA, vB, halfScalar, fill);

		vA = vB;
	}

	vB = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, 0)));
	previousBox = inkStrokeGeneratorAdd(tessellator, previousBoxPtr, vA, vB, halfScalar, fill);

	inkTessellatorEnd(tessellator);
	generator->currentVertices = NULL;
}

/*void inkStrokeGeneratorEnd(inkStrokeGenerator* strokeGenerator)
{
//#define inkGLLine
	if (strokeGenerator == NULL || strokeGenerator->generator == NULL || strokeGenerator->generator->currentVertices == NULL || strokeGenerator->generator->tessellator == NULL || strokeGenerator->stroke == NULL)
	{
		return;
	}

	if (isnan(strokeGenerator->stroke->thickness))
		return;

	inkGenerator* generator = strokeGenerator->generator;
	inkTessellator* tessellator = generator->tessellator;

#ifndef inkGLLine
	inkTessellatorBegin(GL_TRIANGLE_STRIP, tessellator);
#else
	inkTessellatorBegin(GL_LINE_LOOP, tessellator);
	if (tessellator->currentRenderGroup != NULL && strokeGenerator->stroke != NULL)
	{
		tessellator->currentRenderGroup->glLineWidth = strokeGenerator->stroke->thickness;
	}
#endif

	INKvertex* vertex;

#ifndef inkGLLine
	void* fill = strokeGenerator->generator->fill;

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

	vA = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 1)));

	if (count > 2)
	{
		vB = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 2)));
	}
	else if (count == 2)
	{
		vB = vA;
	}
#endif

	// TODO:	inkTessellatorVertex copies the vertex right now, make sure this
	//			will ALWAYS be the case, or this will fail.
	inkArrayForEach(generator->currentVertices, vertex)
	{
#ifndef inkGLLine
		vC = *vertex;

		inkTriangleBisectionTraverser(inkPointMake(vA.x, vA.y), inkPointMake(vB.x, vB.y), inkPointMake(vC.x, vC.y), halfScalar, &inner, &outer);

		inkGeneratorInitVertex(&vInner, inner, fill);
		inkGeneratorInitVertex(&vOuter, outer, fill);

		inkTessellatorVertex(&vInner, tessellator);
		inkTessellatorVertex(&vOuter, tessellator);

		vB = vA;
		vA = vC;
#else
		inkTessellatorVertex(vertex, tessellator);
#endif
	}

#ifndef inkGLLine
	if (count > 2)
	{
		vC = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, 0)));

		inkTriangleBisectionTraverser(inkPointMake(vA.x, vA.y), inkPointMake(vB.x, vB.y), inkPointMake(vC.x, vC.y), halfScalar, &inner, &outer);

		inkGeneratorInitVertex(&vInner, inner, fill);
		inkGeneratorInitVertex(&vOuter, outer, fill);

		inkTessellatorVertex(&vInner, tessellator);
		inkTessellatorVertex(&vOuter, tessellator);
	}
#endif

	inkTessellatorEnd(tessellator);
	generator->currentVertices = NULL;
}*/

void inkStrokeGeneratorEndConvert(void* generator)
{
	inkStrokeGeneratorEnd((inkStrokeGenerator*)generator);
}
