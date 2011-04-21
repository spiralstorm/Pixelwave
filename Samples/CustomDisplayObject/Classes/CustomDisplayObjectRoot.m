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

#import "CustomDisplayObjectRoot.h"

#import "ColorfulHexagon.h"

@implementation CustomDisplayObjectRoot

- (void) initializeAsRoot
{
	// I am going to make a hexagon with the radius being 1/4 the height of the
	// stage.
	hexagon = [[ColorfulHexagon alloc] initWithRadius:(self.stage.stageHeight * 0.25)];
	[self addChild:hexagon];
	[hexagon release];
	
	// Move the hexagon to the center of the screen.
	hexagon.x = self.stage.stageWidth  * 0.5f;
	hexagon.y = self.stage.stageHeight * 0.5f;

	// Listen to frame events, so we can rotate it.
	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame:)];

	// Listen to touch events to see if the hexagon gets touched.
	[self.stage addEventListenerOfType:PXTouchEvent_TouchUp   listener:PXListener(touchUp:)];
	[self.stage addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(checkCollision:)];
	[self.stage addEventListenerOfType:PXTouchEvent_TouchMove listener:PXListener(checkCollision:)];
}

- (void) dealloc
{
	// Cleaning up: Release retained objects, remove event listeners, etc.

	[super dealloc];
}

- (void) touchUp:(PXTouchEvent *)event
{
	// Upon a touch release, we will set the background back to grey.
	self.stage.backgroundColor = 0x888888;
}
- (void) checkCollision:(PXTouchEvent *)event
{
	// If the hexagon is touched then change the background color to green,
	// otherwise keep it grey.
	if ([hexagon hitTestPointWithX:event.stageX y:event.stageY shapeFlag:YES])
		self.stage.backgroundColor = 0x88AA88;
	else
		self.stage.backgroundColor = 0x888888;
}

- (void) onFrame:(PXEvent *)event
{
	// For fun, rotate the hexagon 2 degrees every frame.
	hexagon.rotation += 2.0f;
}

@end
