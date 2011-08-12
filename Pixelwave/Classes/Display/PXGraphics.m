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

#include "PXEngine.h"

#import "PXGraphics.h"
#include "PXMath.h"
#include "PXMathUtils.h"
#include "PXGL.h"

#import "PXLinkedList.h"
#import "PXObjectPool.h"
#import "PXPooledObject.h"

#define PX_GRAPHICS_DEFAULT_PRECISION 0.25f

//LineGroup class used to store vertices
#define PX_GRAPHICS_GROUP_MAX_POINTS 100
typedef enum
{
	PXGraphicsGroup_Lines = 1,
	PXGraphicsGroup_Triangles,
	PXGraphicsGroup_TriangleStrip
} PXGraphicsGroups;

@interface PXGraphicsGroup : NSObject <PXPooledObject>
{
@private
	float lineRadius;
	GLubyte r, g, b, a;

	PXGLVertex *verts;

	unsigned vertsCount;

	PXGraphicsGroups groupType;

	unsigned color;
	float alpha;
}

@property (nonatomic) float lineRadius;

@property (nonatomic) GLubyte r;
@property (nonatomic) GLubyte g;
@property (nonatomic) GLubyte b;
@property (nonatomic) GLubyte a;

@property (nonatomic) unsigned vertsCount;

@property (nonatomic) PXGraphicsGroups groupType;

@property (nonatomic) unsigned color;
@property (nonatomic) float alpha;

@property (nonatomic) PXGLVertex *verts;

- (void) addPointWithX:(float)x y:(float)y;
- (void) setColor:(unsigned)hex alpha:(float)alpha;

@end

@implementation PXGraphicsGroup

@synthesize verts;// = vPtr;

@synthesize lineRadius;

@synthesize r;
@synthesize g;
@synthesize b;
@synthesize a;

@synthesize vertsCount;

@synthesize groupType;

@synthesize color;
@synthesize alpha;

- (id) init
{
	self = [super init];

	if (self)
	{
		verts = calloc(PX_GRAPHICS_GROUP_MAX_POINTS, sizeof(PXGLVertex));

		vertsCount = 0;
		groupType = PXGraphicsGroup_Lines;
	}

	return self;
}

- (void) dealloc
{
	if (verts)
	{
		free(verts);
	}
	verts = 0;
	vertsCount = 0;

	[super dealloc];
}

- (void) reset
{
	vertsCount = 0;
	groupType = PXGraphicsGroup_Lines;

	verts = memset(verts, 0, sizeof(PXGLVertex) * PX_GRAPHICS_GROUP_MAX_POINTS);
}

- (void) setColor:(unsigned)hex alpha:(float)_alpha
{
	r = (hex & 0xff0000) >> 16;
	g = (hex & 0x00ff00) >> 8;
	b = (hex & 0x0000ff);
	a = _alpha * 0xFF;

	color = hex;
	alpha = _alpha;
}

- (void) addPointWithX:(float)x y:(float)y
{
	if (vertsCount >= PX_GRAPHICS_GROUP_MAX_POINTS - 1)
	{
		return;
	}

	PXGLVertex *p = &verts[vertsCount];

	p->x = x;
	p->y = y;

	++vertsCount;
}

@end

//Main Graphics Class

@implementation PXGraphics

- (id) init
{
	self = [super init];

	if (self)
	{
		groups = [[PXLinkedList alloc] init];

		cGroup = nil;
		currentGroupType = PXGraphicsGroup_Lines;

		[self clear];
	}

	return self;
}

- (void) dealloc
{
	// Return everything to the object pool
	[self clear];

	[groups release];

	[super dealloc];
}

/**
 * Begins a fill sequence. Any line, circle, ellipse or rectangle drawn after
 * this call, and before #endFill will be filled in with the
 * specified color and alpha.
 *
 * @param color The color for the fill in hex form ranging from 0x000000 for black, and
 * 0xFFFFFF for white.
 * @param alpha The alpha channel for the color ranging between 0.0f for invisible to
 * 1.0f for full visibility.
 *
 * **Example:**
 *	PXShape *shape = [PXShape new];
 *	[shape.graphics beginFill:0xFF0000 alpha:1.0f];
 *	[shape.graphics drawRectWithX:100 y:150 width:64 height:32];
 *	[shape.graphics endFill];
 *	// A red rectangle at (100, 150) with a size of (64, 32) will be drawn to
 *	// the screen, assuming the shape was added to the display list.
 *
 * @see PXShape
 */
- (void) beginFill:(unsigned)color alpha:(float)alpha
{
	[self lineStyleWithThickness:0 color:color alpha:alpha];
	cGroup.groupType = PXGraphicsGroup_Triangles;
	currentGroupType = cGroup.groupType;
}

/**
 * Ends the fill sequence. Any line, circle, ellipse or rectangle drawn after
 * the #beginFill call, and before this call will be filled in with
 * the specified color and alpha.
 *
 * **Example:**
 *	PXShape *shape = [PXShape new];
 *	[shape.graphics beginFill:0xFF0000 alpha:1.0f];
 *	[shape.graphics drawRectWithX:100 y:150 width:64 height:32];
 *	[shape.graphics endFill];
 *	// A red rectangle at (100, 150) with a size of (64, 32) will be drawn to
 *	// the screen, assuming the shape was added to the display list.
 *
 * @see PXShape
 */
- (void) endFill
{
}

/**
 * Sets the values needed to define a line.  Any line, circle, ellipse or
 * rectangle drawn after this call, will have be made up of lines with the
 * specified thickness, color and alpha.
 *
 * **Example:**
 *	PXShape *shape = [PXShape new];
 *	[shape.graphics [lineStyle 0xFF0000] alpha:1.0f];
 *	[shape.graphics drawRectWithX:100 y:150 width:64 height:32];
 *	// A red outline of a rectangle at (100, 150) with a size of (64, 32) will
 *	// be drawn to the screen, assuming the shape was added to the display list.
 *
 * @see PXShape
 */
- (void) lineStyleWithThickness:(float)thickness color:(unsigned)color alpha:(float)lineAlpha
{
	// If we have a current line group,a nd that line group only has 1 vertex in
	// it, we put it there and it wasn't used.
	if (cGroup && cGroup.vertsCount <= 1)
	{
		[cGroup reset];
	}
	else
	{
		cGroup = (PXGraphicsGroup *)([PXEngineGetSharedObjectPool() newObjectUsingClass:[PXGraphicsGroup class]]);
		[groups addObject:cGroup];
	}

	cGroup.groupType = PXGraphicsGroup_Lines;
	currentGroupType = cGroup.groupType;

	cGroup.lineRadius = thickness * 0.5f;
	[cGroup setColor:color alpha:lineAlpha];

	[cGroup addPointWithX:currentX y:currentY];
}

- (void) moveToX:(float)mx y:(float)my
{
	currentX = mx;
	currentY = my;

	if (cGroup)
	{
		// Create a new group
		if (currentGroupType == PXGraphicsGroup_Lines)
		{
			// Line loop mode
			[self lineStyleWithThickness:cGroup.lineRadius * 2.0f color:cGroup.color alpha:cGroup.alpha];
		}
		else
		{
			// Fill mode
			[self beginFill:cGroup.color alpha:cGroup.alpha];
		}
	}
}

- (void) lineToX:(float)mx y:(float)my
{
	if (currentGroupType != PXGraphicsGroup_Lines)
	{
		currentGroupType = PXGraphicsGroup_Lines;
		[self moveToX:currentX y:currentY];
	}

	[self _lineToX:mx y:my];
}

- (void) _lineToX:(float)mx y:(float)my
{
	if (cGroup)
		[cGroup addPointWithX:mx y:my];

	currentX = mx;
	currentY = my;
}

- (void) clear
{
	for (PXGraphicsGroup *group in groups)
	{
		[PXEngineGetSharedObjectPool() releaseObject:group];
	}

	[groups removeAllObjects];

	cGroup = nil;

	currentX = currentY = 0;
}

//Utility functions///

- (void) drawRectWithX:(float)rx y:(float)ry width:(float)rwidth height:(float)rheight
{
	[self moveToX:rx y:ry];
	if (cGroup.groupType == PXGraphicsGroup_Lines)
	{
		[self _lineToX:rx + rwidth y:ry];
		[self _lineToX:rx + rwidth y:ry + rheight];
		[self _lineToX:rx y:ry + rheight];
		[self _lineToX:rx y:ry];
	}
	else
	{
		cGroup.groupType = PXGraphicsGroup_TriangleStrip;
		[self _lineToX:rx y:ry + rheight];
		[self _lineToX:rx + rwidth y:ry];
		[self _lineToX:rx + rwidth y:ry + rheight];
	}
}

- (void) drawCircleWithX:(float)x y:(float)y radius:(float)radius
{
	[self drawCircleWithX:x y:y radius:radius precision:PX_GRAPHICS_DEFAULT_PRECISION];
}

- (void) drawCircleWithX:(float)x y:(float)y radius:(float)radius precision:(float)precision
{
	float diameter = radius * 2.0f;
	[self drawEllipseWithX:x - radius y:y - radius width:diameter height:diameter precision:precision];
}

- (void) drawEllipseWithX:(float)x y:(float)y width:(float)width height:(float)height
{
	[self drawEllipseWithX:x y:y width:width height:height precision:PX_GRAPHICS_DEFAULT_PRECISION];
}

- (void) drawEllipseWithX:(float)x y:(float)y width:(float)width height:(float)height precision:(float)precision
{
	if (precision < 0.0f || PXMathIsZero(precision))
		return;
	else if (precision > 1.0f)
		precision = 1.0f;

	width *= 0.5f;
	height *= 0.5f;

	float xPWidth = x + width;
	float yPHeight = y + height;

	float _x = xPWidth + width;
	float _y = yPHeight;

	[self moveToX:_x y:_y];

	float PIM2 = M_PI * 2.0f;
	float maxPoints = PX_GRAPHICS_GROUP_MAX_POINTS - 2.0f - cGroup.vertsCount;
	if (maxPoints < 0.0f || PXMathIsZero(maxPoints))
		return;

	float maxPointsWillAdd = precision * maxPoints;
	float addAmount = PIM2 / maxPointsWillAdd;

	if (cGroup.groupType == PXGraphicsGroup_Lines)
	{
		for (float angle = addAmount; angle < PIM2; angle += addAmount)
		{
			_x = xPWidth + (cosf(angle) * width);
			_y = yPHeight + (sinf(angle) * height);
			[self _lineToX:_x y:_y];
		}

		[self _lineToX:xPWidth + width y:yPHeight];
	}
	else
	{
		cGroup.groupType = PXGraphicsGroup_TriangleStrip;
		int numPointsAdded = 0;
		for (float angle = addAmount; angle < M_PI; angle += addAmount)
		{
			_x = xPWidth + (cosf(angle) * width);
			_y = yPHeight + (sinf(angle) * height);
			[self _lineToX:_x y:_y];
			++numPointsAdded;

			_x = xPWidth + (cosf(-angle) * width);
			_y = yPHeight + (sinf(-angle) * height);
			[self _lineToX:_x y:_y];
			++numPointsAdded;
		}

		if (numPointsAdded < (int)maxPointsWillAdd)
		{
			_x = xPWidth + (cosf(M_PI) * width);
			_y = yPHeight + (sinf(M_PI) * height);
			[self _lineToX:_x y:_y];
		}
	}
}

//////////////////////

////////////////////

- (void) _renderGL
{
	//return;
	//Render all the line groups

	//Render the lines
	//PXGLShadeModel(GL_SMOOTH);
	//PXGLDisable(GL_TEXTURE_2D);
	//PXGLDisable(GL_POINT_SPRITE_OES);
	//PXGLDisableClientState(GL_TEXTURE_COORD_ARRAY);
	//PXGLDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	//PXGLDisableClientState(GL_COLOR_ARRAY);
	//PXGLColor4ub(0xFF, 0xFF, 0xFF, 0xFF);
	//return;

	for (PXGraphicsGroup *group in groups)
	{
		if (group.vertsCount == 0)
			continue;

		if (group.groupType == PXGraphicsGroup_Lines)
			PXGLLineWidth(group.lineRadius);

		PXGLColor4ub(group.r, group.g, group.b, group.a);

		PXGLVertexPointer(2, GL_FLOAT, sizeof(PXGLVertex), group.verts);

		switch (group.groupType)
		{
			case PXGraphicsGroup_Lines:
				PXGLDrawArrays(GL_LINE_STRIP, 0, group.vertsCount);
				break;
			case PXGraphicsGroup_Triangles:
				PXGLDrawArrays(GL_TRIANGLES, 0, group.vertsCount);
				break;
			case PXGraphicsGroup_TriangleStrip:
				PXGLDrawArrays(GL_TRIANGLE_STRIP, 0, group.vertsCount);
				break;
			default:
				break;
		}
	}
}

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	*retBounds = CGRectZero;

	if ([groups count] == 0)
		return;

	PXGLVertex *point;
	int index = 0;

	int ptX = 0, ptY = 0;
	int xMin = INT_MAX, xMax = INT_MIN;
	int yMin = INT_MAX, yMax = INT_MIN;
	for (PXGraphicsGroup *group in groups)
	{
		for (index = 0; index < group.vertsCount; ++index)
		{
			point = &group.verts[index];
			ptX = point->x;
			ptY = point->y;

			if (ptX < xMin)
				xMin = ptX;

			if (ptX > xMax)
				xMax = ptX;

			if (ptY < yMin)
				yMin = ptY;

			if (ptY > yMax)
				yMax = ptY;
		}
	}

	retBounds->origin.x = (float)xMin;
	retBounds->origin.y = (float)yMin;
	retBounds->size.width  = (float)xMax - retBounds->origin.x;
	retBounds->size.height = (float)yMax - retBounds->origin.y;
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y
{
	PXGLVertex *point;
	int index = 0;

	int ptX = 0, ptY = 0;
	int xMin = INT_MAX, xMax = INT_MIN;
	int yMin = INT_MAX, yMax = INT_MIN;
	for (PXGraphicsGroup *group in groups)
	{
		xMin = INT_MAX; xMax = INT_MIN;
		yMin = INT_MAX; yMax = INT_MIN;
		for (index = 0; index < group.vertsCount; ++index)
		{
			point = &group.verts[index];
			ptX = point->x;
			ptY = point->y;

			if (ptX < xMin)
				xMin = ptX;

			if (ptX > xMax)
				xMax = ptX;

			if (ptY < yMin)
				yMin = ptY;

			if (ptY > yMax)
				yMax = ptY;
		}

		if ((x >= xMin && x <= xMax) && (y >= yMin && y <= yMax))
			return YES;
	}

	return NO;
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	if ([groups count] == 0)
		return NO;

	if (!shapeFlag)
		return [self _containsPointWithLocalX:x localY:y];

	PXMathPoint pt = PXMathPointMake(x, y);
	PXMathTriangle tri;

	PXGLVertex *point;
	int index = 0;

	//if it is a square then use aabb to check, etc.
	for (PXGraphicsGroup *group in groups)
	{
		if (group.vertsCount < 2)
			continue;

		if (group.groupType == PXGraphicsGroup_Lines)
		{
			//tri.pointA = group.verts[0];
			point = &group.verts[0];
			//tri.pointA = PXMathPointMake(point->x, point->y);
			PXMathPointSet(&(tri.pointA), point->x, point->y );

			point = &group.verts[1];
			for (index = 2; index < group.vertsCount; ++index)
			{
				tri.pointB = PXMathPointMake(point->x, point->y);
				//PXMathPointSet(tri.pointB, point->x, point->y);

				point = &group.verts[index];
				tri.pointC = PXMathPointMake(point->x, point->y);
				//PXMathPointSet(tri.pointC, point->x, point->y);

				if (PXMathIsPointInTriangle(&pt, &tri))
					return YES;
			}
		}
		else if (group.groupType == PXGraphicsGroup_Triangles)
		{
			for (index = -1; index + 2 < group.vertsCount; )
			{
				point = &group.verts[++index];
				PXMathPointSet(&(tri.pointA), point->x, point->y );
				point = &group.verts[++index];
				PXMathPointSet(&(tri.pointB), point->x, point->y );
				point = &group.verts[++index];
				PXMathPointSet(&(tri.pointC), point->x, point->y );

				if (PXMathIsPointInTriangle(&pt, &tri))
					return YES;
			}
		}
		else if (group.groupType == PXGraphicsGroup_TriangleStrip)
		{
			for (index = 1; index + 1 < group.vertsCount; ++index)
			{
				point = &group.verts[index - 1];
				PXMathPointSet(&(tri.pointA), point->x, point->y );
				point = &group.verts[index];
				PXMathPointSet(&(tri.pointB), point->x, point->y );
				point = &group.verts[index + 1];
				PXMathPointSet(&(tri.pointC), point->x, point->y );

				if (PXMathIsPointInTriangle(&pt, &tri))
					return YES;
			}
		}
	}

	return NO;
}

@end
