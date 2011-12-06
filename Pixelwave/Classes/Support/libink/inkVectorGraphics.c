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

#include "inkGLU.h"

// TODO:	Percision too high can create floating point issues where an
//			intersection is impossible to find due to the points being too close
//			together.
// NOTE:	See the '+ 2', this is to add the first and last points always
const unsigned int inkVectorGraphicsCurvePercision = 11 + 2;

typedef enum
{
	inkCurveType_Quadratic = 0,
	inkCurveType_Cubic,
} inkCurveType;

inkInline inkPoint inkPosition(inkCanvas* canvas, inkPoint position, bool relative)
{
	if (canvas == NULL || relative == false)
		return position;

	return inkPointAdd(canvas->cursor, position);
}

inkInline void inkSetCursor(inkCanvas* canvas, inkPoint position)
{
	if (canvas == NULL)
		return;

	canvas->cursor = position;
}

void inkClear(inkCanvas* canvas)
{
	if (canvas == NULL)
		return;

	inkArrayClear(canvas->commandList);
	inkArrayClear(canvas->renderGroups);
}

void inkMoveTo(inkCanvas* canvas, inkPoint position)
{
	inkMoveTov(canvas, position, false);
}

void inkLineTo(inkCanvas* canvas, inkPoint position)
{
	inkLineTov(canvas, position, false);
}

void inkCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor)
{
	inkCurveTov(canvas, control, anchor, false);
}

void inkQuadraticCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor)
{
	inkQuadraticCurveTov(canvas, control, anchor, false);
}

void inkCubicCurveTo(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor)
{
	inkCubicCurveTov(canvas, controlA, controlB, anchor, false);
}

void inkMoveTov(inkCanvas* canvas, inkPoint position, bool relative)
{
	position = inkPosition(canvas, position, relative);

	inkMoveToCommand command = position;
	inkAddCommand(canvas, inkCommandType_MoveTo, &command);

	inkSetCursor(canvas, position);
}

void inkLineTov(inkCanvas* canvas, inkPoint position, bool relative)
{
	position = inkPosition(canvas, position, relative);

	inkLineToCommand command = position;
	inkAddCommand(canvas, inkCommandType_LineTo, &command);

	inkSetCursor(canvas, position);
}

void inkCurveTov(inkCanvas* canvas, inkPoint control, inkPoint anchor, bool relative)
{
	inkQuadraticCurveTo(canvas, control, anchor);
}

void inkQuadraticCurveTov(inkCanvas* canvas, inkPoint control, inkPoint anchor, bool relative)
{
	control = inkPosition(canvas, control, relative);
	anchor = inkPosition(canvas, anchor, relative);

	inkQuadraticCurveToCommand command;
	command.control = control;
	command.anchor = anchor;

	inkAddCommand(canvas, inkCommandType_QuadraticCurveTo, &command);

	inkSetCursor(canvas, anchor);
}

void inkCubicCurveTov(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor, bool relative)
{
	controlA = inkPosition(canvas, controlA, relative);
	controlB = inkPosition(canvas, controlB, relative);
	anchor = inkPosition(canvas, anchor, relative);

	inkCubicCurveToCommand command;
	command.controlA = controlA;
	command.controlB = controlB;
	command.anchor = anchor;

	inkAddCommand(canvas, inkCommandType_CubicCurveTo, &command);

	inkSetCursor(canvas, anchor);
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

void inkWindingStyle(inkCanvas* canvas, inkWindingRule winding)
{
	inkWindingCommand command = winding;

	inkAddCommand(canvas, inkCommandType_Winding, &command);
}

void inkEndFill(inkCanvas* canvas)
{
	inkAddCommand(canvas, inkCommandType_EndFill, NULL);
}

void inkLineStyleNone(inkCanvas* canvas)
{
	inkLineStyle(canvas, inkStrokeDefault, inkSolidFillDefault);
}

void inkEndGenerators(inkFillGenerator** fillGeneratorPtr, inkStrokeGenerator** strokeGeneratorPtr)
{
	if (fillGeneratorPtr)
	{
		// Must be destroyed before we end the stroke generator
		inkFillGeneratorEnd(*fillGeneratorPtr);
		inkFillGeneratorDestroy(*fillGeneratorPtr);
		*fillGeneratorPtr = NULL;
	}

	if (strokeGeneratorPtr)
	{
		// Must be done after we destroy the fill generator.
		inkStrokeGeneratorEnd(*strokeGeneratorPtr);
		inkStrokeGeneratorDestroy(*strokeGeneratorPtr);
		*strokeGeneratorPtr = NULL;
	}
}

inkPoint inkUpdatePosition(inkCanvas* canvas, inkPoint point)
{
	return point;
}

void inkCurve(inkCanvas* canvas, inkFillGenerator* fillGenerator, inkStrokeGenerator* strokeGenerator, inkCurveType curveType, inkPoint controlA, inkPoint controlB, inkPoint anchor)
{
	if (fillGenerator == NULL && strokeGenerator == NULL)
		return;

	inkPoint d;

	if (fillGenerator != NULL && fillGenerator->generator != NULL)
		d = fillGenerator->generator->previous;
	else if (strokeGenerator != NULL && strokeGenerator->generator != NULL)
		d = strokeGenerator->generator->previous;
	else
		return;

	inkPoint point;
	inkPoint previousPoint = d;

	float tIncrement = 1.0f / (float)(inkVectorGraphicsCurvePercision - 1);
	float t;
	float t2;
	float t3;

	inkPoint a;
	inkPoint b;
	inkPoint c;

	if (curveType == inkCurveType_Cubic)
	{
		c = inkPointSubtract(inkPointScale(controlA, 3.0f), inkPointScale(d, 3.0f));
		b = inkPointAdd(inkPointSubtract(inkPointScale(controlB, 3.0f), inkPointScale(controlA, 6.0f)), inkPointScale(d, 3.0f));
		a = inkPointSubtract(inkPointAdd(inkPointSubtract(anchor, inkPointScale(controlB, 3.0f)), inkPointScale(controlA, 3.0f)), d);
	}
	else if (curveType == inkCurveType_Quadratic)
	{
		c = inkPointSubtract(inkPointScale(controlB, 2.0f), inkPointScale(d, 2.0f));
		b = inkPointAdd(inkPointSubtract(anchor, inkPointScale(controlB, 2.0f)), d);
		a = inkPointZero;
	}
	else
		return;

	unsigned int index;

	for (index = 0, t = 0.0f; index < inkVectorGraphicsCurvePercision; ++index, t += tIncrement)
	{
		t2 = t * t;
		t3 = t2 * t;

		point = inkPointMake((a.x * t3) + (b.x * t2) + (c.x * t) + d.x,
							 (a.y * t3) + (b.y * t2) + (c.y * t) + d.y);

		if (inkPointIsEqual(previousPoint, point) == false)
		{
			previousPoint = point;

			point = inkUpdatePosition(canvas, point);
			inkFillGeneratorLineTo(fillGenerator, point);
			inkStrokeGeneratorLineTo(strokeGenerator, point);
		}
	}
}

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
void inkBuild(inkCanvas* canvas)
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
				inkMoveToCommand* command = (inkPoint*)(commandData);

				inkPoint point = inkUpdatePosition(canvas, *command);
				inkFillGeneratorMoveTo(fillGenerator, point);
				inkStrokeGeneratorMoveTo(strokeGenerator, point);
			}
				break;
			case inkCommandType_LineTo:
			{
				inkLineToCommand* command = (inkPoint*)(commandData);

				inkPoint point = inkUpdatePosition(canvas, *command);
				inkFillGeneratorLineTo(fillGenerator, point);
				inkStrokeGeneratorLineTo(strokeGenerator, point);
			}
				break;
			case inkCommandType_QuadraticCurveTo:
			{
				inkQuadraticCurveToCommand* command = (inkQuadraticCurveToCommand*)(commandData);

				inkCurve(canvas, fillGenerator, strokeGenerator, inkCurveType_Quadratic, inkPointZero, command->control, command->anchor);
			//	inkFillGeneratorQuadraticCurveTo(fillGenerator, command->control, command->anchor);
			//	inkStrokeGeneratorQuadraticCurveTo(strokeGenerator, command->control, command->anchor);
				break;
			}
			case inkCommandType_CubicCurveTo:
			{
				inkCubicCurveToCommand* command = (inkCubicCurveToCommand*)(commandData);

				inkCurve(canvas, fillGenerator, strokeGenerator, inkCurveType_Quadratic, command->controlA, command->controlB, command->anchor);
			//	inkFillGeneratorCubicCurveTo(fillGenerator, command->controlA, command->controlB, command->anchor);
			//	inkStrokeGeneratorCubicCurveTo(strokeGenerator, command->controlA, command->controlB, command->anchor);
			}
				break;
			case inkCommandType_SolidFill:
			{
				inkEndGenerators(&fillGenerator, NULL);

				inkSolidFillCommand* fill = (inkSolidFillCommand*)(commandData);

				fillGenerator = inkFillGeneratorCreate(fillTessellator, canvas->renderGroups, fill);
			}
				break;
			case inkCommandType_BitmapFill:
			{
				inkEndGenerators(&fillGenerator, NULL);

				inkBitmapFillCommand* fill = (inkBitmapFillCommand*)(commandData);

				fillGenerator = inkFillGeneratorCreate(fillTessellator, canvas->renderGroups, fill);
			}
				break;
			case inkCommandType_GradientFill:
			{
				inkEndGenerators(&fillGenerator, NULL);

				inkGradientFillCommand* fill = (inkGradientFillCommand*)(commandData);

				fillGenerator = inkFillGeneratorCreate(fillTessellator, canvas->renderGroups, fill);
			}
				break;
			case inkCommandType_LineStyle:
			{
				inkEndGenerators(NULL, &strokeGenerator);

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

				// Setting the fill will properly concat the vertices on
				inkStrokeGeneratorSetFill(strokeGenerator, command);
			}
				break;
			case inkCommandType_LineGradient:
			{
				inkLineGradientCommand* command = (inkLineGradientCommand*)(commandData);

				// Setting the fill will properly concat the vertices on
				inkStrokeGeneratorSetFill(strokeGenerator, command);
			}
				break;
			case inkCommandType_Winding:
			{
				inkWindingCommand* command = (inkWindingCommand*)(commandData);

				inkTessellatorSetWindingRule(fillTessellator, *command);
				inkTessellatorSetWindingRule(strokeTessellator, *command);
			}
				break;
			case inkCommandType_EndFill:
				inkEndGenerators(&fillGenerator, NULL);
				if (strokeGenerator)
				{
					inkStrokeGeneratorEnd(strokeGenerator);
					inkGeneratorRemoveAllVertices(strokeGenerator->generator);
				}
				break;
			default:
				break;
		}
	}

	inkEndGenerators(&fillGenerator, &strokeGenerator);

	canvas->cursor = inkPointZero;

	inkArray* renderGroups = inkRenderGroups(canvas);

	if (renderGroups == NULL)
	{
		canvas->bounds = inkRectZero;
		return;
	}

	inkRenderGroup* renderGroup;
	inkArray* vertexArray;
	INKvertex* vertex;
	unsigned int vertexCount;

	inkPoint minPoint = inkPointMax;
	inkPoint maxPoint = inkPointMin;

	inkArrayPtrForEach(renderGroups, renderGroup)
	{
		vertexArray = renderGroup->vertices;
		vertexCount = inkArrayCount(vertexArray);

		if (vertexCount == 0)
			continue;

		inkArrayForEach(vertexArray, vertex)
		{
			minPoint = inkPointMake(fminf(minPoint.x, vertex->x), fminf(minPoint.y, vertex->y));
			maxPoint = inkPointMake(fmaxf(maxPoint.x, vertex->x), fmaxf(maxPoint.y, vertex->y));
		}
	}

	canvas->bounds = inkRectMake(minPoint, inkSizeFromPoint(inkPointSubtract(maxPoint, minPoint)));
}

bool inkContainsPoint(inkCanvas* canvas, inkPoint point, bool useBoundingBox)
{
	inkArray* renderGroups = inkRenderGroups(canvas);

	if (renderGroups == NULL)
		return false;

	inkRenderGroup* renderGroup;
	inkArray* vertexArray;
	INKvertex* vertex;
	inkTriangle triangle = inkTriangleZero;
	inkPoint firstPoint;

	unsigned int index;
	unsigned int vertexCount;

	if (inkRectContainsPoint(canvas->bounds, point) == false)
		return false;
	else if (useBoundingBox == true)
		return true;

	inkArrayPtrForEach(renderGroups, renderGroup)
	{
		vertexArray = renderGroup->vertices;
		vertexCount = inkArrayCount(vertexArray);

		if (vertexCount == 0)
			continue;

		index = 0;

		firstPoint = *((inkPoint*)inkArrayElementAt(vertexArray, 0));
		triangle.pointC = *((inkPoint*)inkArrayElementAt(vertexArray, vertexCount - 1));

		inkArrayForEach(vertexArray, vertex)
		{
			triangle.pointA = triangle.pointB;
			triangle.pointB = triangle.pointC;
			triangle.pointC = inkPointMake(vertex->x, vertex->y);

			switch(renderGroup->glDrawMode)
			{
		// POINTS
				case GL_POINTS:
					if (inkPointIsEqual(triangle.pointC, point))
						return true;
					break;

		// LINES
				case GL_LINES:
					if (index % 2 == 0)
						break; // must break so index iterates
				case GL_LINE_STRIP:
					if (index == 0)
						break; // must break so index iterates
				case GL_LINE_LOOP:
					// At index  0, point B will be the last point, and pointC
					// will be the first point, thus checking loop.
					if (inkLineContainsPoint(inkLineMake(triangle.pointB, triangle.pointC), point))
						return true;

					break;

		// TRIANGLES
				case GL_TRIANGLES:
					if (index % 3 != 0)
						break;
				case GL_TRIANGLE_FAN:
					if (renderGroup->glDrawMode == GL_TRIANGLE_FAN)
						triangle.pointA = firstPoint;
				case GL_TRIANGLE_STRIP:
					if (index < 2)
						break; // must break so index iterates

					if (inkTriangleContainsPoint(triangle, point))
					{
						inkTriangleContainsPoint(triangle, point);
						return true;
					}

					break;
			}

			++index;
		}
	}

	return false;
}

unsigned int inkDraw(inkCanvas* canvas)
{
	return inkDrawv(canvas, glEnable, glDisable, glEnableClientState, glDisableClientState, glPointSize, glLineWidth, glBindTexture, glVertexPointer, glTexCoordPointer, glColorPointer, glDrawArrays, glDrawElements);
}

unsigned int inkDrawv(inkCanvas* canvas, inkStateFunction enableFunc, inkStateFunction disableFunc, inkStateFunction enableClientFunc, inkStateFunction disableClientFunc, inkPointSizeFunction pointSizeFunc, inkLineWidthFunction lineWidthFunc, inkTextureFunction textureFunc, inkPointerFunction vertexFunc, inkPointerFunction textureCoordinateFunc, inkPointerFunction colorFunc, inkDrawArraysFunction drawArraysFunc, inkDrawElementsFunction drawElementsFunc)
{
	inkArray* renderGroups = inkRenderGroups(canvas);

	if (renderGroups == NULL)
		return 0;

	inkRenderGroup* renderGroup;
	inkArray* vertexArray;
	INKvertex* vertices;

	pointSizeFunc(4.0f);

	unsigned int vertexArrayCount;
	unsigned int totalVertexCount = 0;

	inkArrayPtrForEach(renderGroups, renderGroup)
	{
		vertexArray = renderGroup->vertices;

		lineWidthFunc(renderGroup->glLineWidth);

		if (renderGroup->glTextureName != 0)
		{
			disableClientFunc(GL_COLOR_ARRAY);
			enableClientFunc(GL_TEXTURE_COORD_ARRAY);
			
			enableFunc(GL_TEXTURE_2D);
			textureFunc(GL_TEXTURE_2D, renderGroup->glTextureName);
		}
		else
		{
			disableFunc(GL_TEXTURE_2D);
			enableClientFunc(GL_COLOR_ARRAY);
			disableClientFunc(GL_TEXTURE_COORD_ARRAY);
		}

		if (vertexArray != NULL)
		{
			vertices = vertexArray->elements;

			vertexArrayCount = inkArrayCount(vertexArray);
			totalVertexCount += vertexArrayCount;

			vertexFunc(2, GL_FLOAT, sizeof(INKvertex), &(vertices->x));
			textureCoordinateFunc(2, GL_FLOAT, sizeof(INKvertex), &(vertices->s));
			colorFunc(4, GL_UNSIGNED_BYTE, sizeof(INKvertex), &(vertices->r));

			drawArraysFunc(renderGroup->glDrawMode, 0, vertexArrayCount);
		}
	}

	return totalVertexCount;
}
