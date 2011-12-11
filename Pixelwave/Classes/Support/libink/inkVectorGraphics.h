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

inkExtern void inkMoveTo(inkCanvas* canvas, inkPoint position);
inkExtern void inkLineTo(inkCanvas* canvas, inkPoint position);
inkExtern void inkCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor);
inkExtern void inkQuadraticCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor);
inkExtern void inkCubicCurveTo(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor);

inkExtern void inkMoveTov(inkCanvas* canvas, inkPoint position, bool relative);
inkExtern void inkLineTov(inkCanvas* canvas, inkPoint position, bool relative);
inkExtern void inkCurveTov(inkCanvas* canvas, inkPoint control, inkPoint anchor, bool relative, bool reflect);
inkExtern void inkQuadraticCurveTov(inkCanvas* canvas, inkPoint control, inkPoint anchor, bool relative, bool reflect);
inkExtern void inkCubicCurveTov(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor, bool relative, bool reflect);

inkExtern void inkBeginFill(inkCanvas* canvas, inkSolidFill solidFill);
inkExtern void inkBeginBitmapFill(inkCanvas* canvas, inkBitmapFill bitmapFill);
inkExtern void inkBeginGradientFill(inkCanvas* canvas, inkGradientFill gradientFill);

inkExtern void inkLineStyle(inkCanvas* canvas, inkStroke stroke, inkSolidFill solidFill);
inkExtern void inkLineBitmapStyle(inkCanvas* canvas, inkBitmapFill bitmapFill);
inkExtern void inkLineGradientStyle(inkCanvas* canvas, inkGradientFill gradientFill);

inkExtern void inkWindingStyle(inkCanvas* canvas, inkWindingRule winding);

inkExtern void inkEndFill(inkCanvas* canvas);
inkExtern void inkLineStyleNone(inkCanvas* canvas);

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
inkExtern void inkBuild(inkCanvas* canvas);

inkExtern bool inkContainsPoint(inkCanvas* canvas, inkPoint point, bool useBoundingBox, bool useStroke);
inkExtern unsigned int inkArcLengthSegmentCount(inkCanvas* canvas, float arcLength);

inkExtern void inkPushMatrix(inkCanvas* canvas);
inkExtern void inkPopMatrix(inkCanvas* canvas);
inkExtern void inkLoadMatrix(inkCanvas* canvas, inkMatrix matrix);
inkExtern void inkMultMatrix(inkCanvas* canvas, inkMatrix matrix);
inkExtern void inkRotate(inkCanvas* canvas, float radians);
inkExtern void inkRotatef(inkCanvas* canvas, float radians);
inkExtern void inkScale(inkCanvas* canvas, inkSize scale);
inkExtern void inkScalef(inkCanvas* canvas, float x, float y);
inkExtern void inkTranslate(inkCanvas* canvas, inkPoint offset);
inkExtern void inkTranslatef(inkCanvas* canvas, float x, float y);

inkExtern unsigned int inkDraw(inkCanvas* canvas);
inkExtern unsigned int inkDrawv(inkCanvas* canvas, inkRenderer renderer);

#endif
