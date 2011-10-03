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

#import "PKParticleRendererBase.h"

#import "PXLinkedList.h"

/**
 * The base class for all particle renderers in PixelKit.
 */
@implementation PKParticleRendererBase

- (id) init
{
	self = [super init];

	if (self)
	{
		_renderMode = PXRenderMode_BatchAndManageStates;

		emitters = [[PXLinkedList alloc] init];
	}

	return self;
}

- (void) dealloc
{
	[self removeAllEmitters];
	[emitters release];

	[super dealloc];
}

- (void) addEmitter:(PKParticleEmitter *)emitter
{
	if (emitter == nil)
		return;

	if (emitter.renderer != nil)
	{
		[emitter.renderer removeEmitter:emitter];
	}

	[emitter _setRender:self];

	if ([emitters containsObject:emitter] == NO)
	{
		[emitters addObject:emitter];

		// Add all of the emitter's particles
		PKParticle *particle;

		PXArrayBufferPtrForEach(emitter.particles, particle)
		{
			[self particleEmitter:emitter didCreateParticle:particle];
		}
	}
}

- (void) removeEmitter:(PKParticleEmitter *)emitter
{
	// They can change the variable technically, so this is a must; we can not
	// compare against the variable. If it is in our list, we MUST remove it!
	if ([emitters containsObject:emitter] == NO)
		return;

	// Remove all of the emitter's particles
	PKParticle *particle;

	PXArrayBufferPtrForEach(emitter.particles, particle)
	{
		[self particleEmitter:emitter didDestroyParticle:particle];
	}

	[emitter _setRender:nil];

	[emitters removeObject:emitter];
}

- (void) removeAllEmitters
{
	PXLinkedList *copyList = [[PXLinkedList alloc] init];
	[copyList addObjectsFromList:emitters];

	for (PKParticleEmitter *emitter in copyList)
	{
		[self removeEmitter:emitter];
	}

	[copyList release];
}

- (void) particleEmitter:(PKParticleEmitter *)emitter didCreateParticle:(PKParticle *)particle
{
}

- (void) particleEmitter:(PKParticleEmitter *)emitter didDestroyParticle:(PKParticle *)particle
{
}

- (void) particleEmitter:(PKParticleEmitter *)emitter didUpdateWithDeltaTime:(float)deltaTime
{
}

- (void) particleEmitter:(PKParticleEmitter *)emitter flowDidComplete:(id<PKParticleFlow>)flow
{
}

- (void) particleEmitterIsEmpty:(PKParticleEmitter *)emitter
{
}

- (PXLinkedList *)emitters
{
	return emitters;
}

- (BOOL) isCapableOfRenderingGraphicOfType:(Class)graphicType
{
	return YES;
}

@end
