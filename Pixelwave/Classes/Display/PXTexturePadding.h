//
//  PXTexturePadding.h
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

typedef struct
{
	float top;
	float right;
	float bottom;
	float left;
} _PXTexturePadding;

@interface PXTexturePadding : NSObject <NSCopying>
{
@private
	_PXTexturePadding padding;
}

@property (nonatomic, assign) float top;
@property (nonatomic, assign) float right;
@property (nonatomic, assign) float bottom;
@property (nonatomic, assign) float left;

- (id) initWithTop:(float)top
			 right:(float)right
			bottom:(float)bottom
			  left:(float)left;

- (void) setTop:(float)top
		  right:(float)right
		 bottom:(float)bottom
		   left:(float)left;

+ (PXTexturePadding *)texturePaddingWithTop:(float)top
									  right:(float)right
									 bottom:(float)bottom
									   left:(float)left;

@end

/// @cond DX_IGNORE
@interface PXTexturePadding (PrivateButPublic)
- (id) _initWithPadding:(_PXTexturePadding)padding;
- (void) setPadding:(_PXTexturePadding)padding;
- (_PXTexturePadding) _padding;
+ (PXTexturePadding *)_texturePaddingWithPadding:(_PXTexturePadding)padding;
@end

#ifndef _PX_TEXTURE_PADDING_H_
#define _PX_TEXTURE_PADDING_H_

#ifdef __cplusplus
extern "C" {
#endif

_PXTexturePadding _PXTexturePaddingMake(float top, float right, float bottom, float left);

#ifdef __cplusplus
}
#endif
#endif

/// @endcond
