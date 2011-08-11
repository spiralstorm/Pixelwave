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

#import "CustomFontRoot.h"
#import "TimeLabel.h"

#define COLOR_ANIM_DURATION 10.0f // In seconds

/*
 *	This sample demostrates how to load and display a custom font. Here we
 *	use a font sheet created with "Glyph Designer" (OSX only), but any glyph
 *	maker that can output the Angelcode .fnt format will work.
 *
 *	After setting up the font  we get a little fancy
 *	and display the current time using several TextField objects to emulate
 *	the look of a digital clock. We also use the HSV (Hue, Saturation, Value)
 *	color space to easily animate through all the colors of the rainbow on our
 *	"LED" display.
 *
 *	NOTE: This app is designed for the iPad only. As an exercise you could
 *	try to make it fit into an iPhone app as well. But don't feel bad if you don't.
 */
@implementation CustomFontRoot

- (void) initializeAsRoot
{
	self.stage.backgroundColor = 0x000000;	
	
	//////////////////
	// Font loading //
	//////////////////
	
	[PXFont registerFontWithContentsOfFile:@"myFont.fnt" name:@"myFont" options:nil];
	
	////////////////////////
	// Creating the label //
	////////////////////////
	
	timeLabel = [TimeLabel new];
	[self addChild:timeLabel];

	// Optimization - We are only going to listen to touch events on the stage.
	self.stage.touchChildren = NO;
	
	// Position the label is the initial spot
	[self centerLabel];
	
	///////////////
	// Animation //
	///////////////
	
	animTime = 0.0f;
	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame)];
	
	//////////////////////
	// Auto orientation //
	//////////////////////
	
	self.stage.autoOrients = YES;
	[self.stage addEventListenerOfType:PXStageOrientationEvent_OrientationChange listener:PXListener(orientationChange:)];
	
	// Let's set it up so that the app never rotates upside-down. In order
	// to do that we'll need to listen to the ORIENTATION_CHANGING event and
	// prevent it from proceeding if the orientation is upside-down
	[self.stage addEventListenerOfType:PXStageOrientationEvent_OrientationChanging listener:PXListener(orientationChanging:)];
	
	///////////////////////
	// Touch interaction //
	///////////////////////
	
	// On click, let's toggle between military/non-military time
	[self.stage addEventListenerOfType:PXTouchEvent_Tap listener:PXListener(onTap)];
}

- (void) dealloc
{
	[self.stage removeEventListenerOfType:PXTouchEvent_Tap listener:PXListener(onTap)];
	[self.stage removeEventListenerOfType:PXStageOrientationEvent_OrientationChanging listener:PXListener(orientationChanging:)];
	[self.stage removeEventListenerOfType:PXStageOrientationEvent_OrientationChange listener:PXListener(orientationChange:)];

	[self removeEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame)];
	
	[timeLabel release];
	timeLabel = nil;
	
	[PXFont unregisterFontWithName:@"myFont"];
	
	[super dealloc];
}

/**
 *	The main loop
 */
- (void) onFrame
{
	// Set the label to display the current time
	[timeLabel setTimeWithDate:[NSDate date]];
	
	// Cycle through the colors of the rainbow
	animTime += 1.0f / self.stage.frameRate;
	float hue = fmodf(animTime / COLOR_ANIM_DURATION, 1.0f) * 360.0f;
	
	[timeLabel setHue:hue];
}

- (void) onTap
{
	timeLabel.militaryTime = !timeLabel.militaryTime;
}

/*
 *	This function gets called on init and when the orientation of the
 *	stage changes due to a device rotation
 */
- (void) centerLabel
{
	timeLabel.x = self.stage.stageWidth * 0.5f - timeLabel.width * 0.5f;
	timeLabel.y = self.stage.stageHeight * 0.5f - timeLabel.height * 0.5f;
}

/*
 *	Just for s#!ts and giggles, let's support all orientation except
 *	updside down.
 */
- (void) orientationChanging:(PXStageOrientationEvent *)e
{
	if (e.afterOrientation == PXStageOrientation_PortraitUpsideDown)
	{
		[e preventDefault];
	}
}

/*
 *	When the orientation of the device changes, update the label to be
 *	in the center
 */
- (void) orientationChange:(PXStageOrientationEvent *)e
{
	[self centerLabel];
}

@end
