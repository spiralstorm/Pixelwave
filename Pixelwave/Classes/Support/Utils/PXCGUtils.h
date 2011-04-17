//
//  PXUIKitUtils.h
//  Pixelwave
//
//  Created by Oz Michaeli on 4/16/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
@class PXTextureData;

CGImageRef PXCGUtilsCreateCGImage(void *pixels, int w, int h, CGAffineTransform *transform);
CGImageRef PXCGUtilsCreateCGImageFromTextureData(PXTextureData *textureData);
CGImageRef PXCGUtilsCreateCGImageFromScreenBuffer();