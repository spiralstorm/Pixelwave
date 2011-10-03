//
//  PKFrameTimer.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/7/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "Pixelwave.h"

@class PKFrameTimerEvent;

@interface PKFrameTimer : PXEventDispatcher
{
@private
	double lastFrameTime;
	PXDisplayObject *displayObject;
	PKFrameTimerEvent *sharedEvent;
}

+ (PKFrameTimer *)sharedFrameTimer;

@end
