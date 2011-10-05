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

#import "PKPEXParticleEffectParser.h"

#import "TBXML.h"
#import "TBXMLNSDataAdditions.h"
#import "TBXMLParticleAdditions.h"

#include "PKDesignerParticleEmitterLoadedData.h"

#include "PXDebug.h"

@implementation PKPEXParticleEffectParser

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
		const char *charArray = (const char *)[data bytes];
		NSString *string = [NSString stringWithCString:charArray encoding:NSASCIIStringEncoding];
		NSRange range = [string rangeOfString:@"<particleEmitterConfig>"];

		if (range.length > 0)
		{
			return YES;
		}
	}
	else if (origin != nil)
	{
		return [[origin lowercaseString] hasSuffix:@"pex"];
	}

	return NO;
}

+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	[extensions addObject:@"pex"];
}

- (BOOL) _parse
{
	[self _setLoadedData:PKDesignerParticleEmitterLoadedDataCreate()];

	PKDesignerParticleEmitterLoadedData *designerData = loadedData;

	if (designerData != nil)
	{
		TBXML *particleXML = [[[TBXML alloc] initWithXMLData:data] autorelease];
		TBXMLElement *rootXMLElement = particleXML.rootXMLElement;

		// Make sure we have a root element or we cant process this file
		if (!rootXMLElement)
		{
			PXDebugLog(@"ParticleEmitter: Could not find root element in particle config file.");
			[self _setLoadedData:NULL];
			return NO;
		}

		// First thing to grab is the texture that is to be used for the point sprite
		TBXMLElement *element = [TBXML childElementNamed:@"texture" parentElement:rootXMLElement];

		// Grab the values. For information as to what they mean, please look at
		// the struct.
		if (element)
		{
			PXTextureData *textureData = [PKParticleEffectParser _newTextureDataFromTextureString:[TBXML valueOfAttributeNamed:@"data" forElement:element]
																						   orPath:[TBXML valueOfAttributeNamed:@"name" forElement:element]
																				 premultiplyAlpha:premultiply];
			PKDesignerParticleEmitterLoadedDataSetTextureData(designerData, textureData);
			[textureData release];
		}

		designerData->emissionType						= [TBXMLParticleAdditions intValue:particleXML fromChildElementNamed:@"emitterType" parentElement:rootXMLElement];
		designerData->startPosition						= [TBXMLParticleAdditions point:particleXML fromChildElementNamed:@"sourcePosition" parentElement:rootXMLElement];
		designerData->startPositionVariance				= [TBXMLParticleAdditions point:particleXML fromChildElementNamed:@"sourcePositionVariance" parentElement:rootXMLElement];
		designerData->speed								= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"speed" parentElement:rootXMLElement];
		designerData->speedVariance						= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"speedVariance" parentElement:rootXMLElement];
		designerData->lifeSpan							= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"particleLifeSpan" parentElement:rootXMLElement];
		designerData->lifeSpanVariance					= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"particleLifespanVariance" parentElement:rootXMLElement];
		designerData->angleOfCreation					= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"angle" parentElement:rootXMLElement];
		designerData->angleOfCreationVariance			= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"angleVariance" parentElement:rootXMLElement];
		designerData->gravity							= [TBXMLParticleAdditions point:particleXML fromChildElementNamed:@"gravity" parentElement:rootXMLElement];
		designerData->radialAcceleration				= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"radialAcceleration" parentElement:rootXMLElement];
		designerData->radialAccelerationVariance		= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"radialAccelVariance" parentElement:rootXMLElement];
		designerData->tangentialAcceleration			= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"tangentialAcceleration" parentElement:rootXMLElement];
		designerData->tangentialAccelerationVariance	= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"tangentialAccelVariance" parentElement:rootXMLElement];
		designerData->startColor						= [TBXMLParticleAdditions color:particleXML fromChildElementNamed:@"startColor" parentElement:rootXMLElement];
		designerData->startColorVariance				= [TBXMLParticleAdditions color:particleXML fromChildElementNamed:@"startColorVariance" parentElement:rootXMLElement];
		designerData->endColor							= [TBXMLParticleAdditions color:particleXML fromChildElementNamed:@"finishColor" parentElement:rootXMLElement];
		designerData->endColorVariance					= [TBXMLParticleAdditions color:particleXML fromChildElementNamed:@"finishColorVariance" parentElement:rootXMLElement];
		designerData->maxParticles						= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"maxParticles" parentElement:rootXMLElement];
		designerData->startScale						= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"startParticleSize" parentElement:rootXMLElement];
		designerData->startScaleVariance				= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"startParticleSizeVariance" parentElement:rootXMLElement];	
		designerData->endScale							= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"finishParticleSize" parentElement:rootXMLElement];
		designerData->endScaleVariance					= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"finishParticleSizeVariance" parentElement:rootXMLElement];
		designerData->duration							= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"duration" parentElement:rootXMLElement];
		designerData->blendSource						= [TBXMLParticleAdditions intValue:particleXML fromChildElementNamed:@"blendFuncSource" parentElement:rootXMLElement];
		designerData->blendDestination					= [TBXMLParticleAdditions intValue:particleXML fromChildElementNamed:@"blendFuncDestination" parentElement:rootXMLElement];

		// These paramters are used when you want to have the particles spinning around the source location
		designerData->radius							= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"maxRadius" parentElement:rootXMLElement];
		designerData->radiusVariance					= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"maxRadiusVariance" parentElement:rootXMLElement];
		designerData->minRadius							= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"minRadius" parentElement:rootXMLElement];
		designerData->radiusVelocity					= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"rotatePerSecond" parentElement:rootXMLElement];
		designerData->radiusVelocityVariance			= [TBXMLParticleAdditions floatValue:particleXML fromChildElementNamed:@"rotatePerSecondVariance" parentElement:rootXMLElement];
	}

	return designerData != nil;
}

@end
