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
	// TODO: Implement

	float x = rect.origin.x;
	float y = rect.origin.y;
	float w = rect.size.width;
	float h = rect.size.height;
	float rw = ellipseSize.width;
	float rh = ellipseSize.height;
	inkMoveTof(canvas,				x + rw,			y);
	inkLineTof(canvas,				x + w - rw,		y);
	inkQuadraticCurveTof(canvas,	x + w,			y,					x + w,			y + rh);
	inkLineTof(canvas,				x + w,			y + h - rh);
	inkQuadraticCurveTof(canvas,	x + w,			y + h,				x + w - rw,		y + h);
	inkLineTof(canvas,				x + rw,			y + h);
	inkQuadraticCurveTof(canvas,	x,				y + h,				x,				y + h - rh);
	inkLineTof(canvas,				x,				y + rh);
	inkQuadraticCurveTof(canvas,	x,				y,					x + rw,			y);

	/*inkMoveTof(canvas,				x + radius,				y);
	inkLineTof(canvas,				x + width - radius,		y);
	inkQuadraticCurveTof(canvas,	x + width,				y,						x + width,				y + radius);
	inkLineTof(canvas,				x + width,				y + height - radius);
	inkQuadraticCurveTof(canvas,	x + width,				y + height,				x + width - radius,		y + height);
	inkLineTof(canvas,				x + radius,				y + height);
	inkQuadraticCurveTof(canvas,	x,						y + height,				x,						y + height - radius);
	inkLineTof(canvas,				x,						y + radius);
	inkQuadraticCurveTof(canvas,	x,						y,						x + radius,				y);*/

	//inkMoveTo(canvas, rect.origin);
	/*rect.graphics.moveTo( 0, tl );
	rect.graphics.curveTo( 0, 0, tl, 0 );
	rect.graphics.lineTo(w - tr, 0);
	rect.graphics.curveTo( w, 0, w, tr );
	rect.graphics.lineTo(w, h - br);
	rect.graphics.curveTo( w, h, w - br, h );
	rect.graphics.lineTo(bl, h);
	rect.graphics.curveTo( 0, h, 0, h - bl );*/

	/*float x1 = inkRectLeft(rect);
	float x2 = inkRectRight(rect);
	float y1 = inkRectTop(rect);
	float y2 = inkRectBottom(rect);

	float xRadius = fminf(ellipseSize.width, rect.size.width  * 0.5f);
	float yRadius = fminf(ellipseSize.height, rect.size.height * 0.5f);

	inkMoveTof(canvas, x1 + xRadius, y1);
	inkLineTof(canvas, x1 + xRadius, y1);

	inkMoveTof(canvas, x1 + xRadius, y1); // MoveTo
	inkLineTof(canvas, x2 - xRadius, y1); // LineTo
	inkCubicCurveTof(canvas, x2 - (1 - KAPPA) * xRadius, y1,     // CurveTo
				x2, y1 + (1 - KAPPA) * yRadius,
				x2, y1 + yRadius);
	inkLineTof(canvas, x2, y2 - yRadius);                   // LineTo
	inkCubicCurveTof(canvas, x2, y2 - (1 - KAPPA) * yRadius,     // CurveTo
				x2 - (1 - KAPPA) * xRadius, y2,
				x2 - xRadius, y2);
	inkLineTof(canvas, x1 + xRadius, y2);                  // LineTo
	inkCubicCurveTof(canvas, x1 + (1 - KAPPA) * xRadius, y2,           // CurveTo
						x1, y2 - (1 - KAPPA) * yRadius,
						x1, y2 - yRadius);
	inkLineTof(canvas, x1, y1 + yRadius);                  // LineTo
	inkCubicCurveTof(canvas, x1, y1 + KAPPA * yRadius,           // CurveTo
					x1 + (1 - KAPPA) * xRadius, y1,
				x1 + xRadius, y1);*/

	/*qreal pts[] = {
		x1 + xRadius, y1,                   // MoveTo
		x2 - xRadius, y1,                   // LineTo
		x2 - (1 - KAPPA) * xRadius, y1,     // CurveTo
		x2, y1 + (1 - KAPPA) * yRadius,
		x2, y1 + yRadius,
		x2, y2 - yRadius,                   // LineTo
		x2, y2 - (1 - KAPPA) * yRadius,     // CurveTo
		x2 - (1 - KAPPA) * xRadius, y2,
		x2 - xRadius, y2,
		x1 + xRadius, y2,                   // LineTo
		x1 + (1 - KAPPA) * xRadius, y2,           // CurveTo
		x1, y2 - (1 - KAPPA) * yRadius,
		x1, y2 - yRadius,
		x1, y1 + yRadius,                   // LineTo
		x1, y1 + KAPPA * yRadius,           // CurveTo
		x1 + (1 - KAPPA) * xRadius, y1,
		x1 + xRadius, y1
	};*/
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
