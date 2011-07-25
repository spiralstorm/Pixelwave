//
//  PXTexturePadding.h
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

/// @cond DX_IGNORE
#ifndef _PX_TEXTURE_PADDING_H_
#define _PX_TEXTURE_PADDING_H_

typedef struct
{
	float top;
	float right;
	float bottom;
	float left;
} _PXTexturePadding;

#ifdef __cplusplus
extern "C" {
#endif
	
	_PXTexturePadding _PXTexturePaddingMake(float top, float right, float bottom, float left);
	
#ifdef __cplusplus
}
#endif
#endif
/// @endcond


@interface PXTexturePadding : NSObject <NSCopying>
{
@public
	_PXTexturePadding _padding;
}

/**
 *	The amount of padding (in points) to be added to
 *	the top side of the texture;
 */
@property (nonatomic, assign) float top;
/**
 *	The amount of padding (in points) to be added to
 *	the right side of the texture;
 */
@property (nonatomic, assign) float right;
/**
 *	The amount of padding (in points) to be added to
 *	the bottom side of the texture;
 */
@property (nonatomic, assign) float bottom;
/**
 *	The amount of padding (in points) to be added to
 *	the left side of the texture;
 */
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