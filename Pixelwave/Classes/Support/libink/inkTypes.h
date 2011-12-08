//
//  inkTypes.h
//  ink
//
//  Created by John Lattin on 11/7/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_TYPES_H_
#define _INK_TYPES_H_

#include "inkHeader.h"

#if defined(__GNUC__)
#define    inkNan          __builtin_nanf("0x7fc00000")
#else
#define    inkNan          __nan( )
#endif

typedef void (*inkPointSizeFunction)(float);
typedef void (*inkLineWidthFunction)(float);
typedef void (*inkStateFunction)(unsigned int);

typedef void (*inkPointerFunction)(int, unsigned int, int, const void*);

typedef void (*inkDrawArraysFunction)(unsigned int, int, int);
typedef void (*inkDrawElementsFunction)(unsigned int, int, unsigned int, const void*);

typedef void (*inkTextureFunction)(unsigned int, unsigned int);

typedef void (*inkGetBooleanFunction)(unsigned int, unsigned char*);
typedef void (*inkGetFloatFunction)(unsigned int, float*);
typedef void (*inkGetIntegerFunction)(unsigned int, int*);

typedef void (*inkGetTexParameterFunction)(unsigned int, unsigned int, int*);
typedef void (*inkSetTexParameterFunction)(unsigned int, unsigned int, int);

typedef struct
{
	unsigned int textureName;
	int minFilter;
	int magFilter;
	int wrapS;
	int wrapT;

	float lineWidth;
	float pointSize;
} inkPresetGLData;

#define _inkPresetGLDataDefault {0, GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT, 0.0f, 4.0f}
inkExtern const inkPresetGLData inkPresetGLDataDefault;

typedef struct
{
	inkStateFunction enableFunc;
	inkStateFunction disableFunc;
	inkStateFunction enableClientFunc;
	inkStateFunction disableClientFunc;
	inkGetBooleanFunction getBooleanFunc;
	inkGetFloatFunction getFloatFunc;
	inkGetIntegerFunction getIntegerFunc;
	inkPointSizeFunction pointSizeFunc;
	inkLineWidthFunction lineWidthFunc;
	inkTextureFunction textureFunc;
	inkGetTexParameterFunction getTexParamFunc;
	inkSetTexParameterFunction setTexParamFunc;
	inkPointerFunction vertexFunc;
	inkPointerFunction textureCoordinateFunc;
	inkPointerFunction colorFunc;
	inkDrawArraysFunction drawArraysFunc;
	inkDrawElementsFunction drawElementsFunc;
} inkRenderer;

#define _inkRendererDefault {glEnable, glDisable, glEnableClientState, glDisableClientState, glGetBooleanv, glGetFloatv, glGetIntegerv, glPointSize, glLineWidth, glBindTexture, glGetTexParameteriv, glTexParameteri, glVertexPointer, glTexCoordPointer, glColorPointer, glDrawArrays, glDrawElements}
inkExtern const inkRenderer inkRendererDefault;

inkExtern inkRenderer inkRendererMake(inkStateFunction enableFunc, inkStateFunction disableFunc, inkStateFunction enableClientFunc, inkStateFunction disableClientFunc, inkGetBooleanFunction getBooleanFunc, inkGetFloatFunction getFloatFunc, inkGetIntegerFunction getIntegerFunc, inkPointSizeFunction pointSizeFunc, inkLineWidthFunction lineWidthFunc, inkTextureFunction textureFunc, inkGetTexParameterFunction getTexParamFunc, inkSetTexParameterFunction setTexParamFunc, inkPointerFunction vertexFunc, inkPointerFunction textureCoordinateFunc, inkPointerFunction colorFunc, inkDrawArraysFunction drawArraysFunc, inkDrawElementsFunction drawElementsFunc);

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

#define _inkSpreadMethodDefault inkSpreadMethod_Pad
inkExtern const inkSpreadMethod inkSpreadMethodDefault;

typedef enum
{
	inkInterpolationMethod_LinearRGB = 0,
	inkInterpolationMethod_RGB
} inkInterpolationMethod;

#define _inkInterpolationMethodDefault inkInterpolationMethod_RGB
inkExtern const inkInterpolationMethod inkInterpolationMethodDefault;

typedef enum
{
	inkGradientType_Linear = 0,
	inkGradientType_Radial
} inkGradientType;

#define _inkGradientTypeDefault inkGradientType_Linear
inkExtern const inkGradientType inkGradientTypeDefault;

typedef enum
{
	inkPathWinding_EvenOdd = 0,
	inkPathWinding_NonZero
} inkPathWinding;

#define _inkPathWindingDefault inkPathWinding_EvenOdd
inkExtern const inkPathWinding inkPathWindingDefault;

typedef enum
{
	inkTriangleCulling_Negative = -1,
	inkTriangleCulling_None,
	inkTriangleCulling_Posative
} inkTriangleCulling;

#define _inkTriangleCullingDefault inkTriangleCulling_None
inkExtern const inkTriangleCulling inkTriangleCullingDefault;

typedef enum
{
	inkJointStyle_Bevel = 0,
	inkJointStyle_Miter,
	inkJointStyle_Round
} inkJointStyle;

#define _inkJointStyleDefault inkJointStyle_Round
inkExtern const inkJointStyle inkJointStyleDefault;

typedef enum
{
	inkLineScaleMode_Horizontal = -1,
	inkLineScaleMode_None,
	inkLineScaleMode_Normal,
	inkLineScaleMode_Vertical
} inkLineScaleMode;

#define _inkLineScaleModeDefault inkLineScaleMode_Horizontal
inkExtern const inkLineScaleMode inkLineScaleModeDefault;

typedef enum
{
	inkCapsStyle_None = 0,
	inkCapsStyle_Round,
	inkCapsStyle_Square
} inkCapsStyle;

#define _inkCapsStyleDefault inkCapsStyle_Round
inkExtern const inkCapsStyle inkCapsStyleDefault;

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
	inkCommandType_EndFill,
	inkCommandType_Winding
} inkCommandType;

typedef enum
{
	inkWindingRule_EvenOdd = 0,
	inkWindingRule_NonZero,
	inkWindingRule_Positive,
	inkWindingRule_Negative,
	inkWindingRule_AbsGeqTwo
} inkWindingRule;

typedef enum
{
	inkPathCommand_NoOp = 0,
	inkPathCommand_MoveTo,
	inkPathCommand_LineTo,
	inkPathCommand_QuadraticCurveTo,
	inkPathCommand_CubicCurveTo,
	inkPathCommand_WideMoveTo,
	inkPathCommand_WideLineTo
} inkPathCommand;

#endif
