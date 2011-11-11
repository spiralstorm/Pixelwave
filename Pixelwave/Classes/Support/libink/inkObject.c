//
//  inkObject.c
//  ink
//
//  Created by John Lattin on 11/11/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkObject.h"

inkObject* inkObjectCreate(void* holder, inkDestroyFunction destroyFunction)
{
	inkObject* object = malloc(sizeof(inkObject));

	if (object != NULL)
	{
		object->retainCount = 1;
	}

	return object;
}

void inkObjectDestroy(inkObject* object)
{
	if (object != NULL)
	{
		if (object->holder && object->destroyFunction)
		{
			object->destroyFunction(object->holder);
		}

		free(object);
	}
}

void inkObjectRetain(inkObject* object)
{
	if (object == NULL)
		return;
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
