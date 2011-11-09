//
//  PXGraphicsSolidFill.h
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsData.h"
#import "PXGraphicsFill.h"

@interface PXGraphicsSolidFill : NSObject <PXGraphicsData, PXGraphicsFill>
{
@protected
	unsigned int color;
	float alpha;
}

@property (nonatomic, assign) unsigned int color;
@property (nonatomic, assign) float alpha;

- (id) initWithColor:(unsigned int)color;
- (id) initWithColor:(unsigned int)color alpha:(float)alpha;

@end
