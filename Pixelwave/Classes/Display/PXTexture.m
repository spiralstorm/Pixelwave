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

#import "PXRectangle.h"
#import "PXTextureData.h"

#import "PXTexture.h"

#include "PXEngine.h"
#include "PXGL.h"

/**
 *	@ingroup Display
 *
 *	Used for drawing PXTextureData objects to the screen.
 *	A PXTexture is a subclass of the PXDisplayObject which can be specified to
 *	render an entire texture or just a specific area.
 *
 *	@see PXTextureLoader
 *	@see PXTextureData
 */
@implementation PXTexture

@synthesize textureData;//, smoothing, repeat;
@synthesize anchorX = anchorX, anchorY = anchorY;
@synthesize contentWidth, contentHeight;

- (id) init
{
	if (self = [super init])
	{
		// Only have to do this once, alternatively, you could just call the
		// normal PXGLEnable and PXGLEnableClient state every frame.
		_PXGLStateEnable(&_glState, GL_TEXTURE_2D);
		_PXGLStateEnableClientState(&_glState, GL_TEXTURE_COORD_ARRAY);

		contentWidth = 0;
		contentHeight = 0;

		anchorX = anchorY = 0.0f;

		self.smoothing = NO;
		self.repeat = YES;

		textureData = nil;

		// Set the clipRect to 0,0,0,0
		memset(verts, 0, sizeof( PXGLTextureVertex ) * 4);
	}

	return self;
}

/**
 *	Creates a texture that represents the specified texture data.
 *
 *	@param texture
 *		The texture data that this texture represents.
 *
 *	@b Example:
 *	@code
 *	PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:@"happy.png"];
 *	PXTextureData *data = [loader newTextureData]; 
 *	PXTexture *tex = [[PXTexture alloc] initWithTextureData:data];
 *	@endcode
 *
 *	@see PXTextureData
 *	@see PXTextureLoader
 */
- (id) initWithTextureData:(PXTextureData *)_textureData
{
	if ([self init])
	{
		self.textureData = _textureData;
	}

	return self;
}

- (void) dealloc
{
	self.textureData = nil;

	[super dealloc];
}

// Resets the clip rectangle
- (void) setTextureData:(PXTextureData *)_textureData
{
	[textureData release];

	textureData = [_textureData retain];

	if (textureData)
	{
		float one_scalingFactor = 1.0f / textureData.contentScaleFactor;
		
		[self setClipRectWithX:0
						  andY:0
					  andWidth:textureData->_contentWidth * one_scalingFactor
					 andHeight:textureData->_contentHeight * one_scalingFactor];
	}
}

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	retBounds->origin.x = verts[0].x;
	retBounds->origin.y = verts[0].y;
	retBounds->size.width  = verts[3].x - verts[0].x;
	retBounds->size.height = verts[3].y - verts[0].y;
}

- (BOOL) _containsPointWithLocalX:(float)x andLocalY:(float)y shapeFlag:(BOOL)shapeFlag
{
	return ((x >= verts[0].x) & (x <= verts[3].x) & (y >= verts[0].y) & (y <= verts[3].y));
	/*CGPoint point = CGPointMake( x , y );
	   CGTriangle triangle;
	   CGTriangleMake( triangle , verts[0].x , verts[0].y , verts[1].x , verts[1].y , verts[2].x , verts[2].y );
	   if (PXMathPointInTriangle( point , &triangle ))
	        return YES;

	   return PXMathPointInTriangle( point , &triangle );*/
}

#pragma mark Clipping the texture

/**
 *	Sets the clip area and anchor point in one call.
 *
 *	@param x
 *		The left position of the clip rectangle in points.
 *	@param y
 *		The top position of the clip rectangle in points.
 *	@param width
 *		The width of the clip rectangle in points.
 *	@param height
 *		The height of the clip rectangle in points.
 *	@param anchorX
 *		The horizontal anchor position, in percent.
 *	@param anchorY
 *		The vertical anchor position, in percent.
 *
 *	@b Example:
 *	@code
 *	PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:@"happy.png"];
 *	PXTextureData *data = [loader newTextureData]; 
 *	PXTexture *tex = [[PXTexture alloc] initWithTextureData:data];
 *
 *	[tex setClipRectWithX:16 andY:16 andWidth:32 andHeight:64 usingAnchorX:0.5f andAnchorY:0.5f];
 *	// tex would represent a 32x64 image that is part of the whole image of
 *	// happy, starting at (16, 16).  Its anchor will be at (16, 32) in local
 *	// point coordinates.
 *	@endcode
 *
 *	@see #setClipRect:
 */
- (void) setClipRectWithX:(int)x
					 andY:(int)y
				 andWidth:(ushort)width
				andHeight:(ushort)height
			 usingAnchorX:(float)__anchorX
			   andAnchorY:(float)__anchorY
{
	if (!textureData) return;
	
	contentWidth = width;
	contentHeight = height;
	
	float contentScaleFactor = textureData.contentScaleFactor;
	
	float sPerPixel = textureData->_sPerPixel * contentScaleFactor;
	float tPerPixel = textureData->_tPerPixel * contentScaleFactor;
	
	float minS = x * sPerPixel;
	float minT = y * tPerPixel;
	float maxS = (x + width) * sPerPixel;
	float maxT = (y + height) * tPerPixel;
	
	PXGLTextureVertex *vert;

	// Set the texture coordinates
	//Top Left
	vert = verts + 0;
	vert->s = minS;
	vert->t = minT;
	
	//Top Right
	vert = verts + 1;
	vert->s = maxS;
	vert->t = minT;
	
	//Bottom Left
	vert = verts + 2;
	vert->s = minS;
	vert->t = maxT;
	
	//Bottom Right
	vert = verts + 3;
	vert->s = maxS;
	vert->t = maxT;
	
	[self setAnchorWithX:__anchorX andY:__anchorY];
}

/**
 *	Sets the clip area and anchor point in one call.
 *
 *	@param x
 *		The left position of the clip rectangle in points.
 *	@param y
 *		The top position of the clip rectangle in points.
 *	@param width
 *		The width of the clip rectangle in points.
 *	@param height
 *		The height of the clip rectangle in points.
 *
 *	@see #setClipRect:
 */
- (void) setClipRectWithX:(int)x andY:(int)y andWidth:(ushort)width andHeight:(ushort)height
{
	[self setClipRectWithX:x
					  andY:y
				  andWidth:width
				 andHeight:height
			  usingAnchorX:anchorX
				andAnchorY:anchorY];
}

- (void) setClipRect:(PXRectangle *)clipRect
{
	if (clipRect)
	{
		[self setClipRectWithX:clipRect.x
						  andY:clipRect.y
					  andWidth:clipRect.width
					 andHeight:clipRect.height];
	}
	else
	{
		if (textureData)
		{
			[self setClipRectWithX:0
							  andY:0
						  andWidth:textureData.width
						 andHeight:textureData.height];
		}
		else
		{
			[self setClipRectWithX:0
							  andY:0
						  andWidth:0
						 andHeight:0];
		}
	}
}

- (PXRectangle *)clipRect
{
	PXRectangle *rect = [PXRectangle new];

	PXGLTextureVertex *firstVert = verts;
	PXGLTextureVertex *lastVert  = &(verts[3]);
	// Use the topLeft and bottomRight verts to get the clip rectangle
	rect.x = firstVert->x;
	rect.y = firstVert->y;
	rect.width  = lastVert->x - firstVert->x;
	rect.height = lastVert->y - firstVert->y;

	return [rect autorelease];
}

#pragma mark Properties

- (void) setSmoothing:(BOOL)smoothing
{
	if (smoothing)
		smoothingType = GL_LINEAR;
	else
		smoothingType = GL_NEAREST;
}
- (BOOL) smoothing
{
	return (smoothingType == GL_LINEAR);
}

- (void) setRepeat:(BOOL)repeat
{
	if (repeat)
		wrapType = GL_REPEAT;
	else
		wrapType = GL_CLAMP_TO_EDGE;
}
- (BOOL) repeat
{
	return (wrapType == GL_REPEAT);
}

#pragma mark Anchors

- (void) setAnchorX:(float)val
{
	[self setAnchorWithX:val andY:anchorY];
}

- (void) setAnchorY:(float)val
{
	[self setAnchorWithX:anchorX andY:val];
}

/**
 *	Sets anchor position in percent.  If the texture was 32x64 and you set the x
 *	anchor position to 0.5f, and the y anchor position to 0.5f, then in point
 *	coordinates the anchor would be at (16, 32) in local point coordinates.  The
 *	anchor position is what the texture will rotate and position itself around.
 *
 *	@param x
 *		The horizontal anchor position, in percent where 0.0f <= x <= 1.0f.
 *	@param y
 *		The vertical anchor position, in percent where 0.0f <= y <= 1.0f.
 *
 *	@b Example:
 *	@code
 *	PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:@"happy.png"];
 *	PXTextureData *data = [loader newTextureData]; 
 *	PXTexture *tex = [[PXTexture alloc] initWithTextureData:data];
 *
 *	[tex setAnchorWithX:0.5f andY:0.5f];
 *	// tex would represent the happy image.  Assuming happy is a 32x64 image,
 *	// then its anchor will be at (16, 32) in local point coordinates.
 *	@endcode
 *
 *	@see PXTextureData
 *	@see PXTextureLoader
 */
- (void) setAnchorWithX:(float)x andY:(float)y
{
	anchorX = x;
	anchorY = y;

	x *= contentWidth;
	y *= contentHeight;

	PXGLTextureVertex *vert;

	//Top Left
	vert = &verts[0];
	vert->x = -x;
	vert->y = -y;

	//Top Right
	vert = &verts[1];
	vert->x = contentWidth - x;
	vert->y = -y;

	//Bottom Left
	vert = &verts[2];
	vert->x = -x;
	vert->y = contentHeight - y;

	//Bottom Right
	vert = &verts[3];
	vert->x = contentWidth - x;
	vert->y = contentHeight - y;
}

/**
 *	Sets anchor position in points, relative to the current textureData.
 *	If #textureData is <code>nil</code>, this method call is ignored.
 *
 *	@param x
 *		The horizontal anchor position in points, within the textureData.
 *	@param y
 *		The vertical anchor position in points, within the textureData.
 *
 *	@b Example:
 *	@code
 *	PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:@"happy.png"];
 *	PXTextureData *data = [loader newTextureData]; 
 *	PXTexture *tex = [[PXTexture alloc] initWithTextureData:data];
 *
 *	[tex setAnchorWithPointX:16 andPointY:32];
 *	// tex would represent the happy image.  Assuming happy is a 32x64 image,
 *	// then its anchor will be at (16, 32) in local point coordinates.
 *	@endcode
 *
 *	@see PXTextureData
 *	@see PXTextureLoader
 */
- (void) setAnchorWithPointX:(float)x andPointY:(float)y
{
	if (contentWidth == 0 || contentHeight == 0)
	{
		return;
	}

	[self setAnchorWithX:(x / (float)contentWidth) andY:(y / (float)contentHeight)];
}

#pragma Rendering

- (void) _renderGL
{
	if (textureData == nil)
		return;

//	PXGLEnable( GL_TEXTURE_2D );
//	PXGLEnableClientState( GL_TEXTURE_COORD_ARRAY );

	PXGLBindTexture( GL_TEXTURE_2D, textureData->_glName );

	if (smoothingType != textureData->_smoothingType)
	{
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, smoothingType);
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, smoothingType);
		textureData->_smoothingType = smoothingType;
	}
	if (wrapType != textureData->_wrapType)
	{
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapType);
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapType);
		textureData->_wrapType = wrapType;
	}

	PXGLVertexPointer(2, GL_FLOAT, sizeof( PXGLTextureVertex ), &(verts->x));
	PXGLTexCoordPointer(2, GL_FLOAT, sizeof( PXGLTextureVertex ), &(verts->s));

	PXGLDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark Utility functions

/**
 *	Creates an autoreleased PXTexture object with the given PXTextureData object
 *
 *	@see PXTextureData
 */
+ (PXTexture *)textureWithTextureData:(PXTextureData *)textureData
{
	return [[[PXTexture alloc] initWithTextureData:textureData] autorelease];
}
+ (PXTexture *)textureWithContentsOfFile:(NSString *)path
{
	return [PXTexture textureWithContentsOfFile:path modifier:nil];
}
+ (PXTexture *)textureWithContentsOfFile:(NSString *)path modifier:(id<PXTextureModifier>)modifier
{
	PXTextureLoader *textureLoader = [[PXTextureLoader alloc] initWithContentsOfFile:path
																		   modifier:modifier];
	PXTextureData *textureData = [textureLoader newTextureData];

	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];

	[textureData release];
	[textureLoader release];

	return [texture autorelease];
}

+ (PXTexture *)textureWithContentsOfURL:(NSURL *)url
{
	return [PXTexture textureWithContentsOfURL:url modifier:nil];
}

+ (PXTexture *)textureWithContentsOfURL:(NSURL *)url modifier:(id<PXTextureModifier>)modifier
{
	PXTextureLoader *textureLoader = [[PXTextureLoader alloc] initWithContentsOfURL:url
																		  modifier:modifier];
	PXTextureData *textureData = [textureLoader newTextureData];

	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];

	[textureData release];
	[textureLoader release];

	return [texture autorelease];
}

+ (PXTexture *)textureWithData:(NSData *)data
{
	return [PXTexture textureWithData:data modifier:nil];
}

+ (PXTexture *)textureWithData:(NSData *)data modifier:(id<PXTextureModifier>)modifier
{
	PXTextureData *textureData = [[PXTextureData alloc] initWithData:data modifier:modifier];

	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];

	[textureData release];

	return [texture autorelease];
}

/*- (id) copyWithZone:(NSZone *)zone
{
	PXTexture *tex = [[[self class] allocWithZone:zone] initWithTextureData:textureData];

	tex.smoothing = self.smoothing;
	tex.repeat = self.repeat;
	tex.anchorX = self.anchorX;
	tex.anchorY = self.anchorY;

	tex.x = self.x;
	tex.y = self.y;
	tex.width = self.width;
	tex.height = self.height;
	tex.rotation = self.rotation;

	tex.transform = self.transform;

	return tex;
}*/

@end
