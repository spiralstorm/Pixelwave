//
//  ___PROJECTNAMEASIDENTIFIER___Root.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "___PROJECTNAMEASIDENTIFIER___Root.h"

#import "Box2DUtils.h"
#import "PKBox2DDebugLayer.h"

// We consider these methods private
@interface ___PROJECTNAMEASIDENTIFIER___Root(Private)
- (void) createScene;
@end

@implementation ___PROJECTNAMEASIDENTIFIER___Root

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
	bool doSleep = true;

	physicsWorld = new b2World(gravity, doSleep);

	// Zero out the callbacks
	destructionListener = NULL;
	contactListener = NULL;

	//// Uncomment these to listen to Box2D events: ////
	
	// destructionListener = new DestructionListener();
	// physicsWorld->SetDestructionListener(destructionListener);
	//
	// contactListener = new ContactListener();
	// physicsWorld->SetContactListener(contactListener);
	
	//////////////////////////
	// Set up the main loop //
	/////////////////////////

	[self addEventListenerOfType:PX_EVENT_ENTER_FRAME
						listener:PXListener(onFrame)];

	/////////////////////////////////////
	// Set up the debug graphics layer //
	/////////////////////////////////////

	PKBox2DDebugLayer *layer = [PKBox2DDebugLayer new];
	layer.physicsWorld = physicsWorld;
	layer.scale = POINTS_PER_METER;
	layer.touchPicking = YES;
	// ^ Comment out the previous line to disable object picking

	[self addChild:layer];
	[layer release];

	////////////////////////
	// Populate the world //
	////////////////////////

	[self createScene];
}

- (void) dealloc
{
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

//////////////////////////
// Initialize the world //
//////////////////////////

- (void) createScene
{
	// This is a sample scene. Feel free to replace this code with your own:
	float stageWidth = self.stage.stageWidth;
	float stageHeight = self.stage.stageHeight;

	b2Body *body = NULL;

	//// Create bounds /////

	PXRectangle *bounds = [PXRectangle rectangleWithX:0.0f
												 andY:0.0f
											 andWidth:stageWidth
											andHeight:stageHeight];
	
	[Box2DUtils staticBorderInWorld:physicsWorld
							   rect:bounds
						  thickness:10.0f];

	//// Create a bouncy ball ////

	// Create a circle 30px in radius
	b2CircleShape circle;
	circle.m_radius = PointsToMeters(30.0f);

	body = [Box2DUtils dynamicBodyInWorld:physicsWorld
							 withFriction:1.0f
							  restitution:0.8f
									shape:&circle];

	// Place the circle in the center of the screen
	body->SetTransform(b2Vec2_px2m(stageWidth * 0.5f, stageHeight * 0.5f), 0.0f);
}

///////////////////
// The main loop //
///////////////////

- (void) onFrame
{
	physicsWorld->Step(timeStep, velocityIterations, positionIterations);
}

@end
