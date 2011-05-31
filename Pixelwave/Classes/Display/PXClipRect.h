//
//  PXClipRect.h
//  TextureAtlasB
//
//  Created by Oz Michaeli on 4/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PXGL.h"

/**
 *	Describes the clip area within a TextureData object. The coordinates are
 *	in points as opposed to pixels.
 */
@interface PXClipRect : NSObject <NSCopying>
{
@private
	float x;
	float y;
	float width;
	float height;

	BOOL invalidated;
@public
	// Raw data
	ushort _numVertices;
	PXGLTextureVertex *_vertices;

	// The size of the frame within the texture atlas
	float _contentWidth, _contentHeight;
	float _contentRotation;
}

////////////////
// Properties //
////////////////

// General clip shape

/**
 *	Avoid using values that aren't multiples of 90.0
 *	(it makes the hit-test act unintuitively). For regular rotation changes
 *	just use
 *	the rotation property
 */
@property (nonatomic) float rotation;

// Rect specific

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float width;
@property (nonatomic) float height;

/////////////
// Methods //
/////////////

// When making a version of this method without rotation, the compiler freaks
// out because it can't tell the differnce between it and the similarly named
// method in PXRectangle
- (id) initWithX:(float)x y:(float)y width:(float)width height:(float)height rotation:(float)rotation;

- (void) setX:(float)x
			y:(float)y
		width:(float)width
	   height:(float)height
	 rotation:(float)rotation;

// Utility
+ (PXClipRect *)clipRectWithX:(float)x y:(float)y width:(float)width height:(float)height;
+ (PXClipRect *)clipRectWithX:(float)x y:(float)y width:(float)width height:(float)height rotation:(float)rotation;

@end

@interface PXClipRect(PrivateButPublic)
- (void) _validate;
@end
