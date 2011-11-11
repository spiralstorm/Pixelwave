//
//  inkCommandGroup.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_COMMAND_H_
#define _INK_COMMAND_H_

#include "inkHeader.h"

#include "inkTypes.h"
#include "inkArray.h"

#include "inkGeometry.h"
#include "inkFill.h"
#include "inkStroke.h"

typedef inkPoint inkMoveToCommand;
typedef inkPoint inkLineToCommand;

typedef struct
{
	inkPoint control;
	inkPoint anchor;
} inkCurveToCommand;

typedef inkSolidFill inkSolidFillCommand;
typedef inkBitmapFill inkBitmapFillCommand;
typedef inkGradientFill inkGradientFillCommand;

typedef struct
{
	inkSolidFill fill;
	inkStroke stroke;
} inkLineStyleCommand;

typedef inkBitmapFill inkLineBitmapCommand;
typedef inkGradientFill inkLineGradientCommand;

typedef struct
{
	void* data;

	inkCommandType type;
} inkCommand;

inkExtern inkCommand* inkCommandCreate(inkCommandType type, void* data);
inkExtern void inkCommandDestroy(inkCommand* command);

#endif
