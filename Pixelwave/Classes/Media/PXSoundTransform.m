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

#import "PXSoundTransform.h"

/**
 * A PXSoundTransform object represents the volume and pitch of a
 * #PXSoundChannel.
 *
 * The following code creates a sound transform with 120% volume and 80%
 * pitch:
 *	PXSoundTransform *transform = [[PXSoundTransform alloc] initWithVolume:1.2f pitch:0.8f];
 *	// Volume will be 120% and pitch will be 80%
 */
@implementation PXSoundTransform

@synthesize volume;
@synthesize pitch;

- (id) init
{
	return [self initWithVolume:1.0f pitch:1.0f];
}

/**
 * Creates a new sound transform with the given #volume and
 * #pitch.
 *
 * @param volume The amplitude of the sound.
 * @param pitch The frequency of the sound.
 *
 * **Example:**
 *	PXSoundTransform *transform = [[PXSoundTransform alloc] initWithVolume:1.2f pitch:0.8f];
 *	// Volume will be 120% and pitch will be 80%
 */
- (id) initWithVolume:(float)_volume pitch:(float)_pitch
{
	self = [super init];

	if (self)
	{
		volume = _volume;
		pitch  = _pitch;
	}

	return self;
}

#pragma mark NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	PXSoundTransform *copy = [[[self class] allocWithZone:zone] initWithVolume:volume pitch:pitch];

	return copy;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(volume=%f, pitch=%f)", volume, pitch];
}

#pragma mark Pooled Reset

- (void) reset
{
	volume = 1.0f;
	pitch  = 1.0f;
}

#pragma mark -
#pragma mark Static Methods

/**
 * Creates a sound transform with the given #volume and #pitch.
 *
 * @param volume The amplitude of the sound.
 * @param pitch The frequency of the sound.
 *
 * @return The created sound transform.
 *
 * **Example:**
 *	PXSoundTransform *transform = [PXSoundTransform soundTransformWithVolume:1.2f pitch:0.8f];
 *	// Volume will be 120% and pitch will be 80%
 */
+ (PXSoundTransform *)soundTransformWithVolume:(float)volume pitch:(float)pitch
{
	return [[[PXSoundTransform alloc] initWithVolume:volume pitch:pitch] autorelease];
}

@end
