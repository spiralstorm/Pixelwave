//
//  inkCommandGroup.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_COMMAND_GROUP_H_
#define _INK_COMMAND_GROUP_H_

#include "inkHeader.h"

#include "inkTypes.h"
#include "inkArray.h"

typedef struct
{
	inkArray *data;
	
	inkPathCommand pathCommand;
} inkCommand;

inkExtern inkCommand *inkCommandCreate();
inkExtern void inkCommandDestroy(inkCommand *command);

inkExtern void inkCommandAdd(inkCommand *command, inkPathCommand pathCommand, void *data);

#endif
