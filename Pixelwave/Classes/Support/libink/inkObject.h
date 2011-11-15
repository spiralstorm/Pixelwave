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

	unsigned short retainCount;
	// If the object is on the stack, not the holder
	bool _onStack;
} inkObject;

// I am on the stack, when my retain count goes to 0 I will just free my holder.
// You MUST still call release on me, however retain will be odd if I fall off
// the stack, as the holder will not get released. So, be careful when using
// this.
inkExtern inkObject inkObjectMake(void* holder, inkDestroyFunction destroyFunction);

// I am on the heap, when my retain count goes to 0, I will free my holder and
// myself
inkExtern inkObject* inkObjectCreate(void* holder, inkDestroyFunction destroyFunction);

inkExtern void inkObjectRetain(inkObject* object);
inkExtern void inkObjectRelease(inkObject* object);

inkExtern unsigned short inkObjectRetainCount(inkObject* object);

#endif
