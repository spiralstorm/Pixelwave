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

#import "SimpleSoundRoot.h"

@implementation SimpleSoundRoot

- (void) initializeAsRoot
{
	
	// Set the background color of the stage to a sensible gray
	self.stage.backgroundColor = 0x444444;
	
	////////////////////
	// Load the sound //
	////////////////////
	
	sound = [PXSound soundWithContentsOfFile:@"Bell.wav"];
	[sound retain];
	
	///////////////////////
	// Instructions text //
	///////////////////////
	
	txtInstructions = [PXTextField new];
	
	txtInstructions.font = @"Chalkduster";
	txtInstructions.fontSize = 30.0f;
	
	txtInstructions.align = PXTextFieldAlign_Center;
	txtInstructions.textColor = 0xFFFFFF;
	
	txtInstructions.x = self.stage.stageWidth * 0.5f;
	txtInstructions.y = self.stage.stageHeight * 0.5f;
	
	txtInstructions.text = @"[Touch for sound]";
	
	[self addChild:txtInstructions];

	// An optimization - we are only listening to touches on the stage anyway.
	self.stage.touchChildren = NO;
	
	/////////////////////
	// Event Listeners //
	/////////////////////
	
	// Use an ENTER_FRAME event to animate the text
	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame)];
	// Use the TOUCH_DOWN event to play a sound when the screen is pressed
	[self.stage addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(onTouchDown)];
}

- (void) onTouchDown
{
	// Specify the volume and pitch we want to use in a SoundTransform object
	PXSoundTransform *t = [PXSoundTransform soundTransformWithVolume:[PXMath randomFloatInRangeFrom:0.5f to:1.0f] 
															   pitch:[PXMath randomFloatInRangeFrom:0.5f to:2.0f]];
	
	// Play the sound with the random transformation
	[sound playWithStartTime:0 loopCount:0 soundTransform:t];
}

- (void) onFrame
{
	// Pulsate the text so the user doesn't get bored
	txtInstructions.alpha = 0.5 + sinf(PXGetTimerSec() * 2.0f) * 0.5f;
}

- (void) dealloc
{
	// Always remember to remove event listeners
	[self removeEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame)];
	[self removeEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(onTouchDown)];
	
	// Clean up memory
	[sound release];
	sound = nil;
	
	[txtInstructions release];
	txtInstructions = nil;
	
	[super dealloc];
}

@end
