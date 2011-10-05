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

#import "PKParticleEmitter.h"

#import "PKParticleFlow.h"
#import "PKParticleFactory.h"
#import "PKParticleInitializer.h"
#import "PKParticleAction.h"
#import "PKParticle.h"
#import "PKParticleRenderer.h"
#import "PKGraphicInitializer.h"

#import "PKFrameTimer.h"
#import "PKFrameTimerEvent.h"

#import "PKParticleCreator.h"

#import "PXLinkedList.h"
#import "PXMathUtils.h"
#import "PXDebug.h"

static unsigned int pkParticleEmitterNameCount = 0;
static id<PKParticleFactory> pkParticleEmitterDefaultFactory = nil;

bool PKParticleEmitterDeleteCheckFunction(PXArrayBuffer *buffer, void *element, void *userData);
void PKParticleUpdateFunction(PXArrayBuffer *buffer, void *element, void *userData);

@interface PKParticleEmitter(Private)
- (void) createParticles:(unsigned int)count;
- (void) destroyParticle:(PKParticle *)particle;
- (void) validateGraphicTypes;
- (id<PKGraphicInitializer>) anyGraphicInitializer;
@end

/**
 * The particle emitter is in charge of creating, updating, and destroying
 * particles.
 *
 * factory
 * flow
 * Initializers
 * Actions
 * Starting/stopping
 * Updating (manual/automatic)
 * Runahead
 * Rendering
 */
@implementation PKParticleEmitter

@synthesize name;

@synthesize renderer;
@synthesize delegate;

@synthesize particleFactory;

@synthesize flow;

@synthesize particles;

@synthesize x;
@synthesize y;

@synthesize rotation;

@synthesize started;
@synthesize running;

/**
 * A single, shared #PKParticleCreator factory which produces instances of
 * #PXParticle. This is the default factory used by any #PXParticleEmitter
 * unless a different one is set. The advantage of using the default factory is
 * that it allows for all emitters which use it to access the same pool of
 * particles, making efficient use of memory.
 */
+ (id<PKParticleFactory>) defaultParticleFactory
{
	if (!pkParticleEmitterDefaultFactory)
	{
		pkParticleEmitterDefaultFactory = [[PKParticleCreator alloc] init];
	}

	return pkParticleEmitterDefaultFactory;
}

- (id) init
{
	self = [super init];

	if (self)
	{
		name = [[NSString alloc] initWithFormat:@"%u", (pkParticleEmitterNameCount++)];

		particles = PXArrayBufferCreate();
		PXArrayBufferSetElementSize(particles, sizeof(id *));

		initializers = [[PXLinkedList alloc] init];
		_actions = [[PXLinkedList alloc] init];

		self.particleFactory = [PKParticleEmitter defaultParticleFactory];
	}

	return self;
}

- (void) dealloc
{
	[self stop];

	[self removeAllParticles];
	PXArrayBufferRelease(particles);
	particles = NULL;

	[self removeAllInitializers];
	[initializers release];
	initializers = nil;

	[self removeAllActions];
	[_actions release];
	_actions = nil;

	renderer = nil;
	delegate = nil;

	self.particleFactory = nil;

	[name release];

	[super dealloc];
}

- (float)rotation
{
	return PXMathToDeg(rotation);
}

- (void)setRotation:(float)value
{
	rotation = PXMathToRad(value);
}

- (void) _setRender:(id<PKParticleRenderer>)_renderer
{
	renderer = _renderer;

	[self validateGraphicTypes];
}

/**
 * Removes each living particle from the emitter and returns it to the emitter's
 * #particleFactory.
 *
 * Calling this method sends the appropriate messages to the #delegate if one is
 * available.
 */
- (void) removeAllParticles
{
	if (particles == NULL)
		return;

	PKParticle *particle;

	PXArrayBufferPtrForEach(particles, particle)
	{
		[self destroyParticle:particle];
	}

	PXArrayBufferUpdateCount(particles, 0);
}

- (unsigned int) numParticles
{
	if (particles == NULL)
		return 0;

	return PXArrayBufferCount(particles);
}

- (void)setParticleFactory:(id<PKParticleFactory>)value
{
	if (particles != NULL && PXArrayBufferCount(particles) > 0)
	{
		PXDebugLog(@"PKParticleEmitter: the particle factory cannot be changed while particle exist in the emitter");
	}
	
	[value retain];
	[particleFactory release];
	particleFactory = value;
}

/**
 * Adds an initializer to the emitter's collection. Inititalizers are executed
 * on the emitter's particles as they are created, in the order in which the
 * initializers were added.
 *
 * This method will fail if the emitter currently holds any living particles.
 * It's advised to add all initializers to an emitter before starting it.
 *
 * @param initializer the initializer to add.
 *
 * @see PKParticleInitializer
 */
- (void) addInitializer:(id<PKParticleInitializer>)initializer
{
	if ([self hasInitializer:initializer] == YES)
	{
		return;
	}

	if (particles != NULL && PXArrayBufferCount(particles) > 0)
	{
		PXDebugLog(@"PKParticleEmitter: initializers cannot be added while particles exist in the emitter");
	}
	else
	{
		if ([initializer conformsToProtocol:@protocol(PKGraphicInitializer)])
		{
			// If there's already a graphic initializer, let's warn the user
			// that it's not advised

			id<PKGraphicInitializer> graphicInitializer = [self anyGraphicInitializer];

			if (graphicInitializer != nil)
			{
				PXDebugLog(@"PXParticleEmitter (\"%@\"): Warning! This emitter already contains a GraphicInitializer (%@). It's not advised to have more than one graphic initializer within an emitter.",
					  name,
					  NSStringFromClass([graphicInitializer class]));
			}
		}

		[initializers addObject:initializer];

		if ([initializer respondsToSelector:@selector(addedToEmitter:)])
		{
			[initializer addedToEmitter:self];
		}

		[self validateGraphicTypes];
	}
}

/**
 * Removes an initializer to the emitter's collection.
 *
 * This method will fail if the emitter currently holds any living particles.
 *
 * @param initializer the initializer to remove.
 *
 * @see PKParticleInitializer
 */
- (void) removeInitializer:(id<PKParticleInitializer>)initializer
{
	if ([self hasInitializer:initializer] == NO)
	{
		return;
	}

	if (particles != NULL && PXArrayBufferCount(particles) > 0)
	{
		PXDebugLog(@"PKParticleEmitter: initializers cannot be removed while particles exist in the emitter");
		return;
	}

	if ([initializer respondsToSelector:@selector(removedFromEmitter:)])
	{
		[initializer removedFromEmitter:self];
	}

	[initializers removeObject:initializer];
}

/**
 * Removes all the initializers from the emitter's collection.
 *
 * If the emitter contains any living particles this method will fail. To
 * completely stop the emitter use the #stop method.
 */
- (void) removeAllInitializers
{
	if (particles != NULL && PXArrayBufferCount(particles) > 0)
	{
		PXDebugLog(@"PKParticleEmitter: initializers cannot be removed while particles exist in the emitter");
		return;
	}

	PXLinkedList *retainList = [[PXLinkedList alloc] init];
	[retainList addObjectsFromList:initializers];

	for (id initializer in retainList)
	{
		[self removeInitializer:initializer];
	}

	[retainList release];
}

/**
 * Checks if the given initializer exists within the emitter.
 *
 * @see PKParticleInitializer
 */
- (BOOL) hasInitializer:(id<PKParticleInitializer>)initializer
{
	return [initializers containsObject:initializer];
}

/**
 * Checks if any of the initializers in the emitter are of the given type.
 *
 * @see PKParticleInitializer
 */
- (BOOL) hasInitializerOfType:(Class)initializerType
{
	for (id initializer in initializers)
	{
		if ([initializer class] == initializerType)
			return YES;
	}

	return NO;
}

/**
 * Adds an action to the emitter's collection. Actions are executed on the
 * emitter's particles every frame in the order in which they were added.
 *
 * @param action the action to add.
 *
 * @see PKParticleAction
 */
- (void) addAction:(id<PKParticleAction>)action
{
	if ([self hasAction:action] == YES)
	{
		return;
	}

	[_actions addObject:action];

	if ([action respondsToSelector:@selector(addedToEmitter:)])
	{
		[action addedToEmitter:self];
	}
}

/**
 * Removes an action from the emitter's collection.
 *
 * @see PKParticleAction
 */
- (void) removeAction:(id<PKParticleAction>)action
{
	if ([self hasAction:action] == NO)
	{
		return;
	}

	if ([action respondsToSelector:@selector(action:)])
	{
		[action removedFromEmitter:self];
	}

	[_actions removeObject:action];
}

/**
 * Removes all the actions from the emitter's collection.
 */
- (void) removeAllActions
{
	PXLinkedList *retainList = [[PXLinkedList alloc] init];
	[retainList addObjectsFromList:_actions];

	for (id action in retainList)
	{
		[self removeAction:action];
	}

	[retainList release];
}

/**
 * Checks if the given action exists within the emitter.
 *
 * @see PKParticleAction
 */
- (BOOL) hasAction:(id<PKParticleAction>)action
{
	return [_actions containsObject:action];
}

/**
 * Checks if any of the action in the emitter are of the given type.
 *
 * @see PKParticleAction
 */
- (BOOL) hasActionOfType:(Class)actionType
{
	for (id action in _actions)
	{
		if ([action class] == actionType)
			return YES;
	}

	return NO;
}

/**
 * Starts the emitter's internal timer, causing is to update itself
 * automatically until #stop or #paused are called.
 *
 * When the emitter updates itself, calling #updateWithDeltaTime: explicitly
 * isn't necessary.
 */
- (void) start
{
	if (started == YES)
		return;

	started = YES;

	[self createParticles:[flow startWithEmitter:self]];

	[self resume];
}

/**
 * Starts the emitter after it's been paused.
 */
- (void) resume
{
	if (running == YES)
		return;

	running = YES;

	[[PKFrameTimer sharedFrameTimer] addEventListenerOfType:PKFrameTimerEvent_Tick listener:PXListener(onTick:)];
}

/**
 * Paused the emitter, causing all the particles to freeze in place, and all
 * particle emitting to stop.
 *
 * To resume, call the #resume method.
 */
- (void) pause
{
	if (running == NO)
		return;

	running = NO;

	[[PKFrameTimer sharedFrameTimer] removeEventListenerOfType:PKFrameTimerEvent_Tick listener:PXListener(onTick:)];
}

/**
 * Stops the emitter, destroying all of its living particles.
 */
- (void) stop
{
	if (started == NO)
		return;

	started = NO;

	[self pause];
	[self removeAllParticles];
}

- (void) onTick:(PKFrameTimerEvent *)event
{
	if (running == NO)
		return;

	float dt = event.deltaTime;

	// Clamp the delta time from 0.0 to 1.0 seconds (no less than 1 fps).
	PXMathClamp(dt, 0.0f, 1.0f);

	float frameRate = [PXStage mainStage].frameRate;
	dtAccum += dt;
	float desiredDT = 1.0f / frameRate;

	int updateCount = roundf(dtAccum / desiredDT);
	if (updateCount <= 0)
	{
		// This should never happen.
		updateCount = 0;
		dtAccum = 0.0f;
	}
	else
		dtAccum -= updateCount * desiredDT;

//	if (updateCount > 1 && frameRate > 59.0f)
//	{
//		updateCount >>= 1;
//		desiredDT *= 2.0f;
//	}

	for (int index = 0; index < updateCount; ++index)
	{
		[self updateWithDeltaTime:desiredDT];
	}
}

/**
 * This is equivelant to running #runAheadWithDuration:frameRate with a
 * frameRate of 10.
 *
 * @see #runAheadWithDuration:frameRate
 */
- (void) runAheadWithDuration:(float)duration
{
	[self runAheadWithDuration:duration frameRate:10.0f];
}

/**
 * Fast forwards the emitter the specified amount of time.
 *
 * This is useful when it's necessary for a particle effect to start out as if
 * it's been running for a few seconds. Note that this method actually simulates
 * all the particles forward one frame at a time, so it could get slow for
 * longer durations / higher frame rates.
 *
 * @param duration The amount of time, in seconds, to fast forward the emitter
 * @param frameRate The framerate at which to simulate the emitter while fast
 * forwarding.
 */
- (void) runAheadWithDuration:(float)duration frameRate:(float)frameRate
{
	if (PXMathIsZero(duration) == YES)
		return;

	BOOL isFlowing = flow.running;

	if (isFlowing == NO)
	{
		[self createParticles:[flow startWithEmitter:self]];
		[flow resume];
	}

	float desiredDT = 1.0f / frameRate;

	unsigned int updateCount = fabsf((duration < 0.0f) ? floorf(duration / desiredDT) : ceilf(duration / desiredDT));

	for (unsigned int index = 0; index < updateCount; ++index)
	{
		[self updateWithDeltaTime:desiredDT];
	}

	if (isFlowing == NO)
	{
		[flow pause];
	}
}

- (void) createParticles:(unsigned int)count
{
	if (count == 0)
		return;

	PKParticle *particle;
	id<PKParticleInitializer> initializer;

	id *idPtr = NULL;

	for (unsigned int index = 0; index < count; ++index)
	{
		// Ask the creator to make a particle for us
		if (idPtr == NULL)
		{
			idPtr = PXArrayBufferNext(particles);
		}

		if (idPtr == NULL)
			break;

		*idPtr = NULL;

		particle = [particleFactory newParticle];

		if (particle != nil)
		{
			[self initializeParticle:particle];
			
			PXLinkedListForEach(initializers, initializer)
			{
				[initializer initializeParticle:particle emitter:self];
			}

			if (particle->isExpired == NO)
			{
				id<PKParticleAction> action;

				PXLinkedListForEach(_actions, action)
				{
					[action updateParticle:particle emitter:self deltaTime:0.0f];
				}
			}

			if (particle->isExpired)
			{
				id<PKParticleInitializer> initializer;

				PXLinkedListForEach(initializers, initializer)
				{
					[initializer disposeParticle:particle emitter:self];
				}

				[particleFactory returnParticle:particle];
			}
			else
			{
				// Tell everyone about it
				[renderer particleEmitter:self didCreateParticle:particle];
				[delegate particleEmitter:self didCreateParticle:particle];

				*idPtr = particle;
				idPtr = NULL;
			}
		} // end of if (particle != nil)
	} // end for

	if (idPtr != NULL)
	{
		unsigned int newCount = PXArrayBufferCount(particles);

		if (newCount > 0)
		{
			newCount -= 1;
			PXArrayBufferUpdateCount(particles, newCount);
		}
	}
}

/**
 * The emitter's main loop. This method updates all of the particles in the
 * emitter and creates / removes particles if necessary.
 *
 * You should only call this method if you'd like to run your own simulation
 * loop. If you prefer to let the emitter update itself you should use the
 * #start, #pause, and #resume methods.
 *
 * @see #start
 * @see #pause
 * @see #resume
 */
- (void) updateWithDeltaTime:(float)dt
{
	_currentDT = dt;

	// Ask the flow how many particles to create
	unsigned int particleCount = 0;
	if ([flow complete] == NO)
	{
		particleCount = [flow updateWithEmitter:self deltaTime:dt];
	}

	[self createParticles:particleCount];

	if (PXArrayBufferCount(particles) > 0)
	{
		// PERFORM ALL ACTIONS - Update all the particles' states
		PXArrayBufferListUpdate(particles, self, PKParticleEmitterDeleteCheckFunction, PKParticleUpdateFunction);
	}
	else
	{
		[delegate particleEmitterIsEmpty:self];
	}

	[renderer particleEmitter:self didUpdateWithDeltaTime:dt];
	[delegate particleEmitter:self didUpdateWithDeltaTime:dt];

	if ([flow complete] == YES && PXArrayBufferCount(particles) == 0)
	{
		[delegate particleEmitter:self flowDidComplete:flow];
	}
}

- (void) initializeParticle:(PKParticle *)particle
{
	particle->x = x;
	particle->y = y;

	particle->rotation = rotation;
}

- (void) destroyParticle:(PKParticle *)particle
{
	// Call the renderer and delegate first because the initializer can set the
	// graphic to nil, which they may need.
	[renderer particleEmitter:self didDestroyParticle:particle];
	[delegate particleEmitter:self didDestroyParticle:particle];

	id<PKParticleInitializer> initializer;

	PXLinkedListForEach(initializers, initializer)
	{
		[initializer disposeParticle:particle emitter:self];
	}

	[particleFactory returnParticle:particle];
}

- (id<PKGraphicInitializer>) anyGraphicInitializer
{
	for (id<PKParticleInitializer> initializer in initializers)
	{
		if ([initializer conformsToProtocol:@protocol(PKGraphicInitializer)])
		{
			return (id<PKGraphicInitializer>)initializer;
		}
	}
	
	return nil;
}

/*
 * Check to see if the current graphic initializers align with the renderer's
 * requirements.
 */
- (void) validateGraphicTypes
{
	if (renderer == nil)
		return;

	id<PKGraphicInitializer> graphicInitializer = [self anyGraphicInitializer];

	if (!graphicInitializer)
		return;

	Class graphicType = [graphicInitializer graphicType];

	if ([renderer isCapableOfRenderingGraphicOfType:graphicType] == NO)
	{
		PXDebugLog(@"PXParticleEmitter (\"%@\"): Warning! Renderer of type %@ isn't capable of rendering particles with a graphic of type %@ (from GraphicInitializer of type %@)",
				   name,
				   NSStringFromClass([renderer class]),
				   NSStringFromClass(graphicType),
				   NSStringFromClass([graphicInitializer class]));
	}
}

/**
 * 
 */
+ (PKParticleEmitter *)particleEmitter
{
	return [[[PKParticleEmitter alloc] init] autorelease];
}

@end

bool PKParticleEmitterDeleteCheckFunction(PXArrayBuffer *buffer, void *element, void *userData)
{
	PKParticle *particle = *((void **)(element));
	PKParticleEmitter *emitter = userData;

	if (particle != nil)
	{
		if (particle->isExpired == false)
		{
			return false;
		}
	}

	[emitter destroyParticle:particle];

	return true;
}

void PKParticleUpdateFunction(PXArrayBuffer *buffer, void *element, void *userData)
{
	PKParticleEmitter *emitter = userData;
	id<PKParticleAction> action;
	PXLinkedList *actions = emitter->_actions;
	PKParticle *particle = *((void **)(element));

	PXLinkedListForEach(actions, action)
	{
		[action updateParticle:particle emitter:emitter deltaTime:emitter->_currentDT];
	}

	particle->wasJustCreated = NO;
}
