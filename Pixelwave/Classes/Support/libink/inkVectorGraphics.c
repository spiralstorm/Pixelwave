//
//  inkVectorGraphics.c
//  ink
//
//  Created by John Lattin on 11/7/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkVectorGraphics.h"

#include "inkCommand.h"

#include "inkFillGenerator.h"
#include "inkStrokeGenerator.h"

inkExtern void inkClear(inkCanvas* canvas)
{
	if (canvas == NULL)
		return;

	inkArrayClear(canvas->commandList);
	inkArrayClear(canvas->renderGroups);
}

inkExtern void inkMoveTo(inkCanvas* canvas, inkPoint position)
{
	inkAddCommand(canvas, inkCommandType_MoveTo, &position);
}

inkExtern void inkLineTo(inkCanvas* canvas, inkPoint position)
{
	inkAddCommand(canvas, inkCommandType_LineTo, &position);
}

inkExtern void inkCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor)
{
	inkCurveToCommand command = {control, anchor};

	inkAddCommand(canvas, inkCommandType_CurveTo, &command);

	/*if (canvas == NULL)
		return;

	// TODO: Implement properly instead of just making lots of LineTos
	const unsigned int percision = 100;

	inkPoint nextPoint;
	inkPoint previousPoint = inkPointMake(390.000000, 160.000000);

	float tIncrement = 1.0f / (float)(percision - 1);
	float t;
	float oneMinusT;

	float pWeight;
	float cWeight;
	float aWeight;

	unsigned int index;

	for (index = 0, t = 0.0f, oneMinusT = 1.0f; index < percision; ++index, t += tIncrement, oneMinusT -= tIncrement)
	{
		pWeight = oneMinusT * oneMinusT;
		cWeight = 2 * t * oneMinusT;
		aWeight = t * t;

		nextPoint = inkPointMake((previousPoint.x * pWeight) + (control.x * cWeight) + (anchor.x * aWeight),
								 (previousPoint.y * pWeight) + (control.y * cWeight) + (anchor.y * aWeight));

		inkLineTo(canvas, nextPoint);
	}*/
}

inkExtern void inkBeginFill(inkCanvas* canvas, inkSolidFill solidFill)
{
	inkAddCommand(canvas, inkCommandType_SolidFill, &solidFill);
}

inkExtern void inkBeginBitmapFill(inkCanvas* canvas, inkBitmapFill bitmapFill)
{
	if (canvas == NULL)
		return;

	// TODO: Implement
}

inkExtern void inkBeginGradientFill(inkCanvas* canvas, inkGradientFill gradientFill)
{
	if (canvas == NULL)
		return;

	// TODO: Implement
}

inkExtern void inkLineStyle(inkCanvas* canvas, inkStroke stroke, inkSolidFill solidFill)
{
	if (canvas == NULL)
		return;

	// TODO: Implement
}

inkExtern void inkLineBitmapStyle(inkCanvas* canvas, inkBitmapFill bitmapFill)
{
	if (canvas == NULL)
		return;

	// TODO: Implement
}

inkExtern void inkLineGradientStyle(inkCanvas* canvas, inkGradientFill gradientFill)
{
	if (canvas == NULL)
		return;

	// TODO: Implement
}

inkExtern void inkEndFill(inkCanvas* canvas)
{
	inkAddCommand(canvas, inkCommandType_EndFill, NULL);
}

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
inkExtern void inkRasterize(inkCanvas* canvas)
{
	if (canvas == NULL)
		return;

	inkArray* commandList = canvas->commandList;
	void* commandData;
	inkCommand* command;
	inkCommandType commandType;
	inkFillInfo* fillGenerator = NULL;
	inkTessellator* tessellator = inkSharedTesselator;

	inkArrayPtrForEach(commandList, command)
	{
		commandType = command->type;
		commandData = command->data;

		switch(commandType)
		{
			case inkCommandType_MoveTo:
			{
				inkPoint* point = (inkPoint*)(commandData);
				inkFillGeneratorMoveTo(fillGenerator, *point);
			}
				break;
			case inkCommandType_LineTo:
			{
				inkPoint* point = (inkPoint*)(commandData);
				inkFillGeneratorLineTo(fillGenerator, *point);
			}
				break;
			case inkCommandType_CurveTo:
			{
				inkCurveToCommand* command = (inkCurveToCommand*)(commandData);
				inkFillGeneratorCurveTo(fillGenerator, command->control, command->anchor);
			}
				break;
			case inkCommandType_SolidFill:
			{
				inkTessellatorBeginPolygon(tessellator, canvas->renderGroups);

				inkFillGeneratorDestroy(fillGenerator);
				inkSolidFill* fill = (inkSolidFill*)(commandData);

				fillGenerator = inkFillGeneratorCreate(fill, tessellator);
			}
				break;
			case inkCommandType_BitmapFill:
				break;
			case inkCommandType_GradientFill:
				break;
			case inkCommandType_LineStyle:
				break;
			case inkCommandType_LineBitmap:
				break;
			case inkCommandType_LineGradient:
				break;
			case inkCommandType_EndFill:
				inkFillGeneratorEnd(fillGenerator);
				break;
			default:
				break;
		}
	}

	inkTessellatorEndContour(tessellator);
	inkTessellatorEndPolygon(tessellator);

	inkFillGeneratorDestroy(fillGenerator);
}
