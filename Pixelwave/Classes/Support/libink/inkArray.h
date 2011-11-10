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
inkExtern inkArray* inkArrayCreate(size_t elementSize);
inkExtern void inkArrayDestroy(inkArray* array);

// Adjust size
inkExtern void* inkArrayPush(inkArray* array);
inkExtern void inkArrayPop();
inkExtern void inkArrayClear();

inkExtern void inkArrayRemoveFromLeft(inkArray* array, unsigned int count);
inkExtern void inkArrayRemoveFromRight(inkArray* array, unsigned int count);

// Inquiry
inkExtern unsigned int inkArrayCount(inkArray* array);
inkExtern void* inkArrayElementAt(inkArray* array, unsigned int index);

#endif
