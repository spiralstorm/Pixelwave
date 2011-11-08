//
//  PXGraphicsUtils.h
//  TesselationTest
//
//  Created by John Lattin on 11/7/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _PX_GRAPHICS_UTILS_H_
#define _PX_GRAPHICS_UTILS_H_

#include "PXHeaderUtils.h"

#include "PXGLUtils.h"
#include "PXArrayBuffer.h"
#include "PXGraphicsUtilTypes.h"

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark -
#pragma mark Structs
#pragma mark -

typedef struct
{
	PXArrayBuffer *vertices;

	GLenum drawMode;
} _PXGraphicsRenderGroup;

typedef struct
{
	PXArrayBuffer *commandList;
	PXArrayBuffer *renderGroups;
} _PXGraphics;

_PXGraphics *_PXGraphisCreate();
void _PXGraphicsDestroy(_PXGraphics *graphics);

_PXGraphicsRenderGroup *_PXGraphicsRenderGroupCreate();
_PXGraphicsRenderGroup *_PXGraphicsRenderGroupCreatev(size_t vertexSize, GLenum drawMode);

void _PXGraphicsRenderGroupDestroy(_PXGraphicsRenderGroup *group);

#pragma mark -
#pragma mark Clearing
#pragma mark -

void PXGraphicsUtilsClear(_PXGraphics *graphics);

#pragma mark -
#pragma mark Moving the cursor
#pragma mark -

void PXGraphicsUtilsMoveTo(_PXGraphics *graphics, float x, float y);
void PXGraphicsUtilsLineTo(_PXGraphics *graphics, float x, float y);
void PXGraphicsUtilsCurveTo(_PXGraphics *graphics, float controlX, float controlY, float anchorX, float anchorY);

#pragma mark -
#pragma mark Fills
#pragma mark -

void PXGraphicsUtilsBeginFill(_PXGraphics *graphics, unsigned int color, float alpha);
void PXGraphicsUtilsBeginBitmapFill(_PXGraphics *graphics, PXGLMatrix *matrix, float sPerPoint, float tPerPoint, bool repeat, bool smooth, void *userData);
void PXGraphicsUtilsBeginGradientFill(_PXGraphics *graphics, PXGradientType type, unsigned int *colors, float *alphas, unsigned int colorCount, float *ratios, unsigned int ratioCount, PXGLMatrix *matrix, PXSpreadMethod spreadMethod, PXInterpolationMethod interpolationMethod, float focalPointRatio);

#pragma mark -
#pragma mark Lines
#pragma mark -

void PXGraphicsUtilsLineStyle(_PXGraphics *graphics, float thickness, unsigned int color, float alpha, bool pixelHinting, PXLineScaleMode scaleMode, PXCapsStyle caps, PXJointStyle joints, float miterLimit);
void PXGraphicsUtilsLineBitmapStyle(_PXGraphics *graphics, PXGLMatrix *matrix, float sPerPoint, float tPerPoint, bool repeat, bool smooth, void *userData);
void PXGraphicsUtilsLineGradientStyle(_PXGraphics *graphics, PXGradientType type, unsigned int *colors, float *alphas, unsigned int colorCount, float *ratios, unsigned int ratioCount, PXGLMatrix *matrix, PXSpreadMethod spreadMethod, PXInterpolationMethod interpolationMEthod, float focalPointRatio);

#pragma mark -
#pragma mark Ending
#pragma mark -

void PXGraphicsUtilsEndFill(_PXGraphics *graphics);

void PXGraphicsUtilsRasterize(_PXGraphics *graphics);

#pragma mark -
#pragma mark Helper
#pragma mark -

void PXGraphicsUtilsDrawCircle(_PXGraphics *graphics, float x, float y, float radius);
void PXGraphicsUtilsDrawEllipse(_PXGraphics *graphics, float x, float y, float width, float height);
void PXGraphicsUtilsDrawRect(_PXGraphics *graphics, float x, float y, float width, float height);
void PXGraphicsUtilsDrawRoundRect(_PXGraphics *graphics, float x, float y, float width, float height, float ellipseWidth, float ellipseHeight);

#ifdef __cplusplus
}
#endif

#endif
