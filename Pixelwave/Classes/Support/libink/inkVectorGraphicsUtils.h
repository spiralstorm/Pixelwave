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

inkExtern void inkDrawCircle(inkCanvas* canvas, inkPoint position, float radius);
inkExtern void inkDrawEllipse(inkCanvas* canvas, inkRect boundingRect);
inkExtern void inkDrawRect(inkCanvas* canvas, inkRect rect);
inkExtern void inkDrawRoundRect(inkCanvas* canvas, inkRect rect, inkSize ellipseSize);

inkExtern void inkDrawPath(inkCanvas* canvas, inkArray* commands, inkArray* points, inkWindingRule winding);

inkExtern void inkDrawSVGPath(inkCanvas* canvas, const char* path);
inkExtern void inkDrawSVGPathv(inkCanvas* canvas, const char* path, inkPoint offset);

#endif
