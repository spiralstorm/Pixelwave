//
//  PXClipRect.h
//  TextureAtlasB
//
//  Created by Oz Michaeli on 4/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PXGL.h"

@interface PXClipRect : NSObject <NSCopying> {
@private
	ushort x, y;
	ushort width, height;
	
	BOOL invalidated;
	BOOL _padding1, _padding2, _padding3;
	
@public
	// The size of the frame within the texture atlas
	ushort _contentWidth, _contentHeight;
	float _contentRotation;
	// Always positive, in clock-wise order {top, right, bottom, left}
	ushort *_contentPadding;
	
	ushort _numVertices;
	PXGLTextureVertex *_vertices;
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

@property (nonatomic, readonly) ushort paddingTop;
@property (nonatomic, readonly) ushort paddingRight;
@property (nonatomic, readonly) ushort paddingBottom;
@property (nonatomic, readonly) ushort paddingLeft;

/////////////
// Methods //
/////////////

// When making a version of this method without rotation, the compiler freaks
// out because it can't tell the differnce between it and the similarly named
// method in PXRectangle
- (id)initWithX:(ushort)x andY:(ushort)y
	   andWidth:(ushort)width andHeight:(ushort)height
	   rotation:(float)rotation;

- (id)initWithX:(ushort)x andY:(ushort)y
	   andWidth:(ushort)width andHeight:(ushort)height
	   rotation:(float)rotation
		padding:(ushort *)padding;

/**
 *	@param padding
 *		a C-array of unsigned shorts, 4 items long. Pass 0 to reset the padding
 *		
 */
- (void)setPadding:(ushort *)padding;

// Utility
+ (PXClipRect *)clipRectWithX:(ushort)x andY:(ushort)y andWidth:(ushort)width andHeight:(ushort)height;
+ (PXClipRect *)clipRectWithX:(ushort)x andY:(ushort)y andWidth:(ushort)width andHeight:(ushort)height rotation:(float)rotation;

@end

@interface PXClipRect(PrivateButPublic)
- (void) _validate;
@end