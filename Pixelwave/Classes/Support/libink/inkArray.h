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
	void *elements;
	
	unsigned int count;
	
	size_t _byteCount;
	size_t _usedSize;
	size_t _elementSize;
} inkArray;

// Make and destroy
inkExtern inkArray* inkArrayCreate(size_t elementSize);
inkExtern void inkArrayDestroy(inkArray* array);

// Adjust size
inkExtern void* inkArrayPush(inkArray* array);
inkExtern void* inkArrayPushElements(inkArray* array, unsigned int count);
inkExtern void inkArrayPop(inkArray* array);
inkExtern void inkArrayClear(inkArray* array);

inkExtern void inkArrayRemoveFromLeft(inkArray* array, unsigned int count);
inkExtern void inkArrayRemoveFromRight(inkArray* array, unsigned int count);

inkExtern void inkArrayUpdateCount(inkArray *array, unsigned int count);

// Inquiry
inkExtern unsigned int inkArrayCount(inkArray* array);
inkExtern void* inkArrayElementAt(inkArray* array, unsigned int index);

// MARK: -
// MARK: Macros
// MARK: -

// MARK: Normal
#define inkArrayForEach(_array_, _obj_) \
	inkArrayForEachv(_array_, _obj_, 0, 0)
#define inkArrayForEachv(_array_, _obj_, _beg_, _cont_) \
	unsigned int inkUniqueVar(_index_); \
	unsigned int inkUniqueVar(_count_) = 0; \
	unsigned int inkUniqueVar(_size_) = 0; \
	uint8_t *inkUniqueVar(_bytes_) = NULL;\
\
	if (_array_) \
	{ \
		inkUniqueVar(_count_) = inkArrayCount(_array_); \
		inkUniqueVar(_size_) = (_array_)->_elementSize; \
		inkUniqueVar(_bytes_) = (uint8_t *)((_array_)->elements); \
	} \
\
	if (inkUniqueVar(_bytes_) && inkUniqueVar(_count_) > 0)\
	for (inkUniqueVar(_index_) = 0, (_obj_) = (__typeof__(_obj_))(inkUniqueVar(_bytes_)), _beg_; \
		 inkUniqueVar(_index_) < inkUniqueVar(_count_); \
		 ++inkUniqueVar(_index_), (inkUniqueVar(_bytes_)) += (inkUniqueVar(_size_)), (_obj_) = (__typeof__(_obj_))(inkUniqueVar(_bytes_)), _cont_)

// MARK: Reverse
#define inkArrayForEachRev(_array_, _obj_) \
	inkArrayForEachRevv(_array_, _obj_, 0, 0)
#define inkArrayForEachRevv(_array_, _obj_, _beg_, _cont_) \
	int inkUniqueVar(_index_); \
	int inkUniqueVar(_count_) = 0; \
	unsigned int inkUniqueVar(_size_) = 0; \
	uint8_t *inkUniqueVar(_bytes_) = NULL;\
\
	if (_array_) \
	{ \
		inkUniqueVar(_count_) = inkArrayCount(_array_); \
		inkUniqueVar(_size_) = (_array_)->_elementSize; \
		inkUniqueVar(_bytes_) = (uint8_t *)((_array_)->elements) + ((inkUniqueVar(_count_) - 1) * inkUniqueVar(_size_)); \
	} \
\
	if (inkUniqueVar(_bytes_) && inkUniqueVar(_count_) > 0)\
		for (inkUniqueVar(_index_) = inkUniqueVar(_count_) - 1, (_obj_) = (__typeof__(_obj_))(inkUniqueVar(_bytes_)), _beg_; \
			 inkUniqueVar(_index_) >= 0; \
			 --inkUniqueVar(_index_), (inkUniqueVar(_bytes_)) -= (inkUniqueVar(_size_)), (_obj_) = (__typeof__(_obj_))(inkUniqueVar(_bytes_)), _cont_)

// MARK: Ptr Normal
#define inkArrayPtrForEach(_array_, _obj_) \
	inkArrayPtrForEachv(_array_, _obj_, 0, 0)
#define inkArrayPtrForEachv(_array_, _obj_, _beg_, _cont_) \
	unsigned int inkUniqueVar(_index_); \
	unsigned int inkUniqueVar(_count_) = 0; \
	unsigned int inkUniqueVar(_size_) = 0; \
	uint8_t *inkUniqueVar(_bytes_) = NULL;\
\
	if (_array_) \
	{ \
		inkUniqueVar(_count_) = inkArrayCount(_array_); \
		inkUniqueVar(_size_) = (_array_)->_elementSize; \
		inkUniqueVar(_bytes_) = (uint8_t *)((_array_)->elements); \
	} \
\
	if (inkUniqueVar(_bytes_) && inkUniqueVar(_count_) > 0)\
	for (inkUniqueVar(_index_) = 0, (_obj_) = *((__typeof__(&(_obj_)))(inkUniqueVar(_bytes_))), _beg_; \
		 inkUniqueVar(_index_) < inkUniqueVar(_count_); \
		 ++inkUniqueVar(_index_), (inkUniqueVar(_bytes_)) += (inkUniqueVar(_size_)), (inkUniqueVar(_index_) < inkUniqueVar(_count_)) ? ((_obj_) = *((__typeof__(&(_obj_)))(inkUniqueVar(_bytes_))), _cont_) : 0)

// MARK: Ptr Reverse
#define inkArrayPtrForEachRev(_array_, _obj_) \
	inkArrayPtrForEachRevv(_array_, _obj_, 0, 0)
#define inkArrayPtrForEachRevv(_array_, _obj_, _beg_, _cont_) \
	int inkUniqueVar(_index_); \
	int inkUniqueVar(_count_) = 0; \
	unsigned int inkUniqueVar(_size_) = 0; \
	uint8_t *inkUniqueVar(_bytes_) = NULL;\
\
	if (_array_) \
	{ \
		inkUniqueVar(_count_) = inkArrayCount(_array_); \
		inkUniqueVar(_size_) = (_array_)->_elementSize; \
		inkUniqueVar(_bytes_) = (uint8_t *)((_array_)->elements) + ((inkUniqueVar(_count_) - 1) * inkUniqueVar(_size_)); \
	} \
\
	if (inkUniqueVar(_bytes_) && inkUniqueVar(_count_) > 0)\
		for (inkUniqueVar(_index_) = inkUniqueVar(_count_) - 1, (_obj_) = *((__typeof__(&(_obj_)))(inkUniqueVar(_bytes_))), _beg_; \
			 inkUniqueVar(_index_) >= 0; \
			 --inkUniqueVar(_index_), (inkUniqueVar(_bytes_)) -= (inkUniqueVar(_size_)), (inkUniqueVar(_index_) >= 0) ? ((_obj_) = *((__typeof__(&(_obj_)))(inkUniqueVar(_bytes_))), _cont_) : 0) 

#endif
