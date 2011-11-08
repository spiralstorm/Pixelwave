//
//  PXGraphicsStroke.m
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsStroke.h"

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
	self = [super init];

	if (self)
	{
		fill = NULL;

		scaleMode = PXLineScaleMode_Normal;
		caps = PXCapsStyle_None;
		joints = PXJointStyle_Round;

		thickness = NAN;
		miterLimit = 3.0f;

		pixelHinting = NO;
	}

	return self;
}

- (void) dealloc
{
	self.fill = nil;

	[super dealloc];
}

@end
