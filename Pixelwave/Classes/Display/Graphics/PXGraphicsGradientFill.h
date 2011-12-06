//
//  PXGraphicsGradientFill.h
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsData.h"
#import "PXGraphicsFill.h"

#include "PXGraphicsTypes.h"

@class PXMatrix;

@interface PXGraphicsGradientFill : NSObject <PXGraphicsData, PXGraphicsFill>
{
@protected
	NSArray *colors;
	NSArray *alphas;
	NSArray *ratios;

	PXMatrix *matrix;

	PXGradientType type;
	PXSpreadMethod spreadMethod;
	PXInterpolationMethod interpolationMethod;

	float focalPointRatio;
}

@property (nonatomic, copy) NSArray *colors;
@property (nonatomic, copy) NSArray *alphas;
@property (nonatomic, copy) NSArray *ratios;

@property (nonatomic, copy) PXMatrix *matrix;

@property (nonatomic, assign) PXGradientType type;
@property (nonatomic, assign) PXSpreadMethod spreadMethod;
@property (nonatomic, assign) PXInterpolationMethod interpolationMethod;

@property (nonatomic, assign) float focalPointRatio;

- (id) initWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios;
- (id) initWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix;
- (id) initWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod;
- (id) initWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod;
- (id) initWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio;

@end
