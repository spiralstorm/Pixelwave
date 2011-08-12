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

#import "PXAVSoundParser.h"

#import <AVFoundation/AVFoundation.h>

#import "PXSoundEngine.h"
#import "PXAVSound.h"

#import "PXDebug.h"

@interface PXAVSoundParser(Private)
+ (AVAudioPlayer *)validateAndReleasePlayer:(AVAudioPlayer *)player
							withSavedPlayer:(AVAudioPlayer *)savedPlayer;
@end

@implementation PXAVSoundParser

- (BOOL) isModifiable
{
	return NO;
}

+ (BOOL) isApplicableForData:(NSData *)data origin:(NSString *)origin
{
	return YES;
}
+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	// Compressed:
	[extensions addObject:@"mp3"];
	[extensions addObject:@"m4a"];
	[extensions addObject:@"alac"];
	[extensions addObject:@"aifc"];
	[extensions addObject:@"acc"];
	
	// Uncompressed:
	[extensions addObject:@"caf"];
	
	[extensions addObject:@"aif"];
	[extensions addObject:@"aiff"];
	
	[extensions addObject:@"wav"];
}

- (BOOL) _parse
{
	return (data ? YES : NO);
}

- (PXSound *)newSound
{
	unsigned length = 0;

	AVAudioPlayer *player = [PXAVSoundParser newPlayerFromData:data];
	length = player.duration * 1000.0f;
	[player release];

	PXAVSound *sound = [[PXAVSound alloc] initWithLength:length data:data];

	return sound;
}

+ (AVAudioPlayer *)newPlayerFromData:(NSData *)_data
{
	if (!_data)
	{
		return nil;
	}

	PXSoundEngineInit();

	NSError *error;
	// Holding onto an extra retain (retain = 2), please see the comment block
	// in the 'else' for more info.  As a side note, this will never break, even
	// if the issue gets fixed.
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:_data error:&error];
	AVAudioPlayer *savedPlayer = [player retain];

	if (savedPlayer)
	{
		// Saved player and player are the same variable. I am retaining then
		// releasing to get rid of warnings, this is actually unnecessary. You
		// may notice a double release on player though, that is because of the
		// extra retain mentioned earlier.
		[savedPlayer retain];
		[player release];
		player = savedPlayer;
		// Bring the retain count back to 1.
		[savedPlayer release];
	}
	else
	{
		PXDebugLog(@"PXAVSoundParser:newPlayerFromData error:%@", error);

		// This loops through and releases all the retains on the player.  This
		// is done because as of October, 2010 AVAudioPlayer had a memory leak
		// with allocations.  This corrects it, and if they fix that memory
		// leak, this will still work leak free.
		unsigned short index;
		unsigned short playerCount = [player retainCount];
		for (index = 0; index < playerCount; ++index)
			[player release];
		player = nil;
	}

	if (error)
	{
		PXDebugLog(@"PXAVSoundParser:newPlayerFromData .... error:%@", error);
		[player release];
		player = nil;
	}

	// Calling this can have the player end early without a delegate, which we
	// can't have yet.
	//[player prepareToPlay];
	// TODO Later: When we make an av sound channel that does not auto-play, we
	// need to set the delegate, then call prepareToPlay.  See above for more
	// details.

	return player;
}

@end
