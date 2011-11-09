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

#import "PKPListParticleEffectParser.h"

#import "PXTextureData.h"

#include "PXPrivateUtils.h"
#include "PKDesignerParticleEmitterLoadedData.h"

@implementation PKPListParticleEffectParser

- (id) init
{
    self = [super init];

    if (self)
	{
        // Initialization code here.
    }
    
    return self;
}

+ (BOOL) isApplicableForData:(NSData *)data origin:(NSString *)origin
{
	if (data != nil)
	{
		NSString *errorString = nil;
		NSDictionary *dictionary = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:nil errorDescription:&errorString];

		if (errorString == nil && dictionary != nil)
		{
			return YES;
		}
	}
	else if (origin != nil)
	{
		return [[origin lowercaseString] hasSuffix:@"plist"];
	}

	return NO;
}

+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	[extensions addObject:@"plist"];
}

- (BOOL) _parse
{
	NSString *errorString = nil;
	NSDictionary *dictionary = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:nil errorDescription:&errorString];

	if (errorString != nil || dictionary == nil)
	{
		return NO;
	}

	[self _setLoadedData:PKDesignerParticleEmitterLoadedDataCreate()];

	PKDesignerParticleEmitterLoadedData *designerData = loadedData;

	if (designerData != nil)
	{
		// These macro's will help us grab values from the dictionary.
#define PKParticleEmitterIntFromDictionary(_dictionary_, _key_) \
	[((NSNumber *)([(_dictionary_) objectForKey:_key_])) intValue]
#define PKParticleEmitterFloatFromDictionary(_dictionary_, _key_) \
	[((NSNumber *)([(_dictionary_) objectForKey:_key_])) floatValue]
#define PKParticleEmitterPointFromDictionary(_dictionary_, _key_) \
	CGPointMake(PKParticleEmitterFloatFromDictionary(_dictionary_, ([NSString stringWithFormat:@"%@x", _key_])), \
				PKParticleEmitterFloatFromDictionary(_dictionary_, ([NSString stringWithFormat:@"%@y", _key_])))
#define PKParticleEmitterColorFromDictionary(_dictionary_, _key_) \
	PKColorMakeRGBA(PX_COLOR_FLOAT_TO_BYTE(PKParticleEmitterFloatFromDictionary(_dictionary_, ([NSString stringWithFormat:@"%@Red",   _key_]))), \
					PX_COLOR_FLOAT_TO_BYTE(PKParticleEmitterFloatFromDictionary(_dictionary_, ([NSString stringWithFormat:@"%@Green", _key_]))), \
					PX_COLOR_FLOAT_TO_BYTE(PKParticleEmitterFloatFromDictionary(_dictionary_, ([NSString stringWithFormat:@"%@Blue",  _key_]))), \
					PX_COLOR_FLOAT_TO_BYTE(PKParticleEmitterFloatFromDictionary(_dictionary_, ([NSString stringWithFormat:@"%@Alpha", _key_]))))

		// Grab the values. For information as to what they mean, please look at
		// the struct.
		PXTextureData *textureData = [PKParticleEffectParser _newTextureDataFromTextureString:[dictionary objectForKey:@"textureImageData"]
																					   orPath:[dictionary objectForKey:@"textureFileName"]
																			 premultiplyAlpha:premultiply];
		PKDesignerParticleEmitterLoadedDataSetTextureData(designerData, textureData);
		[textureData release];

		designerData->emissionType						= PKParticleEmitterIntFromDictionary(dictionary, @"emitterType");
		designerData->startPosition						= PKParticleEmitterPointFromDictionary(dictionary, @"sourcePosition");
		designerData->startPositionVariance				= PKParticleEmitterPointFromDictionary(dictionary, @"sourcePositionVariance");
		designerData->speed								= PKParticleEmitterFloatFromDictionary(dictionary, @"speed");
		designerData->speedVariance						= PKParticleEmitterFloatFromDictionary(dictionary, @"speedVariance");
		designerData->lifeSpan							= PKParticleEmitterFloatFromDictionary(dictionary, @"particleLifespan");
		designerData->lifeSpanVariance					= PKParticleEmitterFloatFromDictionary(dictionary, @"particleLifespanVariance");
		designerData->angleOfCreation					= PKParticleEmitterFloatFromDictionary(dictionary, @"angle");
		designerData->angleOfCreationVariance			= PKParticleEmitterFloatFromDictionary(dictionary, @"angleVariance");
		designerData->gravity							= PKParticleEmitterPointFromDictionary(dictionary, @"gravity");
		designerData->radialAcceleration				= PKParticleEmitterFloatFromDictionary(dictionary, @"radialAcceleration");
		designerData->radialAccelerationVariance		= PKParticleEmitterFloatFromDictionary(dictionary, @"radialAccelVariance");
		designerData->tangentialAcceleration			= PKParticleEmitterFloatFromDictionary(dictionary, @"tangentialAcceleration");
		designerData->tangentialAccelerationVariance	= PKParticleEmitterFloatFromDictionary(dictionary, @"tangentialAccelVariance");
		designerData->startColor						= PKParticleEmitterColorFromDictionary(dictionary, @"startColor");
		designerData->startColorVariance				= PKParticleEmitterColorFromDictionary(dictionary, @"startColorVariance");
		designerData->endColor							= PKParticleEmitterColorFromDictionary(dictionary, @"finishColor");
		designerData->endColorVariance					= PKParticleEmitterColorFromDictionary(dictionary, @"finishColorVariance");
		designerData->maxParticles						= PKParticleEmitterFloatFromDictionary(dictionary, @"maxParticles");
		designerData->startScale						= PKParticleEmitterFloatFromDictionary(dictionary, @"startParticleSize");
		designerData->startScaleVariance				= PKParticleEmitterFloatFromDictionary(dictionary, @"startParticleSizeVariance");	
		designerData->endScale							= PKParticleEmitterFloatFromDictionary(dictionary, @"finishParticleSize");
		designerData->endScaleVariance					= PKParticleEmitterFloatFromDictionary(dictionary, @"finishParticleSizeVariance");
		designerData->duration							= PKParticleEmitterFloatFromDictionary(dictionary, @"duration");
		designerData->blendSource						= PKParticleEmitterIntFromDictionary(dictionary, @"blendFuncSource");
		designerData->blendDestination					= PKParticleEmitterIntFromDictionary(dictionary, @"blendFuncDestination");

		// These paramters are used when you want to have the particles spinning around the source location
		designerData->radius							= PKParticleEmitterFloatFromDictionary(dictionary, @"maxRadius");
		designerData->radiusVariance					= PKParticleEmitterFloatFromDictionary(dictionary, @"maxRadiusVariance");
		designerData->minRadius							= PKParticleEmitterFloatFromDictionary(dictionary, @"minRadius");
		designerData->radiusVelocity					= PKParticleEmitterFloatFromDictionary(dictionary, @"rotatePerSecond");
		designerData->radiusVelocityVariance			= PKParticleEmitterFloatFromDictionary(dictionary, @"rotatePerSecondVariance");

		designerData->rotationStart						= PKParticleEmitterFloatFromDictionary(dictionary, @"rotationStart");
		designerData->rotationStartVariance				= PKParticleEmitterFloatFromDictionary(dictionary, @"rotationStartVariance");
		designerData->rotationEnd						= PKParticleEmitterFloatFromDictionary(dictionary, @"rotationEnd");
		designerData->rotationEndVariance				= PKParticleEmitterFloatFromDictionary(dictionary, @"rotationEndVariance");
	}

	return designerData != nil;
}

@end
