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

#include <ctype.h>

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
	inkMoveTof(canvas, rect.origin.x + ellipseSize.width, rect.origin.y);
	inkLineTof(canvas, rect.origin.x + rect.size.width - ellipseSize.width, rect.origin.y);
	inkQuadraticCurveTof(canvas, rect.origin.x + rect.size.width, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + ellipseSize.height);
	inkLineTof(canvas, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - ellipseSize.height);
	inkQuadraticCurveTof(canvas, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, rect.origin.x + rect.size.width - ellipseSize.width, rect.origin.y + rect.size.height);
	inkLineTof(canvas, rect.origin.x + ellipseSize.width, rect.origin.y + rect.size.height);
	inkQuadraticCurveTof(canvas, rect.origin.x, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y + rect.size.height - ellipseSize.height);
	inkLineTof(canvas, rect.origin.x, rect.origin.y + ellipseSize.height);
	inkQuadraticCurveTof(canvas, rect.origin.x, rect.origin.y, rect.origin.x + ellipseSize.width, rect.origin.y);
}

void inkDrawPath(inkCanvas* canvas, inkArray* commands, inkArray* points, inkWindingRule winding)
{
	assert(canvas != NULL);

    // TODO: Write this directly into the command queue, becuase it's faster
	if (commands == NULL || points == NULL)
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

char inkPathGetCommand(char ** path_ptr)
{
    char cmd = **path_ptr;
    ++*path_ptr;
    return cmd;
}

float inkPathGetFloat(char ** path_ptr)
{
    char* path = *path_ptr;
    float result = 0.0f;
    while ( !isdigit(*path) && *path != '-' ) ++path;
    result = strtod(path, path_ptr);
    return result;
}

inkPoint inkPathGetPoint(char** path_ptr)
{
    float x = inkPathGetFloat(path_ptr);
    float y = inkPathGetFloat(path_ptr);
    return inkPointMake(x,y);
}



void inkDrawSVGPathv(inkCanvas* canvas, const char* path, inkPoint offset)
{
    char cmd;
    inkPoint p1, p2, p3;
    bool relative;
    while ( *path ) {
        cmd = inkPathGetCommand((char**)&path);
        relative = islower(cmd);
        switch ( cmd ) {
			case 'z':
				break;
			case 'C':
			case 'c':
				p1 = inkPathGetPoint((char**)&path);
				p2 = inkPathGetPoint((char**)&path);
				p3 = inkPathGetPoint((char**)&path);
				
				if (!relative) p1 = inkPointAdd(p1, offset);
				if (!relative) p2 = inkPointAdd(p2, offset);
				if (!relative) p3 = inkPointAdd(p3, offset);
				
				break;
			case 'Q':
			case 'q':
			case 's':
			case 'S':
				p1 = inkPathGetPoint((char**)&path);
				p2 = inkPathGetPoint((char**)&path);
				
				if (!relative) p1 = inkPointAdd(p1, offset);
				if (!relative) p2 = inkPointAdd(p2, offset);
				break;
			case 'm':
			case 'M':
			case 'L':
			case 'l':
			case 'T':
			case 't':
				p1 = inkPathGetPoint((char**)&path);
				
				if (!relative) p1 = inkPointAdd(p1, offset);
				break;
			case 'H':
			case 'h':
				p1 = inkPointMake(inkPathGetFloat((char**)&path),relative ? 0 : canvas->cursor.y);
				if (!relative) p1.x += offset.x;
				break;
			case 'V':
			case 'v':
				p1 = inkPointMake(relative ? 0 : canvas->cursor.x, inkPathGetFloat((char**)&path));
				if (!relative) p1.y += offset.y;
				break;
        }
		
        switch ( cmd ) {
			case 'm':
			case 'M':
				inkMoveTov(canvas, p1,relative);
				break;
			case 'L':
			case 'l':
			case 'H':
			case 'h':
			case 'V':
			case 'v':
				inkLineTov(canvas, p1, relative);
				break;
			case 'Q':
			case 'q':
				inkCurveTov(canvas, p1, p2, relative, false);
				break;
			case 'T':
			case 't':
				inkCurveTov(canvas, inkPointZero, p1, relative, true);
				break;
			case 'C':
			case 'c':
				inkCubicCurveTov(canvas, p1, p2, p3, relative, false);
				break;
			case 'S':
			case 's':
				inkCubicCurveTov(canvas, inkPointZero, p1, p2, relative, true);
				break;
			case 'z':
			case 'Z':
				//End Path
				break;
        }
    }
}

void inkDrawSVGPath(inkCanvas* canvas, const char* path)
{
    inkDrawSVGPathv(canvas, path, inkPointZero);
}

int inkDrawHersheyFont(inkCanvas* canvas, const char* path)
{
	int xmax = 0;
	int xmin = 0;
	bool first = true;
	bool pen = false;
	inkPoint base = canvas->cursor;

	while (*path)
	{
		char xc = (*(path++));
		char yc = (*(path++));

		if ( xc == ' ' && yc == 'R')
		{
			pen = false;
			continue;
		}

		float xf = xc - 'R';
		float yf = yc - 'R';

		if ( xf > xmax || first ) xmax = xf;
		if ( xf < xmin || first ) xmin = xf;
		if ( pen )
		{
			inkLineTov(canvas,inkPointAdd(inkPointMake(xf, yf), base), false);
		}
		else
		{
			inkMoveTov(canvas,inkPointAdd(inkPointMake(xf, yf), base), false);
			pen = true;
		}

		first = false;
	}

	return xmax - xmin;
}
