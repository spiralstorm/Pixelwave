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

#import "PKParticleInitializerBase.h"

#include "PKDesignerParticleEmissionType.h"
#include "PKRange.h"

@class PKDesignerParticleEffect;
@class PXTextureData;

@interface PKDesignerInitializer : PKParticleInitializerBase
{
@public
	PKDesignerParticleEmissionType emissionType;

	// The starting variance of the particle
	float startVarianceX;
	float startVarianceY;

	// The velocity from the origin based on the angle of creation.
	PKRange speedRange;

	// How long the particle will live
	PKRange lifeSpanRange;

	unsigned char startColorR;
	unsigned char startColorG;
	unsigned char startColorB;
	unsigned char startColorA;
	unsigned char startColorVarianceR;
	unsigned char startColorVarianceG;
	unsigned char startColorVarianceB;
	unsigned char startColorVarianceA;

	unsigned char endColorR;
	unsigned char endColorG;
	unsigned char endColorB;
	unsigned char endColorA;
	unsigned char endColorVarianceR;
	unsigned char endColorVarianceG;
	unsigned char endColorVarianceB;
	unsigned char endColorVarianceA;

	PKRange startScaleRange;
	PKRange endScaleRange;

	PKRange radialAccelerationRange;
	PKRange tangentialAccelerationRange;

	// The particle designer creates particles from the 'start position' with a
	// velocity based on an angle.
	PKRange angleOfCreationRange;

	// The starting radius of the particles. The 'Radial' emission type creates
	// its particles at 'radius' distance from the center, and they move until
	// they reach the 'minRadius', at which time they cease to exist.
	PKRange radiusRange;
	float minRadius;

	// The radius velocity the speed at which the particle traverses from it's
	// start radius to the min radius.
	PKRange radiusVelocityRange;

	PXTextureData *textureData;

	unsigned short blendSource;
	unsigned short blendDestination;

	PKRange sRange;
	PKRange tRange;

	PKRange rotationStartRange;
	PKRange rotationEndRange;
}

@property (nonatomic, retain) PXTextureData *textureData;

@end
