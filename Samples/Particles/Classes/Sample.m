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

#import "Sample.h"

@implementation Sample

- (id) init
{
	self = [super init];

	if (self)
	{
		// Initialization code here.
		PXStage *stage = [PXStage mainStage];
		halfStageSize = CGSizeMake(stage.stageWidth * 0.5f, stage.stageHeight * 0.5f);

		renderers = [[PXLinkedList alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	[renderers release];
	renderers = nil;

	[super dealloc];
}

- (NSString *)description
{
	return @"Sample";
}

- (void) addRenderer:(id<PKParticleRenderer>)renderer
{
	[renderers addObject:renderer];

	if ([renderer isKindOfClass:[PXDisplayObject class]])
	{
		[self addChild:(PXDisplayObject *)renderer];
	}
}

- (void) removeRenderer:(id<PKParticleRenderer>)renderer
{
	if ([renderer isKindOfClass:[PXDisplayObject class]])
	{
		[self removeChild:(PXDisplayObject *)renderer];
	}

	[renderers removeObject:renderer];
}

- (unsigned int) particleCount
{
	unsigned int count = 0;
	PXLinkedList *emitters;

	id<PKParticleRenderer> renderer;
	PKParticleEmitter *emitter;

	for (renderer in renderers)
	{
		emitters = [renderer emitters];

		for (emitter in emitters)
		{
			count += emitter.numParticles;
		}
	}

	return count;
}

- (void) setup
{
}

- (void) teardown
{
	while (renderers.count > 0)
	{
		[self removeRenderer:[renderers lastObject]];
	}
}

- (void) onTouchDown:(PXTouchEvent *)event
{
}

- (void) onTouchMove:(PXTouchEvent *)event
{
}

- (void) onTouchUp:(PXTouchEvent *)event
{
}

- (void) onTouchCancel:(PXTouchEvent *)event
{
}

@end
