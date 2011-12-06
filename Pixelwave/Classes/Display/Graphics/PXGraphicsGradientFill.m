//
//  PXGraphicsGradientFill.m
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsGradientFill.h"

#import "PXGraphics.h"

@implementation PXGraphicsGradientFill

@synthesize colors;
@synthesize alphas;
@synthesize ratios;

@synthesize matrix;

@synthesize type;
@synthesize spreadMethod;
@synthesize interpolationMethod;

@synthesize focalPointRatio;

- (id) init
{
	return [self initWithGradientType:PXGradientType_Linear colors:nil alphas:nil ratios:nil];
}

- (id) initWithGradientType:(PXGradientType)_type colors:(NSArray *)_colors alphas:(NSArray *)_alphas ratios:(NSArray *)_ratios
{
	return [self initWithGradientType:_type colors:_colors alphas:_alphas ratios:_ratios matrix:nil];
}

- (id) initWithGradientType:(PXGradientType)_type colors:(NSArray *)_colors alphas:(NSArray *)_alphas ratios:(NSArray *)_ratios matrix:(PXMatrix *)_matrix
{
	return [self initWithGradientType:_type colors:_colors alphas:_alphas ratios:_ratios matrix:_matrix spreadMethod:PXSpreadMethod_Pad];
}

- (id) initWithGradientType:(PXGradientType)_type colors:(NSArray *)_colors alphas:(NSArray *)_alphas ratios:(NSArray *)_ratios matrix:(PXMatrix *)_matrix spreadMethod:(PXSpreadMethod)_spreadMethod
{
	return [self initWithGradientType:_type colors:_colors alphas:_alphas ratios:_ratios matrix:_matrix spreadMethod:_spreadMethod interpolationMethod:PXInterpolationMethod_RGB];
}

- (id) initWithGradientType:(PXGradientType)_type colors:(NSArray *)_colors alphas:(NSArray *)_alphas ratios:(NSArray *)_ratios matrix:(PXMatrix *)_matrix spreadMethod:(PXSpreadMethod)_spreadMethod interpolationMethod:(PXInterpolationMethod)_interpolationMethod
{
	return [self initWithGradientType:_type colors:_colors alphas:_alphas ratios:_ratios matrix:_matrix spreadMethod:_spreadMethod interpolationMethod:_interpolationMethod focalPointRatio:0.0f];
}

- (id) initWithGradientType:(PXGradientType)_type colors:(NSArray *)_colors alphas:(NSArray *)_alphas ratios:(NSArray *)_ratios matrix:(PXMatrix *)_matrix spreadMethod:(PXSpreadMethod)_spreadMethod interpolationMethod:(PXInterpolationMethod)_interpolationMethod focalPointRatio:(float)_focalPointRatio
{
	self = [super init];

	if (self)
	{
		self.type = _type;
		self.colors = _colors;
		self.alphas = _alphas;
		self.ratios = _ratios;
		self.matrix = _matrix;
		self.spreadMethod = _spreadMethod;
		self.interpolationMethod = _interpolationMethod;
		self.focalPointRatio = _focalPointRatio;
	}

	return self;
}

- (void) dealloc
{
	self.colors = nil;
	self.alphas = nil;
	self.ratios = nil;

	self.matrix = nil;

	[super dealloc];
}

- (void) _sendToGraphics:(PXGraphics *)graphics
{
	[graphics beginFillWithGradientType:type colors:colors alphas:alphas ratios:ratios matrix:matrix spreadMethod:spreadMethod interpolationMethod:interpolationMethod focalPointRatio:focalPointRatio];
}

- (void) _sendToGraphicsAsStroke:(PXGraphics *)graphics
{
	[graphics lineStyleWithGradientType:type colors:colors alphas:alphas ratios:ratios matrix:matrix spreadMethod:spreadMethod interpolationMethod:interpolationMethod focalPointRatio:focalPointRatio];
}

@end
