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

#import "PXSoundMixer.h"

#import "PXSoundTransform.h"
#import "PXSoundListener.h"

#include "PXSoundEngine.h"

/**
 * The PXSoundMixer contains a series of static methods to manipulate how
 * sounds are played and listened to.
 *
 * @see PXSoundTransform, PXSoundListener
 */
@implementation PXSoundMixer

/**
 * Initializes the sound engine so that when you go to play a sound there is
 * not the initial delay of setting up the engine. This is suggested to do at
 * the start of your program if you are in need of playing sounds immediately
 * within the duration of your app.
 */
+ (void) warmUp
{
	PXSoundEngineInit();
	PXSoundEngineInitAL();
}

/**
 * Changes the pitch and volume of every sound.
 *
 * @param soundTransform The sound transform to set.
 *
 * **Example:**
 *	PXSoundTransform *soundTransform = [[PXSoundTransform alloc] initWithVolume:0.5f pitch:2.0f];
 *	[PXSoundMixer setSoundTransform:soundTransform];
 *	// All sounds will now be at 50% volume from what they were, meaning if a
 *	// sound was at 30% volume, it is now at 15%, likewise the pitch is at 200%,
 *	// meaning if the pitch of a sound was at 50%, it is now at 100%.
 *	[soundTransform release];
 */
+ (void) setSoundTransform:(PXSoundTransform *)soundTransform
{
	PXSoundEngineSetSoundTransform(soundTransform);
}
/**
 * Returns the global sound transform.
 *
 * @return The global sound transform.
 *
 * **Example:**
 *	PXSoundTransform *globalSoundTransform = [PXSoundMixer soundTransform];
 *	// globalSoundTransform by default will have 1.0f for volume, and 1.0f for
 *	// pitch.
 */
+ (PXSoundTransform *)soundTransform
{
	return [[PXSoundEngineGetSoundTransform() copy] autorelease];
}

/**
 * Returns the global sound listener.
 *
 * @return The global sound listener.
 *
 * **Example:**
 *	PXSoundListener *globalSoundListener = [PXSoundMixer soundListener];
 */
+ (PXSoundListener *)soundListener
{
	return PXSoundEngineGetSoundListener();
}

/**
 * Sets the speed of sound, this is useful for the doppler effect.
 *
 * @param speedOfSound The speed of sound.
 *
 * **Example:**
 *	[PXSoundMixer setSpeedOfSound:64.0f];
 *	// Sets the speed of sound to 64.0 points/second.
 */
+ (void) setSpeedOfSound:(float)speedOfSound
{
	PXSoundEngineSetSpeedOfSound(speedOfSound);
}
/**
 * Returns the speed of sound.
 *
 * @return The speed of sound.
 *
 * **Example:**
 *	float speedOfSound = [PXSoundMixer speedOfSound];
 *
 * **Default:** 340.29f
 */
+ (float) speedOfSound
{
	return PXSoundEngineGetSpeedOfSound();
}

/**
 * Sets the distance model for the sound. This means that the further the
 * sound gets from the listener, how it the volume will change. The two
 * options available are either `PXSoundMixerDistanceModel_Linear`
 * or `PXSoundMixerDistanceModel_Logarithmic`.
 *
 * @param distanceModel The distance model.
 *
 * **Example:**
 *	[PXSoundMixer setDistanceModel:PXSoundMixerDistanceModel_Logarithmic];
 *
 * @see PXSoundListener
 *
 * **Default:** `PXSoundMixerDistanceModel_Logarithmic`
 */
+ (void) setDistanceModel:(PXSoundMixerDistanceModel)distanceModel
{
	PXSoundEngineSetDistanceModel(distanceModel);
}

/**
 * Returns the current distance model, the two options are
 * `PXSoundMixerDistanceModel_Linear` or
 * `PXSoundMixerDistanceModel_Logarithmic`.  The default value is
 * `PXSoundMixerDistanceModel_Logarithmic`.
 *
 * The distance model is how the volume of a sound changes depending on how far
 * it is from the `PXSoundListener`.
 *
 * @return The distance model.
 *
 * **Example:**
 *	PXSoundMixerDistanceModel distanceModel = [PXSoundMixer distanceModel];
 */
+ (PXSoundMixerDistanceModel) distanceModel
{
	return PXSoundEngineGetDistanceModel();
}

/**
 * Plays all sound channels.
 */
+ (void) playAll
{
	PXSoundEnginePlayAll();
}
/**
 * Pauses all sound channels.
 */
+ (void) pauseAll
{
	PXSoundEnginePauseAll();
}
/**
 * Stops all sound channels.
 */
+ (void) stopAll
{
	PXSoundEngineStopAll();
}
/**
 * Rewinds all sound channels.
 */
+ (void) rewindAll
{
	PXSoundEngineRewindAll();
}

@end
