//
//  inkVectorGraphics.h
//  ink
//
//  Created by John Lattin on 11/7/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_VECTOR_GRAPHICS_H_
#define _INK_VECTOR_GRAPHICS_H_

#include "inkHeader.h"
#include "inkArray.h"
#include "inkTypes.h"
#include "inkCanvas.h"
#include "inkFill.h"
#include "inkStroke.h"

inkExtern void inkClear(inkCanvas* canvas);

inkExtern void inkMoveTo(inkCanvas* canvas, inkPoint position);
inkExtern void inkLineTo(inkCanvas* canvas, inkPoint position);
inkExtern void inkCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor);

inkExtern void inkBeginFill(inkCanvas* canvas, inkSolidFill);
inkExtern void inkBeginBitmapFill(inkCanvas* canvas, inkBitmapFill bitmapFill);
inkExtern void inkBeginGradientFill(inkCanvas* canvas, inkGradientFill gradientFill);

inkExtern void inkLineStyle(inkCanvas* canvas, inkStroke stroke, inkSolidFill solidFill);
inkExtern void inkLineBitmapStyle(inkCanvas* canvas, inkBitmapFill bitmapFill);
inkExtern void inkLineGradientStyle(inkCanvas* canvas, inkGradientFill gradientFill);

inkExtern void inkEndFill(inkCanvas* canvas);

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
inkExtern void inkRasterize(inkCanvas* canvas);

#endif
