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
	ushort x;
	ushort y;
	ushort width;
	ushort height;

	BOOL invalidated;
@public
	// Raw data
	ushort _numVertices;
	PXGLTextureVertex *_vertices;

	// The size of the frame within the texture atlas
	ushort _contentWidth, _contentHeight;
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

@property (nonatomic) ushort x;
@property (nonatomic) ushort y;
@property (nonatomic) ushort width;
@property (nonatomic) ushort height;

/////////////
// Methods //
/////////////

// When making a version of this method without rotation, the compiler freaks
// out because it can't tell the differnce between it and the similarly named
// method in PXRectangle
- (id)initWithX:(ushort)x andY:(ushort)y
	   andWidth:(ushort)width andHeight:(ushort)height
	   rotation:(float)rotation;

- (void)setX:(ushort)x
		   Y:(ushort)y
	   width:(ushort)width
	  height:(ushort)height
	rotation:(float)rotation;

// Utility
+ (PXClipRect *)clipRectWithX:(ushort)x andY:(ushort)y andWidth:(ushort)width andHeight:(ushort)height;
+ (PXClipRect *)clipRectWithX:(ushort)x andY:(ushort)y andWidth:(ushort)width andHeight:(ushort)height rotation:(float)rotation;

@end

@interface PXClipRect(PrivateButPublic)
- (void) _validate;
@end