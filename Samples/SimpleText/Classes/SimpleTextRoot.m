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

#import "SimpleTextRoot.h"

@implementation SimpleTextRoot

- (void) initializeAsRoot
{
	self.stage.backgroundColor = 0x454545;

	///////////////////////
	// Simple text field //
	///////////////////////

	txt0 = [PXTextField new];

	txt0.font = @"Helvetica";
	txt0.text = @"This text was rendered on the fly!";
	txt0.fontSize = 30.0f;

	//////////////////
	// Texture font //
	//////////////////

	// Create the font options, which describes the size, character sets and
	// everything else a font needs to know to be loaded into a font sheet.
	PXFontOptions *fontOptions = [PXTextureFontOptions textureFontOptionsWithSize:25.0f
																	characterSets:PXFontCharacterSet_AllLetters
																specialCharacters:@"!,."];

	// Create a texture font by specifying the name:
	PXFont *systemTextureFont = [PXFont fontWithSystemFont:@"American Typewriter" options:fontOptions];

	// Register the font with Pixelwave
	[PXFont registerFont:systemTextureFont withName:@"systemFont"];

	// Now the font can be used by referencing its registered name
	txt1 = [[PXTextField alloc] initWithFont:@"systemFont"];
	txt1.text = @"This text uses a font-sheet";

	///////////////////
	// External font //
	///////////////////

	// Let's create and register a texture font with an external file

	PXFont *externalTextureFont = [PXFont fontWithContentsOfFile:@"akbar.ttf" options:fontOptions];
	[PXFont registerFont:externalTextureFont withName:@"loadedFont"];

	txt2 = [[PXTextField alloc] initWithFont:@"loadedFont"];
	txt2.text = @"This text uses a loaded TrueType font";

	///////////
	// Color //
	///////////

	// Make all the text white
	unsigned int textColor = 0xFFFFFF;

	txt0.textColor = txt1.textColor = txt2.textColor = textColor;

	//////////////
	// Position //
	//////////////

	txt0.align = txt1.align = txt2.align = PXTextFieldAlign_Center;
	txt0.x = txt1.x = txt2.x = self.stage.stageWidth * 0.5f;

	txt0.y = self.stage.stageHeight * 0.15f;
	txt1.y = self.stage.stageHeight * 0.45f;
	txt2.y = self.stage.stageHeight * 0.8f;

	[self addChild:txt0];
	[self addChild:txt1];
	[self addChild:txt2];	
}

- (void) dealloc
{
	// Cleaning up: Release retained objects, remove event listeners, etc.
	[txt0 release];
	[txt1 release];
	[txt2 release];

	txt0 = nil;
	txt1 = nil;
	txt2 = nil;

	[super dealloc];
}

@end
