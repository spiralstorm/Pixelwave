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

- (void) onOrientationChanging:(PXStageOrientationEvent *)event;

@end

// Newton's Cradle
// ===============
//
// This application demostrates:
//
//	-	How to use Box2D to create a newton's cradle. Notice that the physics
//		are a bit wonky. That's because Box2D isn't designed to handle this kind of
//		precise simualtion (hence the label on the plaque). Still, it works pretty well.
//
//	-	How to connect the Box2D world with real graphics. Drawing the output of Box2D using
//		the PKBox2DDebugLayer class is pretty simple. Here we take it a step further and
//		connect real display objects to the physical ones. This functionallity is achieved
//		with the BodyAttacher class (included in this project).
//
//	-	How to include sounds in a physical simulation. Here we simply listen to the collision
//		events dispatched by Box2D (using the code in Box2DListener.mm, included in this project)
//		and respond by playing a wooden click sound every time two objects collide. We adjust the
//		volume of the sound to reflect the impact of the collision, and randomely adjust its
//		pitch to make it sound more realistic.

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
	
	self.stage.autoOrients = YES;
	[self.stage addEventListenerOfType:PXStageOrientationEvent_OrientationChanging listener:PXListener(onOrientationChanging:)];
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

- (void) onOrientationChanging:(PXStageOrientationEvent *)event
{
	PXStageOrientation orientation = event.afterOrientation;
	
	if(orientation != PXStageOrientation_LandscapeLeft &&
	   orientation != PXStageOrientation_LandscapeRight)
	{
		[event preventDefault];
	}
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
	
	// This empty sprite will hold the graphics of the ball objects.
	worldSprite = [[PXSimpleSprite alloc] init];
	[self addChild:worldSprite];
	[worldSprite release];
	
	// Top bar with the plaque
	PXTexture *topPiece = [atlas textureForFrame:@"TopBar.png"];
	[topPiece setAnchorWithX:0.5f y:0.0f];
	topPiece.x = stageWidth * 0.5f;
	[self addChild:topPiece];
	
	// The top bar's shadow
	PXTexture *topPieceShadow = [atlas textureForFrame:@"TopBarShadow.png"];
	topPieceShadow.width = stageWidth;
	topPieceShadow.y = topPiece.y + topPiece.height;
	[self addChild:topPieceShadow];
	
	// Uncomment the next block to render the raw Box2D output:
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
	// to simulate the conditions in a real Newton's cradle
	b2FixtureDef fixtureDef;
	fixtureDef.friction = 0.0f;
	fixtureDef.restitution = 0.995f;
	
	// All dynamic objects need a density
	fixtureDef.density = 1.0f;
	
	b2Body *body;
	b2RevoluteJointDef jointDef;
<<<<<<< HEAD
	
	// Hold a reference to all the bodies in the world. We'll use this
	// list when resetting the scene.
	ballBodies = new b2Body*[ballCount];
	
	// We pre-calculate what we can regarding the placement
	// of the objects.
	float spaceBetween = (radius * 2.0f) + 2.0f;
	float xPos = (stageWidth * 0.5f) - (ballCount * radius) + radius;
	float yPos = 0.0f;
	
	// Graphics
	BodyAttacher *attacher = nil;
	CradleItemShadowSprite *shadowSprite = nil;
	CradleItemSprite *itemSprite = nil;
	
	// Time to create the cradle ball objects.
	
	int i;
	for(i = 0; i < ballCount; ++i){
		
		//// PHYSICS ////
		
=======

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
		texture.clipRect = [PXClipRect clipRectWithX:0.0f y:0.0f width:ballTextureSize height:ballTextureSize];
		[texture setAnchorWithX:0.5f y:0.5f];
		texture.x = 0.0f;
		texture.y = stringLength;
		texture.scale = ballTextureScale;
		texture.smoothing = YES;

		// Make a texture for the rope
		texture = [[PXTexture alloc] initWithTextureData:textureData];
		[simpleSprite addChild:texture];
		[texture release];

		// Set the area of the texture that the rope lives.
		texture.clipRect = [PXClipRect clipRectWithX:512 - stringTextureWidth y:0.0f width:stringTextureWidth height:stringTextureHeight];
		[texture setAnchorWithX:0.5f y:0.0f];
		texture.width = stringTextureWidth;
		texture.height = stringLength;
		texture.smoothing = YES;

>>>>>>> Updated the touch heirachy to properly handle display objects being removed whom have captured a touch. They now send a cancel event out which will trickle upwards incase any of it's parents need it as well. Also, updated some of the samples so they work with the new pixelwave system
		// Set the position of the body
		bodyDef.position = b2Vec2_px2m(xPos, yPos);
		
		body = [Box2DUtils bodyInWorld:physicsWorld
						   withBodyDef:&bodyDef
							fixtureDef:&fixtureDef
								shapes:&circle, nil];
		
		// Keep a reference to this body. This is used later when the
		// user double-taps the screen to reset the scene.
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
		
		//// GRAPHICS ////
		
		// Wall shadow graphic
		shadowSprite = [[CradleItemShadowSprite alloc] initWithAtlas:atlas ropeLength:stringLength];
		[worldSprite addChild:shadowSprite];
		[shadowSprite release];
		
		attacher = [[BodyAttacher alloc] init];
		attacher.body = body;
		attacher.displayObject = shadowSprite;
		attacher.xOffset = 10.0f * myContentScale;
		
		[bodyAttachers addObject:attacher];
		[attacher release];
		
		// Main graphic
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
	// Get a reference to the touched display object
	CradleItemSprite *itemSprite = (CradleItemSprite *)event.fixture->GetBody()->GetUserData();
	// Turn on the glow
	[itemSprite setSelected:YES];
}
- (void) onPickEnd:(PKBox2DTouchPickerEvent *)event
{
	// Get a reference to the touched display object
	CradleItemSprite *itemSprite = (CradleItemSprite *)event.fixture->GetBody()->GetUserData();
	// Turn off the glow
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

// Places all the objects back to their original state.
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

// This method is invoked by Box2D when two objects collide.
// We use the normal force of the collision to calculate how
// foreful the collision was and adjust the volume of the
// impact noise accordingly.
//
// Side note: If you're interested in playing a sound when two
// objects slide on one another you would need to know the
// tangential force of the contact (this is the force in
// the direction perpendicular to the collision normal).
// This method only provides the normal force, but you can
// implement a different one to grab the tangential force.
// See Box2DListenerDelegate for more.

- (void) contactListener:(ContactListener *)listener
	  collisionWithBodyA:(b2Body *)bodyA
				   bodyB:(b2Body *)bodyB
			 normalForce:(float)normalForce
{
	// Cushion the volume
	float volume = (normalForce / GRAVITY) * 8.0f;

	// Efficency addition, if the volume is less then 1 percent, ignore it.
	if (volume < 0.08f)
		return;

	// A small randomization of the pitch makes it sound cooler and slightly
	// 'unique' each a pair of objects collide.
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

// Updates all the Pixelwave display objects which were attached to
// physics bodies so that they match their transformations.
- (void) updateAttachers
{
	BodyAttacher *bodyAttacher;
	for (bodyAttacher in bodyAttachers)
	{
		[bodyAttacher update];
	}
}

@end
