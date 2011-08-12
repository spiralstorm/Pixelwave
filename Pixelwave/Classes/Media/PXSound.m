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

#import "PXSound.h"

#include "PXSoundEngine.h"

#include "PXPrivateUtils.h"
#include "PXExceptionUtils.h"

#import "PXSoundChannel.h"
#import "PXSoundTransform.h"
#import "PXSoundLoader.h"

#include "PXSoundModifier.h"
#import "PXSoundParser.h"

/**
 * Represents a loaded sound.  Sounds should never be
 * initialized manually, but through a #PXSoundLoader or this class's utility creation methods.
 *
 * @see [PXSoundLoader newSound]
 */
@implementation PXSound

@synthesize length;

- (id) init
{
	//return [self _initWithLength:0];
	PXThrow(PXException, @"Sound objects should not be initialized directly. Use SoundLoader instead");
	
	[self release];
	return nil;
}

- (id) _initWithLength:(unsigned)_length
{
	self = [super init];

	if (self)
	{
		length = _length;
	}

	return self;
}

/**
 * Creates a sound using the data given. The data is parsed into a usable
 * format.
 *
 * @param data The raw data.
 *
 * @return The parsed sound.
 *
 * **Example:**
 *	NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sound.wav" ofType:nil]];
 *	PXSound *sound = [[PXSound alloc] initWithData:data];
 *	PXSoundChannel *channel = [sound play];
 *	// The sound will begin playing, and channel will be your reference.
 */
- (id) initWithData:(NSData *)data
{
	return [self initWithData:data modifier:nil];
}

/**
 * Creates a sound using the data given. The data is parsed into a usable
 * format.
 *
 * @param data The raw data.
 * @param modifier The modifier is used to modify the loaded bytes; once set, it can not be
 * un-done. The modifier will be ignored if the data is not modifiable.
 *
 * @return The parsed sound.
 *
 * **Example:**
 *	NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sound.wav" ofType:nil]];
 *	PXSound *sound = [[PXSound alloc] initWithData:data modifier:[PXSoundModifiers soundModifierToMono]];
 *	PXSoundChannel *channel = [sound play];
 *	// The sound will be converted to mono, then begin playing, and channel will
 *	// be your reference.
 *
 * @see PXSoundParser
 */
- (id) initWithData:(NSData *)data modifier:(id<PXSoundModifier>)modifier
{
	self = [super init];

	if (self)
	{
		PXSoundParser *soundParser = [[PXSoundParser alloc] initWithData:data
																modifier:modifier];
		PXSound *newSound = [soundParser newSound];

		[soundParser release];

		[self release];

		self = newSound;

		// If initialization code is needed, do a check if self exists prior to
		// doing any code.
	}

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(length=%u, is3DReady=%@)",
			length,
			PX_BOOL_TO_STRING(self.is3DReady)];
}

#pragma mark -
#pragma mark Properties

- (BOOL) is3DReady
{
	return NO;
}

#pragma mark -
#pragma mark Methods

/**
 * Plays a sound from the start, doesn't loop and has a volume and pitch of
 * 1.0f.
 *
 * @return The reference to the sound channel that will be playing.
 *
 * **Example:**
 *	PXSound *sound = [PXSound soundWithContentsOfFile:@"sound.wav"];
 *	PXSoundChannel *channel = [sound play];
 *	// The sound will begin playing, and channel will be your reference.
 */
- (PXSoundChannel *)play
{
	return [self playWithStartTime:0 loopCount:0 soundTransform:nil];
}

/**
 * Plays a sound from the start, doesn't loop and has a volume and pitch of
 * 1.0f.
 *
 * @param startTime The time in milliseconds for the sound to begin. Each loop will also
 * begin at this time. You should not set a start time for larger then the
 * length of the sound.
 * @param loopCount The quantity of times you wish the sound to loop.  If 0 is stated, the
 * sound only plays once. If 10 is stated, the sound plays 11 times. If
 * `PX_SOUND_INFINITE_LOOPS` is stated, then the sound plays for
 * infinate times.
 * @param soundTransform The the transform for the sound.
 *
 * @return The reference to the sound channel that will be playing.
 *
 * **Example:**
 *	PXSoundLoader *soundLoader = [[PXSoundLoader alloc] initWithContentsOfFile:@"sound.wav"];
 *	PXSound *sound = [soundLoader newSound];
 *
 *	PXSoundTransform3D *soundTransform3D = [[PXSoundTransform3D alloc] initWithVolume:1.2f pitch:0.8f];
 *	soundTransform3D.x = 40.0f;
 *	soundTransform3D.y = 15.0f;
 *	// The sound can only be 3D if it is mono and the correct file type.  To
 *	// check for this, you can use the is3DReady method.
 *
 *	PXSoundChannel *channel = [sound playWithStartTime:4500 loopCount:PX_SOUND_INFINITE_LOOPS soundTransform:soundTransform3D];
 *	// The sound will begin at, and loop from, 4.5 seconds for an indefinite
 *	// quantity of time.  It's volume will be 120% and pitch 80% at position
 *	// [40.0f,15.0f,0.0f] with velocity [0.0f,0.0f,0.0f].
 *
 *	// Release the memory
 *	[soundTransform3D release];
 *	[soundLoader release];
 *	[sound release];
 *
 * @see PXSoundTransform, [PXSound is3DReady]
 */
- (PXSoundChannel *)playWithStartTime:(unsigned)startTime
							loopCount:(int)loopCount
					   soundTransform:(PXSoundTransform *)soundTransform
{
	PXSoundEngineInit();

	return nil;
}

#pragma mark -
#pragma mark Static Methods

/**
 * Creates a sound by loading the file at the given path.
 *
 * @param filePath The path of the file.
 *
 * @return The loaded and parsed sound, if the sound fails loading then
 * `nil` is returned instead.
 *
 * **Example:**
 *	PXSound *sound = [PXSound soundWithContentsOfFile:@"sound.wav"];
 *	// Sound is loaded and ready to go.
 */
+ (PXSound *)soundWithContentsOfFile:(NSString *)path
{
	return [PXSound soundWithContentsOfFile:path modifier:nil];
}

/**
 * Creates a sound by loading the file at the given path.
 *
 * @param filePath The path of the file.
 * @param modifier The modifier is used to modify the loaded bytes; once set, it can not be
 * un-done. The modifier will be ignored if the data is not modifiable.
 *
 * @return The loaded and parsed sound, if the sound fails loading then
 * `nil` is returned instead.
 *
 * **Example:**
 *	PXSound *sound = [PXSound soundWithContentsOfFile:@"sound.wav" modifier:[PXSoundModifiers soundModifierToMono]];
 *	// Sound is loaded, converted to mono, and ready to go.
 */
+ (PXSound *)soundWithContentsOfFile:(NSString *)path modifier:(id<PXSoundModifier>)modifier
{
	PXSoundLoader *soundLoader = [[PXSoundLoader alloc] initWithContentsOfFile:path modifier:modifier];
	PXSound *sound = [soundLoader newSound];
	[soundLoader release];

	return [sound autorelease];
}

/**
 * Creates a sound by loading the file at the given url.
 *
 * @param url The url of the file.
 *
 * @return The loaded and parsed sound, if the sound fails loading then
 * `nil` is returned instead.
 *
 * **Example:**
 *	PXSound *sound = [PXSound soundWithContentsOfURL:@"www.mywebsite.com/sound.wav"];
 *	// Sound is loaded and ready to go.
 */
+ (PXSound *)soundWithContentsOfURL:(NSURL *)url
{
	return [PXSound soundWithContentsOfURL:url modifier:nil];
}

/**
 * Creates a sound by loading the file at the given url.
 *
 * @param url The url of the file.
 * @param modifier The modifier is used to modify the loaded bytes; once set, it can not be
 * un-done. The modifier will be ignored if the data is not modifiable.
 *
 * @return The loaded and parsed sound, if the sound fails loading then
 * `nil` is returned instead.
 *
 * **Example:**
 *	PXSound *sound = [PXSound soundWithContentsOfURL:@"www.mywebsite.com/sound.wav" modifier:[PXSoundModifiers soundModifierToMono]];
 *	// Sound is loaded, converted to mono, and ready to go.
 */
+ (PXSound *)soundWithContentsOfURL:(NSURL *)url modifier:(id<PXSoundModifier>)modifier
{
	PXSoundLoader *soundLoader = [[PXSoundLoader alloc] initWithContentsOfURL:url modifier:modifier];
	PXSound *sound = [soundLoader newSound];
	[soundLoader release];

	return [sound autorelease];
}

/**
 * Creates a sound by parsing the data.
 *
 * @param data The raw data.
 *
 * @return The loaded and parsed sound, if the sound fails loading then
 * `nil` is returned instead.
 *
 * **Example:**
 *	NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sound.wav" ofType:nil]];
 *	PXSound *sound = [PXSound soundWithData:data];
 *	// Sound is parsed, converted to mono, and ready to go.
 */
+ (PXSound *)soundWithData:(NSData *)data
{
	return [[[PXSound alloc] initWithData:data] autorelease];
}
/**
 * Creates a sound by parsing the data.
 *
 * @param data The raw data.
 * @param modifier The modifier is used to modify the loaded bytes; once set, it can not be
 * un-done. The modifier will be ignored if the data is not modifiable.
 *
 * @return The loaded and parsed sound, if the sound fails loading then
 * `nil` is returned instead.
 *
 * **Example:**
 *	NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sound.wav" ofType:nil]];
 *	PXSound *sound = [PXSound soundWithData:data modifier:[PXSoundModifiers soundModifierToMono]];
 *	// Sound is parsed, converted to mono, and ready to go.
 */
+ (PXSound *)soundWithData:(NSData *)data modifier:(id<PXSoundModifier>)modifier
{
	return [[[PXSound alloc] initWithData:data modifier:modifier] autorelease];
}

@end
