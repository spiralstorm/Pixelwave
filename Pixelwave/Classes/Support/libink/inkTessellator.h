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

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	void *gluTessellator;
} inkTessellator;

inkTessellator *inkTessellatorCreate();
void inkTessellatorDestroy(inkTessellator *tessellator);

#ifdef __cplusplus
}
#endif

#endif
