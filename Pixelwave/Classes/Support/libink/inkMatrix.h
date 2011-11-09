//
//  inkMatrix.h
//  Pixelwave
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_MATRIX_H_
#define _INK_MATRIX_H_

#include "inkHeader.h"

typedef struct
{
	float a;
	float b;
	float c;
	float d;

	float tx;
	float ty;
} inkMatrix;

static inkExtern const inkMatrix inkMatrixIdentity;

inkMatrix inkMatrixMake(float a, float b, float c, float d, float tx, float ty);

inkMatrix inkMatrixConcat(inkMatrix matrixA, inkMatrix matrixB);
inkMatrix inkMatrixInvert(inkMatrix matrix);
inkMatrix inkMatrixRotate(inkMatrix matrix, float angle);
inkMatrix inkMatrixScale(inkMatrix matrix, float sx, float sy);
inkMatrix inkMatrixTranslate(inkMatrix matrix, float dx, float dy);

inkMatrix inkMatrixCreateBox(inkMatrix matrix, float scaleX, float scaleY, float rotation, float tx, float ty);



//-- ScriptName: transformPoint
- (PXPoint *)transformPoint:(PXPoint *)point;
//-- ScriptName: deltaTranfsormPoint
- (PXPoint *)deltaTransformPoint:(PXPoint *)point;

#endif
