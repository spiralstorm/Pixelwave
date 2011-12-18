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

inkInline void inkMoveTo(inkCanvas* canvas, inkPoint position);
inkInline void inkLineTo(inkCanvas* canvas, inkPoint position);
inkInline void inkCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor);
inkInline void inkQuadraticCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor);
inkInline void inkCubicCurveTo(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor);

inkInline void inkMoveTof(inkCanvas* canvas, float x, float y);
inkInline void inkLineTof(inkCanvas* canvas, float x, float y);
inkInline void inkCurveTof(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY);
inkInline void inkQuadraticCurveTof(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY);
inkInline void inkCubicCurveTof(inkCanvas* canvas, float controlAX, float controlAY, float controlBX, float controlBY, float anchorX, float anchorY);

inkInline void inkMoveTofv(inkCanvas* canvas, float x, float y, bool relative);
inkInline void inkLineTofv(inkCanvas* canvas, float x, float y, bool relative);
inkInline void inkCurveTofv(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY, bool relative, bool reflect);
inkInline void inkQuadraticCurveTofv(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY, bool relative, bool reflect);
inkInline void inkCubicCurveTofv(inkCanvas* canvas, float controlAX, float controlAY, float controlBX, float controlBY, float anchorX, float anchorY, bool relative, bool reflect);

inkExtern void inkClear(inkCanvas* canvas);

inkExtern void inkMoveTov(inkCanvas* canvas, inkPoint position, bool relative);
inkExtern void inkLineTov(inkCanvas* canvas, inkPoint position, bool relative);
inkExtern void inkCurveTov(inkCanvas* canvas, inkPoint control, inkPoint anchor, bool relative, bool reflect);
inkExtern void inkQuadraticCurveTov(inkCanvas* canvas, inkPoint control, inkPoint anchor, bool relative, bool reflect);
inkExtern void inkCubicCurveTov(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor, bool relative, bool reflect);

inkInline void inkBeginFillf(inkCanvas* canvas, unsigned int color, float alpha);
inkInline void inkLineStylef(inkCanvas* canvas, float thickness, bool pixelHinting, inkLineScaleMode scaleMode, inkCapsStyle caps, inkJointStyle joints, float miterLimit, unsigned int color, float alpha);

inkExtern void inkBeginFill(inkCanvas* canvas, inkSolidFill solidFill);
inkExtern void inkBeginBitmapFill(inkCanvas* canvas, inkBitmapFill bitmapFill);
inkExtern void inkBeginGradientFill(inkCanvas* canvas, inkGradientFill gradientFill);

inkExtern void inkLineStyle(inkCanvas* canvas, inkStroke stroke, inkSolidFill solidFill);
inkExtern void inkLineBitmapStyle(inkCanvas* canvas, inkBitmapFill bitmapFill);
inkExtern void inkLineGradientStyle(inkCanvas* canvas, inkGradientFill gradientFill);

inkExtern void inkWindingStyle(inkCanvas* canvas, inkWindingRule winding);
inkExtern void inkUserData(inkCanvas* canvas, void* userData);

inkExtern void inkEndFill(inkCanvas* canvas);
inkExtern void inkLineStyleNone(inkCanvas* canvas);

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
inkExtern void inkBuild(inkCanvas* canvas);

inkExtern inkRenderGroup* inkContainsPoint(inkCanvas* canvas, inkPoint point, bool useBoundingBox, bool useStroke);
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
inkExtern unsigned int inkDrawv(inkCanvas* canvas, inkRenderer* renderer);

inkInline void inkMoveTo(inkCanvas* canvas, inkPoint position)
{
	inkMoveTov(canvas, position, false);
}

inkInline void inkLineTo(inkCanvas* canvas, inkPoint position)
{
	inkLineTov(canvas, position, false);
}

inkInline void inkCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor)
{
	inkCurveTov(canvas, control, anchor, false, false);
}

inkInline void inkQuadraticCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor)
{
	inkQuadraticCurveTov(canvas, control, anchor, false, false);
}

inkInline void inkCubicCurveTo(inkCanvas* canvas, inkPoint controlA, inkPoint controlB, inkPoint anchor)
{
	inkCubicCurveTov(canvas, controlA, controlB, anchor, false, false);
}

inkInline void inkMoveTof(inkCanvas* canvas, float x, float y)
{
	inkMoveTo(canvas, inkPointMake(x, y));
}

inkInline void inkLineTof(inkCanvas* canvas, float x, float y)
{
	inkLineTo(canvas, inkPointMake(x, y));
}

inkInline void inkCurveTof(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY)
{
	inkCurveTo(canvas, inkPointMake(controlX, controlY), inkPointMake(anchorX, anchorY));
}

inkInline void inkQuadraticCurveTof(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY)
{
	inkQuadraticCurveTo(canvas, inkPointMake(controlX, controlY), inkPointMake(anchorX, anchorY));
}

inkInline void inkCubicCurveTof(inkCanvas* canvas, float controlAX, float controlAY, float controlBX, float controlBY, float anchorX, float anchorY)
{
	inkCubicCurveTo(canvas, inkPointMake(controlAX, controlAY), inkPointMake(controlBX, controlBY), inkPointMake(anchorX, anchorY));
}

inkInline void inkMoveTofv(inkCanvas* canvas, float x, float y, bool relative)
{
	inkMoveTov(canvas, inkPointMake(x, y), relative);
}

inkInline void inkLineTofv(inkCanvas* canvas, float x, float y, bool relative)
{
	inkLineTov(canvas, inkPointMake(x, y), relative);
}

inkInline void inkCurveTofv(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY, bool relative, bool reflect)
{
	inkCurveTov(canvas, inkPointMake(controlX, controlY), inkPointMake(anchorX, anchorY), relative, reflect);
}

inkInline void inkQuadraticCurveTofv(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY, bool relative, bool reflect)
{
	inkQuadraticCurveTov(canvas, inkPointMake(controlX, controlY), inkPointMake(anchorX, anchorY), relative, reflect);
}

inkInline void inkCubicCurveTofv(inkCanvas* canvas, float controlAX, float controlAY, float controlBX, float controlBY, float anchorX, float anchorY, bool relative, bool reflect)
{
	inkCubicCurveTov(canvas, inkPointMake(controlAX, controlAY), inkPointMake(controlBX, controlBY), inkPointMake(anchorX, anchorY), relative, reflect);
}

inkInline void inkBeginFillf(inkCanvas* canvas, unsigned int color, float alpha)
{
	inkBeginFill(canvas, inkSolidFillMake(color, alpha));
}

inkInline void inkLineStylef(inkCanvas* canvas, float thickness, bool pixelHinting, inkLineScaleMode scaleMode, inkCapsStyle caps, inkJointStyle joints, float miterLimit, unsigned int color, float alpha)
{
	inkLineStyle(canvas, inkStrokeMake(thickness, pixelHinting, scaleMode, caps, joints, miterLimit), inkSolidFillMake(color, alpha));
}

#endif
