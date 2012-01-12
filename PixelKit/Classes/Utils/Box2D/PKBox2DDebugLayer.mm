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

#import "PKBox2DDebugLayer.h"

#include "Box2D.h"
#include "PXGL.h"

// This class implements debug drawing callbacks that are invoked inside
// b2World::Step.
class PKB2DebugDraw : public b2DebugDraw
{
public:
	void DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);
	void DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);
	void DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color);
	void DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color);
	void DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color);
	void DrawTransform(const b2Transform& xf);
private:
	void setGLState( );
};

void PKB2DebugDraw::setGLState()
{
	PXGLDisable( GL_TEXTURE_2D );
	PXGLDisableClientState( GL_TEXTURE_COORD_ARRAY );
	PXGLDisableClientState( GL_COLOR_ARRAY );
	PXGLDisableClientState( GL_POINT_SIZE_ARRAY_OES );
}

void PKB2DebugDraw::DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	setGLState();

	PXGLColor4f(color.r, color.g, color.b,1);
	PXGLVertexPointer(2, GL_FLOAT, 0, vertices);
	PXGLDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}

void PKB2DebugDraw::DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	setGLState();

	PXGLVertexPointer(2, GL_FLOAT, 0, vertices);

	PXGLColor4f(color.r, color.g, color.b,0.5f);
	PXGLDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);

	PXGLColor4f(color.r, color.g, color.b,1);
	PXGLDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}

void PKB2DebugDraw::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	int vertexCount=16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;

	GLfloat glVertices[vertexCount*2];

	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertices[i*2]=v.x;
		glVertices[i*2+1]=v.y;
		theta += k_increment;
	}

	setGLState( );

	PXGLColor4f(color.r, color.g, color.b,1);
	PXGLVertexPointer(2, GL_FLOAT, 0, glVertices);

	PXGLDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
}

void PKB2DebugDraw::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	int vertexCount=16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;

	GLfloat glVertices[vertexCount*2];
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertices[i*2]=v.x;
		glVertices[i*2+1]=v.y;
		theta += k_increment;
	}

	setGLState();

	PXGLColor4f(color.r, color.g, color.b,0.5f);
	PXGLVertexPointer(2, GL_FLOAT, 0, glVertices);
	PXGLDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
	PXGLColor4f(color.r, color.g, color.b,1);
	PXGLDrawArrays(GL_LINE_LOOP, 0, vertexCount);

	// Draw the axis line
	DrawSegment(center,center+radius*axis,color);
}

void PKB2DebugDraw::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)
{
	setGLState();

	GLfloat	glVertices[] =
	{
		p1.x,p1.y,p2.x,p2.y
	};

	PXGLColor4f(color.r, color.g, color.b,1);

	PXGLVertexPointer(2, GL_FLOAT, 0, glVertices);
	PXGLDrawArrays(GL_LINES, 0, 2);
}

void PKB2DebugDraw::DrawTransform(const b2Transform& xf)
{
	b2Vec2 p1 = xf.position, p2;
	const float32 k_axisScale = 0.4f;

	p2 = p1 + k_axisScale * xf.R.col1;
	DrawSegment(p1,p2,b2Color(1,0,0));

	p2 = p1 + k_axisScale * xf.R.col2;
	DrawSegment(p1,p2,b2Color(0,1,0));
}

@implementation PKBox2DDebugLayer

@synthesize physicsWorld, touchPicker;

- (id) init
{
	return [self initWithPhysicsWorld:NULL];
}

- (id) initWithPhysicsWorld:(b2World *)_physicsWorld
{
	if (self = [super init])
	{
		_renderMode = PXRenderMode_BatchAndManageStates;

		physicsWorld = NULL;
		debugDrawer = new PKB2DebugDraw();

		self.flags = b2DebugDraw::e_shapeBit | b2DebugDraw::e_centerOfMassBit | b2DebugDraw::e_jointBit;
		self.physicsWorld = _physicsWorld;
		
		touchPicker = nil;
	}

	return self;
}

- (void) dealloc
{
	self.touchPicking = NO;
	
	self.physicsWorld = NULL;
	
	delete debugDrawer;
	debugDrawer = NULL;

	[super dealloc];
}

- (void) setPhysicsWorld:(b2World *)_physicsWorld
{
	if (physicsWorld)
	{
		physicsWorld->SetDebugDraw(NULL);
	}

	physicsWorld = _physicsWorld;

	if (physicsWorld)
	{
		physicsWorld->SetDebugDraw(debugDrawer);
	}
}

///
// Picking
//

- (void) setTouchPicking:(BOOL)val
{
	if (val && !touchPicker)
	{
		touchPicker = [[PKBox2DTouchPicker alloc] initWithWorld:physicsWorld];
		[self addChild:touchPicker];
		[touchPicker release];
	}
	else if (!val && touchPicker)
	{
		[self removeChild:touchPicker];
		touchPicker = nil;
	}
}

- (BOOL) touchPicking
{
	return touchPicker != nil;
}

- (void) setPrecisePicking:(BOOL)val
{
	if (touchPicker)
	{
		touchPicker.precise = val;
	}
}

- (BOOL) precisePicking
{
	if (touchPicker)
	{
		return touchPicker.precise;
	}

	return NO;
}

//
// Flags
//

- (void) enableFlags:(unsigned)flags
{
	debugDrawer->AppendFlags(flags);
}

- (void) disableFlags:(unsigned)flags
{
	debugDrawer->ClearFlags(flags);
}

- (unsigned) flags
{
	return debugDrawer->GetFlags();
}

- (void) setFlags:(unsigned)val
{
	debugDrawer->SetFlags(val);
}

- (void) _renderGL
{
	if (physicsWorld)
	{
		physicsWorld->DrawDebugData();
	}
}

+ (PKBox2DDebugLayer *)box2DDebugLayerWithPhysicsWorld:(b2World *)physicsWorld
{
	return [[[PKBox2DDebugLayer alloc] initWithPhysicsWorld:physicsWorld] autorelease];
}

@end
