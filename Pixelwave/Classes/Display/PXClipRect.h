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
	float rotation;
	
	BOOL invalidated;
	BOOL _padding1, _padding2, _padding3;

@public
	ushort _contentWidth, _contentHeight;
	ushort _numVertices;
	PXGLTextureVertex *_vertices;
}

@property (nonatomic) ushort x;
@property (nonatomic) ushort y;
@property (nonatomic) ushort width;
@property (nonatomic) ushort height;

/**
 *	Avoid using values that aren't multiples of 90.0
 *	(it makes the hit-test act unintuitively). For regular rotation changes
 *	just use
 *	the rotation property
 */
@property (nonatomic) float rotation;

// When making a version of this method without rotation, the compiler freaks
// out because it can't tell the differnce between it and the similarly named
// method in PXRectangle
- (id)initWithX:(ushort)x andY:(ushort)y andWidth:(ushort)width andHeight:(ushort)height rotation:(float)rotation;

// Utility
+ (PXClipRect *)clipRectWithX:(ushort)x andY:(ushort)y andWidth:(ushort)width andHeight:(ushort)height;
+ (PXClipRect *)clipRectWithX:(ushort)x andY:(ushort)y andWidth:(ushort)width andHeight:(ushort)height rotation:(float)rotation;

@end

@interface PXClipRect(PrivateButPublic)
- (void) _validate;
@end