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

#import "PXSoundParser.h"

#import "PXDebug.h"

#import "PXSound.h"

#import "PXSoundModifier.h"

/**
 * A PXSoundParser takes the given data, and parses it into information needed
 * to play the sound.
 *
 * **Example:**
 *	NSData *data = [[NSData alloc] initWithContentsOfFile:@"sound.wav"];
 *	PXSoundParser *soundParser = [[PXSoundParser alloc] initWithData:data];
 *	PXSound *sound = [soundParser newSound];
 *
 *	// Play the sound
 *	[sound play];
 *
 *	[sound release];
 *	[soundParser release];
 *	[data release];
 */
@implementation PXSoundParser

@synthesize modifier;

- (id) init
{
	PXDebugLog (@"SoundParser must be instantiated with data, modifier, and origin");
	[self release];
	return nil;
}

/**
 * Makes a new sound parser given data, and parses it into information needed
 * to play the sound. This version also stores the origin, in case you
 * need/want it.
 *
 * @param data The loaded data.
 * @param modifier A modifier is used to modify the loaded bytes, a backup is kept so can
 * set the property to `nil` after getting a new sound, and
 * still have your previously loaded data.
 * @param origin The origin of the font.
 *
 * **Example:**
 *	NSData *data = [[NSData alloc] initWithContentsOfFile:@"sound.wav"];
 *	PXSoundParser *soundParser = [[PXSoundParser alloc] initWithData:data
 *	                                                        modifier:[PXSoundModifiers soundModifierToMono]
 *	                                                          origin:@"sound.wav"];
 *	// Now generates a mono version of the sound (assuming the sound was
 *	// modifiable).
 *	PXSound *sound = [soundParser newSound];
 *
 *	// Play the sound
 *	[sound play];
 *
 *	[sound release];
 *	[soundParser release];
 *	[data release];
 */
- (id) initWithData:(NSData *)_data
		   modifier:(id<PXSoundModifier>)_modifier
			 origin:(NSString *)_origin
{
	self = [super init];

	if (self)
	{
		// Find the real class needed
		Class realClass = [PXParser parserForData:_data
											 origin:_origin
										  baseClass:[PXSoundParser class]];

		// If the real parser doesn't exist, give up - there is nothing else we
		// can do.
		if (!realClass)
		{
			[self release];
			return nil;
		}

		// Make a new instance of the parser
		PXSoundParser *newParser = [[realClass alloc] _initWithData:_data
														   modifier:_modifier
															 origin:_origin];

		// Release ourself, as we are going to transform into the new parser.
		[self release];

		// Become the real parser, and allocate any data we need
		self = newParser;
	//	if ()
	//	{
	//	}
	}

	return self;
}

- (id) _initWithData:(NSData *)_data
			modifier:(id<PXSoundModifier>)_modifier
			  origin:(NSString *)_origin
{
	// Set the data and origin
	self = [super _initWithData:_data origin:_origin];

	if (self)
	{
		// Make the sound info (it's bytes and other)
		soundInfo = PXParsedSoundDataCreate(0);
		modifiedSoundInfo = NULL;

		// Parse the data. If we fail at parsing, give up - there is nothing
		// else we can do.
		if (!soundInfo || ![self _parse])
		{
			[self release];
			return nil;
		}

		// Set the modifier to the given one.
		self.modifier = _modifier;
	}

	return self;
}

- (void) dealloc
{
	// Free the normal and modified info. If either are nil, this won't do
	// anything.
	PXParsedSoundDataFree(soundInfo);
	soundInfo = NULL;
	PXParsedSoundDataFree(modifiedSoundInfo);
	modifiedSoundInfo = NULL;

	// Free the modifier
	self.modifier = nil;

	[super dealloc];
}

- (void) setModifier:(id <PXSoundModifier>)_modifier
{
	[_modifier retain];

	// See if we are modifiable.
	BOOL isModifiable = self.isModifiable;

	// Free the previous info.
	PXParsedSoundDataFree(modifiedSoundInfo);
	modifiedSoundInfo = NULL;
	[modifier release];
	modifier = nil;

	// If we can be modified and we hvae a legal modifier, lets use it!
	if (isModifiable && _modifier)
	{
		modifier = [_modifier retain];
		modifiedSoundInfo = [modifier newModifiedSoundDataFromData:soundInfo];
	}

	// Free the extra retain.
	[_modifier release];
}

- (BOOL) isModifiable
{
	// The base class is not modifiable
	return NO;
}

/**
 * Creates a new PXSound object containing all information needed to play the
 * sound.
 *
 * @return The new PXSound object.
 */
- (PXSound *)newSound
{
	// The base class can't make a new sound
	return nil;
}

- (BOOL) _parse
{
	// The base class can't parse
	return NO;
}

@end
