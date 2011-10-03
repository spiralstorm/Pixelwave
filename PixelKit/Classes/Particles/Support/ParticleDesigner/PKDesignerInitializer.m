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

#import "PKDesignerInitializer.h"

#import "PXStage.h"
#import "PXTextureData.h"

#import "PKParticle.h"
#import "PKParticleEmitter.h"
#import "PKDesignerParticle.h"

#include "PXPrivateUtils.h"
#include "PXMathUtils.h"

@implementation PKDesignerInitializer

@synthesize textureData;

- (id) init
{
	self = [super init];

	if (self != nil)
	{
	}

	return self;
}

- (void) dealloc
{
	self.textureData = nil;

	[super dealloc];
}

- (void) initializeParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter
{
	assert(particle->graphic == nil);

	PKDesignerParticle *designerParticle = (PKDesignerParticle *)particle;

	designerParticle->lifetime = PKRangeRandom(lifeSpanRange);
	if (designerParticle->lifetime < 0.001f)
	{
		// If the duration randomly generated is less than 1/100th of a second,
		// it will enver appear, so lets just say it doesn't even exist.
		designerParticle->lifetime = 0.0f;
		designerParticle->isExpired = YES;

		return;
	}

	designerParticle->graphic = [textureData retain];

	designerParticle->blendSource = blendSource;
	designerParticle->blendDestination = blendDestination;

	designerParticle->sMin = sRange.start;
	designerParticle->sMax = sRange.end;
	designerParticle->tMin = tRange.start;
	designerParticle->tMax = tRange.end;

	// Generate it's values.
	designerParticle->x = emitter.x + PXMathFloatInRange(-(startVarianceX), (startVarianceX));
	designerParticle->y = emitter.y + PXMathFloatInRange(-(startVarianceY), (startVarianceY));
	designerParticle->rotation = 0.0f;

	designerParticle->velocityX = PKRangeRandom(speedRange);
	designerParticle->velocityY = PKRangeRandom(speedRange);

	designerParticle->accelerationX = 0.0f;
	designerParticle->accelerationY = 0.0f;

#define PKDesignerInitializerRandomizeColorFromVariance(_store_, _color_, _variance_) \
{ \
	int __val__ = PXMathIntInRange(-_variance_, _variance_); \
	__val__ += _color_; \
	PXMathClamp(__val__, 0x00, 0xFF); \
	_store_ = (__val__); \
}

	PKDesignerInitializerRandomizeColorFromVariance(designerParticle->startR, startColorR, startColorVarianceR);
	PKDesignerInitializerRandomizeColorFromVariance(designerParticle->startG, startColorG, startColorVarianceG);
	PKDesignerInitializerRandomizeColorFromVariance(designerParticle->startB, startColorB, startColorVarianceB);
	PKDesignerInitializerRandomizeColorFromVariance(designerParticle->startA, startColorA, startColorVarianceA);

	PKDesignerInitializerRandomizeColorFromVariance(designerParticle->endR, endColorR, endColorVarianceR);
	PKDesignerInitializerRandomizeColorFromVariance(designerParticle->endG, endColorG, endColorVarianceG);
	PKDesignerInitializerRandomizeColorFromVariance(designerParticle->endB, endColorB, endColorVarianceB);
	PKDesignerInitializerRandomizeColorFromVariance(designerParticle->endA, endColorA, endColorVarianceA);

	designerParticle->startScaleX = PKRangeRandom(startScaleRange);
	designerParticle->startScaleY = designerParticle->startScaleX;
	designerParticle->endScaleX = PKRangeRandom(endScaleRange);
	designerParticle->endScaleY = designerParticle->endScaleX;

	designerParticle->rotationalVelocity = 0.0f;

	// Set the values - Please see the class for more info as to what they are.
	designerParticle->radialAcceleration = PKRangeRandom(radialAccelerationRange);
	designerParticle->tangentialAcceleration = PKRangeRandom(tangentialAccelerationRange);

	designerParticle->angle = PKRangeRandom(angleOfCreationRange);

	if (emissionType == PKDesignerParticleEmissionType_Gravity)
	{
		// This was already calculated
		float vel = designerParticle->velocityX;
		designerParticle->velocityX = vel * cosf(designerParticle->angle);
		designerParticle->velocityY = vel * sinf(designerParticle->angle);
	}

	float radius = (radiusRange.start + radiusRange.end) * 0.5f;
	float lifeSpan = (lifeSpanRange.start + lifeSpanRange.end) * 0.5f;
	float deg = PXMathIsZero(lifeSpan) ? 65536.0f : radius / lifeSpan;

	designerParticle->radius = PKRangeRandom(radiusRange);
	designerParticle->radiusVelocity = deg;
	designerParticle->angleVelocity = PKRangeRandom(radiusVelocityRange);
	designerParticle->startX = designerParticle->x;
	designerParticle->startY = designerParticle->y;
}

- (void) disposeParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter
{
	[(NSObject *)(particle->graphic) release];
	particle->graphic = nil;
}

@end
