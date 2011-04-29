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
	short top, right, bottom, left;
}

@property (nonatomic, assign) short top;
@property (nonatomic, assign) short right;
@property (nonatomic, assign) short bottom;
@property (nonatomic, assign) short left;

- (id) initWithTop:(short)top
			right:(short)right
		   bottom:(short)bottom
			 left:(short)left;

- (void) setTop:(short)top
		 right:(short)right
		bottom:(short)bottom
		  left:(short)left;

+ (PXTexturePadding *)texturePaddingWithTop:(short)top
									  right:(short)right
									 bottom:(short)bottom
									   left:(short)left;

@end
