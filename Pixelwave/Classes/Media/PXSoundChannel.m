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

#import "PXSoundChannel.h"

#import "PXSound.h"
#import "PXSoundTransform.h"

#import "PXSoundEngine.h"

#import "PXDebug.h"

/**
 * Represents a loaded and playing sound. Sound
 * channels should never be initialized manually, but instead created
 * via the [PXSound play] method.
 */
@implementation PXSoundChannel

- (id) init
{
	PXDebugLog(@"Can not initialize a sound channel.  Must produce one through PXSound.\n");

	[self release];
	return nil;
}

- (id) _initWithStartTime:(unsigned)_startTime
				loopCount:(int)_loops
		   soundTransform:(PXSoundTransform *)_soundTransform
{
	self = [super init];

	if (self)
	{
		loopCount = _loops;
		startTime = _startTime;

		soundState = _PXSoundChannelState_Rewinded;

		soundTransform = [[PXSoundTransform alloc] initWithVolume:1.0f pitch:1.0f];
	}

	return self;
}

- (void) dealloc
{
	[soundTransform release];

	[super dealloc];
}

#pragma mark -
#pragma mark Internal Methods

- (void) _update
{
}

- (BOOL) _done
{
	return NO;
}

#pragma mark -
#pragma mark Properties

- (void) setSoundTransform:(PXSoundTransform *)_soundTransform
{
	if (!_soundTransform)
		return;
	
	soundTransform.volume = _soundTransform.volume;
	soundTransform.pitch  = _soundTransform.pitch;
}

- (PXSoundTransform *)soundTransform
{
	return [[soundTransform copy] autorelease];
}

- (unsigned) position
{
	return 0;
}

- (BOOL) isPlaying
{
	return (soundState == _PXSoundChannelState_Playing);
}

#pragma mark -
#pragma mark Methods

/**
 * If the sound is not already playing, it plays the sound from it's current
 * position.
 *
 * **Example:**
 *	PXSound *sound = [PXSound soundWithContentsOfFile:@"sound.wav"];
 *	PXSoundChannel *channel = [sound play];
 *	// The sound is playing
 *	[channel pause];
 *	// The sound is paused
 *	[channel play];
 *	// The sound is playing
 */
- (BOOL) play
{
	if (soundState == _PXSoundChannelState_Playing)
		return YES;
	soundState = _PXSoundChannelState_Playing;

	return [self _play];
}

/**
 * If the sound is not already paused, it pauses the sound at it's current
 * position.
 *
 * **Example:**
 *	PXSound *sound = [PXSound soundWithContentsOfFile:@"sound.wav"];
 *	PXSoundChannel *channel = [sound play];
 *	// The sound is playing
 *	[channel pause];
 *	// The sound is paused
 */
- (void) pause
{
	if (soundState == _PXSoundChannelState_Paused)
		return;
	soundState = _PXSoundChannelState_Paused;

	[self _pause];
}

/**
 * If the sound is not already stopped, it stops the sound and removes it
 * permanently from the play list.
 *
 * **Example:**
 *	PXSound *sound = [PXSound soundWithContentsOfFile:@"sound.wav"];
 *	PXSoundChannel *channel = [sound play];
 *	// The sound is playing
 *	[channel stop];
 *	// The sound is stopped and wont play again
 */
- (void) stop
{
	if (soundState == _PXSoundChannelState_Stopped)
		return;
	soundState = _PXSoundChannelState_Stopped;

	[self _stop];

	PXSoundEngineRemoveSound(self);
}

/**
 * If the sound is not already rewound, it rewinds the sound moving it's
 * position back to 0 and continues playing if it were previously playing, or
 * pause if it was previously paused.  This does not reset the loops already
 * done.
 *
 * **Example:**
 *	PXSound *sound = [PXSound soundWithContentsOfFile:@"sound.wav"];
 *	PXSoundChannel *channel = [sound play];
 *	// The sound is playing
 *	[channel rewind];
 *	// The sound is rewinded and continues playing
 *	[channel pause];
 *	// The sound is paused
 *	[channel rewind];
 *	// The sound is rewinded and continues staying paused
 */
- (void) rewind
{
	_PXSoundChannelState previousState = soundState;

	if (soundState == _PXSoundChannelState_Rewinded)
		return;
	soundState = _PXSoundChannelState_Rewinded;

	[self _rewind];

	if (previousState == _PXSoundChannelState_Paused)
		[self pause];
	else if (previousState == _PXSoundChannelState_Playing)
		[self play];
}

@end
