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

#import "SimpleButtonsRoot.h"

@interface SimpleButtonsRoot(Private)
- (void) onFrame:(PXEvent *)event;

- (void) addTouchListeners;
- (void) removeTouchListeners;

- (void) touchUp:(PXTouchEvent *)event;
- (void) touchDown:(PXTouchEvent *)event;
- (void) touchMove:(PXTouchEvent *)event;
@end

//
//  This example explains how to use simple buttons, listen to their events and
//	respond accordingly.
//
//  "Clean before you build, otherwise the dust will get in." - John
//

@implementation SimpleButtonsRoot

- (void) initializeAsRoot
{
	//////////////////////////////
	// Set up initial variables //
	//////////////////////////////

	// Check if we're on an iPad.
	// This variable is used later to see which images we need to load
	// and how we should scale our movemement values

	isIpad = NO;

#ifdef UI_USER_INTERFACE_IDIOM
	isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif

	// Set up where the shadow will fall
	floorY = self.stage.stageHeight * 0.85f;

	slideVelocity = 0.0f;

	/////////////////
	// Load images //
	/////////////////

	// This demo is going to load two images.  The first image will be the one
	// to move around the screen.  The second will be the arrow to control the
	// actions.

	NSString *fileName = nil;

	// Load a background image
	fileName = isIpad ? @"Background-iPad.png" : @"Background.png";
	PXTexture *backgroundImage = [PXTexture textureWithContentsOfFile:fileName];;

	// Load the raccoon
	fileName = isIpad ? @"Rocky@2x.png" : @"Rocky.png";
	raccoon = [PXTexture textureWithContentsOfFile:fileName];

	// Load the shadow
	fileName = isIpad ? @"Shadow@2x.png" : @"Shadow.png";
	shadow = [PXTexture textureWithContentsOfFile:fileName];

	// Load the arrows
	fileName = isIpad ? @"FurryArrow@2x.png" : @"FurryArrow.png";
	PXTextureData *arrowTextureData = [PXTextureData textureDataWithContentsOfFile:fileName];

	fileName = isIpad ? @"FurryArrowGlow@2x.png" : @"FurryArrowGlow.png";
	PXTextureData *arrowDownTextureData = [PXTextureData textureDataWithContentsOfFile:fileName];

	//////////////////////
	// Make the buttons //
	//////////////////////

	// The four different states of the arrow: left up, left down, right up and
	// right down.
	// Both left and right arrows use the same TextureData for their up state.
	// Both left and right arrows use the same TextureData for their down state.

	PXTexture *leftArrowUp    = [[PXTexture alloc] initWithTextureData:arrowTextureData];
	PXTexture *leftArrowDown  = [[PXTexture alloc] initWithTextureData:arrowDownTextureData];

	PXTexture *rightArrowUp   = [[PXTexture alloc] initWithTextureData:arrowTextureData];
	PXTexture *rightArrowDown = [[PXTexture alloc] initWithTextureData:arrowDownTextureData];

	// Set the anchor point of these arrows to the bottom right to make
	// positioning them easier
	//
	//  _____________
	// |             |
	// |             |
	// |     ==>     |
	// |             | 
	// |____________ x  - The anchor point is here, on the bottom right
	// 

	[leftArrowUp setAnchorWithX:1.0f y:1.0f];
	[leftArrowDown setAnchorWithX:1.0f y:1.0f];
	[rightArrowUp setAnchorWithX:1.0f y:1.0f];
	[rightArrowDown setAnchorWithX:1.0f y:1.0f];

	// Make the two simple buttons, one for the left arrow and one for the right
	// arrow.
	leftArrow = [[PXSimpleButton alloc] initWithUpState:leftArrowUp downState:leftArrowDown];
	rightArrow = [[PXSimpleButton alloc] initWithUpState:rightArrowUp downState:rightArrowDown];

	// Make the left arrow point left by flipping it in the horizontal direction
	leftArrow.scaleX = -1.0f;

	// Release the textures, as their retain is now being held by the buttons.
	[leftArrowUp release];
	[leftArrowDown release];
	[rightArrowUp release];
	[rightArrowDown release];

	/////////////////////////
	// Setup everything //
	/////////////////////////

	// Background image
	[self addChild:backgroundImage];

	// Set the raccoon's anchor point to be in the bottom-center to make it
	// easier to align with the shadow
	[raccoon setAnchorWithX:0.5f y:1.0f];

	// Place the raccoon on the floor
	raccoon.x = self.stage.stageWidth * 0.5f;
	raccoon.y = floorY;

	raccoon.smoothing = YES;

	[self addChild:raccoon];

	// Shadow
	[shadow setAnchorWithX:0.5f y:0.5f];
	[self addChild:shadow];

	shadow.smoothing = YES;

	// Move the arrows into the bottom left and right corners.
	leftArrow.x = 0.0f;
	leftArrow.y = self.stage.stageHeight;
	rightArrow.x = self.stage.stageWidth;
	rightArrow.y = self.stage.stageHeight;

	// Add and release the arrows, as this sprite is holding their retain.
	[self addChild:leftArrow];
	[self addChild:rightArrow];
	[leftArrow release];
	[rightArrow release];

	// The initial direction the image is going in will be neither right nor
	// left.
	direction = 0.0f;

	// Add listeners to the buttons.
	[self addTouchListeners];

	// Add a frame listener for animation.
	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame:)];
}

- (void) dealloc
{
	// All retain's have been dealt with up to this point, the super dealloc
	// will completely remove them.  All there is left for us to do is remove
	// the listeners.
	[self removeEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame:)];
	[self removeTouchListeners];

	[super dealloc];
}

- (void) addTouchListeners
{
	// Add listeners to the left and right arrows.
	
	// Note:
	// It's important to listen to the cancel event as not every touch is
	// guaranteed to recieve a touch up event. If the system takes over the
	// focus of the device (to display a text message for example) while a
	// touch is occuring, a cancel event is dispatched instead of up.

	[leftArrow addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(touchDown:)];
	[leftArrow addEventListenerOfType:PXTouchEvent_TouchUp listener:PXListener(touchUp:)];
	[leftArrow addEventListenerOfType:PXTouchEvent_TouchCancel listener:PXListener(touchUp:)];
	[leftArrow addEventListenerOfType:PXTouchEvent_TouchMove listener:PXListener(touchMove:)];

	[rightArrow addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(touchDown:)];
	[rightArrow addEventListenerOfType:PXTouchEvent_TouchUp listener:PXListener(touchUp:)];
	[rightArrow addEventListenerOfType:PXTouchEvent_TouchCancel listener:PXListener(touchUp:)];
	[rightArrow addEventListenerOfType:PXTouchEvent_TouchMove listener:PXListener(touchMove:)];
}
- (void) removeTouchListeners
{
	// Remove the listeners for the left and right arrows.
	[leftArrow removeEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(touchDown:)];
	[leftArrow removeEventListenerOfType:PXTouchEvent_TouchUp listener:PXListener(touchUp:)];
	[leftArrow removeEventListenerOfType:PXTouchEvent_TouchCancel listener:PXListener(touchUp:)];
	[leftArrow removeEventListenerOfType:PXTouchEvent_TouchMove listener:PXListener(touchMove:)];

	[rightArrow removeEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(touchDown:)];
	[rightArrow removeEventListenerOfType:PXTouchEvent_TouchUp listener:PXListener(touchUp:)];
	[rightArrow removeEventListenerOfType:PXTouchEvent_TouchCancel listener:PXListener(touchUp:)];
	[rightArrow removeEventListenerOfType:PXTouchEvent_TouchMove listener:PXListener(touchMove:)];
}

- (void) onFrame:(PXEvent *)event
{
	// If we're on the iPad, let's scale all the movement values
	float scaleMult = isIpad ? 2.0f : 1.0f;

	/////////////////////////
	// Moving side to side //
	/////////////////////////

	// Move the raccoon with some momentum
	slideVelocity += 1.0f * direction;
	raccoon.x += slideVelocity * scaleMult;
	slideVelocity *= 0.9f;

	//////////////
	// Floating //
	//////////////

	// Float our raccoon 20 units up and down
	float floatMagnitude = 20.0;
	float currFloatDistance = sinf(PXGetTimer() * 0.002f) * floatMagnitude;

	raccoon.y = floorY - (40.0f * scaleMult) - currFloatDistance * scaleMult; 

	///////////////////////
	// Update the shadow //
	///////////////////////

	// Make the shadow get smaller and more faded out when the raccoon is
	// further up
	float floatPercent = (currFloatDistance + floatMagnitude) / (floatMagnitude * 2.0f);

	shadow.scale = (1 - floatPercent) * 0.2f + 0.8f;
	shadow.alpha = (1 - floatPercent) * 0.5f + 0.5f;

	shadow.x = raccoon.x;
	shadow.y = floorY;
}
 
- (void) touchUp:(PXTouchEvent *)event
{
	// Upon release we state that there is no correct direction (aka. the image
	// will not move).
	direction = 0.0f;
}
- (void) touchDown:(PXTouchEvent *)event
{
	// If the left arrows is pressed, then set the direction to the left
	// (negative), otherwise the right arrow was pressed, so set the direction
	// to the right (positive).
	if (event.target == leftArrow)
	{
		direction = -1.0f;
	}
	else
	{
		direction =  1.0f;
	}
}

- (void) touchMove:(PXTouchEvent *)event
{
	// If the touch is inside the target, then we can handle this just like the
	// touch down event. Likewise if it is not inside the target then we can
	// handle it like a touch up event.
	if (event.insideTarget == YES)
	{
		[self touchDown:event];
	}
	else
	{
		[self touchUp:event];
	}
}

@end
