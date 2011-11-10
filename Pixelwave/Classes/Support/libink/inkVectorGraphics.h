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
#include "ink_t.h"
#include "inkFill.h"
#include "inkStroke.h"

inkExtern void inkClear(ink_t* graphics);

inkExtern void inkMoveTo(ink_t* graphics, inkPoint position);
inkExtern void inkLineTo(ink_t* graphics, inkPoint position);
inkExtern void inkCurveTo(ink_t* graphics, inkPoint control, inkPoint anchor);

inkExtern void inkBeginFill(ink_t* graphics, inkSolidFill);
inkExtern void inkBeginBitmapFill(ink_t* graphics, inkBitmapFill bitmapFill);
inkExtern void inkBeginGradientFill(ink_t* graphics, inkGradientFill gradientFill);

inkExtern void inkLineStyle(ink_t* graphics, inkStroke stroke, inkSolidFill solidFill);
inkExtern void inkLineBitmapStyle(ink_t* graphics, inkBitmapFill bitmapFill);
inkExtern void inkLineGradientStyle(ink_t* graphics, inkGradientFill gradientFill);

inkExtern void inkEndFill(ink_t* graphics);

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
inkExtern void inkRasterize(ink_t* graphics);

#endif
