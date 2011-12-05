//
//  inkVectorGraphics.h
//  ink
//
//  Created by John Lattin on 11/7/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_VECTOR_GRAPHICS_H_
#define _INK_VECTOR_GRAPHICS_H_

#include "inkHeader.h"
#include "inkArray.h"
#include "inkTypes.h"
#include "inkCanvas.h"
#include "inkFill.h"
#include "inkStroke.h"

inkExtern void inkClear(inkCanvas* canvas);

// TODO: Make x and y counterparts that call into the real function

inkExtern void inkMoveTo(inkCanvas* canvas, inkPoint position);
inkExtern void inkLineTo(inkCanvas* canvas, inkPoint position);
inkExtern void inkCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor);
inkExtern void inkQuadraticCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor);
inkExtern void inkCubicCurveTo(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor);

inkExtern void inkMoveTov(inkCanvas* canvas, inkPoint position, bool relative);
inkExtern void inkLineTov(inkCanvas* canvas, inkPoint position, bool relative);
inkExtern void inkCurveTov(inkCanvas* canvas, inkPoint control, inkPoint anchor, bool relative);
inkExtern void inkQuadraticCurveTov(inkCanvas* canvas, inkPoint control, inkPoint anchor, bool relative);
inkExtern void inkCubicCurveTov(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor, bool relative);

inkExtern void inkBeginFill(inkCanvas* canvas, inkSolidFill solidFill);
inkExtern void inkBeginBitmapFill(inkCanvas* canvas, inkBitmapFill bitmapFill);
inkExtern void inkBeginGradientFill(inkCanvas* canvas, inkGradientFill gradientFill);

inkExtern void inkLineStyle(inkCanvas* canvas, inkStroke stroke, inkSolidFill solidFill);
inkExtern void inkLineBitmapStyle(inkCanvas* canvas, inkBitmapFill bitmapFill);
inkExtern void inkLineGradientStyle(inkCanvas* canvas, inkGradientFill gradientFill);

inkExtern void inkEndFill(inkCanvas* canvas);
inkExtern void inkLineStyleNone(inkCanvas* canvas);

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
inkExtern void inkBuild(inkCanvas* canvas);

inkExtern bool inkContainsPoint(inkCanvas* canvas, inkPoint point, bool useBoundingBox);

inkExtern unsigned int inkDraw(inkCanvas* canvas);
inkExtern unsigned int inkDrawv(inkCanvas* canvas, inkStateFunction enableFunc, inkStateFunction disableFunc, inkStateFunction enableClientFunc, inkStateFunction disableClientFunc, inkPointSizeFunction pointSizeFunc, inkLineWidthFunction lineWidthFunc, inkTextureFunction textureFunc, inkPointerFunction vertexFunc, inkPointerFunction textureCoordinateFunc, inkPointerFunction colorFunc, inkDrawArraysFunction drawArraysFunc, inkDrawElementsFunction drawElementsFunc);

#endif
