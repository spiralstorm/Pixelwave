//
//  inkVectorGraphics.c
//  ink
//
//  Created by John Lattin on 11/7/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkVectorGraphics.h"

#include "inkTessellator.h"

// We use a shared tessellator because the 'rasterization' step, where
// tessellation is done, should ONLY ever happen on the main thread.
//static PXTessellator *pxGraphicsUtilsSharedTesselator = NULL;

inkExtern void inkClear(inkCanvas* canvas)
{
	// TODO: Implement
}

inkExtern void inkMoveTo(inkCanvas* canvas, inkPoint position)
{
	// TODO: Implement
}

inkExtern void inkLineTo(inkCanvas* canvas, inkPoint position)
{
	// TODO: Implement
}

inkExtern void inkCurveTo(inkCanvas* canvas, inkPoint control, inkPoint anchor)
{
	// TODO: Implement
}

inkExtern void inkBeginFill(inkCanvas* canvas, inkSolidFill solidFill)
{
	// TODO: Implement
}

inkExtern void inkBeginBitmapFill(inkCanvas* canvas, inkBitmapFill bitmapFill)
{
	// TODO: Implement
}

inkExtern void inkBeginGradientFill(inkCanvas* canvas, inkGradientFill gradientFill)
{
	// TODO: Implement
}

inkExtern void inkLineStyle(inkCanvas* canvas, inkStroke stroke, inkSolidFill solidFill)
{
	// TODO: Implement
}

inkExtern void inkLineBitmapStyle(inkCanvas* canvas, inkBitmapFill bitmapFill)
{
	// TODO: Implement
}

inkExtern void inkLineGradientStyle(inkCanvas* canvas, inkGradientFill gradientFill)
{
	// TODO: Implement
}

inkExtern void inkEndFill(inkCanvas* canvas)
{
	// TODO: Implement
}

// ONLY call this method on the main thread as it uses a non-thread safe shared
// tessellator.
inkExtern void inkRasterize(inkCanvas* canvas)
{
	// TODO: Implement
}
