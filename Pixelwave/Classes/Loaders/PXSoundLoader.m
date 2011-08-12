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

#import "PXSoundLoader.h"

#import "PXSound.h"
#import "PXSoundParser.h"
#import "PXSoundModifier.h"

id<PXSoundModifier> pxSoundLoaderDefaultModifier = nil;

@interface PXSoundLoader(Private)
- (id) initWithContentsOfFile:(NSString *)path
						orURL:(NSURL *)url
					modifier:(id<PXSoundModifier>)_modifier;
@end

/**
 * A #PXSoundLoader Loads sounds synchronously and creates #PXSound objects.
 *
 * Once instantiated with a valid file path, objects of the PXSound class will
 * hold the necessary info to play the sound.
 *
 * For most uses generating more than one #PXSound object is unnecessary as a
 * single #PXSound may be shared among many #PXSoundChannels.
 *
 * Once a #PXSound instance has been created, the #PXSoundLoader instance may be
 * safely deallocated by calling `release`. Since #PXSoundLoader
 * keeps a copy of the loaded data, it is advisable to release all unneeded
 * instances as soon as a #PXSound object has been created in order to free up
 * memory.
 *
 * The following sound formats are supported natively:
 *
 * _Can be 3D (if mono)_
 *
 * - .wav
 * - .caf
 *
 * _Cannot be 3D_
 *
 * - .mp3
 * - .m4a
 * - .alac and .acc
 * - .aiff, .aif and .aifc
 *
 * **Example:**
 *	// Create a loader object to load and parse the wav from the application
 *	// bundle.
 *	PXSoundLoader *loader = [[PXSoundLoader alloc] initWithContentsOfFile:@"sound.wav"];
 *	// Turn the loaded data to an OpenAL sound
 *	PXSound *sound = [loader newSound];
 *	// The loader is no longer needed
 *	[loader release];
 *	loader = nil;
 *
 *	// Create a PXSoundChannel object to play the sound
 *	PXSoundChannel *channel = [sound playWithStartTime:0 loopCount:0 soundTransform:nil];
 *	[sound release];
 *	sound = nil;
 *
 *	// Create a loader object to load and parse the mp3 from the application
 *	// bundle.
 *	loader = [[PXSoundLoader alloc] initWithContentsOfFile:@"sound.mp3"];
 *	// Turn the loaded data to an AVAudio sound
 *	PXSound *sound = [loader newSound];
 *	// The loader is no longer needed
 *	[loader release];
 *	loader = nil;
 *
 *	// Create a PXSoundChannel object to play the sound
 *	PXSoundChannel *channel = [sound playWithStartTime:0 loopCount:0 soundTransform:nil];
 *	[sound release];
 *	sound = nil;
 */
@implementation PXSoundLoader

#pragma mark Utility init methods

/**
 * Creates a new PXSoundLoader object containing the loaded sound data.
 * Returns `nil` if the file could not be found, or the file type
 * isn't supported.
 *
 * @param filePath The path of the sound file to load. The file path may be absolute or
 * relative to	the application bundle.
 *
 * **Example:**
 *	PXSoundLoader *loader = [[PXSoundLoader alloc] initWithContentsOfFile:@"sound.wav"];
 *	// Loads the wav sound.
 */
- (id) initWithContentsOfFile:(NSString *)path
{
	return [self initWithContentsOfFile:path orURL:nil modifier:[PXSoundLoader defaultModifier]];
}
/**
 * Creates a new PXSoundLoader object containing the loaded sound data.
 * Returns `nil` if the file could not be found, or the file type
 * isn't supported.
 *
 * @param filePath The path of the sound file to load. The file path may be absolute or
 * relative to	the application bundle.
 * @param modifier If a modifier is stated, it will be used on the loaded bytes to modify
 * them.
 *
 * **Example:**
 *	PXSoundLoader *loader = [[PXSoundLoader alloc] initWithContentsOfFile:@"sound.wav" modifier:[PXSoundModifiers soundModifierToMono]];
 *	// Loads the wav sound and converts it to mono if it is not.
 */
- (id) initWithContentsOfFile:(NSString *)path modifier:(id<PXSoundModifier>)_modifier
{
	return [self initWithContentsOfFile:path orURL:nil modifier:_modifier];
}

/**
 * Creates a new PXSoundLoader object containing the loaded sound data.
 * Returns `nil` if the file could not be found, or the file type
 * isn't supported.
 *
 * @param url The url of the sound file to load.
 *
 * **Example:**
 *	NSURL *url = [NSURL URLWithString:@"www.website.com/sound.wav"];
 *	PXSoundLoader *loader = [[PXSoundLoader alloc] initWithContentsOfURL:url];
 *	// Loads the wav sound.
 */
- (id) initWithContentsOfURL:(NSURL *)url
{
	return [self initWithContentsOfFile:nil orURL:url modifier:[PXSoundLoader defaultModifier]];
}
/**
 * Creates a new PXSoundLoader object containing the loaded sound data.
 * Returns `nil` if the file could not be found, or the file type
 * isn't supported.
 *
 * @param url The url of the sound file to load.
 * @param modifier If a modifier is stated, it will be used on the loaded bytes to modify
 * them.
 *
 * **Example:**
 *	NSURL *url = [NSURL URLWithString:@"www.website.com/sound.wav"];
 *	PXSoundLoader *loader = [[PXSoundLoader alloc] initWithContentsOfURL:url modifier:[PXSoundModifiers soundModifierToMono]];
 *	// Loads the wav sound and converts it to mono if it is not.
 */
- (id) initWithContentsOfURL:(NSURL *)url modifier:(id<PXSoundModifier>)_modifier
{
	return [self initWithContentsOfFile:nil orURL:url modifier:_modifier];
}

#pragma mark Designated Initializer

- (id) initWithContentsOfFile:(NSString *)path
						orURL:(NSURL *)url
					modifier:(id<PXSoundModifier>)modifier
{
	self = [super _initWithContentsOfFile:path orURL:url];

	if (self)
	{
		if (![self _load])
		{
			[self release];
			return nil;
		}

		// Make the new parser
		soundParser = [[PXSoundParser alloc] initWithData:data
												 modifier:modifier
												   origin:origin];

		if (!soundParser)
		{
			[self release];
			return nil;
		}
	}

	return self;
}

- (void) dealloc
{
	[soundParser release];
	soundParser = nil;

	self.modifier = nil;

	[super dealloc];
}

- (void) setModifier:(id<PXSoundModifier>)modifier
{
	soundParser.modifier = modifier;
}

- (id<PXSoundModifier>) modifier
{
	return soundParser.modifier;
}

/**
 * Creates a new PXSound object containing all information needed to play the
 * sound.
 *
 * @return The new PXSound object.
 */
- (PXSound *)newSound
{
	return [soundParser newSound];
}

+ (void) setDefaultModifier:(id<PXSoundModifier>)modifier
{
	id<PXSoundModifier> temp = [modifier retain];
	[pxSoundLoaderDefaultModifier release];
	pxSoundLoaderDefaultModifier = temp;
}
+ (id<PXSoundModifier>) defaultModifier
{
	return pxSoundLoaderDefaultModifier;
}

#pragma mark Utility Methods
#pragma mark -

/////////////
// Utility //
/////////////

/**
 * Creates a PXSoundLoader object containing the loaded sound data. Returns
 * `nil` if the file could not be found, or the file type isn't
 * supported.
 *
 * @param filePath The path of the sound file to load. The file path may be absolute or
 * relative to	the application bundle.
 *
 * @return The resulting, `autoreleased`, #PXSoundLoader object.
 *
 * **Example:**
 *	PXSoundLoader *loader = [PXSoundLoader soundLoaderWithContentsOfFile:@"sound.wav"];
 *	// Loads the wav sound.
 */
+ (PXSoundLoader *)soundLoaderWithContentsOfFile:(NSString *)path
{
	return [[[PXSoundLoader alloc] initWithContentsOfFile:path] autorelease];
}
/**
 * Creates a PXSoundLoader object containing the loaded sound data. Returns
 * `nil` if the file could not be found, or the file type isn't
 * supported.
 *
 * @param filePath The path of the sound file to load. The file path may be absolute or
 * relative to	the application bundle.
 * @param modifier If a modifier is stated, it will be used on the loaded bytes to modify
 * them.
 *
 * @return The resulting, `autoreleased`, #PXSoundLoader object.
 *
 * **Example:**
 *	PXSoundLoader *loader = [PXSoundLoader soundLoaderWithContentsOfFile:@"sound.wav" modifier:[PXSoundModifiers soundModifierToMono]];
 *	// Loads the wav sound and converts it to mono if it is not.
 */
+ (PXSoundLoader *)soundLoaderWithContentsOfFile:(NSString *)path modifier:(id<PXSoundModifier>)modifier
{
	return [[[PXSoundLoader alloc] initWithContentsOfFile:path modifier:modifier] autorelease];
}
/**
 * Creates a PXSoundLoader object containing the loaded sound data. Returns
 * `nil` if the file could not be found, or the file type isn't
 * supported.
 *
 * @param url The url of the sound file to load.
 *
 * @return The resulting, `autoreleased`, #PXSoundLoader object.
 *
 * **Example:**
 *	NSURL *url = [NSURL URLWithString:@"www.website.com/sound.wav"];
 *	PXSoundLoader *loader = [PXSoundLoader soundLoaderWithContentsOfURL:url];
 *	// Loads the wav sound.
 */
+ (PXSoundLoader *)soundLoaderWithContentsOfURL:(NSURL *)url
{
	return [[[PXSoundLoader alloc] initWithContentsOfURL:url] autorelease];
}
/**
 * Creates a PXSoundLoader object containing the loaded sound data. Returns
 * `nil` if the file could not be found, or the file type isn't
 * supported.
 *
 * @param url The url of the sound file to load.
 * @param modifier If a modifier is stated, it will be used on the loaded bytes to modify
 * them.
 *
 * @return The resulting, `autoreleased`, #PXSoundLoader object.
 *
 * **Example:**
 *	NSURL *url = [NSURL URLWithString:@"www.website.com/sound.wav"];
 *	PXSoundLoader *loader = [PXSoundLoader soundLoaderWithContentsOfURL:url modifier:[PXSoundModifiers soundModifierToMono]];
 *	// Loads the wav sound and converts it to mono if it is not.
 */
+ (PXSoundLoader *)soundLoaderWithContentsOfURL:(NSURL *)url modifier:(id<PXSoundModifier>)modifier
{
	return [[[PXSoundLoader alloc] initWithContentsOfURL:url modifier:modifier] autorelease];
}

@end
