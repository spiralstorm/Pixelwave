//
//  PXGraphicsUtilTypes.h
//  TesselationTest
//
//  Created by John Lattin on 11/7/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _PX_GRAPHICS_UTIL_TYPES_H_
#define _PX_GRAPHICS_UTIL_TYPES_H_

typedef enum
{
	PXSpreadMethod_Pad = 0,
	PXSpreadMethod_Reflect,
	PXSpreadMethod_Repeat
} PXSpreadMethod;

typedef enum
{
	PXInterpolationMethod_LinearRGB = 0,
	PXInterpolationMethod_RGB
} PXInterpolationMethod;

typedef enum
{
	PXGradientType_Linear = 0,
	PXGradientType_Radial
} PXGradientType;

typedef enum
{
	PXGraphicsPathWinding_EvenOdd = 0,
	PXGraphicsPathWinding_NonZero
} PXGraphicsPathWinding;

typedef enum
{
	PXTriangleCulling_Negative = -1,
	PXTriangleCulling_None,
	PXTriangleCulling_Posative
} PXTriangleCulling;

typedef enum
{
	PXJointStyle_Bevel = 0,
	PXJointStyle_Miter,
	PXJointStyle_Round
} PXJointStyle;

typedef enum
{
	PXLineScaleMode_Horizontal = -1,
	PXLineScaleMode_None,
	PXLineScaleMode_Normal,
	PXLineScaleMode_Vertical
} PXLineScaleMode;

typedef enum
{
	PXCapsStyle_None = 0,
	PXCapsStyle_Round,
	PXCapsStyle_Square
} PXCapsStyle;

typedef enum
{
	PXPathCommand_NoOp = 0,
	PXPathCommand_MoveTo,
	PXPathCommand_LineTo,
	PXPathCommand_CurveTo,
	PXPathCommand_WideMoveTo,
	PXPathCommand_WideLineTo
} PXPathCommand;

#endif
