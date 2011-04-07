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

#import "Pixelwave.h"
#import "HelloWorldAppDelegate.h"
#import "HelloWorldRoot.h"

@implementation HelloWorldAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
	// Set the orientation to landscape
	[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
	// Disable the idle timer. This is useful for most games.
	[UIApplication sharedApplication].idleTimerDisabled = YES;

	// Create a new Pixelwave View
	pixelView = [[PXView alloc] initWithFrame:window.frame contentScaleFactor:1.0f];

	// Uncomment the following lines to override the default stage properties
	//pixelView.stage.backgroundColor = 0x888888;
	pixelView.stage.frameRate = 60.0f;

	// Create an instance of HelloWorldRoot and set it as the new Root.
	HelloWorldRoot *root = [[HelloWorldRoot alloc] init];
	[pixelView setRoot:root];
	[root release];

	[root initializeAsRoot];

	// Add the Pixelwave view to the main window.
	[window addSubview:pixelView];

    [window makeKeyAndVisible];
}

- (void) dealloc
{
	[pixelView release];
    [window release];
    [super dealloc];
}

@end