
#import "Box2D.h"

// Destruction listener
class DestructionListener : public b2DestructionListener
{
public:
	virtual void SayGoodbye(b2Joint* joint);
	virtual void SayGoodbye(b2Fixture* fixture);
};

// Contact listener
class ContactListener : public b2ContactListener
{
public:
	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
};

// Query Callback
class QueryCallback : public b2QueryCallback
{
public:
	b2Vec2 m_point;
	b2Fixture* m_fixture;
	
	QueryCallback(const b2Vec2& point);
	virtual bool ReportFixture(b2Fixture* fixture);
};

// Raycast Callback
class RaycastCallback : public b2RayCastCallback
{
public:
	virtual float32 ReportFixture(b2Fixture* fixture, const b2Vec2& point,
								  const b2Vec2& normal, float32 fraction);
};
