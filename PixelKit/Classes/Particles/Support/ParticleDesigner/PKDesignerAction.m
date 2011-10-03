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

#import "PKDesignerAction.h"

#import "PKParticle.h"
#import "PKParticleEmitter.h"
#import "PKDesignerParticle.h"
#import "PKDesignerParticleEffect.h"

#include "PXPrivateUtils.h"
#include "PXMathUtils.h"

@implementation PKDesignerAction

- (id) init
{
    self = [super init];

    if (self)
	{
    }

    return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void) updateParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter deltaTime:(float)dt
{
	PKDesignerParticle *designerParticle = (PKDesignerParticle *)particle;

	if (emissionType == PKDesignerParticleEmissionType_Gravity)
	{
		PXMathPoint tangential;
		PXMathPoint radial;
		PXMathPoint accel;

		// If this is the 'gravity' based emisison type, update it appropertly.
		// This update method is based on the Particle Designer update method in
		// their example code. It was updated to use our variables and structure
		designerParticle->x -= designerParticle->startX;
		designerParticle->y -= designerParticle->startY;

		radial = PXMathPointMake(designerParticle->x, designerParticle->y);
		PXMathPointNorm(&radial);

		tangential = PXMathPointMake(-radial.y * designerParticle->tangentialAcceleration,
									  radial.x * designerParticle->tangentialAcceleration);

		radial.x *= designerParticle->radialAcceleration;
		radial.y *= designerParticle->radialAcceleration;

		accel = PXMathPointMake(designerParticle->accelerationX, designerParticle->accelerationY);
		accel.x += radial.x + tangential.x + gravityX;
		accel.y += radial.y + tangential.y + gravityY;

		designerParticle->velocityX += accel.x * dt;
		designerParticle->velocityY += accel.y * dt;

		designerParticle->x += (designerParticle->velocityX * dt) + designerParticle->startX;
		designerParticle->y += (designerParticle->velocityY * dt) + designerParticle->startY;
	}
	else if (emissionType == PKDesignerParticleEmissionType_Radial)
	{
		// If this is the 'radial' based emisison type, update it appropertly.
		// This update method is based on the Particle Designer update method in
		// their example code. It was updated to use our variables and structure
		designerParticle->angle  += designerParticle->angleVelocity  * dt;
		designerParticle->radius -= designerParticle->radiusVelocity * dt;

		designerParticle->x = designerParticle->startX - cosf(designerParticle->angle) * designerParticle->radius;
		designerParticle->y = designerParticle->startY - sinf(designerParticle->angle) * designerParticle->radius;

		if (designerParticle->radius < minRadius)
			designerParticle->age = designerParticle->lifetime;
	}

	float oneMinusPercent = designerParticle->energy;
	float percent = 1.0f - oneMinusPercent;

	designerParticle->r = PXMathLerp(designerParticle->startR, designerParticle->endR, percent);
	designerParticle->g = PXMathLerp(designerParticle->startG, designerParticle->endG, percent);
	designerParticle->b = PXMathLerp(designerParticle->startB, designerParticle->endB, percent);
	designerParticle->a = PXMathLerp(designerParticle->startA, designerParticle->endA, percent);

	designerParticle->scaleX = PXMathLerpf(designerParticle->startScaleX, designerParticle->endScaleX, percent);
	designerParticle->scaleY = PXMathLerpf(designerParticle->startScaleY, designerParticle->endScaleY, percent);

	// AGE
	designerParticle->age += dt;
	designerParticle->energy = 1.0f - (designerParticle->age / designerParticle->lifetime);

	if (designerParticle->age > designerParticle->lifetime)
	{
		designerParticle->energy = 0.0f;
		designerParticle->isExpired = YES;
	}
}

@end
