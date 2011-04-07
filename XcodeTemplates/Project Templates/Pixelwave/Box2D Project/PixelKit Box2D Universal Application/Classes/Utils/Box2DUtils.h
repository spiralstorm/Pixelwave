
#import "Pixelwave.h"
#import "Box2D.h"

// Roughly 9.8 m/(s^2)
#define GRAVITY 9.8f
#define POINTS_PER_METER (64.0f)

#define PointsToMeters(_points_) ((_points_) / POINTS_PER_METER)
#define MetersToPoints(_meters_) ((_meters_) * POINTS_PER_METER)

// Create a b2Vec2 by taking in pixels and converting to meters
#define b2Vec2_px2m(_x_,_y_) (b2Vec2(PointsToMeters(_x_), PointsToMeters(_y_)))

@interface Box2DUtils : NSObject
{
}

// Does a hit test to check if a box2d shape is under a given point
+ (b2Fixture *)fixtureInWorld:(b2World *)physicsWorld
						  atX:(float)xInPoints
						 andY:(float)yInPoints;

// Base Functions
+ (b2Body *)bodyInWorld:(b2World *)physicsWorld
			withBodyDef:(b2BodyDef *)bodyDef
			 fixtureDef:(b2FixtureDef *)fixtureDef
				 shapes:(b2Shape *)shape0, ...;


// Utilities
+ (b2Body *)staticBodyInWorld:(b2World *)physicsWorld
				 withFriction:(float)friction
				  restitution:(float)restitution
					   shapes:(b2Shape *)shape0, ...;
+ (b2Body *)staticBodyInWorld:(b2World *)physicsWorld
				 withFriction:(float)friction
				  restitution:(float)restitution
					    shape:(b2Shape *)shape;
+ (b2Body *)staticBodyInWorld:(b2World *)physicsWorld
					withShape:(b2Shape *)shape;

+ (b2Body *)dynamicBodyInWorld:(b2World *)physicsWorld
				  withFriction:(float)friction
				   restitution:(float)restitution
						shapes:(b2Shape *)shape0, ...;
+ (b2Body *)dynamicBodyInWorld:(b2World *)physicsWorld
				  withFriction:(float)friction
				   restitution:(float)restitution
						 shape:(b2Shape *)shape;
+ (b2Body *)dynamicBodyInWorld:(b2World *)physicsWorld
					 withShape:(b2Shape *)shape;

+ (b2Body *)staticBorderInWorld:(b2World *)physicsWorld
						   rect:(PXRectangle *)rect
					  thickness:(float)thickness;

@end
