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

#import "PKRenderToTextureRenderer.h"

#import "PXEngine.h"

#import "PXStage.h"

#import "PXTexture.h"
#import "PXTextureData.h"

#import "PXEvent.h"

#import "PXColorTransform.h"

#include "PXMathUtils.h"

#import "PXDebug.h"

#import "PKFrameTimer.h"
#import "PKFrameTimerEvent.h"

@interface PKRenderToTextureRenderer(Private)
- (void) onTick:(PKFrameTimerEvent *)event;
@end

@implementation PKRenderToTextureRenderer

@synthesize renderer;

@synthesize trailFade;
@synthesize trail;

@synthesize clearBeforeRender;

- (id) init
{
	return [self initWithRenderer:nil];
}

- (id) initWithRenderer:(id<PKParticleRenderer>)_renderer
{
	self = [super init];

	if (self)
	{
		if (_renderer == nil)
		{
			PXDebugLog(@"PKRenderToTextureRenderer: parameter renderer must be non-nil");
			[self release];
			return nil;
		}

		if ([_renderer isKindOfClass:[PXDisplayObject class]] == NO)
		{
			PXDebugLog(@"PKRenderToTextureRenderer: parameter renderer must be a subclass of PXDisplayObject");
			[self release];
			return nil;
		}

		if ([_renderer emitters].count > 0)
		{
			PXDebugLog(@"PKRenderToTextureRenderer: parameter renderer must be empty");
			[self release];
			return nil;
		}

		renderer = [_renderer retain];

		PXStage *stage = [PXStage mainStage];
		float scale = stage.contentScaleFactor;

		PXTextureData *textureData = [[PXTextureData alloc] initWithWidth:stage.stageWidth  * scale
																   height:stage.stageHeight * scale
															 transparency:YES
																fillColor:0x00000000
													   contentScaleFactor:scale];

		texture = [[PXTexture alloc] initWithTextureData:textureData];
		[textureData release];

		[self addChild:texture];

		self.clearBeforeRender = YES;

		// Having a negative priority isn't actually necessary, what it does is
		// attempt to make sure the emitter updates prior to the renderer. If it
		// does, then we will be rendering the same frame that was just
		// calculated, otherwise we will be a frame behind.
		[[PKFrameTimer sharedFrameTimer] addEventListenerOfType:PKFrameTimerEvent_Tick listener:PXListener(onTick:) useCapture:NO priority:INT_MIN];
	}

	return self;
}

- (void) dealloc
{
	[[PKFrameTimer sharedFrameTimer] removeEventListenerOfType:PKFrameTimerEvent_Tick listener:PXListener(onTick:) useCapture:NO];

	[renderer release];
	renderer = nil;

	// Frees up memory
	self.trail = NO;

	[texture release];

	[super dealloc];
}

- (void) setTrail:(BOOL)_trail
{
	trail = _trail;

	if (trail == YES && backgroundTextureData == nil)
	{
		PXTextureData *textureData = texture.textureData;

		if (textureData == nil)
			return;

		backgroundTextureData = [[PXTextureData alloc] initWithWidth:textureData->_contentWidth
															  height:textureData->_contentHeight
														transparency:YES
														   fillColor:0x00000000
												  contentScaleFactor:textureData->_contentScaleFactor];
		backgroundTexture = [[PXTexture alloc] initWithTextureData:backgroundTextureData];
	}
	else if (trail == NO && backgroundTextureData != nil)
	{
		[backgroundTextureData release];
		backgroundTextureData = nil;
		[backgroundTexture release];
		backgroundTexture = nil;
	}
}

- (void) onFrame
{
	float dt = 1.0f / self.stage.frameRate;
	PKFrameTimerEvent *event = [[PKFrameTimerEvent alloc] initWithType:PKFrameTimerEvent_Tick deltaTime:dt];
	[self onTick:event];
	[event release];
}

- (void) onTick:(PKFrameTimerEvent *)event
{
	if (renderer == nil)
		return;

	PXTextureData *textureData = texture.textureData;

	if (clearBeforeRender == YES && trail == YES)
	{
		float dt = event.deltaTime;
		float alpha = powf(trailFade, dt);
		PXMathClamp(alpha, 0.0f, 1.0f);

		PXColorTransform *transform = [PXColorTransform colorTransformWithRedMult:1.0f greenMult:1.0f blueMult:1.0f alphaMult:alpha];
		[backgroundTextureData drawDisplayObject:texture matrix:nil colorTransform:transform clipRect:nil smoothing:YES clearTexture:YES];

		[textureData drawDisplayObject:backgroundTexture matrix:nil colorTransform:nil clipRect:nil smoothing:YES clearTexture:YES];

		[textureData drawDisplayObject:(PXDisplayObject *)renderer matrix:nil colorTransform:nil clipRect:nil smoothing:YES clearTexture:NO];
	}
	else
	{
		[textureData drawDisplayObject:(PXDisplayObject *)renderer matrix:nil colorTransform:nil clipRect:nil smoothing:YES clearTexture:clearBeforeRender];
	}
}

// Pass along

- (void) addEmitter:(PKParticleEmitter *)emitter
{
	[renderer addEmitter:emitter];
}

- (void) removeEmitter:(PKParticleEmitter *)emitter
{
	[renderer removeEmitter:emitter];
}

- (PXLinkedList *)emitters
{
	return renderer.emitters;
}

- (BOOL) isCapableOfRenderingGraphicOfType:(Class)graphicType
{
	return [renderer isCapableOfRenderingGraphicOfType:graphicType];
}

+ (PKRenderToTextureRenderer *)renderToTextureRendererWithRenderer:(id<PKParticleRenderer>)renderer
{
	return [[[PKRenderToTextureRenderer alloc] initWithRenderer:renderer] autorelease];
}

@end
