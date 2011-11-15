//
//  inkObject.c
//  ink
//
//  Created by John Lattin on 11/11/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkObject.h"

inkInline bool inkObjectInit(inkObject* object, void* holder, inkDestroyFunction destroyFunction, bool onStack)
{
	if (object == NULL)
		return false;

	memset(object, 0, sizeof(inkObject));

	object->_onStack = onStack;

	if (object->holder == NULL)
		return false;

	object->holder = holder;
	object->destroyFunction = destroyFunction;
	object->retainCount = 1;

	return true;
}

inkInline void inkObjectDestroy(inkObject* object)
{
	if (object != NULL)
	{
		if (object->holder && object->destroyFunction)
		{
			object->destroyFunction(object->holder);
		}

		if (object->_onStack == false)
		{
			free(object);
		}
	}
}

inkObject inkObjectMake(void* holder, inkDestroyFunction destroyFunction)
{
	inkObject object;

	inkObjectInit(&object, holder, destroyFunction, true);

	return object;
}

inkObject* inkObjectCreate(void* holder, inkDestroyFunction destroyFunction)
{
	inkObject* object = malloc(sizeof(inkObject));

	if (inkObjectInit(object, holder, destroyFunction, false) == false)
	{
		inkObjectDestroy(object);
	}

	return object;
}

void inkObjectRetain(inkObject* object)
{
	if (object == NULL)
		return;

	++(object->retainCount);
}

void inkObjectRelease(inkObject* object)
{
	if (object == NULL)
		return;

	--(object->retainCount);

	if (object->retainCount == 0)
	{
		inkObjectDestroy(object);
	}
}

unsigned short inkObjectRetainCount(inkObject* object)
{
	if (object == NULL)
		return 0;

	return object->retainCount;
}
