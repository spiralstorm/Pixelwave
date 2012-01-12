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

#ifndef _PK_DESIGNER_PARTICLE_EMITTER_LOADED_DATA_H_
#define _PK_DESIGNER_PARTICLE_EMITTER_LOADED_DATA_H_

#import "PKDesignerParticleEffect.h"

#include "PXHeaderUtils.h"
#include "PKColor.h"

#include <CoreGraphics/CGGeometry.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
	PXTextureData *textureData;

	PKDesignerParticleEmissionType emissionType;
	CGPoint startPosition;
	CGPoint startPositionVariance;
	// The velocity from the origin based on the angle of creation.
	float speed;
	float speedVariance;
	// How long the particle will live
	float lifeSpan;
	float lifeSpanVariance;
	// The particle designer creates particles from the 'start position' with a
	// velocity based on an angle.
	float angleOfCreation;
	float angleOfCreationVariance;
	CGPoint gravity;
	float radialAcceleration;
	float radialAccelerationVariance;
	float tangentialAcceleration;
	float tangentialAccelerationVariance;
	PKColor startColor;
	PKColor startColorVariance;
	PKColor endColor;
	PKColor endColorVariance;
	// The maximum quantity of particles the particle deseigner is willing to
	// create.
	float maxParticles;
	float startScale;
	float startScaleVariance;	
	float endScale;
	float endScaleVariance;
	// How long the particle emitter will emit.
	float duration;
	unsigned short blendSource;
	unsigned short blendDestination;
	// The starting radius of the particles. The 'Radial' emission type creates
	// its particles at 'radius' distance from the center, and they move until
	// they reach the 'minRadius', at which time they cease to exist.
	float radius;
	float radiusVariance;
	float minRadius;
	// The radius velocity the speed at which the particle traverses from it's
	// start radius to the min radius.
	float radiusVelocity;
	float radiusVelocityVariance;

	float rotationStart;
	float rotationStartVariance;
	float rotationEnd;
	float rotationEndVariance;
} PKDesignerParticleEmitterLoadedData;

PXInline PKDesignerParticleEmitterLoadedData *PKDesignerParticleEmitterLoadedDataCreate();
PXInline void PKDesignerParticleEmitterLoadedDataDestroy(PKDesignerParticleEmitterLoadedData *data);

PXInline void PKDesignerParticleEmitterLoadedDataSetTextureData(PKDesignerParticleEmitterLoadedData *data, PXTextureData *textureData);

PXInline PKDesignerParticleEmitterLoadedData *PKDesignerParticleEmitterLoadedDataCreate()
{
	PKDesignerParticleEmitterLoadedData *data = calloc(1, sizeof(PKDesignerParticleEmitterLoadedData));

	if (data)
	{
	}

	return data;
}

PXInline void PKDesignerParticleEmitterLoadedDataDestroy(PKDesignerParticleEmitterLoadedData *data)
{
	if (data)
	{
		PKDesignerParticleEmitterLoadedDataSetTextureData(data, nil);

		free(data);
	}
}

PXInline void PKDesignerParticleEmitterLoadedDataSetTextureData(PKDesignerParticleEmitterLoadedData *data, PXTextureData *textureData)
{
	if (data)
	{
		[textureData retain];
		[data->textureData release];
		data->textureData = textureData;
	}
}

#ifdef __cplusplus
}
#endif

#endif
