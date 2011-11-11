//
//  inkVectorGraphics.c
//  ink
//
//  Created by John Lattin on 11/7/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkVectorGraphics.h"

#include "inkTessellator.h"
#include "inkCommand.h"

#include "inkFillGenerator.h"
#include "inkStrokeGenerator.h"

// TODO: Remove
#include "PXGLUtils.h"

// We use a shared tessellator because the 'rasterization' step, where
// tessellation is done, should ONLY ever happen on the main thread.
//static PXTessellator *pxGraphicsUtilsSharedTesselator = NULL;

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
	if (canvas == NULL)
		return;

	// TODO: Implement
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

	printf("total command count = %u\n", inkArrayCount(commandList));

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
				break;
			case inkCommandType_SolidFill:
			{
				inkFillGeneratorDestroy(fillGenerator);
				inkSolidFill* fill = (inkSolidFill*)(commandData);
				fillGenerator = inkFillGeneratorCreate(sizeof(INKvertex), fill);
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
				inkAddRenderGroup(canvas, fillGenerator->vertices, GL_TRIANGLE_STRIP);
				inkFillGeneratorEnd(fillGenerator);
				break;
			default:
				break;
		}
	}

	inkFillGeneratorDestroy(fillGenerator);
}
