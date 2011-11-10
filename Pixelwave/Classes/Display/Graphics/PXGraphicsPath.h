//
//  PXGraphicsPath.h
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

/*#import "PXGraphicsData.h"

#include "PXArrayBuffer.h"
#include "PXGraphicsUtilTypes.h"

@protocol PXGraphicsPath <NSObject>

@end

@interface PXGraphicsPath : NSObject <PXGraphicsData, PXGraphicsPath>
{
@protected
	PXArrayBuffer *commands;
	PXArrayBuffer *data;

	PXGraphicsPathWinding winding;
}

@property (nonatomic, readonly) PXPathCommand *commands;
@property (nonatomic, readonly) float *data;

@property (nonatomic, readonly) unsigned int commandCount;

@property (nonatomic, assign) PXGraphicsPathWinding winding;

- (id) initWithCommands:(PXPathCommand *)commands commandCount:(unsigned int)commandCount data:(float *)data winding:(PXGraphicsPathWinding)winding;

- (void) moveToX:(float)x y:(float)y;
- (void) lineToX:(float)x y:(float)y;
- (void) curveToControlX:(float)controlX controlY:(float)controlY anchorX:(float)anchorX anchorY:(float)anchorY;
- (void) wideMoveToX:(float)x y:(float)y;
- (void) wideLineToX:(float)x y:(float)y;

@end*/
