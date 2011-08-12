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

@class PXSoundChannel;
@class PXSoundTransform;
@protocol PXSoundModifier;

#define PX_SOUND_INFINITE_LOOPS -1

@interface PXSound : NSObject
{
@protected
	unsigned length;
}

/**
 * The length, in milliseconds, of the sound.
 */
@property (nonatomic, readonly) unsigned length;
/**
 * If the sound is mono and of file type "wav" or "caf" then it is considered
 * to be 3D ready.
 *
 * `YES` if the conditions for being 3D are met, `NO`
 * otherwise.
 *
 * **Example:**
 *	PXSound *mp3Sound = [PXSound soundWithContentsOfFile:@"sound.mp3"];
 *	[mp3Sound is3DReady];
 *	// Will return NO.
 *	PXSound *wavSound = [PXSound soundWithContentsOfFile:@"sound.wav"];
 *	[wavSound is3DReady];
 *	// Will return YES if the wav sound was mono.
 */
@property (nonatomic, readonly) BOOL is3DReady;

//-- ScriptIgnore
- (id) initWithData:(NSData *)data;
//-- ScriptName: Sound
//-- ScriptArg[0]: required
//-- ScriptArg[1]: nil
- (id) initWithData:(NSData *)data modifier:(id<PXSoundModifier>)modifier;

//-- ScriptIgnore
- (PXSoundChannel *)play;
//-- ScriptName: play
//-- ScriptArg[0]: 0
//-- ScriptArg[1]: 0
//-- ScriptArg[2]: nil
- (PXSoundChannel *)playWithStartTime:(unsigned)startTime
							loopCount:(int)loopCount
					   soundTransform:(PXSoundTransform *)soundTransform;

//-- ScriptIgnore
+ (PXSound *)soundWithContentsOfFile:(NSString *)filePath;
//-- ScriptName: makeWithContentsOfFile
//-- ScriptArg[0]: required
//-- ScriptArg[1]: nil
+ (PXSound *)soundWithContentsOfFile:(NSString *)filePath modifier:(id<PXSoundModifier>)modifier;
//-- ScriptIgnore
+ (PXSound *)soundWithContentsOfURL:(NSURL *)url;
//-- ScriptName: makeWithContentsOfURL
//-- ScriptArg[0]: required
//-- ScriptArg[1]: nil
+ (PXSound *)soundWithContentsOfURL:(NSURL *)url modifier:(id<PXSoundModifier>)modifier;
//-- ScriptIgnore
+ (PXSound *)soundWithData:(NSData *)data;
//-- ScriptName: makeWithData
//-- ScriptArg[0]: required
//-- ScriptArg[1]: nil
+ (PXSound *)soundWithData:(NSData *)data modifier:(id<PXSoundModifier>)modifier;

@end

@interface PXSound (PrivateButPublic)
- (id) _initWithLength:(unsigned)length;
@end
