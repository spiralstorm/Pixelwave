//
//  PXGraphicsPath.m
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#import "PXGraphicsPath.h"

#include <CoreGraphics/CGGeometry.h>

#import "PXGraphics.h"

@interface PXGraphicsPath(Private)
- (void) addCommand:(PXPathCommand)command data:(float *)data;
@end

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
	float dat[2] = {x, y};
	[self addCommand:PXPathCommand_MoveTo data:dat];
}

- (void) lineToX:(float)x y:(float)y
{
	float dat[2] = {x, y};
	[self addCommand:PXPathCommand_LineTo data:dat];
}

- (void) curveToControlX:(float)controlX controlY:(float)controlY anchorX:(float)anchorX anchorY:(float)anchorY
{
	float dat[4] = {controlX, controlY, anchorX, anchorY};
	[self addCommand:PXPathCommand_CurveTo data:dat];
}

- (void) wideMoveToX:(float)x y:(float)y
{
	float dat[4] = {0.0f, 0.0f, x, y};
	[self addCommand:PXPathCommand_WideMoveTo data:dat];
}

- (void) wideLineToX:(float)x y:(float)y
{
	float dat[4] = {0.0f, 0.0f, x, y};
	[self addCommand:PXPathCommand_WideLineTo data:dat];
}

- (bool) addData:(float)val
{
	float *valPtr = (float*)PXArrayBufferNext(commands);
	if (valPtr == NULL)
		return false;
	*valPtr = val;

	return true;
}

- (void) addCommand:(PXPathCommand)command data:(float *)dat
{
	if (dat == NULL)
		return;

	unsigned int commandCount = PXArrayBufferCount(commands);
	unsigned int dataCount = PXArrayBufferCount(data);

	PXPathCommand* commandPtr = (PXPathCommand*)PXArrayBufferNext(commands);
	if (commandPtr == NULL)
		return;

	*commandPtr = command;

	switch(command)
	{
		case PXPathCommand_NoOp:
			break;
		case PXPathCommand_WideMoveTo:
		case PXPathCommand_WideLineTo:
			dat += 2;
		case PXPathCommand_MoveTo:
		case PXPathCommand_LineTo:
		{
			if ([self addData:*dat] == false)
				goto fail;
			++dat;
			if ([self addData:*dat] == false)
				goto fail;
		}
			break;
		case PXPathCommand_CurveTo:
		{
			if ([self addData:*dat] == false)
				goto fail;
			++dat;
			if ([self addData:*dat] == false)
				goto fail;
			++dat;
			if ([self addData:*dat] == false)
				goto fail;
			++dat;
			if ([self addData:*dat] == false)
				goto fail;
		}
			break;
	}

	goto success;

fail:
	PXArrayBufferUpdateCount(commands, commandCount);
	PXArrayBufferUpdateCount(data, dataCount);
	return;

success:
	return;
}

- (void) _sendToGraphics:(PXGraphics *)graphics
{
	unsigned int commandCount = PXArrayBufferCount(commands);

	if (commandCount == 0)
		return;

	unsigned int dataCount = PXArrayBufferCount(data);

	if (dataCount == 0)
		return;

	float* values = (float*)data->array;
	unsigned int dataIndex = 0;

	[graphics _setWinding:winding];

	PXPathCommand* commandPtr;

	PXArrayBufferForEach(commands, commandPtr)
	{
		// At this point they share the same data as their non wide to commands.
		switch(*commandPtr)
		{
			case PXPathCommand_NoOp:
				break;
			case PXPathCommand_WideMoveTo:
			case PXPathCommand_MoveTo:
			{
				if (dataIndex + 2 >= dataCount)
					return;
				dataIndex += 2;

				[graphics moveToX:*values y:*(values + 1)];
				values += 2;
			}
				break;
			case PXPathCommand_WideLineTo:
			case PXPathCommand_LineTo:
			{
				if (dataIndex + 2 >= dataCount)
					return;
				dataIndex += 2;

				[graphics lineToX:*values y:*(values + 1)];
				values += 2;
			}
				break;
			case PXPathCommand_CurveTo:
			{
				if (dataIndex + 4 >= dataCount)
					return;
				dataIndex += 4;

				[graphics curveToControlX:*values controlY:*(values + 1) anchorX:*(values + 2) anchorY:*(values + 3)];
				values += 4;
			}
				break;
		}
	}
}

@end
