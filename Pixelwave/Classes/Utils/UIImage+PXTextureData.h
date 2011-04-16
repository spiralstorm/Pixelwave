//
//  UIImage+PXTextureData.h
//  Pixelwave
//
//  Created by Oz Michaeli on 4/16/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIImage.h>

@class PXTextureData;

@interface UIImage (PXTextureData)
{
	- (id) initWithTextureData:(PXTextureData *)textureData;
	+ (UIImage *)imageWithTextureData:(PXTextureData *)textureData;
}

@end
