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

inkInline void inkStrokeGeneratorAddDrawPoint(inkPoint point, inkTessellator* tessellator, void* fill)
{
	INKvertex vertex;

	inkGeneratorInitVertex(&vertex, point, fill);
	inkTessellatorVertex(&vertex, tessellator);
}

void inkStrokeGeneratorRound(inkTessellator* tessellator, void* fill, inkPoint pivotPoint, inkPoint startPoint, float startAngle, float angleDiff, float angleDist)
{
	unsigned int precisionPoints = 2;
	float add = angleDiff / ((float)precisionPoints + 1.0f);

	inkPoint pt0 = startPoint;
	inkPoint pt1;

	float angle = startAngle + add;

	unsigned int index;
	for (index = 0; index < precisionPoints; ++index, angle += add)
	{
		pt1 = inkPointAdd(pivotPoint, inkPointFromPolar(angleDist, angle));

		inkStrokeGeneratorAddDrawPoint(pivotPoint, tessellator, fill);
		inkStrokeGeneratorAddDrawPoint(pt0, tessellator, fill);
		inkStrokeGeneratorAddDrawPoint(pt1, tessellator, fill);
		pt0 = pt1;
	}
}

void inkStrokeGeneratorCap(inkCapsStyle style, inkTessellator* tessellator, void* fill, inkPoint pivot, inkPoint ptA, inkPoint ptB, bool start)
{
	inkPoint pivotPt = pivot;

	float angleA = (inkPointAngle(pivotPt, ptA));
	float angleB = (inkPointAngle(pivotPt, ptB));

	float angleDist = inkPointDistance(ptA, pivotPt);

	float angleDiff = inkAngleOrient(angleA - angleB);

//	inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);
//	inkStrokeGeneratorAddDrawPoint(ptB, tessellator, fill);
//	inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);
//	inkStrokeGeneratorAddDrawPoint(pivotPt, tessellator, fill);
//	inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);
	inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);
	inkStrokeGeneratorAddDrawPoint(ptB, tessellator, fill);
	inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);

	inkStrokeGeneratorRound(tessellator, fill, pivotPt, ptA, angleA, start ? -angleDiff : angleDiff, angleDist);

	inkStrokeGeneratorAddDrawPoint(pivotPt, tessellator, fill);
//	inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);
	inkStrokeGeneratorAddDrawPoint(ptB, tessellator, fill);
	inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);
}

inkBox inkStrokeGeneratorAdd(inkStroke* stroke, inkTessellator* tessellator, inkBox* previousBox, INKvertex vA, INKvertex vB, float halfScalar, void* fill, bool start, bool end, inkPoint *lastPointPtr, inkPoint* innerIntersectionPtr, bool clockwise)
{
	if (stroke == NULL)
		return inkBoxZero;
	if (vA.x == vB.x && vA.y == vB.y)
		return inkBoxZero;

#define inkDrawPointsPleaseA(p, color, a) inkStrokeGeneratorAddDrawPoint(p, tessellator, fill)

#define inkDrawPointsPlease(p, color) inkDrawPointsPleaseA(p, color, 1.0f)

	inkPoint ptA = inkPointMake(vA.x, vA.y);
	inkPoint ptB = inkPointMake(vB.x, vB.y);

	inkBox box = inkLineExpandToBox(inkLineMake(ptA, ptB), halfScalar);

	if (start == true)
	{
		inkStrokeGeneratorCap(stroke->caps, tessellator, fill, ptA, box.pointC, box.pointD, true);
	}

	inkPoint pivotPt = ptA;

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

		inkPoint* localLastPointPtr = &outerB;

		inkLine linePreviousAD = inkLineMake(previousBox->pointD, previousBox->pointA);
		inkLine linePreviousBC = inkLineMake(previousBox->pointC, previousBox->pointB);
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
			//box = inkBoxConcat(*previousBox, box);
			//return box;
			//return inkBoxZero;
			// TODO:	Handle a straight (or parallel) line at some point in
			//			the future.

			// NOTE:	This only needs to be done by either AD or BC
			float distAB = inkPointDistance(lineAD.pointA, linePreviousAD.pointB);
			float distBA = inkPointDistance(lineAD.pointB, linePreviousAD.pointA);

			if (distAB < distBA)
			{
				innerIntersection = inkPointMultiply(inkPointAdd(lineAD.pointA, linePreviousAD.pointB), 0.5f);
				outerIntersection = inkPointMultiply(inkPointAdd(lineBC.pointA, linePreviousBC.pointB), 0.5f);
			}
			else
			{
				innerIntersection = inkPointMultiply(inkPointAdd(lineAD.pointB, linePreviousAD.pointA), 0.5f);
				outerIntersection = inkPointMultiply(inkPointAdd(lineBC.pointB, linePreviousBC.pointA), 0.5f);
			}

			inkDrawPointsPlease(innerIntersection, 0xFF0000);
			inkDrawPointsPlease(outerIntersection, 0x00FF00);
			return box;
		}
		else
			outerIntersection = inkLineIntersection(lineBC, linePreviousBC);

		/*float addist = inkPointDistanceToLine(innerIntersection, lineAD);
		float dadist = inkPointDistanceToLine(innerIntersection, linePreviousAD);
		float bcdist = inkPointDistanceToLine(outerIntersection, lineBC);
		float cbdist = inkPointDistanceToLine(outerIntersection, linePreviousBC);
		printf("addist = %f, daDist = %f, bcdist = %f, cbDist = %f - ", addist, dadist, bcdist, cbdist);*/

		// Is our inner really our outer?
		bool innerOuterSwitch = inkIsPointInLine(innerIntersection, lineAD);
		//if (inkIsPointInLine(innerIntersection, lineAD) == false)
		if (clockwise == false)//innerOuterSwitch == false)
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
		//	printf("opp\n");
		}
		/*else
		{
			// TODO:	WTF? Need to figure out why I need to do this, it
			//			logically shouldn't need to be done.
			inkPoint tempPoint = innerIntersection;
			innerIntersection = outerIntersection;
			outerIntersection = tempPoint;

			tempPoint = innerA;
			innerA = outerA;
			outerA = tempPoint;
			
			tempPoint = innerB;
			innerB = outerB;
			outerB = tempPoint;

			tempPoint = outerA;
			outerA = outerB;
			outerB = tempPoint;
		//	printf("not opp\n");
		}*/

		if (innerOuterSwitch != clockwise)
		{
			inkPoint tempPoint = outerA;
			outerA = outerB;
			outerB = tempPoint;
		}

		float angleA = (inkPointAngle(pivotPt, outerA));
		float angleB = (inkPointAngle(pivotPt, outerB));

		float angleDist = inkPointDistance(outerA, pivotPt);

		float angleDiff = inkAngleOrient(angleA - angleB);

		//printf("diff is %f; a = %f, b = %f\n", angleDiff * 180.0f / M_PI, angleA * 180.0f / M_PI, angleB * 180.0f / M_PI);
		if (isnan(angleDiff))
		{
			
		}

		//stroke->joints = inkJointStyle_Miter;
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
				float dist = inkPointDistance(pivotPt, outerIntersection);
				float maxDist = stroke->thickness * miter;

				float percentDist = maxDist / dist;
				percentDist = 0.1f;
				if (percentDist > 1.0f)
					percentDist = 1.0f;

				if (inkIsEqualf(percentDist, 1.0f))
				{
					inkDrawPointsPlease(innerIntersection, 0xFF0000);
					inkDrawPointsPlease(outerIntersection, 0x00FF00);
					localLastPointPtr = &outerIntersection;
				}
				else
				{
					outerA = inkPointInterpolate(outerA, outerIntersection, percentDist);
					outerB = inkPointInterpolate(outerB, outerIntersection, percentDist);

					inkDrawPointsPlease(innerIntersection, 0xFF0000);
					inkDrawPointsPlease(outerB, 0x0000FF);
					inkDrawPointsPlease(innerIntersection, 0xFF0000);
					inkDrawPointsPlease(outerA, 0x00FF00);
				}
			}
				break;
			case inkJointStyle_Round:
			{
				inkDrawPointsPlease(innerIntersection, 0x00FF00);
				inkDrawPointsPlease(outerB, 0x0000FF);

				inkStrokeGeneratorRound(tessellator, fill, pivotPt, outerB, angleB, angleDiff, angleDist);

				inkDrawPointsPlease(pivotPt, 0x00FF00);
				inkDrawPointsPlease(outerA, 0xFF0000);
				inkDrawPointsPlease(innerIntersection, 0x00FF00);
				inkDrawPointsPlease(outerA, 0xFF0000);
			}
				break;
			default:
				break;
		}

		if (lastPointPtr)
			*lastPointPtr = *localLastPointPtr;
		if (innerIntersectionPtr)
			*innerIntersectionPtr = innerIntersection;
	}

	if (end == true)
	{
		inkStrokeGeneratorCap(stroke->caps, tessellator, fill, ptB, box.pointA, box.pointB, false);
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

//	inkTessellatorBegin(GL_TRIANGLE_STRIP, tessellator);
//	inkTessellatorBegin(GL_LINE_LOOP, tessellator);
	inkTessellatorBegin(GL_LINE_STRIP, tessellator);
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

	inkPoint lastPoint;
	inkPoint innerIntersection;

	// If count is 2, which is the minimum (it will be a line), then a will be 0
	// and b will be 1
	//vA = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 2)));
	//vB = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 1)));

	if (closedLoop)
	{
		if (count == 2)
			return;

		vA = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, count - 2)));
	}
	else
	{
		vA = vB;
	}

	bool clockwise;

	inkBox testBox = inkBoxZero;//inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, NULL, NULL, false);

	//if (count > 2)
	{
	//	previousBox = testBox;
	//	previousBoxPtr = &previousBox;

		vA = vB;

		unsigned int index = 0;

	//	start = false;
	//	end = false;

		float sum = 0.0f;
		INKvertex previousVertex = *((INKvertex *)(inkArrayElementAt(generator->currentVertices, 0)));
		inkArrayForEach(generator->currentVertices, vertex)
		{
			if (index++ == 0)
				continue;

			sum += (vertex->x - previousVertex.x) * (vertex->y + previousVertex.y);
			previousVertex = *vertex;
		}

		clockwise = sum >= 0.0f;

		index = 0;

		// TODO:	inkTessellatorVertex copies the vertex right now, make sure
		//			this will ALWAYS be the case, or this will fail.
		inkArrayForEach(generator->currentVertices, vertex)
		{
			vB = *vertex;

			if (index == 0)
				goto continueStatement;

			if (closedLoop)
			{
			/*	if (index == 0)
				{
					vA = vB;
					++index;
					continue;
				}
				if (index == count - 1)
				{
					testBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, NULL, NULL, clockwise);
					break;
				}*/
			}
			else
			{
				start = (index == 1);
				end = (index == count - 1);
			}

			if (has == true || index == 1)
			{
				testBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, NULL, NULL, clockwise);
				previousBoxPtr = &previousBox;
			}
			else
			{
			//	has = true;
				testBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, &lastPoint, &innerIntersection, clockwise);
			//	has = !inkBoxIsEqual(testBox, inkBoxZero);
			}

			if (inkBoxIsEqual(testBox, inkBoxZero) == false)
			{
				previousBox = testBox;
				has = true;
			}

		//	else
		//		testBox = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, previousBoxPtr, vA, vB, halfScalar, fill, start, end, NULL, NULL, clockwise);
		continueStatement:
			vA = vB;
			++index;
		}

		if (closedLoop)
		{
			inkGeneratorInitVertex(&vA, innerIntersection, fill);
			inkTessellatorVertex(&vA, tessellator);
			inkGeneratorInitVertex(&vA, lastPoint, fill);
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
