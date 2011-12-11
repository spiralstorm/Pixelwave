//
//  inkArray.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkArray.h"

#define inkArrayMinimumElementCount 4

inkInline int64_t inkArrayNextPowerOfTwo(int64_t val)
{
	--val;
		val |= (val >> 1);
		val |= (val >> 2);
		val |= (val >> 4);
		val |= (val >> 8);
		val |= (val >> 16);
		val |= (val >> 32);
	++val;

	return val;
}

inkInline void inkArrayResize(inkArray *array, size_t size);
inkInline void inkArrayUpdateCount(inkArray *array, unsigned int count);

inkArray* inkArrayCreate(size_t elementSize)
{
	if (elementSize == 0)
		return NULL;

	inkArray *array = (inkArray *)(calloc(1, sizeof(inkArray)));

	if (array != NULL)
	{
		array->_elementSize = elementSize;
		array->_byteCount = array->_elementSize * inkArrayMinimumElementCount;
		array->elements = malloc(array->_byteCount);

		if (array->elements == NULL)
		{
			free(array);
			array = NULL;
		}
	}

	return array;
}

void inkArrayDestroy(inkArray* array)
{
	if (array != NULL)
	{
		if (array->elements != NULL)
		{
			free(array->elements);
			array->elements = NULL;
		}

		free (array);
	}
}

inkInline void inkArrayResize(inkArray* array, size_t size)
{
	if (array == NULL || array->elements == NULL)
		return;

	size_t minSize = array->_elementSize * inkArrayMinimumElementCount;
	if (size < minSize)
		size = minSize;

	if (size == array->_byteCount)
		return;

	array->_byteCount = size;
	array->elements = realloc(array->elements, array->_byteCount);
}

inkInline void inkArrayUpdateCount(inkArray* array, unsigned int count)
{
	if (array == NULL)
		return;

	array->count = count;
	array->_usedSize = count * array->_elementSize;

	size_t lowerBounds = array->_byteCount >> 2;

	if ((array->_usedSize < lowerBounds) || (array->_usedSize >= array->_byteCount))
	{
		size_t newSize = inkArrayNextPowerOfTwo(count) * array->_elementSize;
		inkArrayResize(array, newSize);
	}
}

void* inkArrayPush(inkArray* array)
{
	return inkArrayPushElements(array, 1);
}

void* inkArrayPushElements(inkArray* array, unsigned int count)
{
	if (array == NULL || array->elements == NULL)
		return NULL;

	size_t preUsedSize = array->_usedSize;
	array->_usedSize += array->_elementSize * count;
	array->count += count;

	if (array->_usedSize > array->_byteCount)
	{
		unsigned int newCount = array->count + 10;
		size_t newSize = inkArrayNextPowerOfTwo(newCount) * array->_elementSize;
		inkArrayResize(array, newSize);
	}

	void *current = (void *)(((uint8_t*)(array->elements)) + preUsedSize);

	current = memset(current, 0, array->_elementSize);
	// Lets return the next available vertex for use.
	return current;
}

void inkArrayPop(inkArray* array)
{
	inkArrayRemoveFromRight(array, 1);
}

void inkArrayClear(inkArray* array)
{
	inkArrayUpdateCount(array, 0);
}

void inkArrayRemoveFromLeft(inkArray* array, unsigned int count)
{
	if (array == NULL || array->elements == NULL)
		return;

	if (count == 0)
		return;

	unsigned int oldCount = inkArrayCount(array);

	if (count >= oldCount)
	{
		inkArrayUpdateCount(array, 0);
		return;
	}

	size_t elementSize = array->_elementSize;

	uint8_t* bytes = (uint8_t*)(array->elements);
	uint8_t* bytesOffset = bytes + (count * elementSize);

	unsigned int newCount = oldCount - count;

	memmove(bytes, bytesOffset, elementSize * newCount);

	inkArrayUpdateCount(array, newCount);
}

void inkArrayRemoveFromRight(inkArray* array, unsigned int count)
{
	if (array == NULL)
		return;

	if (array->count < count)
		return;

	inkArrayUpdateCount(array, array->count - count);
}

// Inquiry
unsigned int inkArrayCount(inkArray* array)
{
	if (array == NULL)
		return 0;

	return array->count;
}

void* inkArrayElementAt(inkArray* array, unsigned int index)
{
	if (array == NULL)
		return NULL;

	unsigned int count = inkArrayCount(array);

	if (count == 0 || index >= count)
		return NULL;

	return (void *)((uint8_t *)(array->elements) + (index * array->_elementSize));
}
