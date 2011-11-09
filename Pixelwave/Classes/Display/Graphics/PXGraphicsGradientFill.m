//
//  PXGraphicsGradientFill.m
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsGradientFill.h"

@implementation PXGraphicsGradientFill

@synthesize colors;
@synthesize alphas;
@synthesize ratios;

@synthesize matrix;

@synthesize type;
@synthesize spreadMethod;
@synthesize interpolationMethod;

@synthesize focalPointRatio;

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

@end
