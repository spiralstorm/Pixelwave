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

inkInline inkBox inkStrokeGeneratorAdd(inkStroke* stroke, inkTessellator* tessellator, inkBox* previousBox, INKvertex vA, INKvertex vB, float halfScalar, void* fill, bool start, bool end, inkPoint* outerAPtr, inkPoint *outerBPtr, inkPoint* innerIntersectionPtr)
{
	if (stroke == NULL)
		return inkBoxZero;
	if (vA.x == vB.x && vA.y == vB.y)
		return inkBoxZero;

//	inkSolidFill solidFill;

#define inkDrawPointsPleaseA(p, color, a)\
	inkGeneratorInitVertex(&vA, p, fill);\
	inkTessellatorVertex(&vA, tessellator);

//#define inkDrawPointsPleaseA(p, color, a)\
	solidFill = inkSolidFillMake(, a);\
	inkGeneratorInitVertex(&vA, p, &solidFill);\
	inkTessellatorVertex(&vA, tessellator);
//#define inkDrawPointsPleaseA(p, color, a)\
	solidFill = inkSolidFillMake(color, a);\
	inkGeneratorInitVertex(&vA, p, &solidFill);\
	inkTessellatorVertex(&vA, tessellator);
#define inkDrawPointsPlease(p, color) inkDrawPointsPleaseA(p, color, 1.0f)

	inkPoint ptA = inkPointMake(vA.x, vA.y);
	inkPoint ptB = inkPointMake(vB.x, vB.y);

	inkPoint curvePt = ptA;

	inkBox box = inkLineExpandToBox(inkLineMake(ptA, ptB), halfScalar);
	if (previousBox != NULL)
	{
		inkPoint innerA = box.pointD;
		inkPoint innerB = previousBox->pointA;
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
			printf("intersection is nan between lineAD((%f, %f), (%f, %f)) and linePreviousAD((%f, %f), (%f, %f))\n",
				   lineAD.pointA.x, lineAD.pointA.y, lineAD.pointB.x, lineAD.pointB.y,
				   linePreviousAD.pointA.x, linePreviousAD.pointA.y, linePreviousAD.pointB.x, linePreviousAD.pointB.y);
			//return inkBoxZero;
			// TODO:	Handle a straight (or parallel) line at some point in
			//			the future.

			// NOTE:	This only needs to be done by either AD or BC
		}

		outerIntersection = inkLineIntersection(lineBC, linePreviousBC);

		// Is our inner really our outer?
		if (inkIsPointInLine(innerIntersection, lineAD) == false)
		{
			inkPoint tempPoint = innerIntersection;
			innerIntersection = outerIntersection;
			outerIntersection = tempPoint;

			tempPoint = innerA;
			innerA = outerA;
			outerA = tempPoint;

			tempPoint = innerB;
			innerB = outerB;
			outerB = tempPoint;
		}

		if (outerAPtr)
			*outerAPtr = outerA;
		if (outerBPtr)
			*outerBPtr = outerB;
		if (innerIntersectionPtr)
			*innerIntersectionPtr = innerIntersection;

		float angleA = (inkPointAngle(curvePt, outerA));
		float angleB = (inkPointAngle(curvePt, outerB));

		float angleDist = inkPointDistance(outerA, curvePt);

		inkPoint pt0;
		inkPoint pt1;

		float angleDiff = inkAngleOrient(angleA - angleB);

		//printf("diff is %f; a = %f, b = %f\n", angleDiff * 180.0f / M_PI, angleA * 180.0f / M_PI, angleB * 180.0f / M_PI);
		if (isnan(angleDiff))
		{
			
		}

		float miter = stroke->miterLimit;
		if (stroke->joints == inkJointStyle_Bevel)
		{
			miter = (M_PI - angleDiff) / M_PI;
		}

		switch(stroke->joints)
		{
			/// Let bevel fall into miter, I changed the miter limit for this
			case inkJointStyle_Bevel:
			case inkJointStyle_Miter:
			{
				float dist = inkPointDistance(curvePt, outerIntersection);
				float maxDist = stroke->thickness * miter;

				float percentDist = dist / maxDist;

				outerA = inkPointInterpolate(outerA, outerIntersection, percentDist);
				outerB = inkPointInterpolate(outerB, outerIntersection, percentDist);

				if (inkIsEqualf(percentDist, 1.0f))
				{
					inkDrawPointsPlease(innerIntersection, 0xFF0000);
					inkDrawPointsPlease(outerIntersection, 0x00FF00);
				}
				else
				{
					inkDrawPointsPlease(innerIntersection, 0xFF0000);
					inkDrawPointsPlease(outerA, 0x00FF00);
					inkDrawPointsPlease(outerB, 0x0000FF);
				}
			}
				break;
			case inkJointStyle_Round:
			{
				unsigned int precisionPoints = 1;
				float add = angleDiff / ((float)precisionPoints + 1.0f);

				inkDrawPointsPlease(innerIntersection, 0x00FF00);
				inkDrawPointsPlease(outerB, 0x0000FF);

				pt0 = outerB;
				float angle = angleB + add;

				for (unsigned int index = 0; index < precisionPoints; ++index, angle += add)
				{
					pt1 = inkPointAdd(curvePt, inkPointFromPolar(angleDist, angle));

					inkDrawPointsPlease(curvePt, 0x000000);
					inkDrawPointsPlease(pt0, 0xFFFFFF);
					inkDrawPointsPlease(pt1, 0xFFFFFF);
					pt0 = pt1;
				}

				inkDrawPointsPlease(curvePt, 0x00FF00);
				inkDrawPointsPlease(outerA, 0xFF0000);
				inkDrawPointsPlease(innerIntersection, 0x00FF00);
				inkDrawPointsPlease(outerA, 0xFF0000);
			}
				break;
			default:
				break;
		}
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

	inkBox testBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, NULL, NULL, NULL);

	if (count > 2)
	{
		previousBox = testBox;
		previousBoxPtr = &previousBox;

		vA = vB;

		unsigned int index = 0;

		start = false;
		end = false;

		// TODO:	inkTessellatorVertex copies the vertex right now, make sure
		//			this will ALWAYS be the case, or this will fail.
		inkArrayForEach(generator->currentVertices, vertex)
		{
			if (inkBoxIsEqual(testBox, inkBoxZero) == false)
			{
				previousBox = testBox;
			}

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
					testBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, NULL, NULL, NULL);
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
				testBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, &outerA, &outerB, &innerIntersection);
				has = !inkBoxIsEqual(testBox, inkBoxZero);
			}
			else
				testBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, NULL, NULL, NULL);

			vA = vB;
			++index;
		}

		if (closedLoop)
		{
			inkGeneratorInitVertex(&vA, innerIntersection, fill);
			inkTessellatorVertex(&vA, tessellator);
			inkGeneratorInitVertex(&vA, outerB, fill);
			inkTessellatorVertex(&vA, tessellator);
		}
	}

	inkTessellatorEnd(tessellator);
	generator->currentVertices = NULL;
}

void inkStrokeGeneratorEndConvert(void* generator)
{
	inkStrokeGeneratorEnd((inkStrokeGenerator*)generator);
}
