//
//  PXGraphicsBitmapFill.h
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsData.h"
#import "PXGraphicsFill.h"

@class PXTextureData;
@class PXMatrix;

@interface PXGraphicsBitmapFill : NSObject <PXGraphicsData, PXGraphicsFill>
{
@protected
	PXTextureData *textureData;
	PXMatrix *matrix;

	BOOL repeat;
	BOOL smooth;
}

@property (nonatomic, retain) PXTextureData *textureData;
@property (nonatomic, copy) PXMatrix *matrix;

@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) BOOL smooth;

- (id) initWithTextureData:(PXTextureData *)textureData;
- (id) initWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix;
- (id) initWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix repeat:(BOOL)repeat;
- (id) initWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix repeat:(BOOL)repeat smooth:(BOOL)smooth;

@end
