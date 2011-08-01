//
//  PKBox2DTouchPickerEvent.m
//  PixelKit
//
//  Created by Oz Michaeli on 7/31/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PKBox2DTouchPickerEvent.h"

NSString * const PKBox2DTouchPickerEvent_PickStart = @"PickStart";
NSString * const PKBox2DTouchPickerEvent_PickEnd = @"PickEnd";

@implementation PKBox2DTouchPickerEvent

@synthesize fixture, nativeTouch;
	
- (id) initWithType:(NSString *)type isCancelable:(BOOL)cancelable fixture:(b2Fixture *)_fixture nativeTouch:(UITouch *)_nativeTouch
{
	self = [super initWithType:type doesBubble:NO isCancelable:cancelable];
	if (self)
	{
		fixture = _fixture;
		nativeTouch = _nativeTouch;
    }
    
    return self;
}

- (void) dealloc
{
	fixture = NULL;
	nativeTouch = nil;
	
	[super dealloc];
}

- (id) copyWithZone:(NSZone *)zone
{
	PKBox2DTouchPickerEvent *event = [[PKBox2DTouchPickerEvent allocWithZone:zone] initWithType:self.type isCancelable:self.cancelable fixture:fixture nativeTouch:nativeTouch];
	
	return event;
}

@end
