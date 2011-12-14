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
#include "inkVectorGraphics.h"

// Anything less than 5 degrees will just be a line.
//const float inkStrokeGeneratorRoundAngleEpsilon = M_PI / (180 / 5);

typedef struct
{
	inkArray* vertices; // Weak
	void* fill; // Weak
} inkStrokeGeneratorRasterizeObject;

inkInline inkStrokeGeneratorRasterizeObject inkStrokeGeneratorRasterizeObjectMake(inkArray* vertices, void* fill)
{
	inkStrokeGeneratorRasterizeObject object;

	object.vertices = vertices;
	object.fill = fill;

	return object;
}

void inkStrokeGeneratorEndRasterizeGroup(inkStrokeGenerator* strokeGenerator, inkStrokeGeneratorRasterizeObject* rasterizeObject);
void inkStrokeGeneratorEndConcat(void* generator);

inkStrokeGenerator* inkStrokeGeneratorCreate(inkTessellator* tessellator, inkCanvas* canvas, inkArray *renderGroups, inkStroke* stroke)
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

		strokeGenerator->rasterizeGroups = inkArrayCreate(sizeof(inkStrokeGeneratorRasterizeObject));
		if (strokeGenerator->rasterizeGroups == NULL)
		{
			inkStrokeGeneratorDestroy(strokeGenerator);
			return NULL;
		}

		strokeGenerator->generator = generator;
		strokeGenerator->stroke = stroke;
		strokeGenerator->canvas = canvas;

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

			inkArrayDestroy(strokeGenerator->rasterizeGroups);
			inkGeneratorDestroy(strokeGenerator->generator);
		}

		free(strokeGenerator);
	}
}

void inkStrokeGeneratorSetFill(inkStrokeGenerator* strokeGenerator, void* fill)
{
	if (strokeGenerator == NULL || strokeGenerator->generator == NULL)
		return;

	inkStrokeGeneratorEndConcat(strokeGenerator);

	strokeGenerator->generator->fill = fill;
	inkTessellatorSetGLData(strokeGenerator->generator->tessellator, inkFillUpdateGLData(fill, inkTessellatorGetGLData(strokeGenerator->generator->tessellator)));
}

void inkStrokeGeneratorMoveTo(inkStrokeGenerator* strokeGenerator, inkPoint position)
{
	if (strokeGenerator == NULL)
		return;

	inkGeneratorMoveTo(strokeGenerator->generator, position, inkStrokeGeneratorEndConcat, strokeGenerator);
}

void inkStrokeGeneratorLineTo(inkStrokeGenerator* strokeGenerator, inkPoint position)
{
	if (strokeGenerator == NULL)
		return;

	inkGeneratorLineTo(strokeGenerator->generator, position);
}

inkInline void inkStrokeGeneratorAddDrawPoint(inkPoint point, inkTessellator* tessellator, void* fill)
{
	INKvertex vertex;

	inkGeneratorInitVertex(&vertex, point, fill);
	inkTessellatorVertex(&vertex, tessellator);
}

void inkStrokeGeneratorRound(inkTessellator* tessellator, inkCanvas* canvas, void* fill, inkPoint pivotPoint, inkPoint startPoint, float startAngle, float angleDiff, float angleDist)
{
//	return;
//	if (angleDiff < inkStrokeGeneratorRoundAngleEpsilon)
//		return;

	float arcLength = 2.0f * M_PI * angleDist * fabsf(angleDiff / M_PI);
	// guaranteed to at lest return 2.
	unsigned int segmentCount = inkArcLengthSegmentCount(canvas, arcLength);
	//float add = angleDiff / ((float)inkStrokeGeneratorRoundPrecisionPoints + 1.0f);
	float add = angleDiff / ((float)segmentCount);

	inkPoint pt0 = startPoint;
	inkPoint pt1;

	float angle = startAngle + add;

	unsigned int index;
	for (index = 0; index < segmentCount; ++index, angle += add)
	{
		pt1 = inkPointAdd(pivotPoint, inkPointFromPolar(angleDist, angle));

		inkStrokeGeneratorAddDrawPoint(pivotPoint, tessellator, fill);
		inkStrokeGeneratorAddDrawPoint(pt0, tessellator, fill);
		inkStrokeGeneratorAddDrawPoint(pt1, tessellator, fill);
		pt0 = pt1;
	}
}

void inkStrokeGeneratorCap(inkCapsStyle style, inkTessellator* tessellator, inkCanvas* canvas, void* fill, inkPoint pivot, inkPoint ptA, inkPoint ptB, bool reverseAngle)
{
	inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);
	inkStrokeGeneratorAddDrawPoint(ptB, tessellator, fill);
	inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);

	if (style != inkCapsStyle_None)
	{
		float angle = reverseAngle ? -M_PI : M_PI;
		float angleA = inkPointAngle(pivot, ptA);
		float angleDist = inkPointDistance(ptA, pivot);

		switch(style)
		{
			case inkCapsStyle_None:
				break;
			case inkCapsStyle_Round:
				inkStrokeGeneratorRound(tessellator, canvas, fill, pivot, ptA, angleA, angle, angleDist);

				inkStrokeGeneratorAddDrawPoint(pivot, tessellator, fill);
				inkStrokeGeneratorAddDrawPoint(ptB, tessellator, fill);
				inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);

				break;
			case inkCapsStyle_Square:
			{
				inkPoint addPt = inkPointFromPolar(angleDist, angleA + (angle * 0.5f));

				inkPoint outerA = inkPointAdd(ptA, addPt);
				inkPoint outerB = inkPointAdd(ptB, addPt);

				inkStrokeGeneratorAddDrawPoint(outerB, tessellator, fill);
				inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
				inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);

				inkStrokeGeneratorAddDrawPoint(ptB, tessellator, fill);
				inkStrokeGeneratorAddDrawPoint(ptA, tessellator, fill);
			}
				break;
			default:
				break;
		}
	}
}

bool inkStrokeGeneratorAdd(inkStroke* stroke, inkTessellator* tessellator, inkCanvas* canvas, inkBox* previousBox, inkBox* nowBox, INKvertex vA, INKvertex vB, float halfScalar, void* fill, bool start, bool end, inkPoint *lastPointPtr, inkPoint* innerIntersectionPtr, bool clockwise)
{
	inkBox box = inkBoxZero;

	// Needs to be declared and set prior to using the goto.
	bool flip = false;
	bool reverseCaps;
	bool innerOuterSwitch;

	if (stroke == NULL)
		goto returnStatement;

	if (previousBox != NULL && vA.x == vB.x && vA.y == vB.y)
	{
		inkPoint mid = inkPointScale(inkPointAdd(previousBox->pointC, previousBox->pointD), 0.5f);
		vA.x = mid.x;
		vA.y = mid.y;
	}

	if (vA.x == vB.x && vA.y == vB.y)
		goto returnStatement;

	inkPoint ptA = inkPointMake(vA.x, vA.y);
	inkPoint ptB = inkPointMake(vB.x, vB.y);
	inkPoint tempPoint;

	box = inkLineExpandToBox(inkLineMake(ptA, ptB), halfScalar);

	float baAngle = inkPointAngle(ptA, ptB);
	reverseCaps = (baAngle >= 0.0f) ^ ~clockwise;

	if (start == true)
	{
		inkStrokeGeneratorCap(stroke->caps, tessellator, canvas, fill, ptA, box.pointD, box.pointC, reverseCaps);
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
			if (reverseCaps)
			{
				innerIntersection = previousBox->pointB;
				outerIntersection = box.pointC;
			}
			else
			{
				outerIntersection = previousBox->pointA;
				innerIntersection = box.pointD;
			}
		}
		else
		{
			outerIntersection = inkLineIntersection(lineBC, linePreviousBC);
		}

		inkLine lineAB = inkLineMake(box.pointA, box.pointB);
		inkLine linePreviousCD = inkLineMake(previousBox->pointC, previousBox->pointD);

		inkPoint abInnerIntersection = inkLineIntersection(lineAB, linePreviousCD);

		inkLine lineCD = inkLineMake(box.pointC, box.pointD);
		inkLine linePreviousAB = inkLineMake(previousBox->pointA, previousBox->pointB);

		inkPoint cdOuterIntersection = inkLineIntersection(lineCD, linePreviousAB);

		// Is our inner really our outer?
		float innerIntersectionDist = inkPointDistanceToLine(innerIntersection, lineAD);
		float outerIntersectionDist = inkPointDistanceToLine(outerIntersection, lineBC);

		innerOuterSwitch = innerIntersectionDist > outerIntersectionDist;

		if (innerOuterSwitch == true)
		{
			tempPoint = innerIntersection;
			innerIntersection = outerIntersection;
			outerIntersection = tempPoint;

			tempPoint = innerA;
			innerA = outerA;
			outerA = tempPoint;

			tempPoint = innerB;
			innerB = outerB;
			outerB = tempPoint;

			float temp = innerIntersectionDist;
			innerIntersectionDist = outerIntersectionDist;
			outerIntersectionDist = temp;
		}
		else
		{
			flip = !flip;
		}

	//	if (isInnerZero == false && isOuterZero == false)
		{
			if (reverseCaps == true)
			{
				float innerXIntersectionDist = inkPointDistanceToLine(abInnerIntersection, lineAB);

			//	if (inkIsPointInLine(abInnerIntersection, lineAB) == true)
				if (inkIsEqualf(innerXIntersectionDist, innerIntersectionDist) == false && innerXIntersectionDist < innerIntersectionDist)
					innerIntersection = abInnerIntersection;
			}
			else
			{
				float outerXIntersectionDist = inkPointDistanceToLine(cdOuterIntersection, lineCD);

			//	if (inkIsPointInLine(cdOuterIntersection, lineCD) == true)
			//	if (outerXIntersectionDist < outerIntersectionDist)
				if (inkIsEqualf(outerXIntersectionDist, outerIntersectionDist) == false && outerXIntersectionDist < innerIntersectionDist)
					innerIntersection = cdOuterIntersection;
			}
		}

		float angleA = (inkPointAngle(pivotPt, outerA));
		float angleB = (inkPointAngle(pivotPt, outerB));

		float angleDist = inkPointDistance(outerA, pivotPt);

		float angleDiff = inkAngleOrient(angleA - angleB);

		if (inkIsEqualf(angleDiff, baAngle) == true && inkIsEqualf(angleDiff, M_PI) == true)
		{
			angleDiff = -angleDiff;
			//printf("angleDiff and baAngle are the same\n");
		}

		float innerDistFromPivot = inkPointDistance(pivotPt, innerIntersection);

		float d1 = inkPointDistance(box.pointB, box.pointC);
		float d2 = inkPointDistance(previousBox->pointB, previousBox->pointC);
		float ptDist = fminf(d1, d2);
		float maxInnerDistFromPivot = fmaxf(ptDist, angleDist + (cosf(M_PI * 0.25f) * angleDist));
		if (inkIsZerof(innerDistFromPivot) == false && innerDistFromPivot > maxInnerDistFromPivot)
		{
			float innerDistScale = maxInnerDistFromPivot / innerDistFromPivot;

			innerIntersection = inkPointInterpolate(pivotPt, innerIntersection, innerDistScale);
		}

		if (isnan(angleDiff))
		{
			// Seriously, wtf happened?
		}

		float miter = stroke->miterLimit;
		if (stroke->joints == inkJointStyle_Bevel)
		{
			miter = (M_PI - fabsf(angleDiff)) / M_PI;
		}

		if (flip)
		{
			inkStrokeGeneratorAddDrawPoint(outerB, tessellator, fill);
			inkStrokeGeneratorAddDrawPoint(innerB, tessellator, fill);
			inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
			inkStrokeGeneratorAddDrawPoint(innerA, tessellator, fill);
		}
		else
		{
			inkStrokeGeneratorAddDrawPoint(innerB, tessellator, fill);
			inkStrokeGeneratorAddDrawPoint(outerB, tessellator, fill);
			inkStrokeGeneratorAddDrawPoint(innerA, tessellator, fill);
			inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
		}

	//	inkStrokeGeneratorAddDrawPoint(innerA, tessellator, fill);
	//	inkStrokeGeneratorAddDrawPoint(innerB, tessellator, fill);
		/*(if (true)
		{
			if (flip)
			{
				localLastPointPtr = &outerB;
				innerIntersection = innerB;
			}
			else
			{
				localLastPointPtr = &outerB;
				innerIntersection = innerB;
			}

			if (lastPointPtr)
				*lastPointPtr = *localLastPointPtr;
			if (innerIntersectionPtr)
				*innerIntersectionPtr = innerIntersection;
		}
		goto endStatement;*/

		switch(stroke->joints)
		{
			// Let bevel fall into miter, I changed the miter limit for this
			case inkJointStyle_Bevel:
			case inkJointStyle_Miter:
			{
				float maxDist = stroke->thickness * miter;

				if (inkIsZerof(innerIntersectionDist) && inkIsZerof(outerIntersectionDist))
				{
					// Arbitrary value of 65536x larger, as in reality it is
					// infinately far away in this case.
					const float multiplier = 65536.0f;
					innerIntersection = inkPointInterpolate(ptB, ptA, -multiplier);
					outerIntersection = inkPointInterpolate(ptB, ptA,  multiplier);
				}

				float dist = inkPointDistance(pivotPt, outerIntersection);

				float percentDist = maxDist / dist;
				if (percentDist > 1.0f)
					percentDist = 1.0f;

				if (flip)
				{
					inkStrokeGeneratorAddDrawPoint(innerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(outerB, tessellator, fill);

					inkPoint nA = inkPointInterpolate(outerA, outerIntersection, percentDist);
					inkPoint nB = inkPointInterpolate(outerB, outerIntersection, percentDist);

					inkStrokeGeneratorAddDrawPoint(nA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(nB, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(nB, tessellator, fill);

					inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(innerA, tessellator, fill);
				}
				else
				{
					inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(outerB, tessellator, fill);
					
					inkPoint nA = inkPointInterpolate(outerA, outerIntersection, percentDist);
					inkPoint nB = inkPointInterpolate(outerB, outerIntersection, percentDist);
					
					inkStrokeGeneratorAddDrawPoint(nA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(nB, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(nB, tessellator, fill);

					inkStrokeGeneratorAddDrawPoint(innerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(innerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
				}

				localLastPointPtr = &outerB;
				innerIntersection = innerB;
			}
				break;
			case inkJointStyle_Round:
			{
				// TODO:	Check the angleDiff and see if there is actually a
				//			need to do anything here, other then set the local
				//			points that is.

				if (flip)
				{
					inkStrokeGeneratorAddDrawPoint(innerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
					inkStrokeGeneratorRound(tessellator, canvas, fill, pivotPt, outerB, angleB, angleDiff, angleDist);
				}
				else
				{
					inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(outerB, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(outerB, tessellator, fill);
					inkStrokeGeneratorRound(tessellator, canvas, fill, pivotPt, outerB, angleB, angleDiff, angleDist);
				}

				inkStrokeGeneratorAddDrawPoint(pivotPt, tessellator, fill);

				if (flip)
				{
					inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(innerA, tessellator, fill);
				}
				else
				{
					inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(innerA, tessellator, fill);
					inkStrokeGeneratorAddDrawPoint(outerA, tessellator, fill);
				}

				localLastPointPtr = &outerB;
				innerIntersection = innerB;
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

endStatement:
	if (end == true)
	{
		inkStrokeGeneratorCap(stroke->caps, tessellator, canvas, fill, ptB, box.pointB, box.pointA, reverseCaps);
	}

returnStatement:
	if (nowBox != NULL)
		*nowBox = box;

	return flip;
}

void inkStrokeGeneratorEnd(inkStrokeGenerator* strokeGenerator)
{
	if (strokeGenerator == NULL|| strokeGenerator->generator == NULL || strokeGenerator->generator->currentVertices == NULL || strokeGenerator->generator->tessellator == NULL || strokeGenerator->stroke == NULL)
	{
		return;
	}

	inkStrokeGeneratorRasterizeObject obj = inkStrokeGeneratorRasterizeObjectMake(strokeGenerator->generator->currentVertices, strokeGenerator->generator->fill);
	inkStrokeGeneratorEndRasterizeGroup(strokeGenerator, &obj);
}

void inkStrokeGeneratorEndRasterizeGroup(inkStrokeGenerator* strokeGenerator, inkStrokeGeneratorRasterizeObject* rasterizeObject)
{
	if (strokeGenerator == NULL || rasterizeObject == NULL || strokeGenerator->generator == NULL || rasterizeObject->vertices == NULL || strokeGenerator->generator->tessellator == NULL || strokeGenerator->stroke == NULL)
	{
		return;
	}

	if (isnan(strokeGenerator->stroke->thickness))
		return;

	inkArray* vertices = rasterizeObject->vertices;

	inkGenerator* generator = strokeGenerator->generator;
	inkTessellator* tessellator = generator->tessellator;

	inkTessellatorSetGLData(tessellator, inkFillUpdateGLData(strokeGenerator->generator->fill, inkTessellatorGetGLData(tessellator)));

	inkTessellatorBegin(GL_TRIANGLE_STRIP, tessellator);
//	inkTessellatorBegin(GL_LINE_LOOP, tessellator);
//	inkTessellatorBegin(GL_LINE_STRIP, tessellator);
//	inkTessellatorBegin(GL_POINTS, tessellator);

	INKvertex* vertex;

	void* fill = rasterizeObject->fill;

	INKvertex vA;
	INKvertex vB;

	inkBox previousBox;
	inkBox* previousBoxPtr = NULL;

	float halfScalar = strokeGenerator->stroke->thickness * 0.5f;

	unsigned int count = inkArrayCount(vertices);

	if (count <= 1)
		return;

	vA = *((INKvertex *)(inkArrayElementAt(vertices, 0)));
	vB = *((INKvertex *)(inkArrayElementAt(vertices, count - 1)));

	bool closedLoop = inkIsEqualf(vA.x, vB.x) && inkIsEqualf(vA.y, vB.y);
	bool start = count == 2;
	bool end = start || !closedLoop;
	bool has = false;

	inkPoint lastPoint;
	inkPoint innerIntersection;

	if (closedLoop)
	{
		if (count == 2)
			return;

		vA = *((INKvertex *)(inkArrayElementAt(vertices, count - 2)));
	}
	else
	{
		vA = vB;
	}

	bool clockwise;
	bool testHas = false;
	bool flipFirst = false;

	inkBox testBox = inkBoxZero;

	//if (count > 2)
	{
		vA = vB;

		unsigned int index = 0;

		if (closedLoop)
		{
			start = false;
			end = false;
		}

		float sum = 0.0f;
		INKvertex previousVertex = *((INKvertex *)(inkArrayElementAt(vertices, 0)));

		unsigned int startIndex = 1;
		bool dontIncreaseStartIndex = false;

		inkArrayForEach(vertices, vertex)
		{
			if (index++ == 0)
			{
				continue;
			}

			if (dontIncreaseStartIndex == false && previousVertex.x == vertex->x && previousVertex.y == vertex->y)
			{
				++startIndex;
				continue;
			}
			else
			{
				dontIncreaseStartIndex = true;
			}

			sum += (vertex->x - previousVertex.x) * (vertex->y + previousVertex.y);
			previousVertex = *vertex;
		}

		clockwise = sum >= 0.0f;

		index = 0;

		// TODO:	inkTessellatorVertex copies the vertex right now, make sure
		//			this will ALWAYS be the case, or this will fail.
		inkArrayForEach(vertices, vertex)
		{
			vB = *vertex;

			if (index < startIndex)
				goto continueStatement;

			if (closedLoop == false)
			{
				start = (index == startIndex);
				end = (index == count - 1);
			}

			if (has == true || index == startIndex)
			{
				inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, strokeGenerator->canvas, previousBoxPtr, &testBox, vA, vB, halfScalar, fill, start, end, NULL, NULL, clockwise);
				previousBoxPtr = &previousBox;
			}
			else
			{
				testHas = true;
				flipFirst = inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, strokeGenerator->canvas, previousBoxPtr, &testBox, vA, vB, halfScalar, fill, start, end, &lastPoint, &innerIntersection, clockwise);
			}

			if (inkBoxIsEqual(testBox, inkBoxZero) == false)
			{
				previousBox = testBox;
				if (testHas == true)
				{
					testHas = false;
					has = true;
				}
			}
			else if (testHas == true)
			{
				testHas = false;
				has = false;
			}

		continueStatement:
			vA = vB;
			++index;
		}

		if (closedLoop)
		{
			vB = *((INKvertex *)(inkArrayElementAt(vertices, startIndex)));
			inkStrokeGeneratorAdd(strokeGenerator->stroke, tessellator, strokeGenerator->canvas, previousBoxPtr, NULL, vA, vB, halfScalar, fill, false, false, NULL, NULL, clockwise);

			// ROOT of the closed loop issue, need to look into it.
			if (flipFirst == true)
			{
				inkGeneratorInitVertex(&vA, lastPoint, fill);
				inkTessellatorVertex(&vA, tessellator);
			}

			inkGeneratorInitVertex(&vA, innerIntersection, fill);
			inkTessellatorVertex(&vA, tessellator);

			if (flipFirst == false)
			{
				inkGeneratorInitVertex(&vA, lastPoint, fill);
				inkTessellatorVertex(&vA, tessellator);
			}
		}
	}

	inkTessellatorEnd(tessellator);
}

void inkStrokeGeneratorEndConcat(void* generator)
{
	inkStrokeGeneratorEnd((inkStrokeGenerator*)generator);
}
