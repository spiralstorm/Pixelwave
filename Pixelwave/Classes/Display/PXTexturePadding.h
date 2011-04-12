//
//  PXTexturePadding.h
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

@interface PXTexturePadding : NSObject <NSCopying> {
@private
	ushort top, right, bottom, left;
}

@property (nonatomic, assign) ushort top;
@property (nonatomic, assign) ushort right;
@property (nonatomic, assign) ushort bottom;
@property (nonatomic, assign) ushort left;

- (id)initWithTop:(ushort)top
		 andRight:(ushort)right
		andBottom:(ushort)bottom
		  andLeft:(ushort)left;

+ (PXTexturePadding *)texturePaddingWithTop:(ushort)top
								   andRight:(ushort)right
								  andBottom:(ushort)bottom
									andLeft:(ushort)left;

@end
