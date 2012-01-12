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

#import "PKParticleEffect.h"

#import "PKParticleEmitter.h"
#import "PKParticleInitializer.h"
#import "PKParticleAction.h"
#import "PKParticleRenderer.h"
#import "PKParticleEffectLoader.h"
#import "PKParticleEffectParser.h"

#import "PKSteadyFlow.h"

/**
 * Encapsulates all of the data needed to create a single particle effect.
 * Namely a #PKParticleEmitter and a #PKParticleRenderer.
 *
 * An effect can be constructed in real-time by the user, or loaded from an
 * external file. It can also be a mix of both, but that's rarely necessary.
 *
 * To load a particle effect from file you can use the
 * [PKParticleEffect particleEffectWithContentsOfFile:] method or for more
 * control the #PKParticleEffectLoader class.
 *
 * PixelKit currently supports the following particle effect
 * file formats:
 * - .pex (Particle Designer xml with embedded image)
 * - .plist (Particle designer plist with external image)
 */
@implementation PKParticleEffect

@synthesize particleFactory;
@synthesize initializers;
@synthesize actions;

#pragma mark -
#pragma mark Initialization
#pragma mark -

- (id) init
{
	self = [super init];

	if (self)
	{
		initializers = [[PXLinkedList alloc] init];
		actions = [[PXLinkedList alloc] init];
	}

	return self;
}

- (id) initWithContentsOfFile:(NSString *)path
{
	return [self initWithContentsOfFile:path premultiplyAlpha:YES];
}

- (id) initWithContentsOfFile:(NSString *)path premultiplyAlpha:(BOOL)premultiply
{
	[self release];
	PKParticleEffectLoader *loader = [[PKParticleEffectLoader alloc] initWithContentsOfFile:path premultiplyAlpha:premultiply];
	self = [loader newParticleEffect];
	return self;
}

- (id) initWithContentsOfURL:(NSURL *)url
{
	return [self initWithContentsOfURL:url premultiplyAlpha:YES];
}

- (id) initWithContentsOfURL:(NSURL *)url premultiplyAlpha:(BOOL)premultiply
{
	[self release];
	PKParticleEffectLoader *loader = [[PKParticleEffectLoader alloc] initWithContentsOfURL:url premultiplyAlpha:premultiply];
	self = [loader newParticleEffect];
	return self;
}

- (id) initWithData:(NSData *)data
{
	return [self initWithData:data premultiplyAlpha:YES];
}

- (id) initWithData:(NSData *)data premultiplyAlpha:(BOOL)premultiply
{
	[self release];
	PKParticleEffectParser *parser = [[PKParticleEffectParser alloc] initWithData:data origin:nil premultiplyAlpha:premultiply];
	self = [parser newParticleEffect];
	return self;
}

- (void) dealloc
{
	[initializers release];
	initializers = nil;

	[actions release];
	actions = nil;

	self.particleFactory = nil;

	[super dealloc];
}

#pragma mark -
#pragma mark Addition
#pragma mark -

- (void) addInitializer:(id<PKParticleInitializer>) initializer
{
	[self.initializers addObject:initializer];
}

- (void) addAction:(id<PKParticleAction>) action
{
	[self.actions addObject:action];
}

#pragma mark -
#pragma mark Generation
#pragma mark -

- (PKParticleEmitter *)spawnEmitter
{
	PKParticleEmitter *emitter = [self _newEmitter];
	id<PKParticleFlow> flow = [self _newFlow];

	emitter.flow = flow;
	[flow release];

	if (particleFactory)
	{
		emitter.particleFactory = particleFactory;
	}

	for (id<PKParticleInitializer> initializer in initializers)
	{
		[emitter addInitializer:initializer];
	}

	for (id<PKParticleAction> action in actions)
	{
		[emitter addAction:action];
	}

	return [emitter autorelease];
}

- (id<PKParticleRenderer>)spawnRenderer
{
	return [[self _newRenderer] autorelease];
}

- (id<PKParticleRenderer>)spawnRendererContainingEmitter:(PKParticleEmitter **)outEmitterPtr
{
	id<PKParticleRenderer> renderer = [self _newRenderer];
	PKParticleEmitter *emitter = [self spawnEmitter];
	[renderer addEmitter:emitter];

	if (outEmitterPtr)
		*outEmitterPtr = emitter;

	[(id<NSObject>)renderer autorelease];

	return renderer;
}

#pragma mark -
#pragma mark Override Methods
#pragma mark -

- (id <PKParticleFlow>)_newFlow
{
	return nil;
}

- (PKParticleEmitter *)_newEmitter
{
	return [[PKParticleEmitter alloc] init];
}

- (id<PKParticleRenderer>)_newRenderer
{
	return nil;
}

#pragma mark -
#pragma mark Static Methods
#pragma mark -

+ (PKParticleEffect *)particleEffectWithContentsOfFile:(NSString *)path
{
	return [[[PKParticleEffect alloc] initWithContentsOfFile:path] autorelease];
}

+ (PKParticleEffect *)particleEffectWithContentsOfFile:(NSString *)path premultiplyAlpha:(BOOL)premultiply
{
	return [[[PKParticleEffect alloc] initWithContentsOfFile:path premultiplyAlpha:premultiply] autorelease];
}

+ (PKParticleEffect *)particleEffectWithContentsOfURL:(NSURL *)url
{
	return [[[PKParticleEffect alloc] initWithContentsOfURL:url] autorelease];
}

+ (PKParticleEffect *)particleEffectWithContentsOfURL:(NSURL *)url premultiplyAlpha:(BOOL)premultiply
{
	return [[[PKParticleEffect alloc] initWithContentsOfURL:url premultiplyAlpha:premultiply] autorelease];
}

+ (PKParticleEffect *)particleEffectWithData:(NSData *)data
{
	return [[[PKParticleEffect alloc] initWithData:data] autorelease];
}

+ (PKParticleEffect *)particleEffectWithData:(NSData *)data premultiplyAlpha:(BOOL)premultiply
{
	return [[[PKParticleEffect alloc] initWithData:data premultiplyAlpha:premultiply] autorelease];
}

@end
