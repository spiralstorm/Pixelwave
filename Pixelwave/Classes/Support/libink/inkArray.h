//
//  inkArray.h
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_ARRAY_H_
#define _INK_ARRAY_H_

#include "inkHeader.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	void *bytes;

	unsigned int count;

	size_t _byteCount;

	size_t _usedSize;
	size_t _maxUsedSize;

	size_t _minSize;
	size_t _elementSize;
} inkArray;

// Make and destroy
inkArray* inkArrayCreate(size_t elementSize);
void inkArrayDestroy(inkArray* array);

// Adjust size
void* inkArrayPush(inkArray* array);
void inkArrayPop();
void inkArrayClear();

void inkArrayRemoveFromLeft(inkArray* array, unsigned int count);
void inkArrayRemoveFromRight(inkArray* array, unsigned int count);

// Inquiry
unsigned int inkArrayCount(inkArray* array);
void* inkArrayElementAt(inkArray* array, unsigned int index);

#ifdef __cplusplus
}
#endif

#endif
