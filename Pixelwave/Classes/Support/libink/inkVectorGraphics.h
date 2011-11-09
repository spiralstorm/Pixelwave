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

inkExtern void PXGraphicsUtilsClear(ink_t* graphics);

inkExtern void PXGraphicsUtilsMoveTo(ink_t* graphics, float x, float y);
inkExtern void PXGraphicsUtilsLineTo(ink_t* graphics, float x, float y);
inkExtern void PXGraphicsUtilsCurveTo(ink_t* graphics, float controlX, float controlY, float anchorX, float anchorY);

inkExtern void PXGraphicsUtilsBeginFill(ink_t* graphics, unsigned int color, float alpha);
inkExtern void PXGraphicsUtilsBeginBitmapFill(ink_t* graphics, PXGLMatrix *matrix, float sPerPoint, float tPerPoint, bool repeat, bool smooth, void *userData);
inkExtern void PXGraphicsUtilsBeginGradientFill(ink_t* graphics, PXGradientType type, unsigned int *colors, float *alphas, unsigned int colorCount, float *ratios, unsigned int ratioCount, PXGLMatrix *matrix, PXSpreadMethod spreadMethod, PXInterpolationMethod interpolationMethod, float focalPointRatio);

inkExtern void PXGraphicsUtilsLineStyle(ink_t* graphics, float thickness, unsigned int color, float alpha, bool pixelHinting, PXLineScaleMode scaleMode, PXCapsStyle caps, PXJointStyle joints, float miterLimit);
inkExtern void PXGraphicsUtilsLineBitmapStyle(ink_t* graphics, PXGLMatrix *matrix, float sPerPoint, float tPerPoint, bool repeat, bool smooth, void *userData);
inkExtern void PXGraphicsUtilsLineGradientStyle(ink_t* graphics, PXGradientType type, unsigned int *colors, float *alphas, unsigned int colorCount, float *ratios, unsigned int ratioCount, PXGLMatrix *matrix, PXSpreadMethod spreadMethod, PXInterpolationMethod interpolationMethod, float focalPointRatio);

inkExtern void PXGraphicsUtilsEndFill(ink_t* graphics);

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
inkExtern void PXGraphicsUtilsRasterize(ink_t* graphics);

#ifdef __cplusplus
}
#endif

#endif
