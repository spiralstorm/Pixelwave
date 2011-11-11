//
//  inkObject.h
//  ink
//
//  Created by John Lattin on 11/11/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_OBJECT_H_
#define _INK_OBJECT_H_

#include "inkHeader.h"

typedef void (*inkDestroyFunction)(void *);

typedef struct
{
	void* holder;
	inkDestroyFunction destroyFunction;

	unsigned int retainCount;
} inkObject;

inkExtern inkObject* inkObjectCreate(void* holder, inkDestroyFunction destroyFunction);

inkExtern void inkObjectRetain(inkObject* object);
inkExtern void inkObjectRelease(inkObject* object);

#endif
