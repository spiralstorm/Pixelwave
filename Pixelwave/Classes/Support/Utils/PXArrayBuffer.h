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

#import "PXPrivateUtils.h"

#define PX_ARRAY_BUFFER_MAX_CHECKPOINTS 4

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	unsigned index;
	void *pointer;
} PXArrayBufferCheckpoint;

typedef struct
{
	size_t _byteCount;

	size_t _usedSize;
	size_t _maxUsedSize;

	size_t _elementSize;

	unsigned _checkpointIndex;
	PXArrayBufferCheckpoint _checkpoints[PX_ARRAY_BUFFER_MAX_CHECKPOINTS];
	PXArrayBufferCheckpoint _next;
	
//	unsigned _checkpointIndex;
//	void *_checkpoint;
//	unsigned _nextIndex;
//	void *_next;

	void *array;
} PXArrayBuffer;

static const size_t PXArrayBufferMinumSize = sizeof(int) * 32;

#pragma mark -
#pragma mark Declerations
#pragma mark -

PX_INLINE PXArrayBuffer *PXArrayBufferCreate();// PX_ALWAYS_INLINE;
PX_INLINE void PXArrayBufferRelease(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
PX_INLINE void PXArrayBufferResize(PXArrayBuffer *buffer, size_t size);// PX_ALWAYS_INLINE;

PX_INLINE unsigned PXArrayBufferCount(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
PX_INLINE void *PXArrayBufferNext(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
PX_INLINE void PXArrayBufferConsolidate(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
PX_INLINE void PXArrayBufferReset(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
PX_INLINE void PXArrayBufferSetElementSize(PXArrayBuffer *buffer, size_t elementSize);// PX_ALWAYS_INLINE;
PX_INLINE void PXArrayBufferPushCheckpoint(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;
PX_INLINE void PXArrayBufferPopCheckpoint(PXArrayBuffer *buffer);// PX_ALWAYS_INLINE;

#pragma mark -
#pragma mark Implementations
#pragma mark -

PX_INLINE PXArrayBuffer *PXArrayBufferCreate()
{
	PXArrayBuffer *buffer = calloc(1, sizeof(PXArrayBuffer));

	if (buffer)
	{
		buffer->_byteCount = PXArrayBufferMinumSize;
		buffer->array = malloc(buffer->_byteCount);

		if (buffer->array)
		{
		//	buffer->_checkpoint = buffer->array;
		//	buffer->_next = buffer->array;
			unsigned index = 0;
			PXArrayBufferCheckpoint *currentCheckpoint;
			for (index = 0, currentCheckpoint = buffer->_checkpoints;
				 index < PX_ARRAY_BUFFER_MAX_CHECKPOINTS;
				 ++index, ++currentCheckpoint)
			{
				currentCheckpoint->pointer = buffer->array;
			}
			buffer->_next.pointer = buffer->array;
		}
		else
		{
			free(buffer);
			buffer = NULL;
		}
	}

	return buffer;
}
PX_INLINE void PXArrayBufferRelease(PXArrayBuffer *buffer)
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
PX_INLINE void PXArrayBufferResize(PXArrayBuffer *buffer, size_t size)
{
	assert(buffer);
	assert(buffer->array);

	size = MIN(size, PXArrayBufferMinumSize);

	if (size == buffer->_byteCount)
		return;

	buffer->_byteCount = size;
	buffer->array = realloc(buffer->array, buffer->_byteCount);

	size_t pos;
	unsigned index = 0;
	PXArrayBufferCheckpoint *currentCheckpoint;

	for (index = 0, currentCheckpoint = buffer->_checkpoints;
		 index < PX_ARRAY_BUFFER_MAX_CHECKPOINTS;
		 ++index, ++currentCheckpoint)
	{
		pos = buffer->_elementSize * currentCheckpoint->index;
		currentCheckpoint->pointer = &(((char *)(buffer->array))[pos]);
	}

	pos = buffer->_elementSize * buffer->_next.index;
	buffer->_next.pointer = &(((char *)(buffer->array))[pos]);

	//size_t pos = buffer->_elementSize * buffer->_checkpointIndex;
	//buffer->_checkpoint = &(((char *)(buffer->array))[pos]);
	//pos = buffer->_elementSize * buffer->_nextIndex;
	//buffer->_next = &(((char *)(buffer->array))[pos]);
}
PX_INLINE unsigned PXArrayBufferCount(PXArrayBuffer *buffer)
{
	return buffer->_next.index;
}
PX_INLINE void *PXArrayBufferNext(PXArrayBuffer *buffer)
{
	assert(buffer);
	assert(buffer->array);

	buffer->_usedSize += buffer->_elementSize;

	if (buffer->_usedSize > buffer->_byteCount)
	{
		int64_t val = buffer->_byteCount + buffer->_elementSize;

		val -= 1;
			val |= (val >> 1);
			val |= (val >> 2);
			val |= (val >> 4);
			val |= (val >> 8);
			val |= (val >> 16);
			val |= (val >> 32);
		val += 1;

		PXArrayBufferResize(buffer, val);
	}

	void *current = buffer->_next.pointer;

	++(buffer->_next.index);
	buffer->_next.pointer = buffer->_next.pointer + buffer->_elementSize;

	// Lets return the next available vertex for use.
	return current;
}
PX_INLINE void PXArrayBufferConsolidate(PXArrayBuffer *buffer)
{
	assert(buffer);
	assert(buffer->array);

	if (buffer->_maxUsedSize < (buffer->_byteCount >> 2))
	{
		PXArrayBufferResize(buffer, buffer->_byteCount >> 1);
	}

	buffer->_maxUsedSize = 0;
}
PX_INLINE void PXArrayBufferReset(PXArrayBuffer *buffer)
{
	assert(buffer);
	assert(buffer->array);

	buffer->_maxUsedSize = MAX(buffer->_maxUsedSize, buffer->_usedSize);

	buffer->_usedSize = 0;

	//buffer->_checkpointIndex = 0;
	//buffer->_checkpoint = buffer->array;
	//buffer->_nextIndex = 0;
	//buffer->_next = buffer->array;

	buffer->_next.index = 0;
	buffer->_next.pointer = buffer->array;

	unsigned index = 0;
	PXArrayBufferCheckpoint *currentCheckpoint;

	for (index = 0, currentCheckpoint = buffer->_checkpoints;
		 index < PX_ARRAY_BUFFER_MAX_CHECKPOINTS;
		 ++index, ++currentCheckpoint)
	{
		*currentCheckpoint = buffer->_next;
		//currentCheckpoint->index = 0;
		//currentCheckpoint->pointer = buffer->array;
	}
}
PX_INLINE void PXArrayBufferSetElementSize(PXArrayBuffer *buffer, size_t elementSize)
{
	assert(buffer);
	assert(buffer->array);
	//assert(buffer->_next.pointer == buffer->array);

	buffer->_elementSize = elementSize;
}
PX_INLINE void PXArrayBufferPushCheckpoint(PXArrayBuffer *buffer)
{
	assert(buffer);
	assert(buffer->array);
	// If this fails, then you have pushed on too many checkpoints
	assert(buffer->_checkpointIndex + 1 < PX_ARRAY_BUFFER_MAX_CHECKPOINTS);

	//buffer->_checkpoint = buffer->_next;
	buffer->_checkpoints[buffer->_checkpointIndex] = buffer->_next;
	++(buffer->_checkpointIndex);
}
PX_INLINE void PXArrayBufferRevertToCheckpoint(PXArrayBuffer *buffer)
{
	assert(buffer);
	assert(buffer->array);
	// If this fails, then you have popped on too many checkpoints
	assert(buffer->_checkpointIndex - 1 >= 0);

	//buffer->_next = buffer->_checkpoint;

	buffer->_next = buffer->_checkpoints[buffer->_checkpointIndex];
	--(buffer->_checkpointIndex);
}

#ifdef __cplusplus
}
#endif

#endif //_PX_ARRAY_BUFFER_H_
