//
//  ink_t.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_T_H_
#define _INK_T_H_

#include "inkHeader.h"
#include "inkArray.h"

typedef struct
{
	inkArray *commandList;
	inkArray *renderGroups;
} ink_t;

inkExtern ink_t* inkCreate();
inkExtern void inkDestroy(ink_t* graphics);

#endif
