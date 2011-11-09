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
	PXArrayBuffer *data;

	PXPathCommand pathCommand;
} _PXGraphicsCommand;

typedef struct
{
	PXArrayBuffer *commandList;
	PXArrayBuffer *renderGroups;
} _PXGraphics;

_PXGraphics *_PXGraphicsCreate();
void _PXGraphicsDestroy(_PXGraphics *graphics);

_PXGraphicsRenderGroup *_PXGraphicsRenderGroupCreate();
_PXGraphicsRenderGroup *_PXGraphicsRenderGroupCreatev(size_t vertexSize, GLenum drawMode);

void _PXGraphicsRenderGroupDestroy(_PXGraphicsRenderGroup *group);

_PXGraphicsCommand *_PXGraphicsCommandCreate();
void _PXGraphicsCommandDestroy(_PXGraphicsCommand *command);
void _PXGraphicsCommandAdd(_PXGraphicsCommand *command, PXPathCommand pathCommand, void *data);

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
void PXGraphicsUtilsLineGradientStyle(_PXGraphics *graphics, PXGradientType type, unsigned int *colors, float *alphas, unsigned int colorCount, float *ratios, unsigned int ratioCount, PXGLMatrix *matrix, PXSpreadMethod spreadMethod, PXInterpolationMethod interpolationMethod, float focalPointRatio);

#pragma mark -
#pragma mark Ending
#pragma mark -

void PXGraphicsUtilsEndFill(_PXGraphics *graphics);

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
void PXGraphicsUtilsRasterize(_PXGraphics *graphics);

#ifdef __cplusplus
}
#endif

#endif
