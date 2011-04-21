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
#import "PXClipRect.h"
#import "PXTexturePadding.h"

#include "PXEngine.h"
#include "PXGL.h"

#include "PXPrivateUtils.h"

#include <CoreGraphics/CoreGraphics.h>

@interface PXTexture(Private)
- (void)validateAnchors;
- (void)resetClip;
- (void)validateVertices;
- (void)setPaddingRaw:(short *)padding;
@end

void PXTextureCalcAABB(PXGLTextureVertex *verts, unsigned char numVerts, short *padding, CGRect *retRect);

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
@synthesize contentWidth, contentHeight, contentRotation;

- (id) init
{
	return [self initWithTextureData:nil];
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
	self = [super init];
	if (self)
	{
		// Only have to do this once, alternatively, you could just call the
		// normal PXGLEnable and PXGLEnableClient state every frame.
		_PXGLStateEnable(&_glState, GL_TEXTURE_2D);
		_PXGLStateEnableClientState(&_glState, GL_TEXTURE_COORD_ARRAY);
		
		contentWidth = 0;
		contentHeight = 0;
		contentRotation = 0.0f;
		
		paddingEnabled = NO;
		
		anchorX = anchorY = 0.0f;
		
		numVerts = 0;
		verts = 0;
		
		textureData = nil;
		
		anchorsInvalidated = NO;
		resetClipFlag = NO;
		
		self.smoothing = NO;
		self.repeat = YES;
		
		self.textureData = _textureData;
	}
	
	return self;
}

- (void) dealloc
{
	self.textureData = nil;
	
	if (verts)
	{
		free(verts);
		verts = 0;
	}
	
	// Just in case
	numVerts = 0;
	
	[super dealloc];
}

// Resets the clip rectangle
- (void) setTextureData:(PXTextureData *)_textureData
{
	if (_textureData == textureData)
		return;
	
	[_textureData retain];
	[textureData release];
	
	textureData = _textureData;
	
	if (textureData)
	{
		// There's a new texture data, reset the clip rectangle to show
		// it all
		resetClipFlag = YES;
	}
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
 *	[tex setClipRectWithX:16 y:16 width:32 height:64 usingAnchorX:0.5f anchorY:0.5f];
 *	// tex would represent a 32x64 image that is part of the whole image of
 *	// happy, starting at (16, 16).  Its anchor will be at (16, 32) in local
 *	// point coordinates.
 *	@endcode
 *
 *	@see #setClipRect:
 */

- (void) setClipRectWithX:(int)x
					 y:(int)y
				 width:(ushort)width
				height:(ushort)height
{
	[self setClipRectWithX:x y:y width:width height:height usingAnchorX:0.0f anchorY:0.0f];
}

- (void) setClipRectWithX:(int)x
					 y:(int)y
				 width:(ushort)width
				height:(ushort)height
			 usingAnchorX:(float)_anchorX
			   anchorY:(float)_anchorY
{
	if (!textureData) return;
	
	PXClipRect *clipRect = [[PXClipRect alloc] initWithX:x
													   y:y
												   width:width
												  height:height
												rotation:0.0f];
	
	self.clipRect = clipRect;
	[clipRect release];
	
	[self setAnchorWithX:_anchorX y:_anchorY];
}

- (void)setClipRect:(PXClipRect *)clipRect
{
	// Can't set a clip rect if there's no texture data
	if (!textureData)
		return;
	
	// If setting the clip to nil, set it to show the entire TextureData
	if (!clipRect)
	{
		resetClipFlag = YES;
		return;
	}
	
	// Calculate the vertices positions
	[clipRect _validate];
	
	// Set the read-only properties
	contentWidth = clipRect->_contentWidth;
	contentHeight = clipRect->_contentHeight;
	contentRotation = clipRect->_contentRotation;
	
	// Set up my vertices array
	if (numVerts != clipRect->_numVertices)
	{
		numVerts = clipRect->_numVertices;
		verts = realloc(verts, sizeof(PXGLTextureVertex) * numVerts);
	}
	
	// Copy the vertex data from the clip rect to me
	
	float contentScaleFactor = textureData.contentScaleFactor;
	
	float sPerPixel = textureData->_sPerPixel * contentScaleFactor;
	float tPerPixel = textureData->_tPerPixel * contentScaleFactor;
	
	PXGLTextureVertex *myVert, *clipVert;
	
	int i;
	for (i = 0, myVert = verts, clipVert = clipRect->_vertices;
		 i < numVerts;
		 ++i, ++myVert, ++clipVert)
	{
		// Convert from pixels to texture coordinates (s, t)
		myVert->s = clipVert->s * sPerPixel;
		myVert->t = clipVert->t * tPerPixel;
		
		// Just copy these directly (they are pre-rotated)
		myVert->x = clipVert->x;
		myVert->y = clipVert->y;
	}
	
	// No need to reset the clip anymore
	resetClipFlag = NO;
	
	// When necessary, update the new vertices to match the anchors
	anchorsInvalidated = YES;
}

- (PXClipRect *)clipRect
{
	// If there's no texture data, there can't be a clip rect
	if (!textureData)
		return nil;
	
	// If the clip needs to be recalculated, do it before returning
	// it to the user
	if (resetClipFlag)
	{
		[self resetClip];
	}
	
	assert(numVerts > 0 && verts);
	
	//////////////////////////////////////////////
	// Reconstruct the clipRect from the coords //
	//////////////////////////////////////////////
	
	// This part is a bit unconventional, but it is done for a reason:
	// Instead of storing the original (unrotated) clip coordinates we just
	// reconstruct that data with the data we have stored.
	// It saves us from storing two more floats, and this method isn't
	// supposed to be super fast any way
	
	PXGLTextureVertex *vert = &verts[0];
	
	float contentScaleFactor = textureData.contentScaleFactor;
	
	float sPerPixel = textureData->_sPerPixel * contentScaleFactor;
	float tPerPixel = textureData->_tPerPixel * contentScaleFactor;
	
	PXClipRect *rect = [[PXClipRect alloc] initWithX:vert->s / sPerPixel
												y:vert->t / tPerPixel
											width:contentWidth
										   height:contentHeight
											rotation:contentRotation];
	
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
	anchorX = val;
	anchorsInvalidated = YES;
}

- (void) setAnchorY:(float)val
{
	anchorY = val;
	anchorsInvalidated = YES;
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
 *	[tex setAnchorWithX:0.5f y:0.5f];
 *	// tex would represent the happy image.  Assuming happy is a 32x64 image,
 *	// then its anchor will be at (16, 32) in local point coordinates.
 *	@endcode
 *
 *	@see PXTextureData
 *	@see PXTextureLoader
 */
- (void) setAnchorWithX:(float)x y:(float)y
{
	anchorX = x;
	anchorY = y;
	anchorsInvalidated = YES;
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
 *	[tex setAnchorWithPointX:16 pointY:32];
 *	// tex would represent the happy image.  Assuming happy is a 32x64 image,
 *	// then its anchor will be at (16, 32) in local point coordinates.
 *	@endcode
 *
 *	@see PXTextureData
 *	@see PXTextureLoader
 */
- (void) setAnchorWithPointX:(float)x pointY:(float)y
{
	if (contentWidth == 0 || contentHeight == 0)
	{
		return;
	}
	
	[self setAnchorWithX:(x / (float)contentWidth)
					y:(y / (float)contentHeight)];
}

#pragma mark Padding

// Private
// For setting the padding efficiently
- (void) setPaddingRaw:(short *)val
{
	if (val)
	{
		paddingEnabled = YES;
		memcpy(padding, val, sizeof(padding));
		
		// Our hit area is different from our drawing area
		PX_ENABLE_BIT(_flags, _PXDisplayObjectFlags_useCustomHitArea);
	}
	else
	{
		paddingEnabled = NO;
		
		// Our hit area is the same as our drawing area
		PX_DISABLE_BIT(_flags, _PXDisplayObjectFlags_useCustomHitArea);
	}
}

- (void) setPaddingWithTop:(short)top
					 right:(short)right
					bottom:(short)bottom
					  left:(short)left
{
	short newPadding[] = {top, right, bottom, left};
	[self setPaddingRaw:newPadding];
}

- (void) setPadding:(PXTexturePadding *)val
{
	if (val)
	{
		short newPadding[] = {val.top, val.right, val.bottom, val.left};
		[self setPaddingRaw:newPadding];
	}
	else
	{
		[self setPaddingRaw:0];
	}

}
- (PXTexturePadding *)padding
{
	if (!paddingEnabled)
		return nil;
	
	PXTexturePadding *texturePadding = [PXTexturePadding new];
	texturePadding.top = padding[0];
	texturePadding.right = padding[1];
	texturePadding.bottom = padding[2];
	texturePadding.left = padding[3];
	
	return [texturePadding autorelease];
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

#pragma mark Validating

// This method assumes that the vertices have been validated before it gets
// called
- (void)validateAnchors
{
	///////////////////////////////////////////////////////
	// Update the vertex positions to the proper anchors //
	///////////////////////////////////////////////////////
	
	// Calculate the aabb
	
	CGRect aabb;
	PXTextureCalcAABB(verts, numVerts, (paddingEnabled ? padding : 0), &aabb);
	
	// Now shift all the vertices to align with the new anchor
	
	float shiftX = -aabb.origin.x - (aabb.size.width) * anchorX;
	float shiftY = -aabb.origin.y - (aabb.size.height) * anchorY;
	
	int i;
	PXGLTextureVertex *vert = &verts[0];
	
	for (i = 0; i < numVerts; ++i, ++vert)
	{
		vert->x += shiftX;
		vert->y += shiftY;
	}
	
	anchorsInvalidated = NO;
}

///

// Reset the clip rectangle to show the entire frame
- (void)resetClip
{
	// This is a bit hacky
	
	// Update the texture coordinates to match the texture data
	float one_scalingFactor = 1.0f / textureData.contentScaleFactor;
	
	PXClipRect *fullRect = [[PXClipRect alloc] initWithX:0.0f
													y:0.0f
												width:textureData->_contentWidth * one_scalingFactor
											   height:textureData->_contentHeight * one_scalingFactor
												rotation:0.0f];
	[self setClipRect:fullRect];
	[fullRect release];
}

- (void)validateVertices
{
	if (resetClipFlag)
	{
		[self resetClip];
	}
	
	assert(verts && numVerts > 0);
	
	if (anchorsInvalidated)
	{
		[self validateAnchors];
	}
}

#pragma mark DisplayObject

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	if (!textureData)
		return;
	if (!verts || numVerts == 0)
		return;
	
	// Make sure the vertices are up to date
	[self validateVertices];
	
	PXTextureCalcAABB(verts, numVerts, (paddingEnabled ? padding : 0), retBounds);
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	//return ((x >= verts[0].x) & (x <= verts[3].x) & (y >= verts[0].y) & (y <= verts[3].y));
	if (!textureData)
		return NO;
	
	// The vertices must be validated before checking their bounding boxes
	[self validateVertices];
	
	CGRect aabb;
	PXTextureCalcAABB(verts, numVerts, (paddingEnabled ? padding : 0), &aabb);
	
	BOOL b = ((x >= aabb.origin.x) &&
			  (x <= aabb.origin.x + aabb.size.width) &&
			  (y >= aabb.origin.y) &&
			  (y <= aabb.origin.y + aabb.size.height));
	
	return b;
}

#pragma Rendering

- (void) _renderGL
{
	if (textureData == nil)
		return;
	
	// Validate the vertices
	{
		// These copied lines are the same as [self validateVertices].
		// We copy and paste for performance
		
		// <COPY>
		if (resetClipFlag)
		{
			[self resetClip];
		}
		
		assert(verts && numVerts > 0);
		
		if (anchorsInvalidated)
		{	
			[self validateAnchors];
		}
		// </COPY>
	}
	
	PXGLBindTexture( GL_TEXTURE_2D, textureData->_glName );
	
	// Validate the smoothing
	if (smoothingType != textureData->_smoothingType)
	{
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, smoothingType);
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, smoothingType);
		textureData->_smoothingType = smoothingType;
	}
	// Validate the wrapping
	if (wrapType != textureData->_wrapType)
	{
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapType);
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapType);
		textureData->_wrapType = wrapType;
	}
	
	// Draw
	PXGLVertexPointer(2, GL_FLOAT, sizeof( PXGLTextureVertex ), &(verts->x));
	PXGLTexCoordPointer(2, GL_FLOAT, sizeof( PXGLTextureVertex ), &(verts->s));
	
	PXGLDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

//////////////
//////////////
//////////////

#pragma mark Utility functions

+ (PXTexture *)texture
{
	return [[PXTexture new] autorelease];
}
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

@end

#pragma mark Utility

// Utility
void PXTextureCalcAABB(PXGLTextureVertex *verts, unsigned char numVerts, short *padding, CGRect *retRect)
{
	PXGLTextureVertex *vert;
	float x, y;
	
	vert = &verts[0];
	x = vert->x;
	y = vert->y;
	
	float minX = x;
	float maxX = x;
	float minY = y;
	float maxY = y;
	
	unsigned char i;
	
	// Start at verts[1]
	++vert;
	for (i = 1; i < numVerts; ++i, ++vert)
	{
		x = vert->x;
		y = vert->y;

		if (x < minX) minX = x;
		if (x > maxX) maxX = x;

		if (y < minY) minY = y;
		if (y > maxY) maxY = y;
	}
	
	if (padding)
	{
		minY -= padding[0]; // top
		maxX += padding[1]; // right
		maxY += padding[2]; // bottom
		minX -= padding[3]; // left
	}
	
	retRect->origin.x = minX;
	retRect->origin.y = minY;
	retRect->size.width = (maxX - minX);
	retRect->size.height = (maxY - minY);
}