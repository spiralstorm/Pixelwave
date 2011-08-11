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

#import "PXALSoundParser.h"

#import <AudioToolbox/AudioToolbox.h>
#import "PXAL.h"
#import "PXALSound.h"

#include "PXSoundEngine.h"

#import "PXDebug.h"

typedef struct
{
	void *bytes;
	
	int64_t byteCount;
} PXALByteData;

typedef struct
{
	char chunkID[4];
	uint32_t chunkSize;
	char format[4];
} _PXAudioFormatHeader;

OSStatus PXALSoundLoaderFileReader(void *byteData,
								   SInt64 offset,
								   UInt32 length,
								   void *writeBytes,
								   UInt32 *actualCount);
OSStatus PXALSoundLoaderFileWriter(void *inClientData,
								   SInt64 inPosition, 
								   UInt32 requestCount, 
								   const void *buffer, 
								   UInt32 *actualCount);
SInt64 PXALSoundLoaderFileGetSize(void *inClientData);
OSStatus PXALSoundLoaderFileSetSize(void *inClientData,
									SInt64 inSize);

@interface PXALSoundParser(Private)
- (BOOL) loadAudioFromFileID:(AudioFileID)afID;
@end

@implementation PXALSoundParser

- (BOOL) isModifiable
{
	return YES;
}

+ (BOOL) isApplicableForData:(NSData *)data origin:(NSString *)origin
{
	if (!data)
	{
		return NO;
	}

	void *bytes = (void *)[data bytes];
	int byteCount = [data length];

	if (byteCount < sizeof(_PXAudioFormatHeader))
	{
		return NO;
	}

	_PXAudioFormatHeader *chunks = bytes;
	_PXAudioFormatHeader header = *chunks;

	NSString *chunkID = [NSString stringWithFormat:@"%c%c%c%c",
						 header.chunkID[0], header.chunkID[1], header.chunkID[2], header.chunkID[3]];
	NSString *format  = [NSString stringWithFormat:@"%c%c%c%c",
						 header.format[0], header.format[1], header.format[2], header.format[3]];

	chunkID = [chunkID lowercaseString];
	format  = [format lowercaseString];

	if ([chunkID isEqualToString:@"caff"] || [format isEqualToString:@"wave"])
	{
		return YES;
	}

	return NO;
}
+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{	
	//Uncompressed:
	[extensions addObject:@"aif"];
	[extensions addObject:@"aiff"];
	[extensions addObject:@"wav"];
}

- (PXSound *)newSound
{
	if (!soundInfo)
	{
		return nil;
	}

	PXParsedSoundData *curSoundInfo = soundInfo;

	if (modifiedSoundInfo)
	{
		curSoundInfo = modifiedSoundInfo;
	}

	PXSoundFormat format = curSoundInfo->format;
	int freq = curSoundInfo->freq;

	unsigned channelCount = curSoundInfo->channelCount;
	unsigned milliseconds = curSoundInfo->milliseconds;

	void *memData = curSoundInfo->bytes;
	unsigned bytesTotal = curSoundInfo->byteCount;

	PXALSound *sound = [[PXALSound alloc] initWithFormat:format
											   frequency:freq
											  bytesTotal:bytesTotal
												  length:milliseconds
											channelCount:channelCount];

	if (sound)
	{
		ALenum error;

		error = alGetError();
		if (!sound->_alName || error != AL_NO_ERROR)
		{
			[sound release];
			sound = nil;
			return nil;
		}

		alBufferData(sound->_alName, format, memData, bytesTotal, freq);
		error = alGetError();

		if (error != AL_NO_ERROR)
		{
			[sound release];
			sound = nil;
			return nil;
		}
	}

	return sound;
}

- (NSString *)getErrorText:(OSStatus)error
{
	switch(error)
	{
		case kAudioFileUnspecifiedError:
			return @"An unspecified error has occurred.";
		case kAudioFileUnsupportedFileTypeError:
			return @"The file type is not supported.";
		case kAudioFileUnsupportedDataFormatError:
			return @"The data format is not supported by this file type.";
		case kAudioFileUnsupportedPropertyError:
			return @"The property is not supported.";
		case kAudioFileBadPropertySizeError:
			return @"The size of the property data was not correct.";
		case kAudioFilePermissionsError:
			return @"The operation violated the file permissions. For example, an attempt was made to write to a file opened with the kAudioFileReadPermission  constant.";
		case kAudioFileNotOptimizedError:
			return @"The chunks following the audio data chunk are preventing the extension of the audio data chunk. To write more data, you must optimize the file.";
		case kAudioFileInvalidChunkError:
			return @"Either the chunk does not exist in the file or it is not supported by the file.";
		case kAudioFileDoesNotAllow64BitDataSizeError:
			return @"The file offset was too large for the file type. The AIFF and WAVE file format types have 32-bit file size limits.";
		case kAudioFileInvalidPacketOffsetError:
			return @"A packet offset was past the end of the file, or not at the end of the file when a VBR format was written, or a corrupt packet size was read when the packet table was built.";
		case kAudioFileInvalidFileError:
			return @"The file is malformed, or otherwise not a valid instance of an audio file of its type.";
		case kAudioFileOperationNotSupportedError:
			return @"The operation cannot be performed. For example, setting the kAudioFilePropertyAudioDataByteCount constant to increase the size of the audio data in a file is not a supported operation. Write the data instead.";
	}

	return @"Unknown error.";
}

- (BOOL) _parse
{
	PXSoundEngineInitAL();

	AudioFileID afID;

	PXALByteData byteData;
	byteData.bytes = (void *)[data bytes];
	byteData.byteCount = [data length];

//	PXDebugLog (@"PXALSoundParser byte count = %u\n", byteData.byteCount);

	OSStatus didAnErrorOccur = AudioFileOpenWithCallbacks(&byteData,
														  PXALSoundLoaderFileReader,
														  PXALSoundLoaderFileWriter,
														  PXALSoundLoaderFileGetSize,
														  PXALSoundLoaderFileSetSize,
														  0,
														  &afID);
	

	if (didAnErrorOccur)
	{
		[self _log:@"error occured while loading data"];

		if (afID)
		{
			AudioFileClose(afID);
		}

		return NO;
	}

	return [self loadAudioFromFileID:afID];
}

- (BOOL) loadAudioFromFileID:(AudioFileID)afID
{
	if (!soundInfo)
	{
		return NO;
	}

	if (soundInfo->bytes)
	{
		free(soundInfo->bytes);
		soundInfo->bytes = nil;
	}

	OSStatus didAnErrorOccur = 0;

	AudioStreamBasicDescription fileFormat;
	UInt64 fileDataSize = 0;
	UInt32 propertySize = sizeof(UInt64);

	didAnErrorOccur = AudioFileGetProperty(afID, kAudioFilePropertyAudioDataByteCount, &propertySize, &fileDataSize);
	if (didAnErrorOccur)
	{
		[self _log:[NSString stringWithFormat:@"error occured while reading the size, error message:%@", [self getErrorText:didAnErrorOccur]]];

		if (afID)
			AudioFileClose(afID);

		return NO;
	}

//	didAnErrorOccur = NO;

	NSTimeInterval timeInterval;
	propertySize = sizeof(NSTimeInterval);
	didAnErrorOccur = AudioFileGetProperty(afID, kAudioFilePropertyEstimatedDuration, &propertySize, &timeInterval);

	if (didAnErrorOccur)
	{
		[self _log:[NSString stringWithFormat:@"error occured while reading the length, error message:%@", [self getErrorText:didAnErrorOccur]]];

		if (afID)
			AudioFileClose(afID);
		afID = 0;

		return NO;
	}

	soundInfo->milliseconds = timeInterval * 1000;
//	didAnErrorOccur = NO;

	propertySize = sizeof(fileFormat);
	// Get the audio data format
	didAnErrorOccur = AudioFileGetProperty(afID, kAudioFilePropertyDataFormat, &propertySize, &fileFormat);
	if (didAnErrorOccur)
	{
		[self _log:[NSString stringWithFormat:@"error occured while reading the format, error message:%@", [self getErrorText:didAnErrorOccur]]];

		if (afID)
			AudioFileClose(afID);
		afID = 0;

		return NO;
	}

	didAnErrorOccur = NO;

	soundInfo->channelCount = fileFormat.mChannelsPerFrame;
	if (fileFormat.mChannelsPerFrame > 2)
	{
		[self _log:@"unsupported format, channel count is greater than two"];

		didAnErrorOccur = YES;
	}
	if (!TestAudioFormatNativeEndian(fileFormat))
	{
		[self _log:@"unsupported format, must be little-endian PCM"];

		didAnErrorOccur = YES;
	}
	if ((fileFormat.mBitsPerChannel != 8) && (fileFormat.mBitsPerChannel != 16))
	{
		[self _log:@"unsupported format, must be 8 or 16 bit"];

		didAnErrorOccur = YES;
	}

	if (didAnErrorOccur)
	{
		if (afID)
			AudioFileClose(afID);
		afID = 0;

		return NO;
	}

//	didAnErrorOccur = NO;

	if (fileFormat.mBitsPerChannel == 8)
	{
		soundInfo->format = (fileFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO8 : AL_FORMAT_MONO8;
	}
	else
	{
		soundInfo->format = (fileFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
	}

	soundInfo->bytes = malloc(fileDataSize);
	if (!soundInfo->bytes)
	{
		if (afID)
			AudioFileClose(afID);
		afID = 0;

		return NO;
	}

	SInt64 inStartingByte = 0;
	UInt32 numBytes32 = fileDataSize;

	didAnErrorOccur = AudioFileReadBytes(afID, false, inStartingByte, &numBytes32, soundInfo->bytes);
	if (didAnErrorOccur)
	{
		[self _log:[NSString stringWithFormat:@"error occured while reading the data, error message:%@", [self getErrorText:didAnErrorOccur]]];

		if (afID)
			AudioFileClose(afID);
		afID = 0;

		return NO;
	}

	soundInfo->byteCount = numBytes32;

	if (afID)
	{
		AudioFileClose(afID);
		afID = 0;
	}

	soundInfo->freq = fileFormat.mSampleRate;

	return YES;
}

OSStatus PXALSoundLoaderFileReader(void *byteData,
								   SInt64 offset,
								   UInt32 length,
								   void *writeBytes,
								   UInt32 *actualCount)
{
	PXALByteData *data = (PXALByteData *)byteData;

	if (offset + length > data->byteCount)
	{
		int64_t possibleLength = data->byteCount - offset;

		if (possibleLength > 0)
		{
			length = possibleLength;
		}
		else
		{
			PXDebugLog(@"PXALSoundLoaderFileReader:Unable to continue reading, at end of file.");

			return kAudioFileUnspecifiedError;
		}
    }

	void *readByte = data->bytes + offset;

   memcpy(writeBytes, readByte, length);

    *actualCount = length;

    return 0;
}

OSStatus PXALSoundLoaderFileWriter(void *byteData,
								   SInt64 inPosition, 
								   UInt32 requestCount, 
								   const void *buffer, 
								   UInt32 *actualCount)
{
	return kAudioFileUnspecifiedError;
}

SInt64 PXALSoundLoaderFileGetSize(void *byteData)
{
	PXALByteData *data = (PXALByteData *)byteData;

	return data->byteCount;
}

OSStatus PXALSoundLoaderFileSetSize(void *byteData,
									SInt64 inSize)
{
	return kAudioFileUnspecifiedError;
}

@end
