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

@class PXSoundTransform;
@class PXSoundListener;

/**
 * Specifies the distance model used when rendering 3D sounds to the speakers.
 * 
 * @see [PXSoundMixer setDistanceModel:]
 */
typedef enum
{
	/// The linear distance model means that the sound falls off in a linear
	/// fashion the further it is away from the listener.
	PXSoundMixerDistanceModel_Linear = 0,
	/// The linear distance model means that the sound falls off in a
	/// logarithmic fashion the further it is away from the listener. The
	/// exponent is defined in #PXSoundChannel3D.
	PXSoundMixerDistanceModel_Logarithmic
} PXSoundMixerDistanceModel;

@interface PXSoundMixer : NSObject
{
}

//-- ScriptName: warmUp
+ (void) warmUp;

//-- ScriptName: setSoundTransform
+ (void) setSoundTransform:(PXSoundTransform *)soundTransform;
//-- ScriptName: getSoundTransform
+ (PXSoundTransform *)soundTransform;

//-- ScriptName: getSoundListener
+ (PXSoundListener *)soundListener;

//-- ScriptName: setSpeedOfSound
+ (void) setSpeedOfSound:(float)speedOfSound;
//-- ScriptName: getSpeedOfSound
+ (float) speedOfSound;

//-- ScriptName: setDistanceModel
+ (void) setDistanceModel:(PXSoundMixerDistanceModel)distanceModel;
//-- ScriptName: getDistanceModel
+ (PXSoundMixerDistanceModel) distanceModel;

//-- ScriptName: playAll
+ (void) playAll;
//-- ScriptName: pauseAll
+ (void) pauseAll;
//-- ScriptName: stopAll
+ (void) stopAll;
//-- ScriptName: rewindAll
+ (void) rewindAll;

@end
