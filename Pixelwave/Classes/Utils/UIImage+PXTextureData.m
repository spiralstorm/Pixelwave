//
//  UIImage+PXTextureData.m
//  Pixelwave
//
//  Created by Oz Michaeli on 4/16/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "UIImage+PXTextureData.h"
#import "PXTextureData.h"

@implementation UIImage (PXTextureData)

- (id) initWithTextureData:(PXTextureData *)textureData
{
	//#define TEXTURE
	
	void *pixels;
	
	CGRect clipRect = CGRectMake(0, 0, _contentWidth, _contentHeight);
	
#ifdef TEXTURE
	pixels = PXEngineGetTextureDataPixels(self, clipRect);
#else
	int w, h;
	pixels = PXEngineGetScreenPixels(&w, &h);
	clipRect.size.width = w;
	clipRect.size.height = h;	
#endif
	
	int bytesPerPixel = 4;
	int pixelsArrLen = clipRect.size.width * clipRect.size.height * bytesPerPixel;
	
	// Cocoa stuff	
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = bytesPerPixel * clipRect.size.width;
	
	// Create an image to hold the buffer data
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, pixels, pixelsArrLen, releaseData);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	// TODO: Handle the case where the source texture has premultiplied alpha (if it was loaded by cocoa)
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaLast;// kCGImageAlphaPremultipliedLast;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	BOOL shouldInterpolate = NO;
	
	CGImageRef imageRef = CGImageCreate(clipRect.size.width, clipRect.size.height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, provider, NULL, shouldInterpolate, renderingIntent);
	
	CGDataProviderRelease(provider);
	
	// Create a new image that's a transformation of the first one
	uint32_t *pixels2 = malloc(pixelsArrLen);
	CGContextRef context = CGBitmapContextCreate(pixels2, clipRect.size.width, clipRect.size.height, bitsPerComponent, bytesPerRow, colorSpace,
												 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
	
#ifdef TEXTURE
	CGContextTranslateCTM(context, 0.0, clipRect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
#else
	// TO DO: Find how to rotate the screen buffer to always be on the top left
	//PXStage *stage = PXEngineGetStage();
	
	// Landscape Right
	//CGContextRotateCTM(context, 90 * M_PI/180.0f);
	//CGContextTranslateCTM(context, 480 - 320, -480);//stage.stageHeight);
	
	// Portrait
	//CGContextRotateCTM(context, 0 * M_PI/180.0f);
	//CGContextTranslateCTM(context, 0, 0);//stage.stageHeight);
	
	// Landscape Left
	CGContextRotateCTM(context, -90 * M_PI/180.0f);
	CGContextTranslateCTM(context, -480, 0);//stage.stageHeight);
#endif
	
	// Draw the image into the translated context
	CGContextDrawImage(context, CGRectMake(0, 0, clipRect.size.width, clipRect.size.height), imageRef);
	
	// Get rid of the original image
	CGImageRelease(imageRef);
	
	// Turn the context into the output image
	CGImageRef outputImageRef = CGBitmapContextCreateImage(context);
	
	// Get rid of the context
	CGContextRelease(context);
	free(pixels2);
	
	// Put the results into a UIImage
	UIImage *image = [[UIImage alloc] initWithCGImage:outputImageRef];
	
	// Get rid of the output image
	CGImageRelease(outputImageRef);
	
	// Release the color space
	CGColorSpaceRelease(colorSpace);
	
	return [image autorelease];
}

+ (UIImage *)imageWithTextureData:(PXTextureData *)textureData
{
	return [[[UIImage alloc] initWithTextureData:textureData] autorelease];
}

@end
