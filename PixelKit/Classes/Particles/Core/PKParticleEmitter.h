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

#import "PXArrayBuffer.h"

@protocol PKParticleFactory;
@protocol PKParticleFlow;
@protocol PKParticleInitializer;
@protocol PKParticleAction;
@protocol PKParticleRenderer;

@class PXLinkedList;

@class PKParticleEmitter;
@class PKParticle;

@protocol PKParticleEmitterDelegate
- (void) particleEmitter:(PKParticleEmitter *)emitter didCreateParticle:(PKParticle *)particle;
- (void) particleEmitter:(PKParticleEmitter *)emitter didDestroyParticle:(PKParticle *)particle;
- (void) particleEmitter:(PKParticleEmitter *)emitter didUpdateWithDeltaTime:(float)deltaTime;
- (void) particleEmitter:(PKParticleEmitter *)emitter flowDidComplete:(id<PKParticleFlow>)flow;
- (void) particleEmitterIsEmpty:(PKParticleEmitter *)emitter;
@end

@interface PKParticleEmitter : NSObject
{
@private
	NSString *name;

@public
	PXLinkedList *_actions;
	float _currentDT;

@protected
	// weak reference
	id<PKParticleRenderer> renderer;

	id<PKParticleEmitterDelegate> delegate;
	id<PKParticleFactory> particleFactory;

	PXArrayBuffer *particles;
	PXLinkedList *initializers;

	id<PKParticleFlow> flow;

	float dtAccum;

	// Attributes
	float x;
	float y;

	float rotation;

	BOOL running;
	BOOL started;
}

/**
 * A unique name assigned to this emitter.
 *
 * Note that the name is read-only. It can be used for
 * easily associating a particle to the emitter that
 * created it.
 */
@property (nonatomic, readonly) NSString *name;

/**
 * An optional delegate which can respond to the emitter's events.
 *
 * @see #PKParticleEmitterDelegate
 */
@property (nonatomic, assign) id<PKParticleEmitterDelegate> delegate;

/**
 * The renderer within which the emitter is currently living. `nil` if the
 * emitter isn't in any renderer.
 */
@property (nonatomic, readonly) id<PKParticleRenderer> renderer;

/**
 * The #PKParticleFactory which the emitter will use to create its #PKParticle
 * objects. One factory may be shared among several or all the emitters in your
 * application in order to make the best use of resources.
 */
@property (nonatomic, retain) id<PKParticleFactory> particleFactory;

/**
 * A #PKParticleFlow object responsible for controlling the flow at which
 * particles will be emitted from the emitter.
 */
@property (nonatomic, retain) id<PKParticleFlow> flow;

/**
 * A reference to all of the particles created by the emitter which are
 * currently living. Don't tweak the contents of this list unless you know
 * exactly what you're doing.
 */
@property (nonatomic, readonly) PXArrayBuffer *particles;

/**
 * The amount of particles created by the emitter that are currently living.
 */
@property (nonatomic, readonly) unsigned int numParticles;

/**
 * The default x position at which particles emitted by this emitter will be
 * created. This value can be changed at any time.
 *
 * The position of created particles can also be modified via initializers,
 * specifically the #PKPositionInitializer.
 */
@property (nonatomic, assign) float x;
/**
 * The default y position at which particles emitted by this emitter will be
 * created. This value can be changed at any time.
 *
 * The position of created particles can also be modified via initializers,
 * specifically the #PKPositionInitializer.
 */
@property (nonatomic, assign) float y;

/*
 * Defines the rotation of the emitter in degrees. The default value is `0.0`
 * and it grows in the clock-wise direction.
 *
 * The emitter's rotation directly affects the starting position and velocity of
 * all the particles it creates.
 */
@property (nonatomic, assign) float rotation;

/**
 * Specifies if `start` has been called on this emitter.
 */
@property (nonatomic, readonly) BOOL started;
/**
 * Specifies if this emitter is currently active or it has been paused. To check
 * if this emitter was ever started you can use the #started property.
 */
@property (nonatomic, readonly) BOOL running;

- (void) removeAllParticles;

- (void) addInitializer:(id<PKParticleInitializer>)initializer;
- (void) removeInitializer:(id<PKParticleInitializer>)initializer;
- (void) removeAllInitializers;
- (BOOL) hasInitializer:(id<PKParticleInitializer>)initializer;
- (BOOL) hasInitializerOfType:(Class)initializerType;

- (void) addAction:(id<PKParticleAction>)action;
- (void) removeAction:(id<PKParticleAction>)action;
- (void) removeAllActions;
- (BOOL) hasAction:(id<PKParticleAction>)action;
- (BOOL) hasActionOfType:(Class)actionType;

- (void) start;
- (void) resume;
- (void) pause;
- (void) stop;

- (void) runAheadWithDuration:(float)duration;
- (void) runAheadWithDuration:(float)duration frameRate:(float)frameRate;

- (void) updateWithDeltaTime:(float)dt;

+ (id<PKParticleFactory>) defaultParticleFactory;

+ (PKParticleEmitter *)particleEmitter;

@end

@interface PKParticleEmitter (PrivateButPublic)
- (void) _setRender:(id<PKParticleRenderer>)renderer;
@end

@interface PKParticleEmitter (Protected)
- (void) initializeParticle:(PKParticle *)particle;
@end
