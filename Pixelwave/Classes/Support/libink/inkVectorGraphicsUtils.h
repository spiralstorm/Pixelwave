//
//  inkVectorGraphicsUtils.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_VECTOR_GRAPHICS_UTILS_H_
#define _INK_VECTOR_GRAPHICS_UTILS_H_

#include "inkHeader.h"
#include "inkCanvas.h"
#include "inkGeometry.h"

#include "inkTypes.h"
#include "inkVectorGraphics.h"

inkExtern void inkDrawCircle(inkCanvas* canvas, inkPoint position, float radius);
inkExtern void inkDrawEllipse(inkCanvas* canvas, inkRect boundingRect);
inkExtern void inkDrawRect(inkCanvas* canvas, inkRect rect);
inkExtern void inkDrawRoundRect(inkCanvas* canvas, inkRect rect, inkSize ellipseSize);

inkExtern void inkDrawPath(inkCanvas* canvas, inkArray* commands, inkArray* points, inkWindingRule winding);

inkExtern void inkDrawSVGPath(inkCanvas* canvas, const char* path);
inkExtern void inkDrawSVGPathv(inkCanvas* canvas, const char* path, inkPoint offset);

inkExtern int inkDrawHersheyFont(inkCanvas* canvas, const char* path);

// MARK: -
// MARK: Helper Declarations
// MARK: -

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

inkInline void inkCurveToc(inkCanvas* canvas, inkPoint anchor);
inkInline void inkQuadraticCurveToc(inkCanvas* canvas, inkPoint anchor);
inkInline void inkCubicCurveToc(inkCanvas* canvas, inkPoint control, inkPoint anchor);

inkInline void inkCurveTofc(inkCanvas* canvas, float anchorX, float anchorY);
inkInline void inkQuadraticCurveTofc(inkCanvas* canvas, float anchorX, float anchorY);
inkInline void inkCubicCurveTofc(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY);

inkInline void inkMoveTofv(inkCanvas* canvas, float x, float y, bool relative);
inkInline void inkLineTofv(inkCanvas* canvas, float x, float y, bool relative);
inkInline void inkCurveTofv(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY, bool relative, bool reflect);
inkInline void inkQuadraticCurveTofv(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY, bool relative, bool reflect);
inkInline void inkCubicCurveTofv(inkCanvas* canvas, float controlAX, float controlAY, float controlBX, float controlBY, float anchorX, float anchorY, bool relative, bool reflect);

inkInline void inkBeginFillf(inkCanvas* canvas, unsigned int color, float alpha);
inkInline void inkLineStylef(inkCanvas* canvas, float thickness, bool pixelHinting, inkLineScaleMode scaleMode, inkCapsStyle caps, inkJointStyle joints, float miterLimit, unsigned int color, float alpha);

// MARK: -
// MARK: Helper Implementations
// MARK: -

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

inkInline void inkCurveToc(inkCanvas* canvas, inkPoint anchor)
{
	inkQuadraticCurveToc(canvas, anchor);
}

inkInline void inkQuadraticCurveToc(inkCanvas* canvas, inkPoint anchor)
{
	inkQuadraticCurveTov(canvas, inkPointZero, anchor, false, true);
}

inkInline void inkCubicCurveToc(inkCanvas* canvas, inkPoint control, inkPoint anchor)
{
	inkCubicCurveTov(canvas, inkPointZero, control, anchor, false, true);
}

inkInline void inkCurveTofc(inkCanvas* canvas, float anchorX, float anchorY)
{
	inkQuadraticCurveTofc(canvas, anchorX, anchorY);
}

inkInline void inkQuadraticCurveTofc(inkCanvas* canvas, float anchorX, float anchorY)
{
	inkQuadraticCurveTov(canvas, inkPointZero, inkPointMake(anchorX, anchorY), false, true);
}

inkInline void inkCubicCurveTofc(inkCanvas* canvas, float controlX, float controlY, float anchorX, float anchorY)
{
	inkCubicCurveTov(canvas, inkPointZero, inkPointMake(controlX, controlY), inkPointMake(anchorX, anchorY), false, true);
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
