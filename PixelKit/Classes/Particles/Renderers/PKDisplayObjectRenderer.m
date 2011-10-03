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

#import "PKDisplayObjectRenderer.h"
#import "PKParticle.h"
#import "PKParticleEmitter.h"

#include "PXPrivateUtils.h"
#include "PXMathUtils.h"

@interface PKDisplayObjectRenderer (Private)
- (void) renderParticles:(PXArrayBuffer *)particles;
@end

@implementation PKDisplayObjectRenderer

- (id) init
{
    self = [super init];

    if (self)
	{
		[self addEventListenerOfType:PXEvent_Render listener:PXListener(onRender:)];
    }

    return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void) onRender:(PXEvent *)event
{
	for (PKParticleEmitter *emitter in emitters)
	{
		[self renderParticles:emitter.particles];
	}
}

#pragma mark -
#pragma Delegate methods
#pragma mark -

- (void) particleEmitter:(PKParticleEmitter *)emitter didCreateParticle:(PKParticle *)particle
{
	PXDisplayObject *displayObject = particle->graphic;

	[self addChild:displayObject];

	displayObject.x = particle->x;
	displayObject.y = particle->y;
}

- (void) particleEmitter:(PKParticleEmitter *)emitter didDestroyParticle:(PKParticle *)particle
{
	[self removeChild:(PXDisplayObject *)(particle->graphic)];
}

- (void) particleEmitter:(PKParticleEmitter *)emitter didUpdateWithDeltaTime:(float)deltaTime
{
	// Tell Pixelwave to dispatch a render event the next time it renders
	[self.stage invalidate];
}

#pragma mark -
#pragma Rendering
#pragma mark -

- (void) renderParticles:(PXArrayBuffer *)particles
{
	PXGLColorTransform *colorTransform;

	PXDisplayObject *displayObject;
	PKParticle *particle;

	PXArrayBufferPtrForEach(particles, particle)
	{
		displayObject = particle->graphic;
		
		if (!displayObject)
		{
			NSLog(@"No display object in particle");
			continue;
		}

		displayObject.x = particle->x;
		displayObject.y = particle->y;

		displayObject.scaleX = particle->scaleX;
		displayObject.scaleY = particle->scaleY;

		displayObject.rotation = PXMathToDeg(particle->rotation);

		colorTransform = &(displayObject->_colorTransform);

		colorTransform->redMultiplier   = PX_COLOR_BYTE_TO_FLOAT(particle->r);
		colorTransform->greenMultiplier = PX_COLOR_BYTE_TO_FLOAT(particle->g);
		colorTransform->blueMultiplier  = PX_COLOR_BYTE_TO_FLOAT(particle->b);
		colorTransform->alphaMultiplier = PX_COLOR_BYTE_TO_FLOAT(particle->a);
	}
}

- (BOOL) isCapableOfRenderingGraphicOfType:(Class)graphicType
{
	return [graphicType isSubclassOfClass:[PXDisplayObject class]];
}

+ (PKDisplayObjectRenderer *)displayObjectRenderer
{
	return [[[PKDisplayObjectRenderer alloc] init] autorelease];
}

@end
