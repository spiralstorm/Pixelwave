/*
 *  _____                       ___                                            
 * /\  _ `\  __                /\_ \                                           
 * \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
 *  \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
 *   \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
 *    \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
 *     \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
 *       
 *           www.pixelwave.org + www.spiralstormgames.com
 *                            ~;   
 *                           ,/|\.           
 *                         ,/  |\ \.                 Core Team: Oz Michaeli
 *                       ,/    | |  \                           John Lattin
 *                     ,/      | |   |
 *                   ,/        |/    |
 *                 ./__________|----'  .
 *            ,(   ___.....-,~-''-----/   ,(            ,~            ,(        
 * _.-~-.,.-'`  `_.\,.',.-'`  )_.-~-./.-'`  `_._,.',.-'`  )_.-~-.,.-'`  `_._._,.
 * 
 * Copyright (c) 2011 Spiralstorm Games http://www.spiralstormgames.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#import "AppDelegate_iPad.h"
#import "ParticlesRoot.h"

@implementation AppDelegate_iPad

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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

	// Create an instance of PXParticlesRoot and set it as
	// the new root of the main display list.
	ParticlesRoot *root = [[ParticlesRoot alloc] init];
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
    [window release];
	[pixelView release];
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
