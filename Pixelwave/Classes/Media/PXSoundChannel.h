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

#import "PXEventDispatcher.h"

@class PXSound;
@class PXSoundTransform;

typedef enum
{
	_PXSoundChannelState_Stopped = 0,
	_PXSoundChannelState_Paused,
	_PXSoundChannelState_Playing,
	_PXSoundChannelState_Rewinded
} _PXSoundChannelState;

@interface PXSoundChannel : PXEventDispatcher
{
@protected
	PXSoundTransform *soundTransform;

	int loopCount;
	unsigned startTime;

	_PXSoundChannelState soundState;
}

/**
 * The transform of the sound.
 */
@property (nonatomic, copy) PXSoundTransform *soundTransform;
/**
 * The current point in milliseconds of the playing sound.
 */
@property (nonatomic, readonly) unsigned position;
/**
 * `YES` if the sound is playing, otherwise `NO`.
 */
@property (nonatomic, readonly) BOOL isPlaying;

//-- ScriptName: play
- (BOOL) play;
//-- ScriptName: pause
- (void) pause;
//-- ScriptName: stop
- (void) stop;
//-- ScriptName: rewind
- (void) rewind;
@end

@interface PXSoundChannel(PrivateButPublic)
- (id) _initWithStartTime:(unsigned)startTime
				loopCount:(int)loops
		   soundTransform:(PXSoundTransform *)soundTransform;
- (void) _update;
- (BOOL) _done;
@end

@interface PXSoundChannel(Protected)
- (BOOL) _play;
- (void) _pause;
- (void) _stop;
- (void) _rewind;
@end
