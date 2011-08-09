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

#import "PXAVSoundChannel.h"

#import "PXSoundEngine.h"
#import "PXDebug.h"
#import "PXEvent.h"

#import "PXSound.h"
#import "PXSoundTransform.h"
#import "PXSoundTransform3D.h"
#import "PXAVSoundParser.h"

@interface PXAVSoundChannel (Private)
- (void) _setDone:(BOOL)done;
@end

@implementation PXAVSoundChannel

- (id) _initWithData:(NSData *)data
		   startTime:(unsigned)_startTime
		   loopCount:(int)_loops
	  soundTransform:(PXSoundTransform *)_soundTransform
{
	self = [super _initWithStartTime:_startTime loopCount:_loops soundTransform:_soundTransform];

	if (self)
	{
		player = [PXAVSoundParser newPlayerFromData:data];

		isDone = NO;
		player.delegate = self;

		// Convert from seconds to milliseconds
		player.currentTime = (float)startTime * 0.001f;
		player.numberOfLoops = loopCount;
		engineVolume = PXSoundEngineGetSoundTransform().volume;

		self.soundTransform = _soundTransform;

	}

	return self;
}

- (void) dealloc
{
	player.delegate = nil;
	[player release];
	player = nil;

	[super dealloc];
}

- (void) _update
{
	[player updateMeters];
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

		player.delegate = nil;
		[player release];
		player = nil;
	}
}
- (BOOL) _done
{
	return isDone;
}

- (void) setSoundTransform:(PXSoundTransform *)_soundTransform
{
	if (!_soundTransform)
	{
		return;
	}

	if ([_soundTransform isKindOfClass:[PXSoundTransform3D class]])
	{
		PXDebugLog(@"PXSoundChannel warning: 3D playback is not supported for compressed audio (such as mp3)");
	}

	soundTransform.pitch  = _soundTransform.pitch;
	soundTransform.volume = _soundTransform.volume;

	player.volume = _soundTransform.volume * engineVolume;
}

- (PXSoundTransform *)soundTransform
{
	PXSoundTransform *transform = [[PXSoundTransform alloc] init];

	transform.volume = soundTransform.volume;
	transform.pitch  = soundTransform.pitch;

	return [transform autorelease];
}

- (BOOL) _play
{
	if (player.currentTime < 0.0f)
		player.currentTime = 0.0f;

	return [player play];
}

- (void) _pause
{
	[player pause];
}

- (void) _stop
{
	player.numberOfLoops = 0;
	player.currentTime = player.duration;
	[player stop];
}

- (void) _rewind
{
	[player pause];
	player.currentTime = (float)startTime * 0.001f;
}

- (unsigned) position
{
	return floorf(player.currentTime * 0.001f);
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)_player successfully:(BOOL)flag
{
	if (player != _player)
	{
		PXDebugLog (@"PXAVSoundChannel:audioPlayerDidFinishPlaying - wrong player.");

		return;
	}

	if (!flag)
	{
		PXDebugLog(@"audioPlayer(%@) finished playing %@ due to an error\n", _player);
	}

	[self _setDone:YES];
}

- (void) audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)_player error:(NSError *)error
{
	if (player == _player)
	{
		PXDebugLog(@"audioPlayer(%@) had a decode error(%@)\n", _player, error);
		[self _setDone:YES];
	}
	else
	{
		PXDebugLog (@"PXAVSoundChannel:audioPlayerDecodeErrorDidOccur - wrong player.");
	}
}

- (void) audioPlayerBeginInterruption:(AVAudioPlayer *)_player
{
	priorToInteruptionState = soundState;

	switch (soundState)
	{
		case _PXSoundChannelState_Stopped:
			return;
		case _PXSoundChannelState_Paused:
			return;
		case _PXSoundChannelState_Rewinded:
			return;
		case _PXSoundChannelState_Playing:
			[self pause];
			break;
	}
}

- (void) audioPlayerEndInterruption:(AVAudioPlayer *)_player withFlags:(NSUInteger)flags
{
	switch (priorToInteruptionState)
	{
		case _PXSoundChannelState_Stopped:
			return;
		case _PXSoundChannelState_Paused:
			return;
		case _PXSoundChannelState_Rewinded:
			return;
		case _PXSoundChannelState_Playing:
			[self play];
			break;
	}

	priorToInteruptionState = _PXSoundChannelState_Stopped;
}

- (void) audioPlayerEndInterruption:(AVAudioPlayer *)_player
{
	[self audioPlayerEndInterruption:_player withFlags:0];
}

- (void) _setEngineVolume:(float)volume
{
	engineVolume = volume;

	self.soundTransform = soundTransform;
}

@end
