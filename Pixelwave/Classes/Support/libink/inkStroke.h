//
//  inkStroke.h
//  ink
//
//  Created by John Lattin on 11/10/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_STROKE_H_
#define _INK_STROKE_H_

#include "inkHeader.h"
#include "inkTypes.h"

typedef struct
{
	inkLineScaleMode scaleMode;
	inkCapsStyle caps;
	inkJointStyle joints;
	
	float miterLimit;
	float thickness;

	bool pixelHinting;
} inkStroke;

#define _inkStrokeMiterLimitDefault 3.0f
#define _inkStrokeThicknessDefault inkNan
#define _inkStrokePixelHintingDefault false

#define _inkStrokeDefault {_inkLineScaleModeDefault, _inkCapsStyleDefault, _inkJointStyleDefault, _inkStrokeMiterLimitDefault, _inkStrokeThicknessDefault, _inkStrokePixelHintingDefault}

inkExtern const float inkStrokeMiterLimitDefault;
inkExtern const float inkStrokeThicknessDefault;
inkExtern const bool inkStrokePixelHintingDefault;

inkExtern const inkStroke inkStrokeDefault;

inkExtern inkStroke inkStrokeMake(float thickness, bool pixelHinting, inkLineScaleMode scaleMode, inkCapsStyle caps, inkJointStyle joints, float miterLimit);

#endif
