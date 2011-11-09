//
//  inkStrokeGenerator.h
//  ink
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_STROKE_GENERATOR_H_
#define _INK_STROKE_GENERATOR_H_

#include "inkHeader.h"
#include "inkArray.h"
#include "inkTypes.h"

typedef struct
{
	inkLineScaleMode scaleMode;
	inkCapsStyle caps;
	inkJointStyle joints;

	float miterLimit;
	float thickness;
} inkStroke;

typedef struct
{
	inkArray *vertices;

	inkStroke stroke;
} inkStrokeInfo;

inkExtern inkStroke inkStrokeMake(float thickness, unsigned int color, float alpha, bool pixelHinting, inkLineScaleMode scaleMode, inkCapsStyle caps, inkJointStyle joints, float miterLimit);

inkExtern inkStrokeInfo *inkStrokeGeneratorCreate(size_t vertexSize, inkStroke stroke);
inkExtern void inkStrokeGeneratorDestroy(inkStrokeInfo *stroke);

inkExtern void inkStrokeGeneratorMoveTo(inkStrokeInfo *stroke, float x, float y);
inkExtern void inkStrokeGeneratorLineTo(inkStrokeInfo *stroke, float x, float y);
inkExtern void inkStrokeGeneratorEnd(inkStrokeInfo *stroke);

#endif
