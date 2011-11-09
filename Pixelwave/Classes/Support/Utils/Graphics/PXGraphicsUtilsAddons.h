//
//  PXGraphicsUtilsAddons.h
//  Pixelwave
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _PX_GRAPHICS_UTILS_ADDONS_H_
#define _PX_GRAPHICS_UTILS_ADDONS_H_

#include "PXHeaderUtils.h"
#include "PXGraphicsUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

void PXGraphicsUtilsDrawCircle(_PXGraphics *graphics, float x, float y, float radius);
void PXGraphicsUtilsDrawEllipse(_PXGraphics *graphics, float x, float y, float width, float height);
void PXGraphicsUtilsDrawRect(_PXGraphics *graphics, float x, float y, float width, float height);
void PXGraphicsUtilsDrawRoundRect(_PXGraphics *graphics, float x, float y, float width, float height, float ellipseWidth, float ellipseHeight);

#ifdef __cplusplus
}
#endif

#endif
