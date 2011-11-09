//
//  inkVectorGraphicsUtils.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_VECTOR_GRAPHICS_UTILS_H_
#define _INK_VECTOR_GRAPHICS_UTILS_H_

#include "inkHeader.h"
#include "ink_t.h"

inkExtern void inkUtilsDrawCircle(ink_t* graphics, float x, float y, float radius);
inkExtern void inkUtilsDrawEllipse(ink_t* graphics, float x, float y, float width, float height);
inkExtern void inkUtilsDrawRect(ink_t* graphics, float x, float y, float width, float height);
inkExtern void inkUtilsDrawRoundRect(ink_t* graphics, float x, float y, float width, float height, float ellipseWidth, float ellipseHeight);

#endif
