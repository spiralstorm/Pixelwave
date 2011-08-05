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

#import "PXSoundEngine.h"
#import "PXAL.h"
#import "PXLinkedList.h"
#import "PXSoundMixer.h"
#import "PXSoundListener.h"

#import "PXEngine.h"
#import "PXStage.h"
#import "PXAVSoundChannel.h"
#import "PXALSoundChannel.h"

#include "PXEngineUtils.h"
#include "PXSettings.h"

#import "PXSoundTransform.h"
#import "PXDebug.h"

#import <AudioToolbox/AudioServices.h>

ALCdevice  *pxSoundEngineDevice = nil;
ALCcontext *pxSoundEngineContext = nil;
PXLinkedList *pxSoundEngineListOfSounds = nil;
PXSoundListener  *pxSoundEngineSoundListener = nil;
PXSoundTransform *pxSoundEngineSoundTransform = nil;

float pxSoundEngineSpeedOfSound = 340.29f;
PXSoundMixerDistanceModel pxSoundEngineDistanceModel = PXSoundMixerDistanceModel_Logarithmic;

BOOL pxSoundEngineHasBeenInitialized = NO;
BOOL pxSoundEngineALHasBeenInitialized = NO;
BOOL pxSoundEngineAudioHasSessionsInitialized = NO;
BOOL pxSoundEnginePause = NO;

void PXSoundEngineInterruptionListenerCallback(void *inClientData, UInt32 inInterruptionState);

void PXSoundEngineInit( )
{
	if (pxSoundEngineHasBeenInitialized)
	{
		return;
	}

	pxSoundEngineHasBeenInitialized = YES;

	if (!pxSoundEngineAudioHasSessionsInitialized)
	{
		pxSoundEngineAudioHasSessionsInitialized = YES;

#ifdef PX_DEBUG_MODE
		OSStatus status = AudioSessionInitialize(NULL, NULL, PXSoundEngineInterruptionListenerCallback, NULL);

		if (status != kAudioSessionNoError) 
		{
			switch (status)
			{
				case kAudioServicesUnsupportedPropertyError:
					PXDebugLog(@"PXSoundEngine ERROR - AudioSessionInitialize failed: unsupportedPropertyError");
					break;
				case kAudioServicesBadPropertySizeError:
					PXDebugLog(@"PXSoundEngine ERROR - AudioSessionInitialize failed: badPropertySizeError");
					break;
				case kAudioServicesBadSpecifierSizeError:
					PXDebugLog(@"PXSoundEngine ERROR - AudioSessionInitialize failed: badSpecifierSizeError");
					break;
				case kAudioServicesSystemSoundUnspecifiedError:
					PXDebugLog(@"PXSoundEngine ERROR - AudioSessionInitialize failed: systemSoundUnspecifiedError");
					break;
				case kAudioServicesSystemSoundClientTimedOutError:
					PXDebugLog(@"PXSoundEngine ERROR - AudioSessionInitialize failed: systemSoundClientTimedOutError");
					break;
				case 1768843636:
					PXDebugLog(@"PXSoundEngine ERROR - AudioSessionInitialize failed: sound command called before initialization");
					break;
				default:
					PXDebugLog(@"PXSoundEngine ERROR - AudioSessionInitialize failed! %d", status);
					break;
			}
		}
#endif
	}

	pxSoundEngineSoundListener = nil;
	pxSoundEngineSoundTransform = [[PXSoundTransform alloc] init];
	pxSoundEngineListOfSounds = [[PXLinkedList alloc] init];
}

void PXSoundEngineInitAL()
{
	if (pxSoundEngineALHasBeenInitialized)
	{
		return;
	}
	pxSoundEngineALHasBeenInitialized = YES;

	PXSoundEngineInit();

//	PXDebugALBeginErrorChecks(@"initAL");

	pxSoundEngineContext = nil;
	pxSoundEngineDevice = alcOpenDevice(NULL);
//	PXDebugALErrorCheck(@"alcOpenDevice");

	if (pxSoundEngineDevice)
	{
		pxSoundEngineContext = alcCreateContext(pxSoundEngineDevice, NULL);
//		PXDebugALErrorCheck(@"alcCreateContext");

		alcMakeContextCurrent(pxSoundEngineContext);
//		PXDebugALErrorCheck(@"alcMakeContextCurrent");
	}
	else
	{
		pxSoundEngineALHasBeenInitialized = NO;

//		PXDebugALEndErrorChecks();
		return;
	}

	if (!pxSoundEngineContext)
	{
		pxSoundEngineALHasBeenInitialized = NO;

		alcCloseDevice(pxSoundEngineDevice);
//		PXDebugALErrorCheck(@"alcCloseDevice");

//		PXDebugALEndErrorChecks();
		return;
	}

//	PXDebugALEndErrorChecks();

	pxSoundEngineSoundListener = [[PXSoundListener alloc] init];

	PXSoundEngineSetDistanceModel(pxSoundEngineDistanceModel);
	PXSoundEngineSetSpeedOfSound(pxSoundEngineSpeedOfSound);
}

void PXSoundEngineDealloc( )
{
	if (pxSoundEngineALHasBeenInitialized)
	{
		pxSoundEngineALHasBeenInitialized = NO;

		if (pxSoundEngineContext)
			alcDestroyContext(pxSoundEngineContext);
		if (pxSoundEngineDevice)
			alcCloseDevice(pxSoundEngineDevice);

		pxSoundEngineContext = nil;
		pxSoundEngineDevice = nil;
	}
	if (pxSoundEngineHasBeenInitialized)
	{
		pxSoundEngineHasBeenInitialized = NO;

		[pxSoundEngineListOfSounds release];
		pxSoundEngineListOfSounds = nil;
		[pxSoundEngineSoundListener release];
		pxSoundEngineSoundListener = nil;
		[pxSoundEngineSoundTransform release];
		pxSoundEngineSoundTransform = nil;
	}
}

void PXSoundEngineInterruptionListenerCallback(void *userData, UInt32 interruptionState)
{
	if (interruptionState == kAudioSessionBeginInterruption)
	{
		pxSoundEnginePause = YES;
		if (pxSoundEngineALHasBeenInitialized)
		{
			alcMakeContextCurrent (NULL);
		}
	}
	else if (interruptionState == kAudioSessionEndInterruption)
	{
		if (pxSoundEngineALHasBeenInitialized)
		{
			alcMakeContextCurrent (pxSoundEngineContext);
		}
		pxSoundEnginePause = NO;
	}
}

void PXSoundEngineUpdate()
{
	if (!pxSoundEngineHasBeenInitialized)
		return;
	if (pxSoundEnginePause)
		return;

	PXSoundChannel *sound;
	PXLinkedList *removeList = PXUtilsNewPooledList();

	for (sound in pxSoundEngineListOfSounds)
	{
		[sound _update];

		if ([sound _done])
		{
			[removeList addObject:sound];
		}
	}

	[pxSoundEngineListOfSounds removeObjectsInList:removeList];
//	for (sound in removeList)
//	{
//		[pxSoundEngineListOfSounds removeObject:sound];
//	}

	PXUtilsReleasePooledList(removeList);
}

void PXSoundEngineAddSound(PXSoundChannel *sound)
{
	PXSoundEngineInit();

	if (!pxSoundEngineHasBeenInitialized)
		return;

	if (!sound)
		return;

	[pxSoundEngineListOfSounds addObject:sound];
}

void PXSoundEngineRemoveSound(PXSoundChannel *sound)
{
	if (!pxSoundEngineHasBeenInitialized)
		return;

	if (!sound)
		return;

	assert(pxSoundEngineListOfSounds);

	[pxSoundEngineListOfSounds removeObject:sound];
}

PXSoundListener *PXSoundEngineGetSoundListener( )
{
	return pxSoundEngineSoundListener;
}

void PXSoundEngineSetSoundTransform(PXSoundTransform *transform)
{
	if (!pxSoundEngineHasBeenInitialized)
		return;

	if (!transform)
		return;

	pxSoundEngineSoundTransform.volume = transform.volume;
	pxSoundEngineSoundTransform.pitch  = 1.0f;

	[pxSoundEngineSoundListener _setVolume:pxSoundEngineSoundTransform.volume];

	PXSoundChannel *sound;
	for (sound in pxSoundEngineListOfSounds)
	{
		if ([sound isKindOfClass:[PXAVSoundChannel class]])
		{
			[((PXAVSoundChannel *)sound) _setEngineVolume:pxSoundEngineSoundTransform.volume];
		}
	}
}

PXSoundTransform * PXSoundEngineGetSoundTransform( )
{
	if (!pxSoundEngineSoundTransform)
		PXSoundEngineInit();

	return pxSoundEngineSoundTransform;
}

void PXSoundEnginePlayAll( )
{
	if (!pxSoundEngineHasBeenInitialized)
		return;

	PXSoundChannel *sound;
	for (sound in pxSoundEngineListOfSounds)
	{
		[sound play];
	}
}
void PXSoundEngineStopAll( )
{
	if (!pxSoundEngineHasBeenInitialized)
		return;

	PXSoundChannel *sound;
	for (sound in pxSoundEngineListOfSounds)
	{
		[sound stop];
	}

	[pxSoundEngineListOfSounds removeAllObjects];
}
void PXSoundEnginePauseAll( )
{
	if (!pxSoundEngineHasBeenInitialized)
		return;

	PXSoundChannel *sound;
	for (sound in pxSoundEngineListOfSounds)
	{
		[sound pause];
	}
}
void PXSoundEngineRewindAll( )
{
	if (!pxSoundEngineHasBeenInitialized)
		return;

	PXSoundChannel *sound;
	for (sound in pxSoundEngineListOfSounds)
	{
		[sound rewind];
	}
}

void PXSoundEngineUpdateSoundTransforms()
{
	if (!pxSoundEngineHasBeenInitialized)
		return;

	PXSoundChannel *sound;
	for (sound in pxSoundEngineListOfSounds)
	{
		sound.soundTransform = sound.soundTransform;
	}
}

void PXSoundEngineSetSpeedOfSound(float speedOfSound)
{
	PXSoundEngineInitAL();

	pxSoundEngineSpeedOfSound = fabsf(speedOfSound);

//	PXDebugALBeginErrorChecks(@"setSpeedOfSound");

	alSpeedOfSound(pxSoundEngineSpeedOfSound);

//	PXDebugALErrorCheck(@"alSpeedOfSound");
//	PXDebugALEndErrorChecks();
}

float PXSoundEngineGetSpeedOfSound()
{
	return pxSoundEngineSpeedOfSound;
}

void PXSoundEngineSetDistanceModel(PXSoundMixerDistanceModel distanceModel)
{
	PXSoundEngineInitAL();

//	PXDebugALBeginErrorChecks(@"setDistanceModel");

	PXSoundMixerDistanceModel oldModel = pxSoundEngineDistanceModel;
	pxSoundEngineDistanceModel = distanceModel;

	switch (distanceModel)
	{
		case PXSoundMixerDistanceModel_Linear:
			alDistanceModel(AL_LINEAR_DISTANCE);
			break;
		case PXSoundMixerDistanceModel_Logarithmic:
			alDistanceModel(AL_EXPONENT_DISTANCE);
			break;
		default:
			pxSoundEngineDistanceModel = oldModel;
			break;
	}

//	PXDebugALErrorCheck(@"alDistanceModel");
//	PXDebugALEndErrorChecks();

	PXSoundChannel *sound;
	for (sound in pxSoundEngineListOfSounds)
	{
		if ([sound isKindOfClass:[PXALSoundChannel class]])
		{
			[((PXALSoundChannel *)sound) _updateDistanceModel];
		}
	}
}
PXSoundMixerDistanceModel PXSoundEngineGetDistanceModel()
{
	if (!pxSoundEngineSoundListener)
		PXSoundEngineInit();

	return pxSoundEngineDistanceModel;
}

float PXSoundEngineGetDefaultReferenceDistance()
{
	if (!pxSoundEngineSoundListener)
		PXSoundEngineInit();

	return pxSoundEngineSoundListener.defaultReferenceDistance;
}
float PXSoundEngineGetDefaultLogarithmicExponent()
{
	if (!pxSoundEngineSoundListener)
		PXSoundEngineInit();

	return pxSoundEngineSoundListener.defaultLogarithmicExponent;
}
