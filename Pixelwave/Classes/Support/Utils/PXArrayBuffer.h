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

#import "PXHeaderUtils.h"

//#define PX_ARRAY_BUFFER_MAX_CHECKPOINTS 4

#define PXArrayBufferForEach(_array_, _obj_) \
	unsigned PX_UNIQUE_VAR(_index_); \
	unsigned PX_UNIQUE_VAR(_count_) = 0; \
	unsigned PX_UNIQUE_VAR(_size_) = 0; \
	uint8_t *PX_UNIQUE_VAR(_bytes_) = NULL;\
\
	if (_array_) \
	{ \
		PX_UNIQUE_VAR(_count_) = PXArrayBufferCount(_array_); \
		PX_UNIQUE_VAR(_size_) = (_array_)->_elementSize; \
		PX_UNIQUE_VAR(_bytes_) = (uint8_t *)((_array_)->array); \
	} \
\
	for (PX_UNIQUE_VAR(_index_) = 0, (_obj_) = (void *)(PX_UNIQUE_VAR(_bytes_)); \
		 PX_UNIQUE_VAR(_index_) < PX_UNIQUE_VAR(_count_); \
		 ++PX_UNIQUE_VAR(_index_), (PX_UNIQUE_VAR(_bytes_)) += (PX_UNIQUE_VAR(_size_)), (_obj_) = (void *)(PX_UNIQUE_VAR(_bytes_)))

#ifdef __cplusplus
extern "C" {
#endif

/*typedef struct
{
	unsigned index;
	void *pointer;
} PXArrayBufferCheckpoint;*/

typedef struct
{
	void *array;

	size_t _byteCount;

	size_t _usedSize;
	size_t _maxUsedSize;

	size_t _minSize;
	size_t _elementSize;

//	unsigned _checkpointIndex;
//	PXArrayBufferCheckpoint _checkpoints[PX_ARRAY_BUFFER_MAX_CHECKPOINTS];
//	PXArrayBufferCheckpoint _next;

	unsigned count;
} PXArrayBuffer;

#pragma mark -
#pragma mark Declerations
#pragma mark -

PXInline PXArrayBuffer *PXArrayBufferCreate();// PX_ALWAYS_INLINE;
PXInline void PXArrayBufferRelease(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;

PXInline unsigned PXArrayBufferCount(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
PXInline void *PXArrayBufferNext(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
PXInline void PXArrayBufferSetElementSize(PXArrayBuffer *buffer, size_t elementSize);// PX_ALWAYS_INLINE;

PXInline void PXArrayBufferUpdateCount(PXArrayBuffer *buffer, unsigned count);
PXInline void PXArrayBufferSetMinCount(PXArrayBuffer *buffer, unsigned count);
PXInline void PXArrayBufferSetMaxCount(PXArrayBuffer *buffer, unsigned count);

PXInline void PXArrayBufferResize(PXArrayBuffer *buffer, size_t size);// PX_ALWAYS_INLINE;

PXInline void PXArrayBufferListUpdate(PXArrayBuffer *buffer,
							 void *userData,
							 bool (*deleteCheck)(PXArrayBuffer *buffer, void *element, void *userData),
							 void (*updateFunc)(PXArrayBuffer *buffer, void *element, void *userData));

//PXInline void PXArrayBufferConsolidate(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
//PXInline void PXArrayBufferReset(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
//PXInline void PXArrayBufferPushCheckpoint(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
//PXInline void PXArrayBufferPopCheckpoint(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;

#pragma mark -
#pragma mark Implementations
#pragma mark -

PXInline PXArrayBuffer *PXArrayBufferCreate()
{
	PXArrayBuffer *buffer = (PXArrayBuffer *)(calloc(1, sizeof(PXArrayBuffer)));

	if (buffer)
	{
		buffer->_elementSize = sizeof(int);
		buffer->_byteCount = buffer->_elementSize * 32;
		buffer->array = malloc(buffer->_byteCount);

		if (buffer->array)
		{
	//		unsigned index = 0;
	//		PXArrayBufferCheckpoint *currentCheckpoint;
	//		for (index = 0, currentCheckpoint = buffer->_checkpoints;
	//			 index < PX_ARRAY_BUFFER_MAX_CHECKPOINTS;
	//			 ++index, ++currentCheckpoint)
	//		{
	//			currentCheckpoint->pointer = buffer->array;
	//		}
	//		buffer->_next.pointer = buffer->array;
	// 		buffer->_next.index = 0;
		}
		else
		{
			free(buffer);
			buffer = NULL;
		}
	}

	return buffer;
}
PXInline void PXArrayBufferRelease(PXArrayBuffer *buffer)
{
	if (buffer)
	{
		if (buffer->array)
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

	size = MAX(size, buffer->_minSize);

	if (size == buffer->_byteCount)
		return;

	buffer->_byteCount = size;
	buffer->array = realloc(buffer->array, buffer->_byteCount);

//	uint8_t *bytes = buffer->array;
//	size_t pos;
//	unsigned index = 0;
//	PXArrayBufferCheckpoint *currentCheckpoint;

//	for (index = 0, currentCheckpoint = buffer->_checkpoints;
//		 index < PX_ARRAY_BUFFER_MAX_CHECKPOINTS;
//		 ++index, ++currentCheckpoint)
//	{
//		pos = buffer->_elementSize * currentCheckpoint->index;
//		currentCheckpoint->pointer = &(((uint8_t *)(buffer->array))[pos]);
//	}
//

//	pos = buffer->_elementSize * buffer->_next.index;
//	buffer->_next.pointer = bytes + pos;
}
PXInline unsigned PXArrayBufferCount(PXArrayBuffer *buffer)
{
	return buffer->count;//buffer->_next.index;
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
	//	unsigned count = buffer->_next.index;
	//	int64_t val = buffer->_byteCount + buffer->_elementSize;

	//	val = PXMathNextPowerOfTwo64(val);

		unsigned count = buffer->count + 10;
		size_t newSize = PXMathNextPowerOfTwo64(count) * buffer->_elementSize;
		PXArrayBufferResize(buffer, newSize);
	}

	void *current = (void *)(((uint8_t *)(buffer->array)) + preUsedSize);
//	buffer->_next.index = buffer->_usedSize / buffer->_elementSize;
//	void *current = buffer->_next.pointer;

//	++(buffer->_next.index);
//	buffer->_next.pointer = buffer->_next.pointer + buffer->_elementSize;

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

PXInline void PXArrayBufferUpdateCount(PXArrayBuffer *buffer, unsigned count)
{
	assert(buffer);

	buffer->count = count;
	buffer->_usedSize = count * buffer->_elementSize;
//	buffer->_next.index = count;

	//size_t newSize = PXMathNextPowerOfTwo64(buffer->_usedSize);
	size_t lowerBounds = buffer->_byteCount >> 2;
	if ((buffer->_usedSize < lowerBounds && buffer->_usedSize > buffer->_minSize) ||
		buffer->_usedSize >= buffer->_byteCount)
	{
		size_t newSize = PXMathNextPowerOfTwo64(count) * buffer->_elementSize;
		PXArrayBufferResize(buffer, newSize);
	}
}
PXInline void PXArrayBufferSetMinCount(PXArrayBuffer *buffer, unsigned count)
{
	assert(buffer);

	buffer->_minSize = count * buffer->_elementSize;

	if (buffer->_minSize > buffer->_byteCount)
		PXArrayBufferResize(buffer, buffer->_minSize);
}
PXInline void PXArrayBufferSetMaxCount(PXArrayBuffer *buffer, unsigned count)
{
	assert(buffer);

	unsigned byteSize = count * buffer->_elementSize;

	if (byteSize > buffer->_byteCount)
		PXArrayBufferResize(buffer, byteSize);
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

//	unsigned index;
	unsigned aliveCount = 0;
	// This loop goes through each particle in it's current order. If it needs
	// to be deleted, the particle is skipped and the alive pointer is not
	// incremented. If the alive pointer is not equal to the current pointer,
	// then the data from the pointer is copied, hence moving over the data.
	//PXArrayBufferForEach(buffer, element)
	//for (index = 0, element = bytes; index < buffer->count; ++index, element += elementSize)
	//{
	PXArrayBufferForEach(buffer, element)
	{
		if (deleteCheck && deleteCheck(buffer, element, userData))
		{
			continue;
		}

		if (updateFunc)
			updateFunc(buffer, element, userData);

		// If our pointer doesn't equal the next, then we deleted something...
		// so we need to shift the data over.
		if (alive != element)
		{
			memcpy(alive, element, elementSize);
		}

		alive += elementSize;
		++aliveCount;
	}

	PXArrayBufferUpdateCount(buffer, aliveCount);
}


/*PXInline void PXArrayBufferConsolidate(PXArrayBuffer *buffer)
{
	assert(buffer);
	assert(buffer->array);

	if (buffer->_maxUsedSize < (buffer->_byteCount >> 2))
	{
		PXArrayBufferResize(buffer, buffer->_byteCount >> 1);
	}

	buffer->_maxUsedSize = 0;
}
PXInline void PXArrayBufferReset(PXArrayBuffer *buffer)
{
	assert(buffer);
	assert(buffer->array);

	buffer->_maxUsedSize = MAX(buffer->_maxUsedSize, buffer->_usedSize);

	buffer->_usedSize = 0;

	buffer->_next.index = 0;
	buffer->_next.pointer = buffer->array;

	unsigned index = 0;
	PXArrayBufferCheckpoint *currentCheckpoint;

	for (index = 0, currentCheckpoint = buffer->_checkpoints;
		 index < PX_ARRAY_BUFFER_MAX_CHECKPOINTS;
		 ++index, ++currentCheckpoint)
	{
		*currentCheckpoint = buffer->_next;
	}
}

PXInline void PXArrayBufferPushCheckpoint(PXArrayBuffer *buffer)
{
	assert(buffer);
	assert(buffer->array);
	// If this fails, then you have pushed on too many checkpoints
	assert(buffer->_checkpointIndex + 1 < PX_ARRAY_BUFFER_MAX_CHECKPOINTS);

	//buffer->_checkpoint = buffer->_next;
	buffer->_checkpoints[buffer->_checkpointIndex] = buffer->_next;
	++(buffer->_checkpointIndex);
}
PXInline void PXArrayBufferRevertToCheckpoint(PXArrayBuffer *buffer)
{
	assert(buffer);
	assert(buffer->array);
	// If this fails, then you have popped on too many checkpoints
	assert(buffer->_checkpointIndex - 1 >= 0);

	//buffer->_next = buffer->_checkpoint;

	buffer->_next = buffer->_checkpoints[buffer->_checkpointIndex];
	--(buffer->_checkpointIndex);
}*/

#ifdef __cplusplus
}
#endif

#endif //_PX_ARRAY_BUFFER_H_
