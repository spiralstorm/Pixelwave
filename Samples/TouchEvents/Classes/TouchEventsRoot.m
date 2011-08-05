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

#import "TouchEventsRoot.h"

@implementation TouchEventsRoot

- (void) initializeAsRoot
{
	// ------------------------------- Pure Code -------------------------------
	
	self.stage.backgroundColor = 0x454545; // Sexy gray
	
	PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:@"Rocky.png"];
	PXTextureData *data = [loader newTextureData];

	texture = [[PXTexture alloc] initWithTextureData:data];

	[loader release];
	[data release];

	[self addChild:texture];

	texture.anchorX = 0.5f;
	texture.anchorY = 0.5f;
	texture.x = self.stage.stageWidth * 0.5f;
	texture.y = self.stage.stageHeight * 0.5f;

	[self.stage addEventListenerOfType:PXTouchEvent_TouchMove listener:PXListener(moveTexture:)];

	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onEnterFrame:)];
	
	// ------------------------- Detailed Description --------------------------
	// Lets load the texture.
	//PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:@"Rocky.png"];
	//PXTextureData *data = [loader newTextureData];

	// The texture variable is in the header.
	//texture = [[PXTexture alloc] initWithTextureData:data];

	// Lets release the loader and data, we no longer need them now that we have
	// the texture.
	//[loader release];
	//[data release];

	// Add the texture to the screen.
	// Note:	We are keeping a hard referrence to the texture because I am
	//			going to manipulate it outside of this function.  This isn't
	//			necessary as the retain count will still be 1 since "self" is
	//			keeping the referrence to it as it's child.  The retain count of
	//			texture after adding it as a child will be 2, and I will release
	//			it in the dealloc method; which will bring the retain count down
	//			to 1.  Upon the super dealloc being called, our children will be
	//			removed, thus bringing it's retain back down to 0 and it's
	//			dealloc function getting called.
	//[self addChild:texture];

	//texture.scale = 0.5f;
	//texture.anchorX = 0.5f;
	//texture.anchorY = 0.5f;
	//texture.x = self.stage.stageWidth * 0.5f;
	//texture.y = self.stage.stageHeight * 0.5f;

	// Touch event types include:
	// PXTouchEvent_TouchDown
	// PXTouchEvent_TouchUp
	// PXTouchEvent_TouchCancel
	// PXTouchEvent_TouchMove
	// PXTouchEvent_Tap
	// PXListener is a macro that will make a function pointer to your function,
	// the colon ':' states that it will take an argument (in this case a
	// PXTouchEvent).
	// Making the stage itself the listener for this event, thus it will catch
	// any touch to the screen; even if it is not touching the texture itself.
	//[self.stage addEventListenerOfType:PXTouchEvent_TouchMove listener:PXListener(moveTexture:)];
	
	// Listen to ENTER_FRAME events in order to pulsate the image
	//[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onEnterFrame:)];
}

- (void) dealloc
{
	// Release the texture.
	[texture release];

	[self removeEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onEnterFrame:)];

	// Remove the event listener.
	[self.stage removeEventListenerOfType:PXTouchEvent_TouchMove listener:PXListener(moveTexture:)];

	[super dealloc];
}

- (void) onEnterFrame:(PXEvent *)event
{
	texture.alpha = sinf(PXGetTimer() * 0.003f) * 0.35f + 0.65f;
}

- (void) moveTexture:(PXTouchEvent *)event
{
	// Move the middle of texture to where the click is.  It is the middle of
	// the texture that moves because we set the anchor point to [x=0.5f,y=0.5f]
	texture.x = event.stageX;
	texture.y = event.stageY;
}

@end
