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

#import "PXALSoundChannel.h"

#import "PXAL.h"
#import "PXSoundEngine.h"
#import "PXSoundTransform3D.h"
#import "PXALSound.h"

#import "PXEvent.h"

#include "PXMathUtils.h"
#import "PXDebugUtils.h"

@interface PXALSoundChannel(Private)
- (BOOL) errorOccured;
- (void) _setDone:(BOOL)done;
@end

@implementation PXALSoundChannel

- (id) init
{
	PXDebugLog (@"Can not initialize a sound channel.  Must produce one through PXSound.\n");

	[self release];
	return nil;
}

- (id) _initWithSound:(PXALSound *)_sound
			startTime:(unsigned)_startTime
			loopCount:(int)_loops
	   soundTransform:(PXSoundTransform *)_soundTransform
{
	self = [super _initWithStartTime:_startTime loopCount:_loops soundTransform:_soundTransform];

	if (self)
	{
		sound = [_sound retain];
		isDone = YES;

		buffers = 0;
		totalProcessed = 0;

		// Clear the error cache
		alGetError();

		alGenSources(1, &_sourceID);

		if (!_sourceID || [self errorOccured])
		{
			[self release];
			return nil;
		}

		playCount = loopCount + 1;

		if (startTime != 0)
		{
			float percent = (float)startTime / (float)sound.length;
			PXMathClamp(percent, 0.0f, 1.0f);
			byteOffset = percent * sound->_bytesTotal;
		}
		else
			byteOffset = 0;

		if (loopCount == PX_SOUND_INFINITE_LOOPS)
			bufferCount = 16;
		else
			bufferCount = fabsf(playCount);
		buffers = calloc(bufferCount, sizeof(unsigned));

		if (!buffers)
		{
			PXDebugLog (@"SoundChannel error! ID:0x%X - info:'%@'.", AL_OUT_OF_MEMORY, @"out of memory");
		}

		unsigned index;
		unsigned *buffer;

		for (index = 0, buffer = buffers; index < bufferCount; ++index, ++buffer)
			*buffer = sound->_alName;

		alSourceQueueBuffers(_sourceID, bufferCount, buffers);

		if ([self errorOccured])
		{
			alDeleteSources(1, &_sourceID);

			[self release];
			return nil;
		}

		bufferID = 0;

		distanceModel = -1;

		alSourcei(_sourceID, AL_BYTE_OFFSET, byteOffset);

		alSourcei(_sourceID, AL_SOURCE_RELATIVE, AL_TRUE);
		alSource3f(_sourceID, AL_POSITION, 0.0f, 0.0f, 0.0f);
		alSource3f(_sourceID, AL_VELOCITY, 0.0f, 0.0f, 0.0f);
		alSourcef(_sourceID, AL_PITCH, soundTransform.pitch);
		alSourcef(_sourceID, AL_GAIN, soundTransform.volume);

		self.soundTransform = _soundTransform;

		isDone = NO;
	}

	return self;
}

- (void) dealloc
{
	if (_sourceID)
		[self _stop];

	if (buffers)
	{
		if (_sourceID && bufferID < bufferCount - 1)
		{
			alSourceUnqueueBuffers(_sourceID, bufferCount - bufferID, buffers + bufferID);
		}

		free(buffers);
	}

	buffers = 0;
	bufferCount = 0;

	if (_sourceID)
	{
		alDeleteSources(1, &_sourceID);
	}

	[sound release];

	[super dealloc];
}

- (BOOL) errorOccured
{
	ALenum error = alGetError();

	if (error == AL_NO_ERROR)
	{
		return NO;
	}

	//NSString *errorInfo = ;

	PXDebugLog (@"SoundChannel error! ID:0x%X - info:'%@'.", error, PXDebugALErrorInfo(error));

	return YES;
}

- (void) _update
{
	ALint processed;
	alGetSourcei (_sourceID, AL_BUFFERS_PROCESSED, &processed);

	if (processed)
	{
		if (loopCount != PX_SOUND_INFINITE_LOOPS)
		{
			int oldBufferID = bufferID;

			bufferID += processed;
			totalProcessed += processed;

			if (bufferID >= playCount)
			{
				bufferID = playCount - 1;
			}

			int removeCount = (bufferID - oldBufferID);
			if (removeCount > 0)
				alSourceUnqueueBuffers(_sourceID, removeCount, buffers + oldBufferID);

			if (byteOffset != 0)
			{
				[self rewind];
				[self play];
			}
		}
		else
		{
			ALint buffersQueued = 0;
			alGetSourcei(_sourceID, AL_BUFFERS_QUEUED, &buffersQueued);
			alSourceUnqueueBuffers(_sourceID, processed, buffers);
			alSourceQueueBuffers(_sourceID, processed, buffers);
		}
	}

	ALint curByte;
	alGetSourcei(_sourceID, AL_BYTE_OFFSET, &curByte);

	if (curByte < byteOffset)
	{
		alSourcei(_sourceID, AL_BYTE_OFFSET, byteOffset);
	}

	if (totalProcessed >= playCount && loopCount != PX_SOUND_INFINITE_LOOPS)
	{
		[self _setDone:YES];
	}
}

- (void) _setDone:(BOOL)done
{
	if (isDone == done)
	{
		return;
	}

	isDone = done;

	if (isDone)
	{
		PXEvent *event = [[PXEvent alloc] initWithType:PXEvent_SoundComplete bubbles:NO cancelable:NO];
		[self dispatchEvent:event];
		[event release];
	}
}

- (BOOL) _done
{
	return isDone;
}

- (void) setSoundTransform:(PXSoundTransform *)_soundTransform
{
	if (!_soundTransform || !_sourceID)
	{
		return;
	}

	BOOL isCurrent3D = [soundTransform isKindOfClass:[PXSoundTransform3D class]];
	BOOL isNew3D = [_soundTransform isKindOfClass:[PXSoundTransform3D class]];

	if (isNew3D && !sound.is3DReady)
	{
		PXDebugLog(@"PXSoundChannel warning: 3D playback is not supported for this audio file (try converting to mono)");
	}

	if (isCurrent3D != isNew3D)
	{
		[soundTransform release];

		if (isNew3D)
			soundTransform = [[PXSoundTransform3D alloc] init];
		else
			soundTransform = [[PXSoundTransform alloc] init];

		isCurrent3D = isNew3D;
	}

	soundTransform.pitch  = _soundTransform.pitch;
	soundTransform.volume = _soundTransform.volume;

	alSourcef(_sourceID, AL_PITCH, soundTransform.pitch);
	alSourcef(_sourceID, AL_GAIN, soundTransform.volume);

	if (isCurrent3D)
	{
		PXSoundTransform3D *currentSoundTransform3D = (PXSoundTransform3D *)soundTransform;
		PXSoundTransform3D *newSoundTransform3D = (PXSoundTransform3D *)_soundTransform;

		currentSoundTransform3D.x = newSoundTransform3D.x;
		currentSoundTransform3D.y = newSoundTransform3D.y;
		currentSoundTransform3D.z = newSoundTransform3D.z;

		currentSoundTransform3D.velocityX = newSoundTransform3D.velocityX;
		currentSoundTransform3D.velocityY = newSoundTransform3D.velocityY;
		currentSoundTransform3D.velocityZ = newSoundTransform3D.velocityZ;

		currentSoundTransform3D.referenceDistance = newSoundTransform3D.referenceDistance;
		currentSoundTransform3D.logarithmicExponent = newSoundTransform3D.logarithmicExponent;

		[self _updateDistanceModel];

		alSourcei(_sourceID, AL_SOURCE_RELATIVE, AL_FALSE);

		float alX;
		float alY;
		float alZ;

		alX = currentSoundTransform3D.x;
		alY = -currentSoundTransform3D.y;
		alZ = -currentSoundTransform3D.z;
		alSource3f(_sourceID, AL_POSITION, alX, alY, alZ);

		alX = currentSoundTransform3D.velocityX;
		alY = -currentSoundTransform3D.velocityY;
		alZ = -currentSoundTransform3D.velocityZ;
		alSource3f(_sourceID, AL_VELOCITY, alX, alY, alZ);
	}
	else
	{
		alSourcei(_sourceID, AL_SOURCE_RELATIVE, AL_TRUE);
		alSource3f(_sourceID, AL_POSITION, 0.0f, 0.0f, 0.0f);
		alSource3f(_sourceID, AL_VELOCITY, 0.0f, 0.0f, 0.0f);
	}

	soundTransform.pitch  = _soundTransform.pitch;
	soundTransform.volume = _soundTransform.volume;

	alSourcef(_sourceID, AL_PITCH, soundTransform.pitch);
	alSourcef(_sourceID, AL_GAIN, soundTransform.volume);
}

- (void) _updateDistanceModel
{
	PXSoundMixerDistanceModel newDistanceModel = PXSoundEngineGetDistanceModel();

	if (distanceModel == newDistanceModel)
	{
		return;
	}

	distanceModel = newDistanceModel;

	if ([soundTransform isKindOfClass:[PXSoundTransform3D class]])
	{
		PXSoundTransform3D *currentSoundTransform3D = (PXSoundTransform3D *)soundTransform;

		switch (distanceModel)
		{
			case PXSoundMixerDistanceModel_Linear:
				alSourcef(_sourceID, AL_MAX_DISTANCE, currentSoundTransform3D.referenceDistance);
				alSourcef(_sourceID, AL_REFERENCE_DISTANCE, 0.0f);
				alSourcef(_sourceID, AL_ROLLOFF_FACTOR, 1.0f);
				break;
			case PXSoundMixerDistanceModel_Logarithmic:
				alSourcef(_sourceID, AL_REFERENCE_DISTANCE, currentSoundTransform3D.referenceDistance);
				alSourcef(_sourceID, AL_ROLLOFF_FACTOR, currentSoundTransform3D.logarithmicExponent);
				alSourcef(_sourceID, AL_MAX_DISTANCE, 32768.0f);
				break;
			default:
				break;
		}
	}
}

- (BOOL) _play
{
	// Clear the error cache
	alGetError();

	alSourcePlay(_sourceID);

	if ([self errorOccured])
	{
		return NO;
	}

	return YES;
}

- (void) _pause
{
	alSourcePause(_sourceID);
}

- (void) _stop
{
	alSourceStop(_sourceID);

	[self _setDone:YES];
}

- (void) _rewind
{
	//alSourceRewind(_sourceID);
	alSourcei(_sourceID, AL_BYTE_OFFSET, byteOffset);
}

- (unsigned) position
{
	ALint curByte;
	alGetSourcei(_sourceID, AL_BYTE_OFFSET, &curByte);

	float percent = (float)curByte / (float)sound->_bytesTotal;

	return sound.length * percent;
}

/*- (float) leftPeak
{
	//This doesn't work, it gets the position... aka offset
	int format = sound->format;
	 float leftPeak = 0.0f;
	 ALint curByte;
	 AL_
	 alGetSourcei(sourceID, AL_SAMPLE_OFFSET, &curByte);
	 
	 if (format == AL_FORMAT_STEREO8 || format == AL_FORMAT_MONO8)
	 {
	 UInt8 * curBytes = (UInt8 *)(&curByte);
	 leftPeak = (float)curBytes[0]/(float)UINT8_MAX;
	 }
	 else
	 {
	 UInt16 * curBytes = (UInt16 *)(&curByte);
	 leftPeak = (float)curBytes[0]/(float)UINT16_MAX;
	 }
	 
	 return leftPeak;
}

- (float) rightPeak
{
	// This doesn't work, it gets the position... aka offset
	int format = sound->format;
	 float rightPeak = 0.0f;
	 ALint curByte;
	 alGetSourcei(sourceID, AL_SAMPLE_OFFSET, &curByte);
	 
	 int byteID = 1;
	 if (format == AL_FORMAT_MONO8 || format == AL_FORMAT_MONO16)
	 byteID = 0;
	 
	 if (format == AL_FORMAT_STEREO8 || format == AL_FORMAT_MONO8)
	 {
	 UInt8 * curBytes = (UInt8 *)(&curByte);
	 rightPeak = (float)curBytes[byteID]/(float)UINT8_MAX;
	 }
	 else
	 {
	 UInt16 * curBytes = (UInt16 *)(&curByte);
	 rightPeak = (float)curBytes[byteID]/(float)UINT16_MAX;
	 }
	 
	 return rightPeak;
}*/

@end
