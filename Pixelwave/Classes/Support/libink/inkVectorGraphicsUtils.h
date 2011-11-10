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
#include "inkGeometry.h"

inkExtern void inkUtilsDrawCircle(ink_t* graphics, inkPoint position, float radius);
inkExtern void inkUtilsDrawEllipse(ink_t* graphics, inkRect boundingRect);
inkExtern void inkUtilsDrawRect(ink_t* graphics, inkRect rect);
inkExtern void inkUtilsDrawRoundRect(ink_t* graphics, inkRect rect, inkSize ellipseSize);

#endif
