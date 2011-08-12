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
#import "PXPooledObject.h"

@interface PXSoundTransform3D : PXSoundTransform<NSCopying, PXPooledObject>
{
@protected
	float x;
	float y;
	float z;

	float velocityX;
	float velocityY;
	float velocityZ;

	float referenceDistance;
	float logarithmicExponent;
}

/**
 * The horizontal coordinate.
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float x;
/**
 * The vertical coordinate.
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float y;
/**
 * The depth coordinate.
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float z;

/**
 * The horizontal coordinate change per second.
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float velocityX;
/**
 * The vertical coordinate change per second.
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float velocityY;
/**
 * The depth coordinate change per second.
 *
 * **Default:** 0.0f
 */
@property (nonatomic) float velocityZ;

/**
 * The reference for how the volume changes based on it's distance from the
 * listener.
 *
 * If the distance model described in #PXSoundMixer is set to
 * `PXSoundMixerDistanceModel_Linear` then the
 * `logarithmicExponent` is ignored and if a
 * #PXSoundChannel is further then the reference distance away from
 * the listener, then the sound will not be heard. Anywhere in between will be
 * linearly distributed. So if the #PXSoundChannel is 70% of the
 * reference distance away from the user, then the sound is played at 70%
 * volume.
 *
 * If the distance model described in #PXSoundMixer is set to
 * `PXSoundMixerDistanceModel_Logarithmic` then the distance volume
 * is calculated based on the following forumla:
 *	distanceVolume = (distance / referenceDistance) ^ (-logarithmicExponent)
 *
 * The actual volume is computed using the following formula:
 *	playingVolume = volume * distanceVolume * [PXSoundMixer soundTransform].volume
 *
 * **Default:** `[PXSoundMixer soundListener].defaultReferenceDistance`
 *
 * @warning The reference distance can not be negative, the absolute value will
 * be taken before use.
 */
@property (nonatomic) float referenceDistance;
/**
 * The exponent for the logarithmic distance model described in
 * #PXSoundMixer. The exponent is ignored if the distance model is
 * set to `PXSoundMixerDistanceModel_Linear`.  For the forumla used
 * please see the #referenceDistance description.
 *
 * **Default:** `[PXSoundMixer soundListener].defaultLogarithmicExponent`
 *
 * @warning The logarithmic exponent can not be negative, the absolute value
 * will be taken before use.
 */
@property (nonatomic) float logarithmicExponent;

//-- ScriptName: setPosition
- (void) setX:(float)x y:(float)y z:(float)z;
//-- ScriptName: setVelocity
- (void) setVelocityX:(float)x y:(float)y z:(float)z;

//-- ScriptName: make
//-- ScriptArg[0]: 1.0f
//-- ScriptArg[1]: 1.0f
+ (PXSoundTransform3D *)soundTransform3DWithVolume:(float)volume pitch:(float)pitch;

@end
