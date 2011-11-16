//
//  inkTypes.h
//  ink
//
//  Created by John Lattin on 11/7/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_TYPES_H_
#define _INK_TYPES_H_

typedef struct
{
	float x, y;
	unsigned char r, g, b, a;
	float s, t;
} INKvertex;

typedef unsigned int INKenum;

typedef enum
{
	inkFillType_Solid = 0,
	inkFillType_Bitmap,
	inkFillType_Gradient
} inkFillType;

typedef enum
{
	inkSpreadMethod_Pad = 0,
	inkSpreadMethod_Reflect,
	inkSpreadMethod_Repeat
} inkSpreadMethod;

typedef enum
{
	inkInterpolationMethod_LinearRGB = 0,
	inkInterpolationMethod_RGB
} inkInterpolationMethod;

typedef enum
{
	inkGradientType_Linear = 0,
	inkGradientType_Radial
} inkGradientType;

typedef enum
{
	inkPathWinding_EvenOdd = 0,
	inkPathWinding_NonZero
} inkPathWinding;

typedef enum
{
	inkTriangleCulling_Negative = -1,
	inkTriangleCulling_None,
	inkTriangleCulling_Posative
} inkTriangleCulling;

typedef enum
{
	inkJointStyle_Bevel = 0,
	inkJointStyle_Miter,
	inkJointStyle_Round
} inkJointStyle;

typedef enum
{
	inkLineScaleMode_Horizontal = -1,
	inkLineScaleMode_None,
	inkLineScaleMode_Normal,
	inkLineScaleMode_Vertical
} inkLineScaleMode;

typedef enum
{
	inkCapsStyle_None = 0,
	inkCapsStyle_Round,
	inkCapsStyle_Square
} inkCapsStyle;

typedef enum
{
	inkCommandType_MoveTo = 0,
	inkCommandType_LineTo,
	inkCommandType_CurveTo,
	inkCommandType_SolidFill,
	inkCommandType_BitmapFill,
	inkCommandType_GradientFill,
	inkCommandType_LineStyle,
	inkCommandType_LineBitmap,
	inkCommandType_LineGradient,
	inkCommandType_EndFill
} inkCommandType;

typedef enum
{
	inkWindingRule_EvenOdd = 0,
	inkWindingRule_NonZero,
	inkWindingRule_Positive,
	inkWindingRule_Negative,
	inkWindingRule_AbsGeqTwo
} inkWindingRule;

/*typedef enum
{
	inkPathCommand_NoOp = 0,
	inkPathCommand_MoveTo,
	inkPathCommand_LineTo,
	inkPathCommand_CurveTo,
	inkPathCommand_WideMoveTo,
	inkPathCommand_WideLineTo
} inkPathCommand;*/

#endif
