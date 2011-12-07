//
//  inkVectorGraphicsUtils.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkVectorGraphicsUtils.h"

#include "inkTypes.h"
#include "inkVectorGraphics.h"

#define _inkVectorGraphicsUtilsCurveCount 8
const unsigned int inkVectorGraphicsUtilsCurveCount = _inkVectorGraphicsUtilsCurveCount;
const float inkVectorGraphicsUtilsPI_CurveCount = M_PI / (float)_inkVectorGraphicsUtilsCurveCount;

void inkDrawCircle(inkCanvas* canvas, inkPoint position, float radius)
{
	float doubleRadius = radius * 2.0f;
	inkDrawEllipse(canvas, inkRectMake(inkPointMake(position.x - radius, position.y - radius), inkSizeMake(doubleRadius, doubleRadius)));
}

void inkDrawEllipse(inkCanvas* canvas, inkRect boundingRect)
{
	inkSize halfBoundingSize = inkSizeMake(boundingRect.size.width * 0.5f, boundingRect.size.height * 0.5f);
	inkPoint position = inkPointAdd(boundingRect.origin, inkPointFromSize(halfBoundingSize));

	float stepAngle = M_PI * 2 / inkVectorGraphicsUtilsCurveCount;
	unsigned int index;

	inkMoveTo(canvas, inkPointAdd(position, inkPointFromElliptical(halfBoundingSize, 0.0f)));
	float one_cosfVal = 1.0f / cosf(inkVectorGraphicsUtilsPI_CurveCount);
	inkSize controlSize = inkSizeMake(halfBoundingSize.width * one_cosfVal, halfBoundingSize.height * one_cosfVal);

	for (index = 1; index <= inkVectorGraphicsUtilsCurveCount; ++index)
	{
		float angle = stepAngle * index;
		float controlAngle = angle - stepAngle * 0.5f;

		inkPoint control = inkPointAdd(position, inkPointFromElliptical(controlSize, controlAngle));
		inkPoint anchor = inkPointAdd(position, inkPointFromElliptical(halfBoundingSize, angle));
		inkCurveTo(canvas, control, anchor);
	}
}

void inkDrawRect(inkCanvas* canvas, inkRect rect)
{
	inkBox box = inkBoxFromRect(rect);

    inkMoveTo(canvas, box.pointA);
    inkLineTo(canvas, box.pointB);
    inkLineTo(canvas, box.pointC);
	inkLineTo(canvas, box.pointD);
	inkLineTo(canvas, box.pointA);
}

void inkDrawRoundRect(inkCanvas* canvas, inkRect rect, inkSize ellipseSize)
{
	// TODO: Implement
}

void inkDrawPath(inkCanvas* canvas, inkArray* commands, inkArray* points, inkWindingRule winding)
{
    // TODO: Write this directly into the command queue, becuase it's faster
	if (canvas == NULL || commands == NULL || points == NULL)
		return;

	unsigned int pointCount = inkArrayCount(points);

	if (pointCount == 0)
		return;

	inkPoint* pointPtr = (inkPoint*)(points->elements);
	
	unsigned int pointIndex = 0;
    inkPoint* p1;
    inkPoint* p2;
	inkPoint* p3;
    inkCommandType command;

	inkWindingStyle(canvas, winding);

    inkArrayPtrForEach(commands, command)
    {
        switch(command)
		{
            case inkPathCommand_NoOp:
				break;
			case inkPathCommand_WideMoveTo:
			case inkPathCommand_WideLineTo:
				++pointIndex;
				assert(pointIndex < pointCount);
				++pointPtr;
            case inkPathCommand_LineTo:
			case inkPathCommand_MoveTo:
				++pointIndex;
				assert(pointIndex < pointCount);
				p1 = pointPtr;
				++pointPtr;
                break;
			case inkPathCommand_QuadraticCurveTo:
				++pointIndex;
				assert(pointIndex < pointCount);
				p1 = pointPtr;
				++pointPtr;
				++pointIndex;
				assert(pointIndex < pointCount);
				p2 = pointPtr;
				++pointPtr;
                break;
			case inkPathCommand_CubicCurveTo:
				++pointIndex;
				assert(pointIndex < pointCount);
				p1 = pointPtr;
				++pointPtr;
				++pointIndex;
				assert(pointIndex < pointCount);
				p2 = pointPtr;
				++pointPtr;
				++pointIndex;
				assert(pointIndex < pointCount);
				p3 = pointPtr;
				++pointPtr;
                break;
            default:
                assert(0);
        }

        switch(command)
		{
			case inkPathCommand_NoOp:
				break;
			case inkPathCommand_WideMoveTo:
            case inkPathCommand_MoveTo:
                inkMoveTo(canvas, *p1);
                break;
			case inkPathCommand_WideLineTo:
            case inkPathCommand_LineTo:
                inkLineTo(canvas, *p1);
                break;
            case inkPathCommand_QuadraticCurveTo:
                inkQuadraticCurveTo(canvas, *p1, *p2);
                break;
			case inkPathCommand_CubicCurveTo:
                inkCubicCurveTo(canvas, *p1, *p2, *p3);
                break;
            default:
                assert(0);
        }
    }
}
