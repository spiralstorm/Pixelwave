//
//  AppDelegate_iPad.h
//  arc
//
//  Created by John Lattin on 9/21/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pixelwave.h"

@interface AppDelegate_iPad : NSObject <UIApplicationDelegate>
{
@private
    UIWindow *window;
	PXView *pixelView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
