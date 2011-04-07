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

#import "NewtonsCradleRoot.h"

#import "Box2D.h"
#import "PKBox2DDebugLayer.h"

#import "PXMathUtils.h"
#import "Box2DUtils.h"

#import "BodyAttacher.h"

// We consider these methods private
@interface NewtonsCradleRoot(Private)
- (void) createScene;
- (void) addConnectedDisplayObject:(PXDisplayObject *)displayObject atX:(float)x andY:(float)y;
@end

@implementation NewtonsCradleRoot

- (void) initializeAsRoot
{
	// Warm up the sound engine so that our first sound plays on time
	[PXSoundMixer warmUp];

	ceilingBody = nil;

	// Allocate a list to store our bodies and display objects
	bodyAttachers = [[PXLinkedList alloc] init];

	// Load a sound to play for collisons
	collisionSound = [[PXSound soundWithContentsOfFile:@"would.wav"] retain];

	// Setup the physics engine
	// Define some simulation parameters
	timeStep = 1.0f / self.stage.frameRate;

	// When Box2D steps, how many iterations (how much percision) do we want it
	// to go through.
	velocityIterations = 10;
	positionIterations = 10;

	// Define the force of gravity (in meters / second ^ 2)
	b2Vec2 gravity(0.0f, GRAVITY);

	// Should physics bodies sleep when not moving? Why not?
	bool doSleep = true;

	physicsWorld = new b2World(gravity, doSleep);
	physicsWorld->SetContinuousPhysics(true);

	// Zero out the callbacks
	destructionListener = NULL;
	contactListener = NULL;

	// If you want a destruction listener, un-comment these lines.
	//destructionListener = new DestructionListener();
	//physicsWorld->SetDestructionListener(destructionListener);

	// Add the contact listener so that when the balls collide we play a sound.
	contactListener = new ContactListener();
	physicsWorld->SetContactListener(contactListener);

	// Made a delegate for this sample as an example on how you could callback
	// functions in objective-c
	contactListener->delegate = self;

	// Set up the main loop
	[self addEventListenerOfType:PX_EVENT_ENTER_FRAME
						listener:PXListener(onFrame)];


	// Add a touch picker to grab the balls
	PKBox2DTouchPicker *touchPicker = [[PKBox2DTouchPicker alloc] initWithWorld:physicsWorld];
	touchPicker.scale = POINTS_PER_METER;
	[self addChild:touchPicker];
	[touchPicker release];

	// Populate the world
	[self createScene];
}

- (void) dealloc
{
	// Release the list
	[bodyAttachers release];

	// Unload all the listeners
	if (destructionListener)
	{
		physicsWorld->SetDestructionListener(NULL);

		delete destructionListener;
		destructionListener = NULL;
	}

	// Release the contact listener
	if (contactListener)
	{
		physicsWorld->SetContactListener(NULL);

		delete contactListener;
		contactListener = NULL;
	}

	// Cleaning up: Release retained objects, remove event listeners, etc.
	delete physicsWorld;
	physicsWorld = NULL;

	// Release the sound
	[collisionSound release];

	[super dealloc];
}

//////////////////////////
// Initialize the world //
//////////////////////////

- (void) createScene
{
	// Grab the size of the screen, half sizes are also useful
	float stageWidth  = self.stage.stageWidth;
	float stageHeight = self.stage.stageHeight;
	float stageWidth_2  = stageWidth  * 0.5f;
	float stageHeight_2 = stageHeight * 0.5f;

	// TODO: Oz, want to make a @2x version too, pweese?
	// Load the background
	PXTexture *backgroundTex = [PXTexture textureWithContentsOfFile:@"background.png"];
	[backgroundTex setAnchorWithX:0.5f andY:0.5f];
	backgroundTex.x = stageWidth_2;
	backgroundTex.y = stageHeight_2;
	[self addChild:backgroundTex];

	// Load the ball clacker pics
	PXTextureLoader *textureLoader = [[PXTextureLoader alloc] initWithContentsOfFile:@"Clacker.png"];
	PXTextureData *textureData = [textureLoader newTextureData];
	PXTexture *texture;

	// Create a body to have the balls hang from
	b2BodyDef bodyDef;
	ceilingBody = physicsWorld->CreateBody(&bodyDef);

	// The number of balls for the ball clicker
	unsigned ballCount = 5;

	// Set the size of balls to be pendant on the size of the stage (aka. they
	// will be bigger on the iPad)
	float radius = ceilf(self.stage.stageWidth * 0.07f);
	float spaceBetween = (radius * 2.0f) + 2;
	float xPos = (stageWidth * 0.5f) - (ballCount * radius) + radius;
	float stringLength = stageHeight * 0.6f;

	// Texture info...
	unsigned ballTextureSize = 304;
	unsigned short stringTextureWidth = 8;
	unsigned short stringTextureHeight = 352;

	// The scale of the texture so that it will be the size of the radius
	float ballTextureScale = (radius * 2.0f) / ((float)(ballTextureSize));

	// A sprite for each of the "ball and chains" and an attacher to hold them.
	PXSimpleSprite *simpleSprite;
	BodyAttacher *attacher;

	// A circle for the physics of the ball
	b2CircleShape circle;
	circle.m_radius = PointsToMeters(radius);
	circle.m_p.y = PointsToMeters(stringLength);

	// ... it will be dynamic
	bodyDef.type = b2_dynamicBody;

	// Setting the information of the balls.  Friction of 0 and high restitution
	// to simulate the ball clicker.
	b2FixtureDef fixtureDef;
	fixtureDef.friction = 0.0f;
	fixtureDef.restitution = 0.995f;

	// All dynamic objects need a density
	fixtureDef.density = 1.0f;

	b2Body *body;
	b2RevoluteJointDef jointDef;

	// Loop through and make each of the "ball and chains"
	unsigned index;
	for (index = 0; index < ballCount; ++index)
	{
		simpleSprite = [[PXSimpleSprite alloc] init];
		[self addChild:simpleSprite];
		[simpleSprite release];

		simpleSprite.x = xPos;
		simpleSprite.y = 0.0f;

		// Make a texture for the ball
		texture = [[PXTexture alloc] initWithTextureData:textureData];
		[simpleSprite addChild:texture];
		[texture release];

		// Set the area of the texture that the ball lives.
		[texture setClipRectWithX:0 andY:0 andWidth:ballTextureSize andHeight:ballTextureSize usingAnchorX:0.5f andAnchorY:0.5f];
		texture.x = 0.0f;
		texture.y = stringLength;
		texture.scale = ballTextureScale;
		texture.smoothing = YES;

		// Make a texture for the rope
		texture = [[PXTexture alloc] initWithTextureData:textureData];
		[simpleSprite addChild:texture];
		[texture release];

		// Set the area of the texture that the rope lives.
		[texture setClipRectWithX:512 - stringTextureWidth andY:0 andWidth:stringTextureWidth andHeight:stringTextureHeight usingAnchorX:0.5f andAnchorY:0.0f];
		texture.width = stringTextureWidth;
		texture.height = stringLength;
		texture.smoothing = YES;

		// Set the position of the body
		bodyDef.position = b2Vec2_px2m(xPos, 0.0f);

		body = [Box2DUtils bodyInWorld:physicsWorld
						   withBodyDef:&bodyDef
							fixtureDef:&fixtureDef
								shapes:&circle, nil];

		body->SetUserData(simpleSprite);

		// Make a revolute joint so the ball will rotate around
		jointDef.Initialize(ceilingBody, body, b2Vec2_px2m(simpleSprite.x, simpleSprite.y));
		jointDef.collideConnected = true;

		// Set the limits so that it doesn't go further then the ceiling
		jointDef.enableLimit = YES;
		jointDef.lowerAngle = PXMathToRad(-74.5f);
		jointDef.upperAngle = PXMathToRad( 74.5f);

		// Add the joint to the world
		physicsWorld->CreateJoint(&jointDef);

		// Make an attacher and set it's properties
		attacher = [[BodyAttacher alloc] init];
		[bodyAttachers addObject:attacher];
		[attacher release];

		attacher.body = body;
		attacher.displayObject = simpleSprite;

		// Iterate to the position of the next ball
		xPos += spaceBetween;
	}

	// Set a texture for the ceiling
	texture = [[PXTexture alloc] initWithTextureData:textureData];
	[self addChild:texture];
	[texture release];

	// Set the area of the texture that the ceiling lives.
	[texture setClipRectWithX:0 andY:384 andWidth:512 andHeight:128];

	texture.x = 0.0f;
	texture.y = (stageHeight * 0.05f) - texture.height;
	texture.width = stageWidth;

	[textureData release];
	[textureLoader release];
}

- (void) contactListener:(ContactListener *)listener
	  collisionWithBodyA:(b2Body *)bodyA
				andBodyB:(b2Body *)bodyB
		 withNormalForce:(float)normalForce
{
	// Cushion the volume
	float volume = (normalForce / GRAVITY);

	// Efficency addition, if the volume is less then 1 percent, ignore it.
	if (volume < 0.01f)
		return;

	// A small randomization of the pitch to make it sound cooler and slightly
	// 'unique' each time a ball collides.
	PXSoundTransform *soundTransform = [PXSoundTransform soundTransformWithVolume:volume
																		 andPitch:[PXMath randomFloatInRangeFrom:0.9f to:1.1f]];

	// Play the sound
	[collisionSound playWithStartTime:0 loopCount:0 soundTransform:soundTransform];
}

///////////////////
// The main loop //
///////////////////

- (void) onFrame
{
	physicsWorld->Step(timeStep, velocityIterations, positionIterations);

	// Update the attachers.
	BodyAttacher *bodyAttacher;
	for (bodyAttacher in bodyAttachers)
	{
		[bodyAttacher update];
	}
}

@end
