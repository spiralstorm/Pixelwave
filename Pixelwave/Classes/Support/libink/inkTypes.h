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

typedef ssize_t (*inkDataWriter)(void *user, const void *buf, size_t count);
typedef ssize_t (*inkDataReader)(void *user, const void *buf, size_t count);

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

inkExtern const inkRenderer inkRendererDefault;

inkExtern inkRenderer inkRendererMake(inkStateFunction enableFunc, inkStateFunction disableFunc, inkStateFunction enableClientFunc, inkStateFunction disableClientFunc, inkGetBooleanFunction getBooleanFunc, inkGetFloatFunction getFloatFunc, inkGetIntegerFunction getIntegerFunc, inkPointSizeFunction pointSizeFunc, inkLineWidthFunction lineWidthFunc, inkTextureFunction textureFunc, inkGetTexParameterFunction getTexParamFunc, inkSetTexParameterFunction setTexParamFunc, inkPointerFunction vertexFunc, inkPointerFunction textureCoordinateFunc, inkPointerFunction colorFunc, inkDrawArraysFunction drawArraysFunc, inkDrawElementsFunction drawElementsFunc);

typedef unsigned int INKenum;

typedef struct
{
	unsigned char r, g, b, a;
} inkColor;

typedef struct
{
	float r, g, b, a;
} inkColorTransform;

inkInline inkColor inkColorMake(unsigned char r, unsigned char g, unsigned char b, unsigned char a);
inkInline inkColor inkColorFromTransform(inkColorTransform transform);
inkInline inkColor inkColorApplyTransform(inkColor color, inkColorTransform transform);
inkInline inkColorTransform inkColorTransformMake(float r, float g, float b, float a);
inkInline inkColorTransform inkColorTransformFromColor(inkColor color);

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
	inkCommandType_Winding,
	inkCommandType_UserData,
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

typedef enum
{
	inkError_None = 0,
	inkError_OutOfMemory
} inkError;

typedef enum
{
	inkIncompleteDrawStrategy_None = 0,
	inkIncompleteDrawStrategy_Fade,
	inkIncompleteDrawStrategy_Full
} inkIncompleteDrawStrategy;

inkInline inkColor inkColorMake(unsigned char r, unsigned char g, unsigned char b, unsigned char a)
{
	inkColor color;
	
	color.r = r;
	color.g = g;
	color.b = b;
	color.a = a;
	
	return color;
}

inkInline inkColorTransform inkColorTransformMake(float r, float g, float b, float a)
{
	inkColorTransform transform;
	
	transform.r = r;
	transform.g = g;
	transform.b = b;
	transform.a = a;
	
	return transform;
}

inkInline inkColor inkColorFromTransform(inkColorTransform transform)
{
	return inkColorMake(0xFF * transform.r, 0xFF * transform.g, 0xFF * transform.b, 0xFF * transform.a);
}

inkInline inkColorTransform inkColorTransformFromColor(inkColor color)
{
	return inkColorTransformMake(M_1_255 * color.r, M_1_255 * color.g, M_1_255 * color.b, M_1_255 * color.a);
}

inkInline inkColor inkColorApplyTransform(inkColor color, inkColorTransform transform)
{
	return inkColorMake(color.r * transform.r, color.g * transform.g, color.b * transform.b, color.a * transform.a);
}

inkInline inkColor inkColorInterpolate(inkColor colorA, inkColor colorB, float percent)
{
	return inkColorMake(colorA.r + ((colorB.r - colorA.r) * percent),
						colorA.g + ((colorB.g - colorA.g) * percent),
						colorA.b + ((colorB.b - colorA.b) * percent),
						colorA.a + ((colorB.a - colorA.a) * percent));
}

#endif
