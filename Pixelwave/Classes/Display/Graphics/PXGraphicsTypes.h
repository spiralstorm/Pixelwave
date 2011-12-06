//
//  PXGraphicsTypes.h
//  Pixelwave
//
//  Created by John Lattin on 12/6/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _PX_GRAPHICS_TYPES_H_
#define _PX_GRAPHICS_TYPES_H_

#include "inkTypes.h"

typedef enum
{
	PXFillType_Solid = inkFillType_Solid,
	PXFillType_Bitmap = inkFillType_Bitmap,
	PXFillType_Gradient = inkFillType_Gradient
} PXFillType;

typedef enum
{
	PXSpreadMethod_Pad = inkSpreadMethod_Pad,
	PXSpreadMethod_Reflect = inkSpreadMethod_Reflect,
	PXSpreadMethod_Repeat = inkSpreadMethod_Repeat
} PXSpreadMethod;

typedef enum
{
	PXInterpolationMethod_LinearRGB = inkInterpolationMethod_LinearRGB,
	PXInterpolationMethod_RGB = inkInterpolationMethod_RGB
} PXInterpolationMethod;

typedef enum
{
	PXGradientType_Linear = inkGradientType_Linear,
	PXGradientType_Radial = inkGradientType_Radial
} PXGradientType;

typedef enum
{
	PXPathWinding_EvenOdd = inkPathWinding_EvenOdd,
	PXPathWinding_NonZero = inkPathWinding_NonZero
} PXPathWinding;

typedef enum
{
	PXTriangleCulling_Negative = inkTriangleCulling_Negative,
	PXTriangleCulling_None = inkTriangleCulling_None,
	PXTriangleCulling_Posative = inkTriangleCulling_Posative
} PXTriangleCulling;

typedef enum
{
	PXJointStyle_Bevel = inkJointStyle_Bevel,
	PXJointStyle_Miter = inkJointStyle_Miter,
	PXJointStyle_Round = inkJointStyle_Round
} PXJointStyle;

typedef enum
{
	PXLineScaleMode_Horizontal = inkLineScaleMode_Horizontal,
	PXLineScaleMode_None = inkLineScaleMode_None,
	PXLineScaleMode_Normal = inkLineScaleMode_Normal,
	PXLineScaleMode_Vertical = inkLineScaleMode_Vertical
} PXLineScaleMode;

typedef enum
{
	PXCapsStyle_None = inkCapsStyle_None,
	PXCapsStyle_Round = inkCapsStyle_Round,
	PXCapsStyle_Square = inkCapsStyle_Square
} PXCapsStyle;

typedef enum
{
	PXPathCommand_NoOp = inkPathCommand_NoOp,
	PXPathCommand_MoveTo = inkPathCommand_MoveTo,
	PXPathCommand_LineTo = inkPathCommand_LineTo,
	PXPathCommand_CurveTo = inkPathCommand_QuadraticCurveTo,
	PXPathCommand_WideMoveTo = inkPathCommand_WideMoveTo,
	PXPathCommand_WideLineTo = inkPathCommand_WideLineTo
} PXPathCommand;

/*
typedef enum
{
	inkCommandType_MoveTo = 0,
	inkCommandType_LineTo,
	inkCommandType_QuadraticCurveTo,
	inkCommandType_CubicCurveTo,
	inkCommandType_SolidFill,
	inkCommandType_BitmapFill,
	inkCommandType_GradientFill,
	inkCommandType_LineStyle,
	inkCommandType_LineBitmap,
	inkCommandType_LineGradient,
	inkCommandType_EndFill
} PXCommandType;

typedef enum
{
	inkWindingRule_EvenOdd = 0,
	inkWindingRule_NonZero,
	inkWindingRule_Positive,
	inkWindingRule_Negative,
	inkWindingRule_AbsGeqTwo
} PXWindingRule;
*/

#endif
