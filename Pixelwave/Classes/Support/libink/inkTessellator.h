//
//  inkTessellator.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_TESSELLATOR_H_
#define _INK_TESSELLATOR_H_

#include "inkHeader.h"

typedef struct
{
	void *gluTessellator;
} inkTessellator;

inkExtern inkTessellator *inkTessellatorCreate();
inkExtern void inkTessellatorDestroy(inkTessellator *tessellator);

#endif
