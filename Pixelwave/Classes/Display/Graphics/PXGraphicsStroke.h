//
//  PXGraphicsStroke.h
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsData.h"

#include "PXGraphicsUtilTypes.h"

@protocol PXGraphicsFill;

@protocol PXGraphicsStroke
@end

@interface PXGraphicsStroke : NSObject <PXGraphicsData, PXGraphicsStroke>
{
@protected
	id<PXGraphicsFill> fill;

	PXLineScaleMode scaleMode;
	PXCapsStyle caps;
	PXJointStyle joints;

	float thickness;
	float miterLimit;

	BOOL pixelHinting;
}

@property (nonatomic, retain) id<PXGraphicsFill> fill;

@property (nonatomic, assign) PXLineScaleMode scaleMode;
@property (nonatomic, assign) PXCapsStyle caps;
@property (nonatomic, assign) PXJointStyle joints;

@property (nonatomic, assign) float thickness;
@property (nonatomic, assign) float miterLimit;

@property (nonatomic, assign) BOOL pixelHinting;

@end
