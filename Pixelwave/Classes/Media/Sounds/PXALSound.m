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

#import "PXALSound.h"

#import "PXAL.h"
#import "PXSoundEngine.h"
#import "PXALSoundChannel.h"

@implementation PXALSound

- (id) initWithFormat:(int)format
			frequency:(int)frequency
		   bytesTotal:(int)bytesTotal
			   length:(unsigned)_length
		 channelCount:(unsigned)channelCount
{
	self = [super _initWithLength:_length];

	if (self)
	{
		PXSoundEngineInitAL();

		_format = format;
		_freq = frequency;
		_bytesTotal = bytesTotal;
		alGenBuffers(1, &_alName);
		_channelCount = channelCount;
	}

	return self;
}

- (void) dealloc
{
	if (_alName)
	{
//		PXDebugALBeginErrorChecks(@"PXALSound dealloc");

		alDeleteBuffers(1, &_alName);

//		PXDebugALErrorCheck(@"alDeleteBuffers");
//		PXDebugALEndErrorChecks();
	}

	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(%@, format=%d, freq=%d, channelCount=%u)",
			[super description],
			_format,
			_freq,
			_channelCount];
}

- (BOOL) is3DReady
{
	return (_format == AL_FORMAT_MONO8 || _format == AL_FORMAT_MONO16);
}

- (PXSoundChannel *)playWithStartTime:(unsigned)startTime
							loopCount:(int)loops
					   soundTransform:(PXSoundTransform *)soundTransform
{
	[super playWithStartTime:startTime loopCount:loops soundTransform:soundTransform];

	PXALSoundChannel *channel = [[PXALSoundChannel alloc] _initWithSound:self
															   startTime:startTime
															   loopCount:loops
														  soundTransform:soundTransform];

	PXSoundEngineAddSound (channel);
	[channel release];

	if (![channel play])
	{
		PXSoundEngineRemoveSound(channel);
		channel = nil;
	}

	return channel;
}

@end
