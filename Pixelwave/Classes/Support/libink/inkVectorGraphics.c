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

typedef struct
{
	inkFillGenerator* fillGenerator;
	inkStrokeGenerator* strokeGenerator;
} inkCurveGenerators;

inkPoint inkUpdatePositionv(inkPoint point, void* canvas);
inkPoint inkUpdatePosition(inkCanvas* canvas, inkPoint point);

void inkCurve(inkCanvas* canvas, inkFillGenerator* fillGenerator, inkStrokeGenerator* strokeGenerator, inkCurveType curveType, inkPoint controlA, inkPoint controlB, inkPoint anchor);

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

unsigned int inkArcLengthSegmentCount(inkCanvas* canvas, float arcLength)
{
	unsigned int count = lroundf(fabsf(arcLength));

	count *= canvas->pixelsPerPoint * canvas->curveMultiplier;

	if (count < 3)
		count = 3;

	return count;
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
	inkCurveTov(canvas, control, anchor, false, false);
}

void inkQuadraticCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor)
{
	inkQuadraticCurveTov(canvas, control, anchor, false, false);
}

void inkCubicCurveTo(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor)
{
	inkCubicCurveTov(canvas, controlA, controlB, anchor, false, false);
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

void inkCurveTov(inkCanvas* canvas, inkPoint control, inkPoint anchor, bool relative, bool reflect)
{
	inkQuadraticCurveTov(canvas, control, anchor, relative, reflect);
}

void inkQuadraticCurveTov(inkCanvas* canvas, inkPoint control, inkPoint anchor, bool relative, bool reflect)
{
	if (canvas == NULL)
		return;

	if (reflect == false)
		control = inkPosition(canvas, control, relative);
	else
	{
		inkPoint cursor = canvas->cursor;
		control = inkPointAdd(inkPointSubtract(cursor, canvas->previousControl), cursor);
	}

	anchor = inkPosition(canvas, anchor, relative);

	inkQuadraticCurveToCommand command;
	command.control = control;
	command.anchor = anchor;

	inkAddCommand(canvas, inkCommandType_QuadraticCurveTo, &command);

	canvas->previousControl = control;

	inkSetCursor(canvas, anchor);
}

void inkCubicCurveTov(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor, bool relative, bool reflect)
{
	if (reflect == false)
	{
		controlA = inkPosition(canvas, controlA, relative);
		controlB = inkPosition(canvas, controlB, relative);
	}
	else
	{
		inkPoint cursor = canvas->cursor;
		controlA = inkPointAdd(inkPointSubtract(cursor, canvas->previousControl), cursor);
		controlB = inkPosition(canvas, controlB, relative);
	}

	anchor = inkPosition(canvas, anchor, relative);

	inkCubicCurveToCommand command;
	command.controlA = controlA;
	command.controlB = controlB;
	command.anchor = anchor;

	inkAddCommand(canvas, inkCommandType_CubicCurveTo, &command);

	canvas->previousControl = controlB;
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

	inkAddCommand(canvas, inkCommandType_LineBitmap, &command);
}

void inkLineGradientStyle(inkCanvas* canvas, inkGradientFill gradientFill)
{
	inkLineGradientCommand command = gradientFill;

	inkAddCommand(canvas, inkCommandType_LineGradient, &command);
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

inkPoint inkUpdatePositionv(inkPoint point, void* canvas)
{
	return point;
//	return inkUpdatePosition((inkCanvas*)canvas, point);
}

inkPoint inkUpdatePosition(inkCanvas* canvas, inkPoint point)
{
	if (canvas == NULL)
		return inkPointZero;

	return inkMatrixTransformPoint(canvas->matrix, point);
}

void inkCurveAdd(inkPoint point, void* userData)
{
	inkCurveGenerators generators = *((inkCurveGenerators*)userData);

	inkFillGeneratorLineTo(generators.fillGenerator, point);
	inkStrokeGeneratorLineTo(generators.strokeGenerator, point);
}

void inkCurve(inkCanvas* canvas, inkFillGenerator* fillGenerator, inkStrokeGenerator* strokeGenerator, inkCurveType curveType, inkPoint controlA, inkPoint controlB, inkPoint anchor)
{
	inkPoint start;

	if (fillGenerator != NULL && fillGenerator->generator != NULL)
		start = fillGenerator->generator->previous;
	else if (strokeGenerator != NULL && strokeGenerator->generator != NULL)
		start = strokeGenerator->generator->previous;
	else
		return;

	float arcLength = inkCurveLength(inkUpdatePositionv, canvas, curveType, start, controlA, controlB, anchor);

	inkCurveGenerators generators;
	generators.fillGenerator = fillGenerator;
	generators.strokeGenerator = strokeGenerator;

	inkCurveApproximation(inkUpdatePositionv, canvas, curveType, start, controlA, controlB, anchor, inkArcLengthSegmentCount(canvas, arcLength), inkCurveAdd, (void*)(&generators));
}

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
void inkBuild(inkCanvas* canvas)
{
	if (canvas == NULL)
		return;

	inkRemoveAllRenderGroups(canvas);

	inkArray* commandList = canvas->commandList;
	void* commandData;
	inkCommand* command;
	inkCommandType commandType;
	inkFillGenerator* fillGenerator = NULL;
	inkStrokeGenerator* strokeGenerator = NULL;

	inkTessellator* fillTessellator = inkGetFillTessellator();
	inkTessellator* strokeTessellator = inkGetStrokeTessellator();

	inkTessellatorSetIsStroke(fillTessellator, false);
	inkTessellatorSetIsStroke(strokeTessellator, true);

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

				inkPoint control = inkUpdatePosition(canvas, command->control);
				inkPoint anchor = inkUpdatePosition(canvas, command->anchor);
				inkCurve(canvas, fillGenerator, strokeGenerator, inkCurveType_Quadratic, inkPointZero, control, anchor);
			}
				break;
			case inkCommandType_CubicCurveTo:
			{
				inkCubicCurveToCommand* command = (inkCubicCurveToCommand*)(commandData);

				inkPoint controlA = inkUpdatePosition(canvas, command->controlA);
				inkPoint controlB = inkUpdatePosition(canvas, command->controlB);
				inkPoint anchor = inkUpdatePosition(canvas, command->anchor);
				inkCurve(canvas, fillGenerator, strokeGenerator, inkCurveType_Cubic, controlA, controlB, anchor);
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
					inkSize scale = inkMatrixSize(canvas->matrix);
					float val = fabsf(command->stroke.thickness);
					inkPoint thickness = inkPointMake(val, val);
					thickness = inkPointMultiply(thickness, inkPointFromSize(scale));
					command->stroke.thickness = (thickness.x + thickness.y) * 0.5f;
					strokeGenerator = inkStrokeGeneratorCreate(strokeTessellator, canvas, canvas->renderGroups, &(command->stroke));
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
	inkPoint minPointWithStroke = inkPointMax;
	inkPoint maxPointWithStroke = inkPointMin;

	inkArrayPtrForEach(renderGroups, renderGroup)
	{
		vertexArray = renderGroup->vertices;
		vertexCount = inkArrayCount(vertexArray);

		if (vertexCount == 0)
			continue;

		inkArrayForEach(vertexArray, vertex)
		{
			if (renderGroup->isStroke == false)
			{
				minPoint = inkPointMake(fminf(minPoint.x, vertex->x), fminf(minPoint.y, vertex->y));
				maxPoint = inkPointMake(fmaxf(maxPoint.x, vertex->x), fmaxf(maxPoint.y, vertex->y));
			}

			minPointWithStroke = inkPointMake(fminf(minPointWithStroke.x, vertex->x), fminf(minPointWithStroke.y, vertex->y));
			maxPointWithStroke = inkPointMake(fmaxf(maxPointWithStroke.x, vertex->x), fmaxf(maxPointWithStroke.y, vertex->y));
		}
	}

	canvas->bounds = inkRectMake(minPoint, inkSizeFromPoint(inkPointSubtract(maxPoint, minPoint)));
	canvas->boundsWithStroke = inkRectMake(minPointWithStroke, inkSizeFromPoint(inkPointSubtract(maxPointWithStroke, minPointWithStroke)));
}

// TODO:	Remove these methods. They only exist for easier debug call stack
//			tracing.
inkInline bool inkContainsPointSuccess()
{
	return true;
}

inkInline bool inkContainsPointFailure()
{
	return false;
}

bool inkContainsPoint(inkCanvas* canvas, inkPoint point, bool useBoundingBox, bool useStroke)
{
	inkArray* renderGroups = inkRenderGroups(canvas);

	if (renderGroups == NULL)
		return inkContainsPointFailure();

	inkRenderGroup* renderGroup;
	inkArray* vertexArray;
	INKvertex* vertex;
	inkTriangle triangle = inkTriangleZero;
	inkPoint firstPoint;

	unsigned int index;
	unsigned int vertexCount;

	inkRect bounds = useStroke ? canvas->boundsWithStroke : canvas->bounds;

	if (inkRectContainsPoint(bounds, point) == false)
		return inkContainsPointFailure();
	else if (useBoundingBox == true)
		return inkContainsPointSuccess();

	//point = inkPointMake(31.025f, 119.0f);
	inkArrayPtrForEach(renderGroups, renderGroup)
	{
		vertexArray = renderGroup->vertices;
		vertexCount = inkArrayCount(vertexArray);

		if (vertexCount == 0)
			continue;
		if (renderGroup->isStroke == true && useStroke == false)
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
						return inkContainsPointSuccess();
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
						return inkContainsPointSuccess();

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
						return inkContainsPointSuccess();
					}

					break;
			}

			++index;
		}
	}

	return inkContainsPointFailure();
}

void inkPushMatrix(inkCanvas* canvas)
{
	if (canvas == NULL)
		return;

	inkMatrix* matrixPtr = inkArrayPush(canvas->matrixStack);

	if (matrixPtr != NULL)
	{
		*matrixPtr = canvas->matrix;
	}
}

void inkPopMatrix(inkCanvas* canvas)
{
	if (canvas == NULL)
		return;

	inkArrayPop(canvas->matrixStack);

	unsigned int count = inkArrayCount(canvas->matrixStack);

	if (count == 0)
	{
		canvas->matrix = inkMatrixIdentity;
	}
	else
	{
		inkArrayElementAt(canvas->matrixStack, count - 1);
	}
}

void inkLoadMatrix(inkCanvas* canvas, inkMatrix matrix)
{
	if (canvas == NULL)
		return;

	canvas->matrix = matrix;
}

void inkMultMatrix(inkCanvas* canvas, inkMatrix matrix)
{
	if (canvas == NULL)
		return;

	canvas->matrix = inkMatrixMultiply(canvas->matrix, matrix);
}

void inkRotate(inkCanvas* canvas, float radians)
{
	if (canvas == NULL)
		return;

	canvas->matrix = inkMatrixRotate(canvas->matrix, radians);
}

void inkRotatef(inkCanvas* canvas, float radians)
{
	return inkRotate(canvas, radians);
}

void inkScale(inkCanvas* canvas, inkSize scale)
{
	if (canvas == NULL)
		return;

	canvas->matrix = inkMatrixScale(canvas->matrix, scale);
}

void inkScalef(inkCanvas* canvas, float x, float y)
{
	inkScale(canvas, inkSizeMake(x, y));
}

void inkTranslate(inkCanvas* canvas, inkPoint offset)
{
	if (canvas == NULL)
		return;

	canvas->matrix = inkMatrixTranslate(canvas->matrix, offset);
}

void inkTranslatef(inkCanvas* canvas, float x, float y)
{
	inkTranslate(canvas, inkPointMake(x, y));
}

unsigned int inkDraw(inkCanvas* canvas)
{
	return inkDrawv(canvas, inkRendererDefault);
}

unsigned int inkDrawv(inkCanvas* canvas, inkRenderer renderer)
{
	inkArray* renderGroups = inkRenderGroups(canvas);

	if (renderGroups == NULL)
		return 0;

	inkRenderGroup* renderGroup;
	inkArray* vertexArray;
	INKvertex* vertices;

	unsigned int vertexArrayCount;
	unsigned int totalVertexCount = 0;

	inkPresetGLData previousGLData;

	renderer.getIntegerFunc(GL_TEXTURE_BINDING_2D, (int*)&previousGLData.textureName);
	if (previousGLData.textureName != 0)
	{
		renderer.getTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, &previousGLData.magFilter);
		renderer.getTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, &previousGLData.minFilter);
		renderer.getTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, &previousGLData.wrapS);
		renderer.getTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, &previousGLData.wrapT);

		renderer.disableClientFunc(GL_COLOR_ARRAY);
		renderer.enableClientFunc(GL_TEXTURE_COORD_ARRAY);

		renderer.enableFunc(GL_TEXTURE_2D);
	}
	else
	{
		renderer.disableFunc(GL_TEXTURE_2D);
		renderer.enableClientFunc(GL_COLOR_ARRAY);
		renderer.disableClientFunc(GL_TEXTURE_COORD_ARRAY);
	}
	renderer.getFloatFunc(GL_POINT_SIZE, &previousGLData.pointSize);
	renderer.getFloatFunc(GL_LINE_WIDTH, &previousGLData.lineWidth);

	inkPresetGLData origGLData = previousGLData;
	inkPresetGLData startState = previousGLData;

	inkArrayPtrForEach(renderGroups, renderGroup)
	{
		vertexArray = renderGroup->vertices;

		if (previousGLData.pointSize != renderGroup->glData.pointSize)
		{
			previousGLData.pointSize = renderGroup->glData.pointSize;
			renderer.pointSizeFunc(renderGroup->glData.pointSize);
		}

		if (previousGLData.lineWidth != renderGroup->glData.lineWidth)
		{
			previousGLData.lineWidth = renderGroup->glData.lineWidth;
			renderer.pointSizeFunc(renderGroup->glData.lineWidth);
		}

		if (previousGLData.textureName != renderGroup->glData.textureName)
		{
			if (origGLData.textureName != 0)
			{
				if (origGLData.magFilter != previousGLData.magFilter)
					renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, origGLData.magFilter);
				if (origGLData.minFilter != previousGLData.minFilter)
					renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, origGLData.minFilter);
				if (origGLData.wrapS != previousGLData.wrapS)
					renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, origGLData.wrapS);
				if (origGLData.wrapT != previousGLData.wrapT)
					renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, origGLData.wrapT);
			}

			previousGLData.textureName = renderGroup->glData.textureName;

			if (previousGLData.textureName != 0)
			{
				renderer.disableClientFunc(GL_COLOR_ARRAY);
				renderer.enableClientFunc(GL_TEXTURE_COORD_ARRAY);

				renderer.enableFunc(GL_TEXTURE_2D);
				renderer.textureFunc(GL_TEXTURE_2D, renderGroup->glData.textureName);

				renderer.getTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, &previousGLData.magFilter);
				renderer.getTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, &previousGLData.minFilter);
				renderer.getTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, &previousGLData.wrapS);
				renderer.getTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, &previousGLData.wrapT);
			}
			else
			{
				renderer.disableFunc(GL_TEXTURE_2D);
				renderer.enableClientFunc(GL_COLOR_ARRAY);
				renderer.disableClientFunc(GL_TEXTURE_COORD_ARRAY);
			}

			origGLData = previousGLData;
		}

		if (previousGLData.textureName != 0)
		{
			if (previousGLData.magFilter != renderGroup->glData.magFilter)
			{
				previousGLData.magFilter = renderGroup->glData.magFilter;
				renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, renderGroup->glData.magFilter);
			}
			if (previousGLData.minFilter != renderGroup->glData.minFilter)
			{
				previousGLData.minFilter = renderGroup->glData.minFilter;
				renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, renderGroup->glData.minFilter);
			}
			if (previousGLData.wrapS != renderGroup->glData.wrapS)
			{
				previousGLData.wrapS = renderGroup->glData.wrapS;
				renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, renderGroup->glData.wrapS);
			}
			if (previousGLData.wrapT != renderGroup->glData.wrapT)
			{
				previousGLData.wrapT = renderGroup->glData.wrapT;
				renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, renderGroup->glData.wrapT);
			}
		}

		if (vertexArray != NULL)
		{
			vertices = vertexArray->elements;

			vertexArrayCount = inkArrayCount(vertexArray);
			totalVertexCount += vertexArrayCount;

			renderer.vertexFunc(2, GL_FLOAT, sizeof(INKvertex), &(vertices->x));
			renderer.textureCoordinateFunc(2, GL_FLOAT, sizeof(INKvertex), &(vertices->s));
			renderer.colorFunc(4, GL_UNSIGNED_BYTE, sizeof(INKvertex), &(vertices->r));

			renderer.drawArraysFunc(renderGroup->glDrawMode, 0, vertexArrayCount);
		}
	}

	if (origGLData.textureName != previousGLData.textureName)
	{
		if (origGLData.textureName != 0)
		{
			if (origGLData.magFilter != previousGLData.magFilter)
				renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, origGLData.magFilter);
			if (origGLData.minFilter != previousGLData.minFilter)
				renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, origGLData.minFilter);
			if (origGLData.wrapS != previousGLData.wrapS)
				renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, origGLData.wrapS);
			if (origGLData.wrapT != previousGLData.wrapT)
				renderer.setTexParamFunc(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, origGLData.wrapT);
		}

		if (startState.textureName != 0)
		{
			renderer.disableClientFunc(GL_COLOR_ARRAY);
			renderer.enableClientFunc(GL_TEXTURE_COORD_ARRAY);

			renderer.enableFunc(GL_TEXTURE_2D);
			renderer.textureFunc(GL_TEXTURE_2D, startState.textureName);
		}
		else
		{
			renderer.disableFunc(GL_TEXTURE_2D);
			renderer.enableClientFunc(GL_COLOR_ARRAY);
			renderer.disableClientFunc(GL_TEXTURE_COORD_ARRAY);
		}
	}

	return totalVertexCount;
}
