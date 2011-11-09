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

#import "PXClipRect.h"
#include "PXMathUtils.h"

@implementation PXClipRect

@synthesize x, y, width, height, rotation = _contentRotation;

- (id) init
{
	return [self initWithX:0 y:0
				  width:0 height:0
				  rotation:0.0f];
}

- (id) initWithX:(float)_x y:(float)_y width:(float)_width height:(float)_height rotation:(float)_rotation
{
	self = [super init];

	if (self)
	{
		[self setX:_x y:_y width:_width height:_height rotation:_rotation];
	}
	
	return self;
}

- (void) dealloc
{
	if (_vertices)
	{
		free(_vertices);
		_vertices = 0;
	}

	// Just in case...
	_numVertices = 0;
	
	[super dealloc];
}

- (void) setX:(float)_x y:(float)_y width:(float)_width height:(float)_height rotation:(float)_rotation;
{
	x = _x;
	y = _y;
	width = _width;
	height = _height;

	_contentRotation = _rotation;

	invalidated = YES;
}

//
// Properties
//

- (void) setX:(float)val
{
	x = val;
	invalidated = YES;
}
- (void) setY:(float)val
{
	y = val;
	invalidated = YES;
}
- (void) setWidth:(float)val
{
	width = val;
	invalidated = YES;
}
- (void) setHeight:(float)val
{
	height = val;
	invalidated = YES;
}
- (void) setRotation:(float)val
{
	_contentRotation = val;
	invalidated = YES;
}

//
// Methods
//

/*
 * Turn the raw data into actual vertices that a PXTexture can use
 */
- (void) _validate
{
	if (!invalidated)
		return;

	PXGLTextureVertex *vert;
	
	// This code is specific to the rectangle clip shape
	{
		// TODO: Once we agree that clipRect will never be a clip-shape, turn
		// this into a staticly allocated array
		_numVertices = 4;
		_vertices = realloc(_vertices, sizeof(PXGLTextureVertex) * _numVertices);

		_contentWidth = width;
		_contentHeight = height;

		// Texture coordinates (in points)

		// Top left
		vert = &_vertices[0];
		vert->s = x;
		vert->t = y;

		// Top right
		vert = &_vertices[1];
		vert->s = x + width;
		vert->t = y;

		// Bottom left
		vert = &_vertices[2];
		vert->s = x;
		vert->t = y + height;

		// Bottom right
		vert = &_vertices[3];
		vert->s = x + width;
		vert->t = y + height;
	}
	
	// This code will work with any amount of vertices (any clip shape)
	{
		// Screen coordinates (in pixels)
		int i;

		// Simple case: no rotation
		if (PXMathIsZero(_contentRotation))
		{
			for (i = 0, vert = &_vertices[0]; i < _numVertices; ++i, ++vert)
			{
				vert->x = vert->s;
				vert->y = vert->t;
			}
			
		}
		else
		// With rotation
		{
			// Construct a rotation matrix
			
			float rad = -_contentRotation * M_PI / 180.0f;
			
			float cosVal = cosf(rad);
			float sinVal = sinf(rad);
		
			float a, b, c, d;
			a = cosVal;	b = sinVal;
			c = -sinVal; d = cosVal;
			
			float origX, origY;
			
			for (i = 0, vert = &_vertices[0]; i < _numVertices; ++i, ++vert)
			{
				origX = vert->s;
				origY = vert->t;
				
				// newPos = orig.x * xVector + orig.y * yVector
				
				vert->x = (origX * a) + (origY * c);
				vert->y = (origX * b) + (origY * d);
			}
			
		}
	}
	
	invalidated = NO;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(x=%f, y=%f, width=%f, height=%f)", x, y, width, height];
}

#pragma mark NSCopying

- (id) copyWithZone:(NSZone *)zone
{
	PXClipRect *newRect = [[PXClipRect allocWithZone:zone] initWithX:x
																   y:y
															   width:width
															  height:height
															rotation:_contentRotation];
	
	return newRect;
}

#pragma mark Utility

+ (PXClipRect *)clipRectWithX:(float)x y:(float)y
						width:(float)width height:(float)height
{
	return [[[PXClipRect alloc] initWithX:x y:y
								 width:width height:height
								 rotation:0.0f] autorelease];
}

+ (PXClipRect *)clipRectWithX:(float)x y:(float)y
						width:(float)width height:(float)height
					 rotation:(float)rotation
{
	return [[[PXClipRect alloc] initWithX:x y:y
								 width:width height:height
								 rotation:rotation] autorelease];
}

@end
