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

#import "PKSharedDisplayObjectRenderer.h"

#import "PXEngine.h"
#import "PXLinkedList.h"

#import "PKParticle.h"

#include "PXPrivateUtils.h"

@implementation PKSharedDisplayObjectRenderer

@synthesize displayObject;

- (id) initWithDisplayObject:(PXDisplayObject *)_displayObject
{
	self = [super init];

	if (self)
	{
		self.displayObject = _displayObject;
	}

	return self;
}

- (void) dealloc
{
	self.displayObject = nil;

	[super dealloc];
}

- (void) _renderGL
{
	if (!displayObject)
		return;

	// Keep the old values of the display object so we can put them back when we
	// are done.
	PXGLMatrix oldMatrix = displayObject->_matrix;
	PXGLMatrix newMatrix;
	PXGLColorTransform oldColorTransform = displayObject->_colorTransform;
	PXGLColorTransform newColorTransform;
	PKParticle *particle;

	CGSize doSize = CGSizeMake(displayObject.width, displayObject.height);

	// Half the size of the display object... so we can center it.
	CGSize doHalfSize = CGSizeMake(doSize.width  * 0.5f, doSize.height * 0.5f);

	// The current emitter.
	PKParticleEmitter *emitter;

	PXArrayBuffer *particles;

	// Loop through each emitter drawing the display object with their particle
	// values.
	PXLinkedListForEach(emitters, emitter)
	{
		particles = emitter.particles;

		PXArrayBufferPtrForEach(particles, particle)
		{
			// Set the blend function
			PXGLBlendFunc(particle->blendSource, particle->blendDestination);

			// Reset the matrix
			PXGLMatrixIdentity(&newMatrix);
			// Translate it back half, so we center it around 0.0
			PXGLMatrixTranslate(&newMatrix, -(doHalfSize.width), -(doHalfSize.height));

			// Transform by rotating, scaling then translating.
			PXGLMatrixTransform(&newMatrix,
								particle->rotation,
								particle->scaleX, particle->scaleY,
								particle->x, particle->y);

			// Get the color transform.
			newColorTransform = PXGLColorTransformMake(PX_COLOR_BYTE_TO_FLOAT(particle->r),
													   PX_COLOR_BYTE_TO_FLOAT(particle->g),
													   PX_COLOR_BYTE_TO_FLOAT(particle->b),
													   PX_COLOR_BYTE_TO_FLOAT(particle->a));

			// Set the values
			displayObject->_colorTransform = newColorTransform;
			displayObject->_matrix = newMatrix;

			// Render the display object.
			PXEngineRenderDisplayObject(displayObject, YES, NO);
		}
	}

	// Set the values back to what they were.
	displayObject->_colorTransform = oldColorTransform;
	displayObject->_matrix = oldMatrix;
}

+ (PKSharedDisplayObjectRenderer *)sharedDisplayObjectRendererWithDisplayObject:(PXDisplayObject *)displayObject
{
	return [[[PKSharedDisplayObjectRenderer alloc] initWithDisplayObject:displayObject] autorelease];
}

@end
