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

#import "Box2DListeners.h"

#pragma mark -
#pragma mark Destruction Listener

/// Joints and fixtures are destroyed when their associated
/// body is destroyed. Implement this listener so that you
/// may nullify references to these joints and shapes.

/// Called when any joint is about to be destroyed due
/// to the destruction of one of its attached bodies.
void DestructionListener::SayGoodbye(b2Joint* joint)
{
}

/// Called when any fixture is about to be destroyed due
/// to the destruction of its parent body.
void DestructionListener::SayGoodbye(b2Fixture* fixture)
{
}

#pragma mark -
#pragma mark Contact Listener

/// Implement this class to get contact information. You can use these results for
/// things like sounds and game logic. You can also get contact results by
/// traversing the contact lists after the time step. However, you might miss
/// some contacts because continuous physics leads to sub-stepping.
/// Additionally you may receive multiple callbacks for the same contact in a
/// single time step.
/// You should strive to make your callbacks efficient because there may be
/// many callbacks per time step.
/// @warning You cannot create/destroy Box2D entities inside these callbacks.

/// Called when two fixtures begin to touch.
void ContactListener::BeginContact(b2Contact* contact)
{
	B2_NOT_USED(contact);
}

/// Called when two fixtures cease to touch.
void ContactListener::EndContact(b2Contact* contact)
{
	B2_NOT_USED(contact);
}

/// This is called after a contact is updated. This allows you to inspect a
/// contact before it goes to the solver. If you are careful, you can modify the
/// contact manifold (e.g. disable contact).
/// A copy of the old manifold is provided so that you can detect changes.
/// Note: this is called only for awake bodies.
/// Note: this is called even when the number of contact points is zero.
/// Note: this is not called for sensors.
/// Note: if you set the number of contact points to zero, you will not
/// get an EndContact callback. However, you may get a BeginContact callback
/// the next step.
void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
	B2_NOT_USED(contact);
	B2_NOT_USED(oldManifold);
}

/// This lets you inspect a contact after the solver is finished. This is useful
/// for inspecting impulses.
/// Note: the contact manifold does not include time of impact impulses, which can be
/// arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
/// in a separate data structure.
/// Note: this is only called for contacts that are touching, solid, and awake.
void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
	B2_NOT_USED(contact);
	B2_NOT_USED(impulse);
}

#pragma mark -
#pragma mark Query Callback

/// Callback class for AABB queries.

QueryCallback::QueryCallback(const b2Vec2& point)
{
	m_point = point;
	m_fixture = NULL;
}

/// Called for each fixture found in the query AABB.
/// @return false to terminate the query.
bool QueryCallback::ReportFixture(b2Fixture* fixture)
{
	b2Body *body = fixture->GetBody();

	if (body->GetType() != b2_staticBody)
	{
		bool inside = fixture->TestPoint(m_point);
		if (inside)
		{
			m_fixture = fixture;

			return false;
		}
	}

	return true;
}

#pragma mark -
#pragma mark Raycast Callback

/// Callback class for ray casts.

/// Called for each fixture found in the query. You control how the ray cast
/// proceeds by returning a float:
/// return -1: ignore this fixture and continue
/// return 0: terminate the ray cast
/// return fraction: clip the ray to this point
/// return 1: don't clip the ray and continue
/// @param fixture the fixture hit by the ray
/// @param point the point of initial intersection
/// @param normal the normal vector at the point of intersection
/// @return -1 to filter, 0 to terminate, fraction to clip the ray for
/// closest hit, 1 to continue
float32 RaycastCallback::ReportFixture(	b2Fixture* fixture, const b2Vec2& point,
									   const b2Vec2& normal, float32 fraction)
{
	return 0.0f;
}
