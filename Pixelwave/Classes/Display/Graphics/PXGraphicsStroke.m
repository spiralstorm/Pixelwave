//
//  PXGraphicsStroke.m
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

/*#import "PXGraphicsStroke.h"

#import "PXGraphicsFill.h"

@implementation PXGraphicsStroke

@synthesize fill;

@synthesize scaleMode;
@synthesize caps;
@synthesize joints;

@synthesize thickness;
@synthesize miterLimit;

@synthesize pixelHinting;

- (id) init
{
	return [self initWithThickness:NAN];
}

- (id) initWithThickness:(float)_thickness
{
	return [self initWithThickness:_thickness pixelHinting:NO];
}

- (id) initWithThickness:(float)_thickness pixelHinting:(BOOL)_pixelHinting
{
	return [self initWithThickness:_thickness pixelHinting:_pixelHinting scaleMode:PXLineScaleMode_Normal];
}

- (id) initWithThickness:(float)_thickness pixelHinting:(BOOL)_pixelHinting scaleMode:(PXLineScaleMode)_scaleMode
{
	return [self initWithThickness:_thickness pixelHinting:_pixelHinting scaleMode:_scaleMode caps:PXCapsStyle_None];
}

- (id) initWithThickness:(float)_thickness pixelHinting:(BOOL)_pixelHinting scaleMode:(PXLineScaleMode)_scaleMode caps:(PXCapsStyle)_caps
{
	return [self initWithThickness:_thickness pixelHinting:_pixelHinting scaleMode:_scaleMode caps:_caps joints:PXJointStyle_Round];
}

- (id) initWithThickness:(float)_thickness pixelHinting:(BOOL)_pixelHinting scaleMode:(PXLineScaleMode)_scaleMode caps:(PXCapsStyle)_caps joints:(PXJointStyle)_joints
{
	return [self initWithThickness:_thickness pixelHinting:_pixelHinting scaleMode:_scaleMode caps:_caps joints:_joints miterLimit:3.0];
}

- (id) initWithThickness:(float)_thickness pixelHinting:(BOOL)_pixelHinting scaleMode:(PXLineScaleMode)_scaleMode caps:(PXCapsStyle)_caps joints:(PXJointStyle)_joints miterLimit:(float)_miterLimit
{
	return [self initWithThickness:_thickness pixelHinting:_pixelHinting scaleMode:_scaleMode caps:_caps joints:_joints miterLimit:_miterLimit fill:nil];
}

- (id) initWithThickness:(float)_thickness pixelHinting:(BOOL)_pixelHinting scaleMode:(PXLineScaleMode)_scaleMode caps:(PXCapsStyle)_caps joints:(PXJointStyle)_joints miterLimit:(float)_miterLimit fill:(id<PXGraphicsFill>)_fill
{
	self = [super init];

	if (self)
	{
		self.thickness = _thickness;
		self.pixelHinting = _pixelHinting;
		self.scaleMode = _scaleMode;
		self.caps = _caps;
		self.joints = _joints;
		self.miterLimit = _miterLimit;
		self.fill = _fill;
	}

	return self;
}

- (void) dealloc
{
	self.fill = nil;

	[super dealloc];
}

@end*/
