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
#include "inkCanvas.h"
#include "inkGeometry.h"

inkExtern void inkUtilsDrawCircle(inkCanvas* canvas, inkPoint position, float radius);
inkExtern void inkUtilsDrawEllipse(inkCanvas* canvas, inkRect boundingRect);
inkExtern void inkUtilsDrawRect(inkCanvas* canvas, inkRect rect);
inkExtern void inkUtilsDrawRoundRect(inkCanvas* canvas, inkRect rect, inkSize ellipseSize);

#endif
