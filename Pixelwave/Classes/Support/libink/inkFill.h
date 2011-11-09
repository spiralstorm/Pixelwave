//
//  inkFill.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_FILL_H_
#define _INK_FILL_H_

#include "inkHeader.h"

typedef struct
{
	inkFillType fillType; // MUST BE THE FIRST VARIABLE

	unsigned int color;
	float alpha;
} inkSolidFill;

typedef struct
{
	inkFillType fillType; // MUST BE THE FIRST VARIABLE

	inkMatrix *matrix;

	bool repeat;
	bool smooth;
} inkBitmapFill;

typedef struct
{
	inkFillType fillType; // MUST BE THE FIRST VARIABLE

	inkArray* colors;
	inkArray* alphas;
	inkArray* ratios;

	inkMatrix* matrix;

	inkGradientType type;
	inkSpreadMethod spreadMethod;
	inkInterpolationMethod interpolationMethod;

	float focalPointRatio;
} inkGradientFill;

#endif
