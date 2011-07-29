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

#import "HelloWorldRoot.h"

@implementation HelloWorldRoot

- (void) initializeAsRoot
{
	CGPoint center = CGPointMake(self.stage.stageWidth * 0.5f, self.stage.stageHeight * 0.5f);
	PXTextureData *textureData = nil;

	// Background
	// The long way to load a texture
	textureData = [PXTextureData textureDataWithContentsOfFile:@"Background.png"];
	background = [PXTexture textureWithTextureData:textureData];
	[background setAnchorWithX:0.5f y:0.5f];
	background.x = center.x;
	background.y = center.y;
	background.smoothing = YES;
	[self addChild:background];

	// Grid
	// The short way to load a texture
	grid = [PXTexture textureWithContentsOfFile:@"GridBox.png"];

	grid.clipRect = [PXClipRect clipRectWithX:0.0f y:0.0f width:self.stage.stageHeight * 3.0f height:self.stage.stageHeight * 3.0f];
	[grid setAnchorWithX:0.5f y:0.5f];

	grid.alpha = 0.3f;
	grid.smoothing = YES;

	// Place the grid in another container to create an isometric effect
	gridContainer = [PXSimpleSprite new];
	gridContainer.x = center.x;
	gridContainer.y = center.y;
	[self addChild:gridContainer];
	[gridContainer release];

	gridContainer.scaleY = 0.5f;

	[gridContainer addChild:grid];

	// Planet
	planet = [PXTexture textureWithContentsOfFile:@"Planet.png"];

	// Place the registration point in the center of the image
	[planet setAnchorWithX:0.5f y:0.5];
	planet.x = center.x;
	planet.y = center.y;

	// Since this image will be transforming, let's smooth it.
	planet.smoothing = YES;

	[self addChild:planet];

	// Label
	label = [PXTexture textureWithContentsOfFile:@"HelloWorldLabel.png"];
	label.x = center.x;
	label.y = center.y + 170.0f;
	[label setAnchorWithX:0.5f y:0.5f];
	[self addChild:label];

	// Main loop
	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame:)];
}

- (void)onFrame:(PXEvent *)event
{
	planet.rotation += 0.5f;
	grid.rotation -= 0.1f;

	if(background.scale < 1.5f)
	{
		background.scale += 0.0004f;
	}
}

- (void) dealloc
{
	[self removeEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame:)];

	[super dealloc];
}

@end
