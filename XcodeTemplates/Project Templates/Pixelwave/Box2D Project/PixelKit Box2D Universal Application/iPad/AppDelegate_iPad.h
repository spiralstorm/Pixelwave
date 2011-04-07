//
//  AppDelegate_iPad.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
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
