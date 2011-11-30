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

void inkClear(inkCanvas* canvas)
{
	if (canvas == NULL)
		return;

	inkArrayClear(canvas->commandList);
	inkArrayClear(canvas->renderGroups);
}

void inkMoveTo(inkCanvas* canvas, inkPoint position)
{
	inkMoveToCommand command = position;
	inkAddCommand(canvas, inkCommandType_MoveTo, &command);
}

void inkLineTo(inkCanvas* canvas, inkPoint position)
{
	inkLineToCommand command = position;
	inkAddCommand(canvas, inkCommandType_LineTo, &command);
}

void inkCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor)
{
	inkQuadraticCurveTo(canvas, control, anchor);
}

void inkQuadraticCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor)
{
	inkQuadraticCurveToCommand command;
	command.control = control;
	command.anchor = anchor;

	inkAddCommand(canvas, inkCommandType_QuadraticCurveTo, &command);
}

void inkCubicCurveTo(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor)
{
	inkCubicCurveToCommand command;
	command.controlA = controlA;
	command.controlB = controlB;
	command.anchor = anchor;

	inkAddCommand(canvas, inkCommandType_CubicCurveTo, &command);
}

void inkBeginFill(inkCanvas* canvas, inkSolidFill solidFill)
{
	inkSolidFillCommand command = solidFill;
	inkAddCommand(canvas, inkCommandType_SolidFill, &command);
}

void inkBeginBitmapFill(inkCanvas* canvas, inkBitmapFill bitmapFill)
{
	inkBitmapFillCommand command = bitmapFill;
	inkAddCommand(canvas, inkCommandType_BitmapFill, &command);
}

void inkBeginGradientFill(inkCanvas* canvas, inkGradientFill gradientFill)
{
	inkGradientFillCommand command = gradientFill;
	inkAddCommand(canvas, inkCommandType_GradientFill, &command);
}

void inkLineStyle(inkCanvas* canvas, inkStroke stroke, inkSolidFill solidFill)
{
	inkLineStyleCommand command;
	command.fill = solidFill;
	command.stroke = stroke;

	inkAddCommand(canvas, inkCommandType_LineStyle, &command);
}

void inkLineBitmapStyle(inkCanvas* canvas, inkBitmapFill bitmapFill)
{
	inkBitmapFillCommand command = bitmapFill;

	inkAddCommand(canvas, inkCommandType_LineStyle, &command);
}

void inkLineGradientStyle(inkCanvas* canvas, inkGradientFill gradientFill)
{
	inkLineGradientCommand command = gradientFill;

	inkAddCommand(canvas, inkCommandType_LineStyle, &command);
}

void inkEndFill(inkCanvas* canvas)
{
	inkAddCommand(canvas, inkCommandType_EndFill, NULL);
}

void inkLineStyleNone(inkCanvas* canvas)
{
	inkLineStyle(canvas, inkStrokeDefault, inkSolidFillDefault);
}

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
void inkRasterize(inkCanvas* canvas)
{
	if (canvas == NULL)
		return;

	inkArray* commandList = canvas->commandList;
	void* commandData;
	inkCommand* command;
	inkCommandType commandType;
	inkFillGenerator* fillGenerator = NULL;
	inkStrokeGenerator* strokeGenerator = NULL;

	inkTessellator* fillTessellator = inkGetFillTessellator();
	inkTessellator* strokeTessellator = inkGetStrokeTessellator();

	inkArrayPtrForEach(commandList, command)
	{
		commandType = command->type;
		commandData = command->data;

		switch(commandType)
		{
			case inkCommandType_MoveTo:
			{
				inkMoveToCommand* point = (inkPoint*)(commandData);

				inkFillGeneratorMoveTo(fillGenerator, *point);
				inkStrokeGeneratorMoveTo(strokeGenerator, *point);
			}
				break;
			case inkCommandType_LineTo:
			{
				inkLineToCommand* point = (inkPoint*)(commandData);

				inkFillGeneratorLineTo(fillGenerator, *point);
				inkStrokeGeneratorLineTo(strokeGenerator, *point);
			}
				break;
			case inkCommandType_QuadraticCurveTo:
			{
				inkQuadraticCurveToCommand* command = (inkQuadraticCurveToCommand*)(commandData);

				inkFillGeneratorQuadraticCurveTo(fillGenerator, command->control, command->anchor);
				inkStrokeGeneratorQuadraticCurveTo(strokeGenerator, command->control, command->anchor);
				break;
			}
			case inkCommandType_CubicCurveTo:
			{
				inkCubicCurveToCommand* command = (inkCubicCurveToCommand*)(commandData);

				inkFillGeneratorCubicCurveTo(fillGenerator, command->controlA, command->controlB, command->anchor);
				inkStrokeGeneratorCubicCurveTo(strokeGenerator, command->controlA, command->controlB, command->anchor);
			}
				break;
			case inkCommandType_SolidFill:
			{
				inkFillGeneratorEnd(fillGenerator);

				inkFillGeneratorDestroy(fillGenerator);
				inkSolidFillCommand* fill = (inkSolidFillCommand*)(commandData);

				fillGenerator = inkFillGeneratorCreate(fillTessellator, canvas->renderGroups, fill);
			}
				break;
			case inkCommandType_BitmapFill:
			{
				inkFillGeneratorEnd(fillGenerator);

				inkFillGeneratorDestroy(fillGenerator);
				inkBitmapFillCommand* fill = (inkBitmapFillCommand*)(commandData);

				fillGenerator = inkFillGeneratorCreate(fillTessellator, canvas->renderGroups, fill);
			}
				break;
			case inkCommandType_GradientFill:
			{
				inkFillGeneratorEnd(fillGenerator);

				inkFillGeneratorDestroy(fillGenerator);
				inkGradientFillCommand* fill = (inkGradientFillCommand*)(commandData);

				fillGenerator = inkFillGeneratorCreate(fillTessellator, canvas->renderGroups, fill);
			}
				break;
			case inkCommandType_LineStyle:
			{
				inkStrokeGeneratorEnd(strokeGenerator);
				inkStrokeGeneratorDestroy(strokeGenerator);
				strokeGenerator = NULL;

				inkLineStyleCommand* command = (inkLineStyleCommand*)(commandData);

				if (!isnan(command->stroke.thickness))
				{
					strokeGenerator = inkStrokeGeneratorCreate(strokeTessellator, canvas->renderGroups, &(command->stroke));
					inkStrokeGeneratorSetFill(strokeGenerator, &(command->fill));
				}
			}
				break;
			case inkCommandType_LineBitmap:
			{
				inkLineBitmapCommand* command = (inkLineBitmapCommand*)(commandData);

				inkStrokeGeneratorSetFill(strokeGenerator, command);
			}
				break;
			case inkCommandType_LineGradient:
			{
				inkLineGradientCommand* command = (inkLineGradientCommand*)(commandData);

				inkStrokeGeneratorSetFill(strokeGenerator, command);
			}
				break;
			case inkCommandType_EndFill:
				inkFillGeneratorEnd(fillGenerator);
				inkFillGeneratorDestroy(fillGenerator);
				fillGenerator = NULL;
				//inkStrokeGeneratorEnd(strokeGenerator);
				break;
			default:
				break;
		}
	}

	// Must be destroyed before we end the stroke generator
	inkFillGeneratorEnd(fillGenerator);
	inkFillGeneratorDestroy(fillGenerator);

	// Must be done after we destroy the fill generator.
	inkStrokeGeneratorEnd(strokeGenerator);
	inkStrokeGeneratorDestroy(strokeGenerator);
}
