//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import "___PROJECTNAMEASIDENTIFIER___AppDelegate.h"
#import "___PROJECTNAMEASIDENTIFIER___Root.h"

@implementation ___PROJECTNAMEASIDENTIFIER___AppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// Set the orientation to landscape
	[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
	// Disable the idle timer. This is useful for most interactive applications.
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	
	// Create a new Pixelwave View
	pixelView = [[PXView alloc] initWithFrame:window.frame];	
	// Set some basic settings
	pixelView.stage.backgroundColor = 0x808080;
	pixelView.stage.frameRate = 60;
	pixelView.multipleTouchEnabled = YES;

	// Create an instance of ___PROJECTNAMEASIDENTIFIER___Root and set it as
	// the new root of the main display list.
	___PROJECTNAMEASIDENTIFIER___Root *root = [[___PROJECTNAMEASIDENTIFIER___Root alloc] init];
	[pixelView setRoot:root];
	[root release];

	[root initializeAsRoot];

	// Add the Pixelwave view to the main window.
	[window addSubview:pixelView];

    [self.window makeKeyAndVisible];

    return YES;
}

- (void) dealloc
{
	[pixelView release];
    [window release];
    [super dealloc];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state.
	// This can occur for certain types of temporary interruptions (such as an
	// incoming phone call or SMS message) or when the user quits the
	// application and it begins the transition to the background state.

	// Use this method to pause ongoing tasks, disable timers, and throttle down
	// OpenGL ES frame rates. Games should use this method to pause the game.

	// Pause all Pixelwave operations
	pixelView.stage.playing = NO;
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the
	// application was inactive. If the application was previously in the
	// background, optionally refresh the user interface.

	// Resume all Pixelwave operations
	pixelView.stage.playing = YES;
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate
	// timers, and store enough application state information to restore your
	// application to its current state in case it is terminated later.

	// If your application supports background execution, called instead of
	// applicationWillTerminate: when the user quits.
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of  transition from the background to the inactive state:
	// here you can undo many of the changes made on entering the background.
}

- (void) applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate.

    // See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark Memory management

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    // Free up as much memory as possible by purging cached data objects that
	// can be recreated (or reloaded from disk) later.
}

@end
