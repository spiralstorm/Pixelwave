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

#import "ImageLoadingRoot.h"

#define IMAGE_FILE_NAME @"Rocky.png"

@interface ImageLoadingRoot(Private)
- (PXTexture *) method1;
- (PXTexture *) method2;
- (void) pureCodeSummary;
@end

//
//  This example explains how to load a texture, and do simple manipulations
//  with it.  If you are just interested in pure code, please check out the
//  method "pureCodeSummary".
//
//  "Clean before you build, otherwise the dust will get in." - John
//

@implementation ImageLoadingRoot

- (void) initializeAsRoot
{
	
	// Set the background color to a sexy gray
	self.stage.backgroundColor = 0x454545;
	
	// There are many different ways to load a file, and many combinations of
	// them.  This sample will show the two most popular ways to load an image,
	// and add it to the screen.

	// One of these two methods is commented out because they do exactly the
	// same thing (in different ways), and at this time we only wish to display
	// one image.  Our preference is method1, however it is up to you how you
	// wish use it.

	// I am going to keep a reference to the texture we made, so that we can
	// manipulate it later.

	PXTexture *texture;
	texture = [self method1];
	//texture = [self method2];

	// Now that the texture has been loaded, and is part of our display list, we
	// can freely manipulate it as we wish.  This example will set the texture
	// to the middle of the screen at 60% of it's original size, rotated to 45
	// degrees.

	// ------------------------------- Pure Code -------------------------------
	
	texture.x = self.stage.stageWidth * 0.5f;
	texture.y = self.stage.stageHeight * 0.5f;
	texture.anchorX = 0.5f;
	texture.anchorY = 0.5f;
	
	// Things to try:
	//texture.scale = 0.5f;
	//texture.smoothing = YES;
	//texture.rotation = 45.0f;

	// ------------------------- Detailed Description --------------------------
	// Let's make it a little smaller, it is larger then we want it to be.
	// 60% the size it was.
	//texture.scale = 0.6f;

	// Note: Setting the scale property changes the scale of both the width and
	// height, the line above is the same as doing.
	//texture.scaleX = 0.6f;
	//texture.scaleY = 0.6f;

	// Next we want to set the anchor of the texture to the middle of the
	// screen.  The anchor is a float value, 0.5 (50%) would represent the
	// middle of the texture.
	//texture.anchorX = 0.5f;
	//texture.anchorY = 0.5f;

	// Now that the anchor is in the middle of the texture, let's move the
	// entire texture to the middle of the screen.
	//texture.x = self.stage.stageWidth * 0.5f;
	//texture.y = self.stage.stageHeight * 0.5f;

	// Lastly we are going to rotate the texture 45 degrees.
	//texture.rotation = 45.0f;
}

- (void) dealloc
{
	// Cleaning up: Release retained objects, remove event listeners, etc.

	[super dealloc];
}

/// Note:	We use pragma mark so that when you look through the class
///			description in xcode, you will notice a horizontal separator.
#pragma mark -

- (PXTexture *) method1
{
	// ------------------------------- Pure Code -------------------------------
	PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:IMAGE_FILE_NAME];
	PXTextureData *data = [loader newTextureData];
	PXTexture *texture = [[PXTexture alloc] initWithTextureData:data];

	[self addChild:texture];

	[loader release];
	[data release];
	[texture release];

	// ------------------------- Detailed Description --------------------------
	// The PXTextureLoader is in charge of loading the texture from the file,
	// the PXTextureData is in charge of storing the pixel data in OpenGL memory
	// and the PXTexture is an instance of the texture that points to the OpenGL
	// memory for drawing.
	//PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:@"pixelwave_logo.png"];
	// Note the word 'new', if a method uses the key-word new, you must make
	// sure to release it's memory as though you have allocated the memory
	// yourself.
	//PXTextureData *data = [loader newTextureData];
	// Initialize the texture with the data we just made.
	//PXTexture *texture = [[PXTexture alloc] initWithTextureData:data];

	// Once we add the texture to the our display list, then we can freely
	// release our hold on it, thus bringing it's retain count back down to 1.
	// You can do this on deallocation, or now, but it must be done at some point
	// to ensure safe memory management.
	//[self addChild:texture];

	// Release the memory, 'self' has a retain on the texture, and texture has a
	// retain on data.  It is not your job to clean them up, they will be taken
	// care of when this display object get's deallocated; as it will release
	// all children it has.
	// Note:	You can release these individually prior to this, I just like to
	//			separate my code for readability.  You can release the loader
	//			after you have made the data, and you can release the data after
	//			you have made the texture.
	//[loader release];
	//[data release];
	//[texture release];

	return texture;
}

- (PXTexture *) method2
{
	// Using the static method of PXTexture to load the texture will return an
	// autoreleased form of the texture, thus there is no release of it after we
	// add it.
	PXTexture *texture = [PXTexture textureWithContentsOfFile:IMAGE_FILE_NAME];
	[self addChild:texture];

	return texture;
}

#pragma mark -
#pragma mark Pure Code Summary
- (void) pureCodeSummary
{
	PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:IMAGE_FILE_NAME];
	PXTextureData *data = [loader newTextureData];
	PXTexture *texture = [[PXTexture alloc] initWithTextureData:data];

	[self addChild:texture];

	[loader release];
	[data release];
	[texture release];

	texture.scale = 0.6f;
	texture.anchorX = 0.5f;
	texture.anchorY = 0.5f;
	texture.x = self.stage.stageWidth * 0.5f;
	texture.y = self.stage.stageHeight * 0.5f;
	texture.rotation = 45.0f;
}

@end
