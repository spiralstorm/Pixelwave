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

@synthesize x, y, width, height, rotation = _contentRotation;

- (id) init
{
	return [self initWithX:0 y:0
				  width:0 height:0
				  rotation:0.0f];
}

- (id) initWithX:(ushort)_x y:(ushort)_y width:(ushort)_width height:(ushort)_height rotation:(float)_rotation
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

- (void) setX:(ushort)_x y:(ushort)_y width:(ushort)_width height:(ushort)_height rotation:(float)_rotation;
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
	_contentRotation = val;
	invalidated = YES;
}

//
// Methods
//

/*
 *	Turn the raw data into actual vertices that a PXTexture can use
 */
- (void) _validate
{
	if (!invalidated)
		return;

	PXGLTextureVertex *vert;
	
	// This code is specific to the rectangle clip shape
	{
		// TODO: Oz??
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

+ (PXClipRect *)clipRectWithX:(ushort)x y:(ushort)y
					 width:(ushort)width height:(ushort)height
{
	return [[[PXClipRect alloc] initWithX:x y:y
								 width:width height:height
								 rotation:0.0f] autorelease];
}

+ (PXClipRect *)clipRectWithX:(ushort)x y:(ushort)y
					 width:(ushort)width height:(ushort)height
					 rotation:(float)rotation
{
	return [[[PXClipRect alloc] initWithX:x y:y
								 width:width height:height
								 rotation:rotation] autorelease];
}

@end
