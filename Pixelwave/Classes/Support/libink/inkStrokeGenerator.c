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

inkInline inkBox inkStrokeGeneratorAdd(inkStroke* stroke, inkTessellator* tessellator, inkBox* previousBox, INKvertex vA, INKvertex vB, float halfScalar, void* fill, bool start, bool end, inkPoint* outerAPtr, inkPoint *outerBPtr, inkPoint* innerIntersectionPtr)
{
	if (stroke == NULL)
		return inkBoxZero;

//	inkSolidFill solidFill;

#define inkDrawPointsPleaseA(p, color, a)\
	inkGeneratorInitVertex(&vA, p, fill);\
	inkTessellatorVertex(&vA, tessellator);

//#define inkDrawPointsPleaseA(p, color, a)\
	solidFill = inkSolidFillMake(color, a);\
	inkGeneratorInitVertex(&vA, p, &solidFill);\
	inkTessellatorVertex(&vA, tessellator);
#define inkDrawPointsPlease(p, color) inkDrawPointsPleaseA(p, color, 1.0f)

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

	//	inkPoint innerA = box.pointA;
	//	inkPoint innerB = previousBox->pointD;
		inkPoint outerA = box.pointC;
		inkPoint outerB = previousBox->pointB;
		if (inkPointIsEqual(outerA, outerB))
		{
			outerA = box.pointB;
			outerB = previousBox->pointC;
		}

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
		/*if (inkIsPointInLine(innerIntersection, lineAD) == false)
		{
			// TODO: swap innerA with outerA, and innerB with outerB
			inkPoint tempPoint = innerIntersection;
			innerIntersection = outerIntersection;
			outerIntersection = tempPoint;
		//	lineADIsInner = true;
		}*/

		if (outerAPtr)
			*outerAPtr = outerA;
		if (outerBPtr)
			*outerBPtr = outerB;
		if (innerIntersectionPtr)
			*innerIntersectionPtr = innerIntersection;

		switch(stroke->joints)
		{
			case inkJointStyle_Miter:
				inkGeneratorInitVertex(&vA, innerIntersection, fill);
				inkTessellatorVertex(&vA, tessellator);
				inkGeneratorInitVertex(&vA, outerIntersection, fill);
				inkTessellatorVertex(&vA, tessellator);
				break;
			case inkJointStyle_Bevel:
				break;
			case inkJointStyle_Round:
			{
			//	inkDrawPointsPleaseA(outerA, 0xFF0000, 1.0f);
			//	inkDrawPointsPleaseA(outerB, 0x00FF00, 1.0f);
			//	inkDrawPointsPlease(innerIntersection, 0x0000FF);

			//	float angleA = inkPointAngle(outerA, innerIntersection);
			//	float angleB = inkPointAngle(outerB, innerIntersection);
				float angleA = inkPointAngle(innerIntersection, outerA);
				float angleB = inkPointAngle(innerIntersection, outerB);

				while (angleA < 0.0f)
				{
					angleA += M_PI * 2.0f;
				}

				while (angleB < 0.0f)
				{
					angleB += M_PI * 2.0f;
				}

				float angleDist = inkPointDistance(outerA, innerIntersection);
				//float angleBDist = inkPointDistance(outerB, innerIntersection);

			//	printf("angle dist = %f\n", angleDist);
				inkPoint pt0 = inkPointAdd(innerIntersection, inkPointFromPolar(angleDist, angleA));
				inkPoint pt1 = inkPointAdd(innerIntersection, inkPointFromPolar(angleDist, angleB));

				if (angleB > angleA)
				{
					float temp = angleA;
					angleA = angleB;
					angleB = temp;

					inkPoint ptTemp = pt0;
					pt0 = pt1;
					pt1 = ptTemp;
				}

			//	inkPoint pt0 = inkPointFromPolar(innerOuterDist, angleA);
			//	inkPoint pt1 = inkPointFromPolar(innerOuterDist, angleB);

			//	inkDrawPointsPleaseA(pt0, 0x800000, 0.5f);
			//	inkDrawPointsPleaseA(pt1, 0x008000, 0.5f);

			//	inkDrawPointsPlease(innerIntersection, 0xFFFFFF);

				float precisionPoints = 1.0f;
				float diff = angleA - angleB;
				float add = diff / (precisionPoints + 1.0f);

		//		inkDrawPointsPlease(innerIntersection, 0xFFFFFF);
		//		inkDrawPointsPlease(outerB, 0xFFFFFF);

				pt0 = outerB;
				for (float prevAngle = angleB, angle = prevAngle + add; angle < angleA; prevAngle = angle, angle += add)
				{
				//	pt0 = inkPointAdd(innerIntersection, inkPointFromPolar(angleDist, prevAngle));
					pt1 = inkPointAdd(innerIntersection, inkPointFromPolar(angleDist, angle));

					inkDrawPointsPlease(innerIntersection, 0xFFFFFF);
					inkDrawPointsPlease(pt0, 0xFFFFFF);
					inkDrawPointsPlease(pt1, 0xFFFFFF);
					pt0 = pt1;
				}

			///	inkDrawPointsPlease(outerA, 0xFFFFFF);

				inkDrawPointsPlease(innerIntersection, 0xFFFFFF);
				//inkDrawPointsPlease(innerIntersection, 0xFFFFFF);
				inkDrawPointsPlease(outerA, 0xFFFFFF);

				break;

				/*inkGeneratorInitVertex(&vA, outerA, fill);
				inkTessellatorVertex(&vA, tessellator);
				
				inkGeneratorInitVertex(&vA, innerIntersection, fill);
				inkTessellatorVertex(&vA, tessellator);

				float angleA = atan2f(innerIntersection.y - outerA.y, innerIntersection.x - outerA.x);
				float angleB = atan2f(innerIntersection.y - outerB.y, innerIntersection.x - outerB.x);

				while (angleA < 0.0f)
				{
					angleA += M_PI * 2.0f;
				}
				while (angleB < 0.0f)
				{
					angleB += M_PI * 2.0f;
				}

				float innerOuterDist = inkPointDistance(outerA, innerIntersection);

				if (angleB > angleA)
				{
					float temp = angleA;
					angleA = angleB;
					angleB = temp;
				}

				float precisionPoints = 5.0f;
				float diff = angleA - angleB;
				float add = diff / precisionPoints;

				inkPoint pt0;
				inkPoint pt1;

				printf("start angle = %f\n", angleA * 180.0f / 3.14159f);
				printf("end angle = %f\n", angleB * 180.0f / 3.14159f);
				
				for (float prevAngle = angleB, angle = prevAngle + add; angle < angleA; angle += add)
				{
					printf("angle = %f\n", angle * 180.0f / 3.14159f);

					pt0 = inkPointAdd(inkPointFromPolar(innerOuterDist, prevAngle), innerIntersection);
					pt1 = inkPointAdd(inkPointFromPolar(innerOuterDist, angle), innerIntersection);

					inkGeneratorInitVertex(&vA, innerIntersection, fill);
					inkTessellatorVertex(&vA, tessellator);

					inkGeneratorInitVertex(&vA, pt0, fill);
					inkTessellatorVertex(&vA, tessellator);

					inkGeneratorInitVertex(&vA, pt1, fill);
					inkTessellatorVertex(&vA, tessellator);
				}
				printf("\n");

				inkGeneratorInitVertex(&vA, innerIntersection, fill);
				inkTessellatorVertex(&vA, tessellator);*/
			}
				break;
			default:
				break;
		}
/*
	//	if (lineADIsInner == true)
	//		inkGeneratorInitVertex(&vA, intersectAD, fill);
	//	else
	//		inkGeneratorInitVertex(&vA, intersectBC, fill);

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
//	inkTessellatorBegin(GL_LINE_LOOP, tessellator);
//	inkTessellatorBegin(GL_LINE_STRIP, tessellator);
//	inkTessellatorBegin(GL_POINTS, tessellator);

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

	vA = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, 0)));
	vB = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 1)));

	bool closedLoop = inkIsEqualf(vA.x, vB.x) && inkIsEqualf(vA.y, vB.y);
	bool start = count == 2;
	bool end = start || !closedLoop;
	bool has = false;

	inkPoint outerA;
	inkPoint outerB;
	inkPoint innerIntersection;

	// If count is 2, which is the minimum (it will be a line), then a will be 0
	// and b will be 1
	vA = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 2)));
	//vB = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 1)));

	previousBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, NULL, NULL, NULL);

	if (count > 2)
	{
		previousBoxPtr = &previousBox;

		vA = vB;

		unsigned int index = 0;

		start = false;
		end = false;

		// TODO:	inkTessellatorVertex copies the vertex right now, make sure
		//			this will ALWAYS be the case, or this will fail.
		inkArrayForEach(generator->currentVertices, vertex)
		{
			vB = *vertex;

			if (closedLoop)
			{
				if (index == 0)
				{
					vA = vB;
					++index;
					continue;
				}
				if (index == count - 1)
				{
					previousBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, NULL, NULL, NULL);
				//	vA = vB;
					break;
				}
			}
			else
			{
				start = (index == 0);
				end = (index == count - 1);
			}

			if (has == false)
			{
				has = true;
				previousBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, &outerA, &outerB, &innerIntersection);
			}
			else
				previousBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, NULL, NULL, NULL);

			vA = vB;
			++index;
		//	break;
		}

		if (closedLoop)
		{
			inkGeneratorInitVertex(&vA, innerIntersection, fill);
			inkTessellatorVertex(&vA, tessellator);
			inkGeneratorInitVertex(&vA, outerB, fill);
			inkTessellatorVertex(&vA, tessellator);
		//	vB = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, 0)));
		//	inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end);
		}
	}

//	vB = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, 0)));
//	previousBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end);;

	inkTessellatorEnd(tessellator);
	generator->currentVertices = NULL;
}

void inkStrokeGeneratorEndConvert(void* generator)
{
	inkStrokeGeneratorEnd((inkStrokeGenerator*)generator);
}
