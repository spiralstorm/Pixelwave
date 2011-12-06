//
//  PXGraphicsEndFill.m
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsEndFill.h"

#import "PXGraphics.h"

@implementation PXGraphicsEndFill

- (void) _sendToGraphics:(PXGraphics *)graphics
{
	[graphics endFill];
}

- (void) _sendToGraphicsAsStroke:(PXGraphics *)graphics
{
	[graphics lineStyleWithThickness:NAN color:0 alpha:0.0f pixelHinting:NO scaleMode:PXLineScaleMode_None caps:PXCapsStyle_None joints:PXJointStyle_Bevel miterLimit:1.0f];
}

@end
