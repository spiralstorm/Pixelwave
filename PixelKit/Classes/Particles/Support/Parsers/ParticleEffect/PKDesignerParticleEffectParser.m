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

#import "PKDesignerParticleEffectParser.h"

#import "PKDesignerFlow.h"
#import "PKDesignerInitializer.h"
#import "PKDesignerAction.h"

#import "PKParticleCreator.h"
#import "PKDesignerParticle.h"

#include "PKDesignerParticleEmitterLoadedData.h"

@implementation PKDesignerParticleEffectParser

- (PKParticleEffect *)newParticleEffect
{
	if (loadedData == nil)
		return nil;

	PKDesignerParticleEffect *effect = [[PKDesignerParticleEffect alloc] init];

	if (effect != nil)
	{
		PKDesignerParticleEmitterLoadedData *designerData = loadedData;

		float emissionRate = PXMathIsZero(designerData->lifeSpan) ? 4194304.0f : designerData->maxParticles / designerData->lifeSpan;

		effect->startPosition = designerData->startPosition;
		effect->startPosition.y = [PXStage mainStage].stageHeight - effect->startPosition.y;

		effect->rate = emissionRate;
		effect->max = designerData->maxParticles;
		effect->duration = designerData->duration;

		PKDesignerInitializer *designerInitializer = [[PKDesignerInitializer alloc] init];
		if (designerInitializer != nil)
		{
			[effect addInitializer:designerInitializer];
			[designerInitializer release];

			designerInitializer->emissionType = designerData->emissionType;

			designerInitializer->startVarianceX = designerData->startPositionVariance.x;
			designerInitializer->startVarianceY = designerData->startPositionVariance.y;

			designerInitializer->startColorR = designerData->startColor.asRGBA.r;
			designerInitializer->startColorG = designerData->startColor.asRGBA.g;
			designerInitializer->startColorB = designerData->startColor.asRGBA.b;
			designerInitializer->startColorA = designerData->startColor.asRGBA.a;

			designerInitializer->startColorVarianceR = designerData->startColorVariance.asRGBA.r;
			designerInitializer->startColorVarianceG = designerData->startColorVariance.asRGBA.g;
			designerInitializer->startColorVarianceB = designerData->startColorVariance.asRGBA.b;
			designerInitializer->startColorVarianceA = designerData->startColorVariance.asRGBA.a;

			designerInitializer->endColorR = designerData->endColor.asRGBA.r;
			designerInitializer->endColorG = designerData->endColor.asRGBA.g;
			designerInitializer->endColorB = designerData->endColor.asRGBA.b;
			designerInitializer->endColorA = designerData->endColor.asRGBA.a;

			designerInitializer->endColorVarianceR = designerData->endColorVariance.asRGBA.r;
			designerInitializer->endColorVarianceG = designerData->endColorVariance.asRGBA.g;
			designerInitializer->endColorVarianceB = designerData->endColorVariance.asRGBA.b;
			designerInitializer->endColorVarianceA = designerData->endColorVariance.asRGBA.a;

			designerInitializer->speedRange = PKRangeMakeFromVariance(designerData->speed, designerData->speedVariance);

			PKRange lifeSpanRange = PKRangeMakeFromVariance(designerData->lifeSpan, designerData->lifeSpanVariance);
			lifeSpanRange.start = MAX(0.0f, lifeSpanRange.start);
			designerInitializer->lifeSpanRange = lifeSpanRange;

			designerInitializer->angleOfCreationRange = PKRangeMakeFromVariance(PXMathToRad(-(designerData->angleOfCreation)), PXMathToRad(designerData->angleOfCreationVariance));

			designerInitializer->radialAccelerationRange = PKRangeMakeFromVariance(designerData->radialAcceleration, designerData->radialAccelerationVariance);
			designerInitializer->tangentialAccelerationRange = PKRangeMakeFromVariance(-(designerData->tangentialAcceleration), designerData->tangentialAccelerationVariance);

			float one_textureWidth  = 1.0f;

			if (designerData->textureData != nil)
			{
				if (PXMathIsZero(designerData->textureData.width) == NO)
				{
					one_textureWidth = 1.0f / designerData->textureData.width;
				}

				designerInitializer->sRange = PKRangeMake(0.0f, designerData->textureData->_contentWidth  * designerData->textureData->_sPerPixel);
				designerInitializer->tRange = PKRangeMake(0.0f, designerData->textureData->_contentHeight * designerData->textureData->_tPerPixel);
			}

			designerInitializer->startScaleRange = PKRangeMakeFromVariance(designerData->startScale * one_textureWidth, designerData->startScaleVariance * one_textureWidth);
			designerInitializer->endScaleRange = PKRangeMakeFromVariance(designerData->endScale * one_textureWidth, designerData->endScaleVariance * one_textureWidth);

			designerInitializer->radiusRange = PKRangeMakeFromVariance(designerData->radius, designerData->radiusVariance);
			designerInitializer->radiusVelocityRange = PKRangeMakeFromVariance(-(PXMathToRad(designerData->radiusVelocity)), PXMathToRad(designerData->radiusVelocityVariance));
			designerInitializer->minRadius = designerData->minRadius;

			designerInitializer.textureData = designerData->textureData;
			designerInitializer->blendSource = designerData->blendSource;
			designerInitializer->blendDestination = designerData->blendDestination;
		}

		PKDesignerAction *action = [[PKDesignerAction alloc] init];
		if (action != nil)
		{
			[effect addAction:action];
			[action release];

			action->emissionType = designerData->emissionType;
			action->gravityX = designerData->gravity.x;
			action->gravityY = -designerData->gravity.y;
			action->minRadius = designerData->minRadius;
		}

		PKParticleCreator *factory = [[PKParticleCreator alloc] initWithParticleType:[PKDesignerParticle class]];
		effect.particleFactory = factory;
		[factory release];
	}

	return effect;
}

- (void) _setLoadedData:(void *)_data
{
	if (_data == loadedData)
		return;

	if (loadedData != nil)
	{
		PKDesignerParticleEmitterLoadedDataDestroy(loadedData);
		loadedData = NULL;
	}

	if (_data)
	{
		loadedData = _data;
	}
}

@end
