//
//  PXGraphicsPath.m
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsPath.h"

@implementation PXGraphicsPath

@synthesize winding;

- (id) init
{
	return [self initWithCommands:NULL commandCount:0 data:NULL winding:PXPathWinding_EvenOdd];
}

- (id) initWithCommands:(PXPathCommand *)_commands commandCount:(unsigned int)_commandCount data:(float *)_data winding:(PXPathWinding)_winding
{
	self = [super init];

	if (self)
	{
		commands = PXArrayBufferCreatev(sizeof(PXPathCommand));
		data = PXArrayBufferCreatev(sizeof(float));

		if (commands == NULL || data == NULL)
		{
			[self release];
			return nil;
		}

		self.winding = _winding;
	}

	return self;
}

- (void) dealloc
{
	PXArrayBufferRelease(commands);
	PXArrayBufferRelease(data);

	[super dealloc];
}

- (PXPathCommand *)commands
{
	// commands is gauranteed to exist
	return (PXPathCommand *)commands->array;
}

- (float *)data
{
	// data is gauranteed to exist
	return (float *)data->array;
}

- (unsigned int)commandCount
{
	// commands is gauranteed to exist
	return PXArrayBufferCount(commands);
}

- (void) moveToX:(float)x y:(float)y
{
	// TODO: Implement
}

- (void) lineToX:(float)x y:(float)y
{
	// TODO: Implement
}

- (void) curveToControlX:(float)controlX controlY:(float)controlY anchorX:(float)anchorX anchorY:(float)anchorY
{
	// TODO: Implement
}

- (void) wideMoveToX:(float)x y:(float)y
{
	// TODO: Implement
}

- (void) wideLineToX:(float)x y:(float)y
{
	// TODO: Implement
}

@end
