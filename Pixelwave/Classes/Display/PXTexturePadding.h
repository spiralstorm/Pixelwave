//
//  PXTexturePadding.h
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

@interface PXTexturePadding : NSObject <NSCopying> {
@private
	short top, right, bottom, left;
}

@property (nonatomic, assign) short top;
@property (nonatomic, assign) short right;
@property (nonatomic, assign) short bottom;
@property (nonatomic, assign) short left;

- (id)initWithTop:(short)top
			right:(short)right
		   bottom:(short)bottom
			 left:(short)left;

- (void)setTop:(short)top
		 right:(short)right
		bottom:(short)bottom
		  left:(short)left;

+ (PXTexturePadding *)texturePaddingWithTop:(short)top
									  right:(short)right
									 bottom:(short)bottom
									   left:(short)left;

@end
