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

void inkDrawCircle(inkCanvas* canvas, inkPoint position, float radius)
{
	const unsigned int curveCount = 3;
	float stepAngle = M_PI * 2 / curveCount;
	unsigned int index;

	inkMoveTo(canvas, inkPointAdd(position, inkPointMake(radius, 0)));
	float controlRadius = radius / cosf(M_PI / curveCount);

	for (index = 1; index <= curveCount; ++index)
	{
		float angle = stepAngle * index;
		float controlAngle = angle - stepAngle * 0.5f;
		inkPoint control = inkPointAdd(position, inkPointFromPolar(controlRadius, controlAngle));
		inkPoint anchor = inkPointAdd(position, inkPointFromPolar(radius, angle));
		inkCurveTo(canvas, control, anchor);
	}
}

void inkDrawEllipse(inkCanvas* canvas, inkRect boundingRect)
{
	// TODO: Implement
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
