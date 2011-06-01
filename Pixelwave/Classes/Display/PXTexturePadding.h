//
//  PXTexturePadding.h
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

// TODO: Oz, this class could really be a struct instead that lives in
// PXTexture. This way you don't need to memcpy or have multiple instances of
// the variable living around (ex. in setPaddingWithTop:right:bottom:left there
// is: short newPadding[] = {top, right, bottom, left}; which then gets sent.
// Also accessing the variable will be a lot more clear (ex. padding.left vs
// padding[3]).
@interface PXTexturePadding : NSObject <NSCopying>
{
@private
	float top, right, bottom, left;
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
