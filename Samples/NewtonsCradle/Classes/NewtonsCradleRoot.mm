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

#import "Globals.h"

#import "Box2D.h"
#import "PKBox2DDebugLayer.h"

#import "PXMathUtils.h"
#import "Box2DUtils.h"

#import "BodyAttacher.h"

#import "CradleItemSprite.h"
#import "CradleItemShadowSprite.h"

// We consider these methods private
@interface NewtonsCradleRoot(Private)
- (void) createScene;

- (void) onTap:(PXTouchEvent *)event;
- (void) resetScene;
- (void) updateAttachers;

- (void) onPickStart:(PKBox2DTouchPickerEvent *)event;
- (void) onPickEnd:(PKBox2DTouchPickerEvent *)event;

@end

@implementation NewtonsCradleRoot

- (void) initializeAsRoot
{
	initGlobals();
	
	// Warm up the sound engine so that our first sound plays on time
	[PXSoundMixer warmUp];
	
	// Allocate a list to store our bodies and display objects
	bodyAttachers = [[PXLinkedList alloc] init];

	// Load a sound to play for collisons
	collisionSound = [[PXSound soundWithContentsOfFile:@"wood.wav"] retain];
	
	// Setup the physics engine
	// Define some simulation parameters
	timeStep = 1.0f / self.stage.frameRate;

	// When Box2D steps, how many iterations (how much percision) do we want it
	// to go through.
	velocityIterations = 10;
	positionIterations = 10;

	// Set up the Box2D world
	b2Vec2 gravity(0.0f, GRAVITY);
	bool doSleep = true;

	physicsWorld = new b2World(gravity, doSleep);
	physicsWorld->SetContinuousPhysics(true);
	
	// Add the contact listener so that when the balls collide we play a sound.
	contactListener = new ContactListener();
	physicsWorld->SetContactListener(contactListener);
	contactListener->delegate = self;
	
	// Add a touch picker to allow the user to grab the objects.
	touchPicker = [[PKBox2DTouchPicker alloc] initWithWorld:physicsWorld];
	touchPicker.scale = POINTS_PER_METER;
	
	[touchPicker addEventListenerOfType:PKBox2DTouchPickerEvent_PickStart listener:PXListener(onPickStart:)];
	[touchPicker addEventListenerOfType:PKBox2DTouchPickerEvent_PickEnd listener:PXListener(onPickEnd:)];
	
	[self addChild:touchPicker];
	[touchPicker release];
	
	// Populate the world
	[self createScene];
	[self updateAttachers];
	
	// Listen to tap events so the user can reset the scene
	// by double tapping
	[self.stage addEventListenerOfType:PXTouchEvent_Tap listener:PXListener(onTap:)];
	
	// Set up the main loop
	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame)];
}

- (void) dealloc
{
	// Cleaning up: Release retained objects, remove event listeners, etc.
	
	[bodyAttachers release];
	
	if (contactListener)
	{
		physicsWorld->SetContactListener(NULL);

		delete contactListener;
		contactListener = NULL;
	}

	delete physicsWorld;
	physicsWorld = NULL;
	
	delete[] ballBodies;
	ballBodies = NULL;

	// Release the sound
	[collisionSound release];

	[super dealloc];
}

//////////////////////////
// Initialize the world //
//////////////////////////

- (void) createScene
{
	// Grab the size of the screen.
	float stageWidth  = self.stage.stageWidth;
	
	//////////////
	// Graphics //
	//////////////
	
	// Load the atlas
	PXTextureAtlas *atlas = [PXTextureAtlas textureAtlasWithContentsOfFile: isIPad ? @"Atlas@2x.json" : @"Atlas.json" modifier:nil];
	
	// Background
	NSString *bgImageName = isIPad ? @"BGiPad.png" : @"BGiPhone.png";
	
	PXTexture *backgroundTex = [PXTexture textureWithContentsOfFile:bgImageName];
	[self addChild:backgroundTex];
		
	worldSprite = [[PXSimpleSprite alloc] init];
	[self addChild:worldSprite];
	[worldSprite release];
	
	// Top Strip
	PXTexture *topPiece = [atlas textureForFrame:@"TopBar.png"];
	[topPiece setAnchorWithX:0.5f y:0.0f];
	topPiece.x = stageWidth * 0.5f;
	[self addChild:topPiece];
	
	// The top strip shadow
	PXTexture *topPieceShadow = [atlas textureForFrame:@"TopBarShadow.png"];
	topPieceShadow.width = stageWidth;
	topPieceShadow.y = topPiece.y + topPiece.height;
	[self addChild:topPieceShadow];
	
	// Uncomment these lines to render the raw Box2D output:
	//
	// PKBox2DDebugLayer *debugLayer = [[PKBox2DDebugLayer alloc] initWithPhysicsWorld:physicsWorld];
	// debugLayer.scale = POINTS_PER_METER;
	// debugLayer.touchPicking = NO;
	// [self addChild:debugLayer];
	// [debugLayer release];

	/////////////
	// Physics //
	/////////////
	
	// Set up some values
	ballCount = 5;
	float radius = 25.0f * myContentScale;
	float stringLength = 250.0f * myContentScale;
	
	// Create a static body to have joints connected to
	b2BodyDef bodyDef;
	b2Body *staticBody = physicsWorld->CreateBody(&bodyDef);
	
	// Define the shape to be used for the ball objects
	b2CircleShape circle;
	circle.m_radius = PointsToMeters(radius);
	circle.m_p.y = PointsToMeters(stringLength);
	
	bodyDef.type = b2_dynamicBody;
	
	// Using friction of 0.0f and high restitution
	// to simulate a real newton's cradle
	b2FixtureDef fixtureDef;
	fixtureDef.friction = 0.0f;
	fixtureDef.restitution = 0.995f;
	
	// All dynamic objects need a density
	fixtureDef.density = 1.0f;
	
	b2Body *body;
	b2RevoluteJointDef jointDef;
	
	// Hold a reference to all the bodies in the world. We'll use this
	// list when resetting the scene.
	ballBodies = new b2Body*[ballCount];
	
	float spaceBetween = (radius * 2.0f) + 2.0f;
	float xPos = (stageWidth * 0.5f) - (ballCount * radius) + radius;
	float yPos = 0.0f;
	
	// Graphics
	BodyAttacher *attacher;
	CradleItemShadowSprite *shadowSprite;
	CradleItemSprite *itemSprite;
	
	// Time to create the cradle ball objects.
	
	int i;
	for(i = 0; i < ballCount; ++i){
		// Set the position of the body
		bodyDef.position = b2Vec2_px2m(xPos, yPos);
		
		body = [Box2DUtils bodyInWorld:physicsWorld
						   withBodyDef:&bodyDef
							fixtureDef:&fixtureDef
								shapes:&circle, nil];
		
		ballBodies[i] = body;
		
		// Make a revolute joint. This will let the objects of the cradle
		// rotate around a hinge at the top of the screen.
		jointDef.Initialize(staticBody, body, bodyDef.position);
		
		// Set the limits so that it doesn't go further then the ceiling
		jointDef.enableLimit = YES;
		jointDef.lowerAngle = PXMathToRad(-74.5f);
		jointDef.upperAngle = PXMathToRad( 74.5f);
		
		// Add the joint to the world
		physicsWorld->CreateJoint(&jointDef);
		
		/// Graphics ////
		
		// Wall shadow
		shadowSprite = [[CradleItemShadowSprite alloc] initWithAtlas:atlas ropeLength:stringLength];
		[worldSprite addChild:shadowSprite];
		[shadowSprite release];
		
		attacher = [[BodyAttacher alloc] init];
		attacher.body = body;
		attacher.displayObject = shadowSprite;
		attacher.xOffset = 10.0f * myContentScale;
		
		[bodyAttachers addObject:attacher];
		[attacher release];
		
		// Main
		itemSprite = [[CradleItemSprite alloc] initWithAtlas:atlas ropeLength:stringLength];
		[worldSprite addChild:itemSprite];
		[itemSprite release];
		
		attacher = [[BodyAttacher alloc] init];
		attacher.body = body;
		attacher.displayObject = itemSprite;
		
		[bodyAttachers addObject:attacher];
		[attacher release];
		
		// The body should keep a reference its display object so that
		// when the body it gets picked up by the user we can grab a reference
		// to the display and turn the glow on/off.
		body->SetUserData(itemSprite);
		
		// Increment to the position of the next ball
		xPos += spaceBetween;
	}	
}

/////////////////////
// Event listeners //
/////////////////////

// Listeners dispatched by the Box2D touch picker

- (void) onPickStart:(PKBox2DTouchPickerEvent *)event
{
	// Grab the touched display object
	CradleItemSprite *itemSprite = (CradleItemSprite *)event.fixture->GetBody()->GetUserData();
	[itemSprite setSelected:YES];
}
- (void) onPickEnd:(PKBox2DTouchPickerEvent *)event
{
	// Grab the touched display object
	CradleItemSprite *itemSprite = (CradleItemSprite *)event.fixture->GetBody()->GetUserData();
	[itemSprite setSelected:NO];
}

// Dispatched when the user taps anywhere on the screen

- (void) onTap:(PXTouchEvent *)e
{
	if(e.tapCount == 2){
		[self resetScene];
	}
}

//////////////////////
// Scene management //
//////////////////////

- (void) resetScene
{
	[touchPicker resetTouches];
	
	b2Body *ballBody;
	for(int i = 0; i < ballCount; ++i){
		ballBody = ballBodies[i];
		
		b2Vec2 ballPos = ballBody->GetPosition();
		ballBody->SetTransform(ballPos, 0.0f);
		ballBody->SetAngularVelocity(0.0f);
		ballBody->SetLinearVelocity(b2Vec2_zero);
	}
}

- (void) contactListener:(ContactListener *)listener
	  collisionWithBodyA:(b2Body *)bodyA
				   bodyB:(b2Body *)bodyB
			 normalForce:(float)normalForce
{
	// Cushion the volume
	float volume = (normalForce / GRAVITY) * 4.0f;

	// Efficency addition, if the volume is less then 1 percent, ignore it.
	if (volume < 0.01f)
		return;

	// A small randomization of the pitch makes it sound cooler and slightly
	// 'unique' each time a ball collides.
	PXSoundTransform *soundTransform = [PXSoundTransform soundTransformWithVolume:volume
																			pitch:[PXMath randomFloatInRangeFrom:0.9f to:1.1f]];

	// Play the sound
	[collisionSound playWithStartTime:0 loopCount:0 soundTransform:soundTransform];
}

///////////////////
// The main loop //
///////////////////

- (void) onFrame
{
	physicsWorld->Step(timeStep, velocityIterations, positionIterations);

	[self updateAttachers];
}

- (void) updateAttachers
{
	BodyAttacher *bodyAttacher;
	for (bodyAttacher in bodyAttachers)
	{
		[bodyAttacher update];
	}
}

@end
