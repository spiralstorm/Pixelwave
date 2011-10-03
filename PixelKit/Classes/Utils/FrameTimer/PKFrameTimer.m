//
//  PKFrameTimer.m
//  PXParticles
//
//  Created by Spiralstorm Games on 9/7/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKFrameTimer.h"

#import "PKFrameTimerEvent.h"

static PKFrameTimer *pkFrameTimerSharedInstance = nil;

@implementation PKFrameTimer

- (id) init
{
	self = [super init];

	if (self)
	{
		displayObject = [[PXDisplayObject alloc] init];

		[displayObject addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onEnterFrame)];
		lastFrameTime = PXGetTimerSec();

		sharedEvent = [[PKFrameTimerEvent alloc] initWithType:PKFrameTimerEvent_Tick deltaTime:0.0f];
	}

	return self;
}

- (void) dealloc
{
	[displayObject release];
	displayObject = nil;

	[sharedEvent release];
	sharedEvent = nil;

	[super dealloc];
}

- (void) onEnterFrame
{
	double currentFrameTime = PXGetTimerSec();

	// Calculate how much time has passed.
	sharedEvent->_deltaTime = (float)(currentFrameTime - lastFrameTime);
	lastFrameTime = currentFrameTime;

	[self dispatchEvent:sharedEvent];
}

+ (PKFrameTimer *)sharedFrameTimer
{
	@synchronized(pkFrameTimerSharedInstance)
	{
		if (pkFrameTimerSharedInstance == nil)
		{
			pkFrameTimerSharedInstance = [[PKFrameTimer alloc] init];
		}
	}

	return pkFrameTimerSharedInstance;
}

@end
