//
//  inkCanvas.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_CANVAS_H_
#define _INK_CANVAS_H_

#include "inkHeader.h"
#include "inkArray.h"

typedef struct
{
	inkArray *commandList;
	inkArray *renderGroups;
} inkCanvas;

inkExtern inkCanvas* inkCreate();
inkExtern void inkDestroy(inkCanvas* canvas);

#endif
