//
//  PXClipRect.h
//  TextureAtlasB
//
//  Created by Oz Michaeli on 4/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PXGL.h"

@interface PXClipRect : NSObject {
@private
	ushort x, y;
	ushort width, height;
	float rotation;
	
	BOOL invalidated;

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

//- (id)initWithX:(ushort)x andY:(ushort)y andWidth:(ushort)width andHeight:(ushort)height;
- (id)initWithX:(ushort)x andY:(ushort)y andWidth:(ushort)width andHeight:(ushort)height rotation:(float)rotation;

@end

@interface PXClipRect(PrivateButPublic)
- (void) _validate;
@end