//
//  PKBox2DTouchPickerEvent.h
//  PixelKit
//
//  Created by Oz Michaeli on 7/31/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PXEvent.h"
#import "Box2D.h"

#import <UIKit/UIKit.h>

PXExtern NSString * const PKBox2DTouchPickerEvent_PickStart;
PXExtern NSString * const PKBox2DTouchPickerEvent_PickEnd;

@interface PKBox2DTouchPickerEvent : PXEvent
{
@private
	b2Fixture *fixture; // Weak ref
	UITouch *nativeTouch; // Weak ref (Seems to cause crash if retained).
}

@property (nonatomic, readonly) b2Fixture *fixture;
@property (nonatomic, readonly) UITouch	*nativeTouch;

- (id) initWithType:(NSString *)type isCancelable:(BOOL)cancelable fixture:(b2Fixture *)fixture nativeTouch:(UITouch *)nativeTouch;

@end
