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

#import "SimpleBox2DRoot.h"

#import "Box2DUtils.h"
#import "PKBox2DDebugLayer.h"

#define MathToDeg(_rads_) ((_rads_) * 57.295780f)
#define MathToRad(_degs_) ((_degs_) * 0.017453f)
#define MakeLocation(_degs_, _size_) b2Vec2_px2m(cosf(MathToRad(_degs_)) * _size_, sinf(MathToRad(_degs_)) * _size_)

// We consider these methods private
@interface SimpleBox2DRoot(Private)
- (void) createScene;
@end

@implementation SimpleBox2DRoot

- (void) initializeAsRoot
{
	self.stage.frameRate = 60.0;

	//////////////////////////////
	// Setup the physics engine //
	//////////////////////////////

	// Define some simulation parameters
	timeStep = 1.0f / self.stage.frameRate;
	velocityIterations = 10;
	positionIterations = 10;

	// Define the force of gravity (in meters / second ^ 2)
	b2Vec2 gravity(0.0f, GRAVITY);

	// Should physics bodies sleep when not moving? Why not?
	bool doSleep = false;

	physicsWorld = new b2World(gravity, doSleep);

	// Set up the callbacks
	destructionListener = NULL;
	contactListener = NULL;
	
	NSLog(@"%f", self.stage.renderFrameRate);

	// Uncomment these to listen to Box2D events:

	// destructionListener = new DestructionListener();
	// physicsWorld->SetDestructionListener(destructionListener);

	// contactListener = new ContactListener();
	// physicsWorld->SetContactListener(contactListener);

	//////////////////////////
	// Set up the main loop //
	/////////////////////////

	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame)];

	///////////////////////////
	// Add some instructions //
	///////////////////////////

	NSString *fontName = @"American Typewriter";

	PXFontOptions *fontOptions = [PXTextureFontOptions textureFontOptionsWithSize:15.0f
																	characterSets:PXFontCharacterSet_AllLetters
																specialCharacters:nil];

	PXFont *font = [PXFont fontWithSystemFont:fontName options:fontOptions];	
	[PXFont registerFont:font withName:fontName];

	PXTextField *txtInstruction = nil;

	// Label
	txtInstruction = [PXTextField textFieldWithFont:fontName
											   text:@"drag to interact"];

	txtInstruction.textColor = 0xFFFFFF;
	txtInstruction.letterSpacing = 1.0f;
	txtInstruction.alpha = 0.75f;
	txtInstruction.x = 20.0f;
	txtInstruction.y = 20.0f;

	[self addChild:txtInstruction];

	// Label
	txtInstruction = [PXTextField textFieldWithFont:fontName
											   text:@"tilt to change gravity"];

	txtInstruction.textColor = 0xFFFFFF;
	txtInstruction.letterSpacing = 1.0f;
	txtInstruction.alpha = 0.75f;
	txtInstruction.x = 20.0f;
	txtInstruction.y = 40.0f;

	[self addChild:txtInstruction];

	/////////////////////////////////////
	// Set up the debug graphics layer //
	/////////////////////////////////////

	PKBox2DDebugLayer *layer = [PKBox2DDebugLayer new];
	layer.physicsWorld = physicsWorld;
	layer.scale = POINTS_PER_METER;
	layer.touchPicking = YES;

	[self addChild:layer];
	[layer release];

	////////////////////////
	// Populate the world //
	////////////////////////

	[self createScene];

	float dt = timeStep * 0.5f;
	UIAccelerometer * accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.updateInterval = dt;
	accelerometer.delegate = self;
}

- (void) dealloc
{
	[UIAccelerometer sharedAccelerometer].delegate = nil;

	// Cleaning up: Release retained objects, remove event listeners, etc.
	delete physicsWorld;
	physicsWorld = NULL;

	// Unload all the listeners
	if (destructionListener)
	{
		delete destructionListener;
		destructionListener = NULL;
	}

	if (contactListener)
	{
		delete contactListener;
		contactListener = NULL;
	}

	[super dealloc];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	PXVector3D *accelerationVector = [PXVector3D vector3DWithX:acceleration.x
															 y:acceleration.y
															 z:acceleration.z];
	[accelerationVector scaleBy:GRAVITY];

	PXVector3D *normalVectorToPlane = [PXVector3D vector3DWithX:0.0f
															  y:0.0f
															  z:1.0f];
	float accelDotNormal = [accelerationVector dotProductWithVector:normalVectorToPlane];
	[normalVectorToPlane scaleBy:accelDotNormal];

	PXVector3D *gravityVector = [accelerationVector subtractVector:normalVectorToPlane];
	const b2Vec2 gravity(gravityVector.y, gravityVector.x);
	physicsWorld->SetGravity(gravity);
}

//////////////////////////
// Initialize the world //
//////////////////////////

- (void) createScene
{
	float stageWidth  = self.stage.stageWidth;
	float stageHeight = self.stage.stageHeight;

	b2Body *body = NULL;

	//////////////////////
	// Create the walls //
	//////////////////////

	float wallSize = 10.0f;

	PXRectangle *bounds = [PXRectangle rectangleWithX:0.0f
													y:0.0f
												width:stageWidth
											   height:stageHeight];

	[Box2DUtils staticBorderInWorld:physicsWorld
							   rect:bounds
						  thickness:wallSize];

	// Define a triangle
	int32 count = 3;
	float angle = 30.0f;
	float polygonSize = 35.0f;
	b2Vec2 vertices[count];

	vertices[0] = MakeLocation(angle + 000.0f, polygonSize);
	vertices[1] = MakeLocation(angle + 120.0f, polygonSize);
	vertices[2] = MakeLocation(angle + 240.0f, polygonSize);

	// Grab the distance between points to configure a pyramid.
	float xDist = MetersToPoints(vertices[0].x - vertices[1].x);
	float yDist = MetersToPoints(vertices[0].y - vertices[2].y);
	float xDist_2 = xDist * 0.5f;

	b2PolygonShape polygon;
	polygon.Set(vertices, count);

	// Initial x and y values
	unsigned short polygonX = 0;
	unsigned short polygonY = stageHeight - (wallSize + (polygonSize * 0.5f));

	// Set up our loop variables
	signed short polygonCount;
	unsigned char treeDepth;
	unsigned char polygonIndex;

	// Make the pyramid
	for (treeDepth = 0, polygonCount = 4; polygonCount >= 0; ++treeDepth, --polygonCount)
	{
		polygonX = (stageWidth * 0.5f) - (polygonCount * xDist_2) + (xDist_2);

		for (polygonIndex = 0; polygonIndex < polygonCount; ++polygonIndex)
		{
			// Make a right-side-up triangle
			body = [Box2DUtils dynamicBodyInWorld:physicsWorld
									 withFriction:1.0f
									  restitution:0.5f
											shape:&polygon];

			body->SetTransform(b2Vec2_px2m(polygonX, polygonY), 0.0f);

			// If this is not the last triangle made, then make an up-side-down
			// triangle to fit between them.
			if (polygonIndex != polygonCount - 1)
			{
				body = [Box2DUtils dynamicBodyInWorld:physicsWorld
										 withFriction:1.0f
										  restitution:0.5f
												shape:&polygon];

				body->SetTransform(b2Vec2_px2m(polygonX + (xDist_2), polygonY - (polygonSize * 0.5f)), M_PI);
			}

			// Increment the triangle's column location
			polygonX += xDist;
		}

		// Increment the triangle's row location
		polygonY -= yDist;
	}

	// Define a circle
	b2CircleShape circle;
	float radius = 32.0f;
	circle.m_radius = PointsToMeters(radius);

	// Make a circle in the upper right of the screen
	body = [Box2DUtils dynamicBodyInWorld:physicsWorld
							 withFriction:1.0f
							  restitution:0.75f
									shape:&circle];
	body->SetTransform(b2Vec2_px2m((stageWidth - radius) - wallSize, (radius) + wallSize), 0.0f);

	// Make a circle in the upper left of the screen
	body = [Box2DUtils dynamicBodyInWorld:physicsWorld
							 withFriction:1.0f
							  restitution:0.75f
									shape:&circle];

	body->SetTransform(b2Vec2_px2m((radius) + wallSize, (radius) + wallSize), 0.0f);
}

///////////////////
// The main loop //
///////////////////

- (void) onFrame
{
	physicsWorld->Step(timeStep, velocityIterations, positionIterations);
}

@end
