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

#import "PKBox2DTouchPicker.h"
#import "PXMathUtils.h"

// Query Callback
class PKTouchPickerQueryCallback : public b2QueryCallback
{
public:
	b2Vec2 m_point;
	b2Fixture* m_fixture;
	bool m_precise;
	
	PKTouchPickerQueryCallback(const b2Vec2& point, bool precise)
	{
		m_point = point;
		m_fixture = NULL;
		m_precise = precise;
	}
	
	bool ReportFixture(b2Fixture* fixture)
	{
		b2Body *body = fixture->GetBody();
		
		if (body->GetType() != b2_staticBody)
		{
			bool inside = !m_precise || fixture->TestPoint(m_point);
			if (inside)
			{
				m_fixture = fixture;
				
				return false;
			}
		}
		
		return true;
	}
};

#pragma mark -

@interface PKBox2DTouch : NSObject
{
@private
	UITouch *nativeTouch;
	
	b2World *physicsWorld;
	b2MouseJoint *touchJoint;
	b2Body *jointBody;
	b2Body *touchedBody;
}

@property (nonatomic, readonly) UITouch *nativeTouch;
@property (nonatomic, readonly) b2MouseJoint *joint;

@property (nonatomic) b2Vec2 position;

- (id) initWithWorld:(b2World *)physicsWorld fixture:(b2Fixture *)fixture nativeTouch:(UITouch *)nativeTouch;

@end


#pragma mark -

@implementation PKBox2DTouch

@synthesize nativeTouch;
@synthesize joint = touchJoint;

- (id) init
{
	[self release];
	return nil;
}

- (id) initWithWorld:(b2World *)_physicsWorld fixture:(b2Fixture *)fixture nativeTouch:(UITouch *)_nativeTouch
{
	
	if(!_physicsWorld || !fixture || !_nativeTouch)
	{
		[self release];
		return nil;
	}
	
	if (self = [super init])
	{
		// Save the native touch for comparison.
		nativeTouch = _nativeTouch;

		// Set the world and the joint
		physicsWorld = _physicsWorld;
		
		touchedBody = fixture->GetBody();
		
		touchJoint = NULL;
		jointBody = NULL;
	}

	return self;
}

- (void) dealloc
{
	// To free memory, we have to remove the items from the world.
	if (physicsWorld)
	{
		if (touchJoint)
			physicsWorld->DestroyJoint(touchJoint);
		if (jointBody)
			physicsWorld->DestroyBody(jointBody);
	}

	touchJoint = NULL;
	jointBody = NULL;
	physicsWorld = NULL;
	touchedBody = NULL;

	[super dealloc];
}

- (void) setPosition:(b2Vec2)pos
{	
	// If no joint was created, then we can't change it's position.
	if (!touchJoint)
	{
		// Create a body for the touch.
		b2BodyDef bodyDef;
		bodyDef.position.Set(0, 0);
		jointBody = physicsWorld->CreateBody(&bodyDef);
		
		// Find the body that was touched.
		//b2Body *body = fixture->GetBody();
		
		// Define the mouse joint
		b2MouseJointDef jointDef;
		jointDef.bodyA = jointBody;
		jointDef.bodyB = touchedBody;
		jointDef.target = pos;
		jointDef.maxForce = 16000.0f;
		
		// Create a joint to move the body
		touchJoint = (b2MouseJoint*)(physicsWorld->CreateJoint(&jointDef));
		
		// Wake the body
		touchedBody->SetAwake(true);
	}
	else
	{
		// Convert the point from 'point-space' to 'physics-space'.
		touchJoint->SetTarget(pos);
	}
}

- (b2Vec2)position
{
	// If no joint was created, then we can't find it's position.
	if (!touchJoint)
		return b2Vec2_zero;

	// Grab the position and return a point in 'point-space'.
	return touchJoint->GetTarget();
}

@end

@interface PKBox2DTouchPicker(Private)
//
- (void)onAddedToStage;
- (void)onRemovedFromStage;

// Define the touch events
- (void) onTouchDown:(PXTouchEvent *)event;
- (void) onTouchMove:(PXTouchEvent *)event;
- (void) onTouchUp:(PXTouchEvent *)event;
@end

@implementation PKBox2DTouchPicker

@synthesize precise;

- (id) initWithWorld:(b2World *)_physicsWorld
{
	if (self = [super init])
	{
		physicsWorld = _physicsWorld;

		[self addEventListenerOfType:PX_EVENT_ADDED_TO_STAGE listener:PXListener(onAddedToStage)];
		[self addEventListenerOfType:PX_EVENT_REMOVED_FROM_STAGE listener:PXListener(onRemovedFromStage)];
		
		// Create a list of touches
		touches = [[PXLinkedList alloc] init];
		
		precise = YES;
	}

	return self;
}

- (void) dealloc
{
	[self onRemovedFromStage];
	// Release the touch list.
	[touches release];

	physicsWorld = NULL;

	[super dealloc];
}

- (void)onAddedToStage
{
	PXStage *stage = self.stage;
	
	[stage addEventListenerOfType:PX_TOUCH_EVENT_TOUCH_DOWN		listener:PXListener(onTouchDown:)];
	[stage addEventListenerOfType:PX_TOUCH_EVENT_TOUCH_MOVE		listener:PXListener(onTouchMove:)];
	[stage addEventListenerOfType:PX_TOUCH_EVENT_TOUCH_UP		listener:PXListener(onTouchUp:)];
	[stage addEventListenerOfType:PX_TOUCH_EVENT_TOUCH_OUT		listener:PXListener(onTouchUp:)];
	[stage addEventListenerOfType:PX_TOUCH_EVENT_TOUCH_CANCEL	listener:PXListener(onTouchUp:)];
}
- (void)onRemovedFromStage
{
	PXStage *stage = self.stage;
	
	if(!stage) return;
	
	[stage removeEventListenerOfType:PX_TOUCH_EVENT_TOUCH_DOWN	listener:PXListener(onTouchDown:)];
	[stage removeEventListenerOfType:PX_TOUCH_EVENT_TOUCH_MOVE	listener:PXListener(onTouchMove:)];
	[stage removeEventListenerOfType:PX_TOUCH_EVENT_TOUCH_UP		listener:PXListener(onTouchUp:)];
	[stage removeEventListenerOfType:PX_TOUCH_EVENT_TOUCH_OUT	listener:PXListener(onTouchUp:)];
	[stage removeEventListenerOfType:PX_TOUCH_EVENT_TOUCH_CANCEL	listener:PXListener(onTouchUp:)];
}

- (void) onTouchDown:(PXTouchEvent *)event
{
	
	PXPoint *stagePos = event.stagePosition;
	PXPoint *localPos = [self globalToLocal:stagePos];
	
	// Check if we touched a Box2D fixture //////////////////////

	b2Vec2 pos = b2Vec2(localPos.x, localPos.y);
	
	b2AABB aabb;
	b2Vec2 size_2;
	//if(precise)
	{
		size_2 = b2Vec2(PX_SMALL_NUM, PX_SMALL_NUM);
	}
	//else
	//{
	//	float sx = stagePos.x / localPos.x;
	//	float sy = stagePos.y / localPos.y;
	//	
	//	float radius = 32.0f; // The finger is about 32 pixels
	//	size_2 = b2Vec2(radius / sx, radius / sy);
	//}

	
	aabb.lowerBound = pos - size_2;
	aabb.upperBound = pos + size_2;
	
	// Query the world for overlapping shapes.
	PKTouchPickerQueryCallback callback(pos, precise);
	
	physicsWorld->QueryAABB(&callback, aabb);
	
	b2Fixture *fixture = callback.m_fixture;
		
	//////////////////////////////////////////////////////////////

	// If no fixture was 'picked', return
	if (!fixture)
	{
		return;
	}

	// A touch happened, create one.
	PKBox2DTouch *touch = [[PKBox2DTouch alloc] initWithWorld:physicsWorld
													  fixture:fixture
												  nativeTouch:event.nativeTouch];

	touch.position = pos;// localPos;
	
	[touches addObject:touch];
	[touch release];
}

- (void) onTouchMove:(PXTouchEvent *)event
{
	// Find the touch that moved
	PKBox2DTouch *touch;
	for (touch in touches)
	{
		// If the touch that moved is equal to a saved touch, then move that
		// touch accordingly.
		if (touch.nativeTouch == event.nativeTouch)
		{
			PXPoint *localPos = [self globalToLocal:event.stagePosition];
						
			b2Vec2 pos = b2Vec2(localPos.x, localPos.y);
			touch.position = pos;
			break;
		}
	}
}

- (void) onTouchUp:(PXTouchEvent *)event
{
	// Find the touch that was released
	PKBox2DTouch *touch;
	for (touch in touches)
	{
		// If the touch that was released is equal to a saved touch, then remove
		// that touch.
		if (touch.nativeTouch == event.nativeTouch)
		{
			[touches removeObject:touch];
			break;
		}
	}
}

@end
