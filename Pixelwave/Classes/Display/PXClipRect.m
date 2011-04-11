//
//  PXClipRect.m
//  TextureAtlasB
//
//  Created by Oz Michaeli on 4/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PXClipRect.h"
#import "PXMathUtils.h"

@implementation PXClipRect

@synthesize x, y, width, height, rotation;

- (id)init
{
	return [self initWithX:0 andY:0
				  andWidth:0 andHeight:0
				  rotation:0.0f];
}

/*
- (id)initWithX:(ushort)_x andY:(ushort)_y andWidth:(ushort)_width andHeight:(ushort)_height
{
	return [self initWithX:_x andY:_y
				  andWidth:_width andHeight:_height
				  rotation:0.0f];
}
*/

- (id)initWithX:(ushort)_x andY:(ushort)_y andWidth:(ushort)_width andHeight:(ushort)_height rotation:(float)_rotation
{
	if(self = [super init])
	{
		x = _x;
		y = _y;
		width = _width;
		height = _height;
		rotation = _rotation;
		
		_numVertices = 0;
		_vertices = 0;
		
		invalidated = YES;
	}
	
	return self;
}

- (void)dealloc
{
	if(_vertices)
	{
		free(_vertices);
		_vertices = 0;
	}
	
	[super dealloc];
}

///
///
///

- (void) setX:(ushort)val
{
	x = val;
	invalidated = YES;
}
- (void) setY:(ushort)val
{
	y = val;
	invalidated = YES;
}
- (void) setWidth:(ushort)val
{
	width = val;
	invalidated = YES;
}
- (void) setHeight:(ushort)val
{
	height = val;
	invalidated = YES;
}
- (void) setRotation:(float)val
{
	rotation = val;
	invalidated = YES;
}

///
///
///

- (void)_validate
{
	if(!invalidated) return;

	PXGLTextureVertex *vert;
	
	// This code is specific to the rectangle clip shape
	{
		_numVertices = 4;
		_vertices = realloc(_vertices, sizeof(PXGLTextureVertex) * _numVertices);
		
		_contentWidth = width;
		_contentHeight = height;
		
		// Texture coordinates (in pixels)
		
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
		if(PXMathIsZero(rotation))
		{
			for(i = 0, vert = &_vertices[0]; i < _numVertices; ++i, ++vert)
			{
				vert->x = vert->s;
				vert->y = vert->t;
			}
			
		}
		else
		// With rotation
		{
			// Construct a rotation matrix
			
			float rad = -rotation * M_PI / 180.0f;
			
			float cosVal = cosf(rad);
			float sinVal = sinf(rad);
		
			float a, b, c, d;
			a = cosVal;	b = sinVal;
			c = -sinVal; d = cosVal;
			
			float origX, origY;
			
			for(i = 0, vert = &_vertices[0]; i < _numVertices; ++i, ++vert)
			{
				origX = vert->s;
				origY = vert->t;
				
				// newPos = oldPos.x * xVector + oldPos.y * yVector
				
				vert->x = (origX * a) + (origY * c);
				vert->y = (origX * b) + (origY * d);
			}
			
		}
	}
	
	invalidated = NO;
}

@end
