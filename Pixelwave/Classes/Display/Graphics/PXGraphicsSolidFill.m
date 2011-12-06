//
//  PXGraphicsSolidFill.m
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsSolidFill.h"

#import "PXGraphics.h"

@implementation PXGraphicsSolidFill

@synthesize color;
@synthesize alpha;

- (id) init
{
	return [self initWithColor:0x000000];
}

- (id) initWithColor:(unsigned int)_color
{
	return [self initWithColor:_color alpha:1.0f];
}

- (id) initWithColor:(unsigned int)_color alpha:(float)_alpha
{
	self = [super init];

	if (self)
	{
		self.color = _color;
		self.alpha = _alpha;
	}

	return self;
}

- (void) _sendToGraphics:(PXGraphics *)graphics
{
	[graphics beginFill:color alpha:alpha];
}

- (void) _sendToGraphicsAsStroke:(PXGraphics *)graphics
{
	return;
}

@end
