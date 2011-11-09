//
//  inkStructs.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_STRUCTS_H_
#define _INK_STRUCTS_H_

#include "inkTypes.h"
#include "inkArray.h"

typedef struct
{
	inkArray *data;

	inkPathCommand pathCommand;
} inkGraphicsCommand;

inkCommand *inkCommandCreate();
void inkCommandDestroy(inkCommand *command);
void inkCommandAdd(inkCommand *command, inkPathCommand pathCommand, void *data);

#endif
