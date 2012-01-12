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

#import "FountainEffect.h"

@implementation FountainEffect

- (id) init
{
    self = [super init];

    if (self)
	{
		// Initializers
		[self addInitializer:[PKSharedGraphicInitializer sharedGraphicInitializerWithGraphic:[PXTextureData textureDataWithContentsOfFile:@"dot.png"]]];

		[self addInitializer:[PKPositionInitializer positionInitializerWithZone:
							  [PKDiscSectorZone discSectorZoneWithOuterRadius:50.0f innerRadius:50.0f angleRange:PKRangeMake(0.0f, 180.0f)]]];
		[self addInitializer:[PKLifetimeInitializer lifetimeInitializerWithRange:PKRangeMake(1, 3)]];
		[self addInitializer:[PKVelocityInitializer velocityInitializerWithZone:[PKDiscSectorZone discSectorZoneWithOuterRadius:50.0f innerRadius:40.0f angleRange:PKRangeMake(45, 135)]]];
		[self addInitializer:[PKColorInitializer colorInitializerWithMinColor:0x56b1ff maxColor:0xe0f1ff]];
		[self addInitializer:[PKScaleInitializer scaleInitializerWithRange:PKRangeMake(0.1f, 0.6f)]];
		[self addInitializer:[PKBlendInitializer additiveBlendInitializer]];

		// Actions
		[self addAction:[PKMoveAction moveAction]];
		[self addAction:[PKAgeAction ageAction]];
		[self addAction:[PKAccelerateAction accelerateActionWithX:0.0f y:100.0f]];
		[self addAction:[PKFadeAction fadeAction]];
    }

    return self;
}

- (id<PKParticleFlow>)_newFlow
{
	return [[PKSteadyFlow alloc] initWithRate:100.0f];
}

- (id<PKParticleRenderer>)_newRenderer
{
	return [[PKQuadRenderer alloc] initWithSmoothing:YES];
}

@end
