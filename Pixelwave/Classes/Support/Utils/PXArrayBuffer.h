/*
 *  _____                       ___                                            
 * /\  _ `\  __                /\_ \                                           
 * \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
 *  \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
 *   \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
 *    \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
 *     \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
 *       
 *           www.pixelwave.org + www.spiralstormgames.com
 *                            ~;   
 *                           ,/|\.           
 *                         ,/  |\ \.                 Core Team: Oz Michaeli
 *                       ,/    | |  \                           John Lattin
 *                     ,/      | |   |
 *                   ,/        |/    |
 *                 ./__________|----'  .
 *            ,(   ___.....-,~-''-----/   ,(            ,~            ,(        
 * _.-~-.,.-'`  `_.\,.',.-'`  )_.-~-./.-'`  `_._,.',.-'`  )_.-~-.,.-'`  `_._._,.
 * 
 * Copyright (c) 2011 Spiralstorm Games http://www.spiralstormgames.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#ifndef _PX_ARRAY_BUFFER_H_
#define _PX_ARRAY_BUFFER_H_

#include "PXHeaderUtils.h"
#include "PXMathUtils.h"

//#define PX_ARRAY_BUFFER_MAX_CHECKPOINTS 4

#define PXArrayBufferForEach(_array_, _obj_) \
	unsigned int PX_UNIQUE_VAR(_index_); \
	unsigned int PX_UNIQUE_VAR(_count_) = 0; \
	unsigned int PX_UNIQUE_VAR(_size_) = 0; \
	uint8_t *PX_UNIQUE_VAR(_bytes_) = NULL;\
\
	if (_array_) \
	{ \
		PX_UNIQUE_VAR(_count_) = PXArrayBufferCount(_array_); \
		PX_UNIQUE_VAR(_size_) = (_array_)->_elementSize; \
		PX_UNIQUE_VAR(_bytes_) = (uint8_t *)((_array_)->array); \
	} \
\
	if (PX_UNIQUE_VAR(_bytes_))\
	for (PX_UNIQUE_VAR(_index_) = 0, (_obj_) = (void *)(PX_UNIQUE_VAR(_bytes_)); \
		 PX_UNIQUE_VAR(_index_) < PX_UNIQUE_VAR(_count_); \
		 ++PX_UNIQUE_VAR(_index_), (PX_UNIQUE_VAR(_bytes_)) += (PX_UNIQUE_VAR(_size_)), (_obj_) = (void *)(PX_UNIQUE_VAR(_bytes_)))

#define PXArrayBufferPtrForEach(_array_, _obj_) \
	unsigned int PX_UNIQUE_VAR(_index_); \
	unsigned int PX_UNIQUE_VAR(_count_) = 0; \
	unsigned int PX_UNIQUE_VAR(_size_) = 0; \
	uint8_t *PX_UNIQUE_VAR(_bytes_) = NULL;\
\
	if (_array_) \
	{ \
		PX_UNIQUE_VAR(_count_) = PXArrayBufferCount(_array_); \
		PX_UNIQUE_VAR(_size_) = (_array_)->_elementSize; \
		PX_UNIQUE_VAR(_bytes_) = (uint8_t *)((_array_)->array); \
	} \
\
	if (PX_UNIQUE_VAR(_bytes_))\
	for (PX_UNIQUE_VAR(_index_) = 0, (_obj_) = *((void **)(PX_UNIQUE_VAR(_bytes_))); \
		 PX_UNIQUE_VAR(_index_) < PX_UNIQUE_VAR(_count_); \
		 ++PX_UNIQUE_VAR(_index_), (PX_UNIQUE_VAR(_bytes_)) += (PX_UNIQUE_VAR(_size_)), (_obj_) = *((void **)(PX_UNIQUE_VAR(_bytes_))))

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	void *array;

	size_t _byteCount;

	size_t _usedSize;
	size_t _maxUsedSize;

	size_t _minSize;
	size_t _elementSize;

	unsigned int count;
} PXArrayBuffer;

#pragma mark -
#pragma mark Declerations
#pragma mark -

PXInline PXArrayBuffer *PXArrayBufferCreate();// PX_ALWAYS_INLINE;
PXInline PXArrayBuffer *PXArrayBufferCreatev(size_t elementSize);// PX_ALWAYS_INLINE;
PXInline void PXArrayBufferRelease(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;

PXInline unsigned int PXArrayBufferCount(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
PXInline void *PXArrayBufferNext(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
PXInline void PXArrayBufferSetElementSize(PXArrayBuffer *buffer, size_t elementSize);// PX_ALWAYS_INLINE;

PXInline void PXArrayBufferUpdateCount(PXArrayBuffer *buffer, unsigned int count);
PXInline void PXArrayBufferSetMinCount(PXArrayBuffer *buffer, unsigned int count);
PXInline void PXArrayBufferSetMaxCount(PXArrayBuffer *buffer, unsigned int count);

PXInline void PXArrayBufferShiftLeft(PXArrayBuffer *buffer, unsigned int count);

PXInline void PXArrayBufferResize(PXArrayBuffer *buffer, size_t size);// PX_ALWAYS_INLINE;

PXInline void *PXArrayBufferElementAt(PXArrayBuffer *buffer, unsigned int index);

PXInline void PXArrayBufferListUpdate(PXArrayBuffer *buffer,
									  void *userData,
									  bool (*deleteCheck)(PXArrayBuffer *buffer, void *element, void *userData),
									  void (*updateFunc)(PXArrayBuffer *buffer, void *element, void *userData));

#pragma mark -
#pragma mark Implementations
#pragma mark -

PXInline PXArrayBuffer *PXArrayBufferCreate()
{
	return PXArrayBufferCreatev(sizeof(int));
}

PXInline PXArrayBuffer *PXArrayBufferCreatev(size_t elementSize)
{
	if (elementSize == 0)
		return NULL;

	PXArrayBuffer *buffer = (PXArrayBuffer *)(calloc(1, sizeof(PXArrayBuffer)));

	if (buffer != NULL)
	{
		buffer->_elementSize = sizeof(elementSize);
		buffer->_byteCount = buffer->_elementSize * 32;
		buffer->array = malloc(buffer->_byteCount);

		if (buffer->array == NULL)
		{
			free(buffer);
			buffer = NULL;
		}
	}

	return buffer;
}

PXInline void PXArrayBufferRelease(PXArrayBuffer *buffer)
{
	if (buffer != NULL)
	{
		if (buffer->array != NULL)
		{
			free(buffer->array);
			buffer->array = NULL;
		}

		free (buffer);
	}
}
PXInline void PXArrayBufferResize(PXArrayBuffer *buffer, size_t size)
{
	assert(buffer);
	assert(buffer->array);

	// MAX
	size = (size > buffer->_minSize) ? size : buffer->_minSize;

	if (size == buffer->_byteCount)
		return;

	buffer->_byteCount = size;
	buffer->array = realloc(buffer->array, buffer->_byteCount);
}
PXInline unsigned int PXArrayBufferCount(PXArrayBuffer *buffer)
{
	return buffer->count;
}
PXInline void *PXArrayBufferNext(PXArrayBuffer *buffer)
{
	assert(buffer);
	assert(buffer->array);

	size_t preUsedSize = buffer->_usedSize;
	buffer->_usedSize += buffer->_elementSize;
	++(buffer->count);

	if (buffer->_usedSize > buffer->_byteCount)
	{
		unsigned count = buffer->count + 10;
		size_t newSize = PXMathNextPowerOfTwo64(count) * buffer->_elementSize;
		PXArrayBufferResize(buffer, newSize);
	}

	void *current = (void *)(((uint8_t *)(buffer->array)) + preUsedSize);

	current = memset(current, 0, buffer->_elementSize);
	// Lets return the next available vertex for use.
	return current;
}

PXInline void PXArrayBufferSetElementSize(PXArrayBuffer *buffer, size_t elementSize)
{
	assert(buffer);
	assert(buffer->array);

	buffer->_elementSize = elementSize;
}

PXInline void PXArrayBufferUpdateCount(PXArrayBuffer *buffer, unsigned int count)
{
	assert(buffer);

	buffer->count = count;
	buffer->_usedSize = count * buffer->_elementSize;

	size_t lowerBounds = buffer->_byteCount >> 2;
	if ((buffer->_usedSize < lowerBounds && buffer->_usedSize > buffer->_minSize) ||
		buffer->_usedSize >= buffer->_byteCount)
	{
		size_t newSize = PXMathNextPowerOfTwo64(count) * buffer->_elementSize;
		PXArrayBufferResize(buffer, newSize);
	}
}
PXInline void PXArrayBufferSetMinCount(PXArrayBuffer *buffer, unsigned int count)
{
	assert(buffer);

	buffer->_minSize = count * buffer->_elementSize;

	if (buffer->_minSize > buffer->_byteCount)
		PXArrayBufferResize(buffer, buffer->_minSize);
}
PXInline void PXArrayBufferSetMaxCount(PXArrayBuffer *buffer, unsigned int count)
{
	assert(buffer);

	unsigned byteSize = count * buffer->_elementSize;

	if (byteSize > buffer->_byteCount)
		PXArrayBufferResize(buffer, byteSize);
}

PXInline void PXArrayBufferShiftLeft(PXArrayBuffer *buffer, unsigned int count)
{
	assert(buffer);

	if (count == 0)
		return;

	unsigned int oldCount = PXArrayBufferCount(buffer);

	if (count >= oldCount)
	{
		PXArrayBufferUpdateCount(buffer, 0);
		return;
	}

	size_t elementSize = buffer->_elementSize;

	uint8_t *bytes = (uint8_t *)(buffer->array);
	uint8_t *bytesOffset = bytes + (count * elementSize);

	unsigned int newCount = oldCount - count;

	memmove(bytes, bytesOffset, elementSize * newCount);

	PXArrayBufferUpdateCount(buffer, newCount);
}

PXInline void *PXArrayBufferElementAt(PXArrayBuffer *buffer, unsigned int index)
{
	assert(buffer);

	unsigned int count = PXArrayBufferCount(buffer);

	if (count == 0 || index >= count)
		return NULL;

	return (void *)((uint8_t *)(buffer->array) + (index * buffer->_elementSize));
}

PXInline void PXArrayBufferListUpdate(PXArrayBuffer *buffer,
									  void *userData,
									  bool (*deleteCheck)(PXArrayBuffer *buffer, void *element, void *userData),
									  void (*updateFunc)(PXArrayBuffer *buffer, void *element, void *userData))
{
	assert(buffer);

	size_t elementSize = buffer->_elementSize;
	uint8_t *bytes = (uint8_t *)(buffer->array);
	uint8_t *alive = bytes;
	void *element = bytes;

	unsigned int aliveCount = 0;
	// This loop goes through each particle in it's current order. If it needs
	// to be deleted, the particle is skipped and the alive pointer is not
	// incremented. If the alive pointer is not equal to the current pointer,
	// then the data from the pointer is copied, hence moving over the data.
	PXArrayBufferForEach(buffer, element)
	{
		if (deleteCheck && deleteCheck(buffer, element, userData))
		{
			continue;
		}

		if (updateFunc)
			updateFunc(buffer, element, userData);

		// If our pointer doesn't equal the next, then we deleted something...
		// so we need to shift the data over. Each element that is alive is only
		// copied once. This may be decieving because memcpy is used, however it
		// is only used on a SINGLE element at a time.
		if (alive != element)
		{
			memcpy(alive, element, elementSize);
		}

		alive += elementSize;
		++aliveCount;
	}

	PXArrayBufferUpdateCount(buffer, aliveCount);
}

#ifdef __cplusplus
}
#endif

#endif //_PX_ARRAY_BUFFER_H_
