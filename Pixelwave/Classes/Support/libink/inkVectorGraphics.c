//
//  inkVectorGraphics.c
//  ink
//
//  Created by John Lattin on 11/7/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkVectorGraphics.h"

#include "inkTessellator.h"

// We use a shared tessellator because the 'rasterization' step, where
// tessellation is done, should ONLY ever happen on the main thread.
//static PXTessellator *pxGraphicsUtilsSharedTesselator = NULL;

_PXGraphics *_PXGraphicsCreate()
{
	// TODO: Implement

	return NULL;
}

void _PXGraphicsDestroy(_PXGraphics *graphics)
{
	// TODO: Implement
}

_PXGraphicsRenderGroup *_PXGraphicsRenderGroupCreate()
{
	// TODO: Implement

	return NULL;
}

_PXGraphicsRenderGroup *_PXGraphicsRenderGroupCreatev(size_t vertexSize, GLenum drawMode)
{
	// TODO: Implement

	return NULL;
}

void _PXGraphicsRenderGroupDestroy(_PXGraphicsRenderGroup *group)
{
	// TODO: Implement
}

_PXGraphicsCommand *_PXGraphicsCommandCreate()
{
	// TODO: Implement

	return NULL;
}

void _PXGraphicsCommandDestroy(_PXGraphicsCommand *command)
{
	// TODO: Implement
}

void _PXGraphicsCommandAdd(_PXGraphicsCommand *command, PXPathCommand pathCommand, void *data)
{
	// TODO: Implement
}

#pragma mark -
#pragma mark Clearing
#pragma mark -

void PXGraphicsUtilsClear(_PXGraphics *graphics)
{
	// TODO: Implement
}

#pragma mark -
#pragma mark Moving the cursor
#pragma mark -

void PXGraphicsUtilsMoveTo(_PXGraphics *graphics, float x, float y)
{
	// TODO: Implement
}

void PXGraphicsUtilsLineTo(_PXGraphics *graphics, float x, float y)
{
	// TODO: Implement
}

void PXGraphicsUtilsCurveTo(_PXGraphics *graphics, float controlX, float controlY, float anchorX, float anchorY)
{
	// TODO: Implement
}

#pragma mark -
#pragma mark Fills
#pragma mark -

void PXGraphicsUtilsBeginFill(_PXGraphics *graphics, unsigned int color, float alpha)
{
	// TODO: Implement
}

void PXGraphicsUtilsBeginBitmapFill(_PXGraphics *graphics, PXGLMatrix *matrix, float sPerPoint, float tPerPoint, bool repeat, bool smooth, void *userData)
{
	// TODO: Implement
}

void PXGraphicsUtilsBeginGradientFill(_PXGraphics *graphics, PXGradientType type, unsigned int *colors, float *alphas, unsigned int colorCount, float *ratios, unsigned int ratioCount, PXGLMatrix *matrix, PXSpreadMethod spreadMethod, PXInterpolationMethod interpolationMethod, float focalPointRatio)
{
	// TODO: Implement
}

#pragma mark -
#pragma mark Lines
#pragma mark -

void PXGraphicsUtilsLineStyle(_PXGraphics *graphics, float thickness, unsigned int color, float alpha, bool pixelHinting, PXLineScaleMode scaleMode, PXCapsStyle caps, PXJointStyle joints, float miterLimit)
{
	// TODO: Implement
}

void PXGraphicsUtilsLineBitmapStyle(_PXGraphics *graphics, PXGLMatrix *matrix, float sPerPoint, float tPerPoint, bool repeat, bool smooth, void *userData)
{
	// TODO: Implement
}

void PXGraphicsUtilsLineGradientStyle(_PXGraphics *graphics, PXGradientType type, unsigned int *colors, float *alphas, unsigned int colorCount, float *ratios, unsigned int ratioCount, PXGLMatrix *matrix, PXSpreadMethod spreadMethod, PXInterpolationMethod interpolationMethod, float focalPointRatio)
{
	// TODO: Implement
}

#pragma mark -
#pragma mark Ending
#pragma mark -

void PXGraphicsUtilsEndFill(_PXGraphics *graphics)
{
	// TODO: Implement
}

void PXGraphicsUtilsRasterize(_PXGraphics *graphics)
{
	// TODO: Implement
}
