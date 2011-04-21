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

#import "ColorfulHexagon.h"

@implementation ColorfulHexagon

- (id) initWithRadius:(float)_radius
{
	if (self = [super init])
	{
		// Storing the radius.
		radius = _radius;

		// I am going to define a utility macro so I can assign my variables in
		// less lines of visible code.  This macro sets the x, y and color
		// values with the given arguments.
#define SET_VERTEX(_vertex_, _x_, _y_, _r_, _g_, _b_, _a_)\
{\
	(_vertex_).x = (_x_);\
	(_vertex_).y = (_y_);\
	(_vertex_).r = (_r_);\
	(_vertex_).g = (_g_);\
	(_vertex_).b = (_b_);\
	(_vertex_).a = (_a_);\
}
		// A hexagon has 6 sides, and can be defined in 6 vertices.
		vertexCount = 6;
		// I am callocing the memory for the vertices.  Calloc imediately sets
		// each byte of memory that you allocate to 0.  It is useful to calloc
		// rather then malloc, as often it makes it easier to debug; however it
		// does take more time.  I am not doing this sample for speed, it is
		// more alligned for clairty.
		// PXGLColorVertex is a struct that defines a vertex's position and
		// color.  The following struct's are available for use:
		//		PXGLVertex
		//		PXGLColorVertex
		//		PXGLTextureVertex
		//		PXGLColoredTextureVertex
		vertices = calloc(vertexCount, sizeof(PXGLColorVertex));

		float angle = (M_PI * 2.0f)/(float)vertexCount;
		float origAngle = angle;

		// Going to define the hexagon with vertices that include it's position
		// and color.
		//              vertex,            x-position,            y-position,    r,    g,    b,    a
		SET_VERTEX(vertices[0], cosf(0.0f)   * radius, sinf(0.0f)   * radius, 0x00, 0x00, 0xFF, 0xFF);
		SET_VERTEX(vertices[1], cosf( angle) * radius, sinf( angle) * radius, 0x00, 0x88, 0x88, 0xFF);
		SET_VERTEX(vertices[2], cosf(-angle) * radius, sinf(-angle) * radius, 0x88, 0x00, 0x88, 0xFF);
		angle += origAngle;
		SET_VERTEX(vertices[3], cosf( angle) * radius, sinf( angle) * radius, 0x00, 0xFF, 0x00, 0xFF);
		SET_VERTEX(vertices[4], cosf(-angle) * radius, sinf(-angle) * radius, 0xFF, 0x00, 0x00, 0xFF);
		SET_VERTEX(vertices[5], cosf(M_PI)   * radius, sinf(M_PI)   * radius, 0x88, 0x88, 0x00, 0xFF);
	}

	return self;
}

- (void) dealloc
{
	// Free your memory.
	if (vertices)
		free(vertices);

	[super dealloc];
}

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	// Set the bounds to your local bounds, ex:
	retBounds->origin.x = -radius;
	retBounds->origin.y = -radius;
	retBounds->size.width  = radius * 2.0f;
	retBounds->size.height = radius * 2.0f;
}

- (BOOL) _containsPointWithLocalX:(float)x
						   localY:(float)y
						shapeFlag:(BOOL)shapeFlag
{
	// Return YES if the point lyes within your local area.  If shape flag is
	// 'NO', then a simple bounding box check is sufficient.

	if (!shapeFlag)
	{
		CGRect localBounds;
		[self _measureLocalBounds:&localBounds];

		return CGRectContainsPoint(localBounds, CGPointMake(x, y));
	}

	// I am going to do a simple circular bounds detection and call it good for
	// the shape.
	float distanceSq = (x * x) + (y * y);
	float radiusSq = radius * radius;

	return (distanceSq < radiusSq);
}

- (void) _renderGL
{
	// If no vertices exist, then we have nothing to draw... so simply return.
	if (!vertices)
		return;

	// All renderGL methods should invoke every disable and enable they need to
	// put them in the correct state.  You do not need to change it back after
	// you are done, hence why everything needs to change it before drawing.
	// This is because you do not know the state of openGL prior to your draw.

	// Note:	Using PXGL calls rather then gl calls directly can increase
	//			performance.  This is because PXGL caches values and vertices
	//			and sends them in bundled up fashion.
	PXGLDisable(GL_TEXTURE_2D);
	PXGLDisableClientState(GL_TEXTURE_COORD_ARRAY);
	PXGLDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	PXGLEnableClientState(GL_COLOR_ARRAY );
	PXGLColor4ub(0xFF, 0xFF, 0xFF, 0xFF);

	// Give the color pointer and vertex pointer.
	PXGLColorPointer(4, GL_UNSIGNED_BYTE, sizeof(PXGLColorVertex), &(vertices->r));
	PXGLVertexPointer(2, GL_FLOAT, sizeof(PXGLColorVertex), &(vertices->x));

	// Draw the vertices.
	PXGLDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
}

@end
