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

#import "SimpleSliderRoot.h"

#import "Slider.h"

// TODO: Remove this line
#import "PXTextureFontOptions.h"

#define REFLECTION_ALPHA 0.05f
static NSString *fontName = @"TrebuchetMS";

@interface SimpleSliderRoot(Private)
- (PXTextField *)newTextField;
- (PXTextField *)textFieldForSlider:(Slider *)slider;
- (void)updateTextField:(PXTextField *)textField withValue:(float)value;
- (PXTextField *)refForTextField:(PXTextField *)txt;
@end

//
// This demo contains:
// - A working slider component with multi-touch support, dynamic skins, 
//   and variable lengths
// - Dynamic text fields
// - A basic reflection effect
//

@implementation SimpleSliderRoot

- (void) initializeAsRoot
{
	PXTexture *bg = [PXTexture textureWithContentsOfFile:@"BG.png"];
	[self addChild:bg];

	PXTextureData *sliderSkin = [PXTextureData textureDataWithContentsOfFile:@"SliderParts.png"];

	slider1 = [Slider sliderWithSkin:sliderSkin];
	[self addChild:slider1];

	slider2 = [Slider sliderWithSkin:sliderSkin];
	[self addChild:slider2];

	slider1.delegate = self;
	slider2.delegate = self;

	slider1.length = self.stage.stageWidth * 0.7f;
	slider1.x = self.stage.stageWidth * 0.15f;
	slider1.y = self.stage.stageHeight * 0.1f;

	slider2.rotation = -90.0f;
	slider2.length = self.stage.stageHeight * 0.7f;
	slider2.x = self.stage.stageWidth * 0.9f;
	slider2.y = (self.stage.stageHeight * 0.85f);

	////////////////////////////////
	// Create the two text fields //
	////////////////////////////////

	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:37
													   characterSets:PXFontCharacterSet_Numerals
												   specialCharacters:@"%"];	
	PXFont *font = [PXFont fontWithSystemFont:fontName options:fontOptions];
	[PXFont registerFont:font withName:fontName];

	[fontOptions release];

	txt1 = [self newTextField];
	[self addChild:txt1];
	txt1.x = (self.stage.stageWidth  * 0.45f);
	txt1.y = (self.stage.stageHeight * 0.65f);
	txt1.align = PXTextFieldAlign_Right;
	[txt1 release];

	txt2 = [self newTextField];
	[self addChild:txt2];
	txt2.x = (self.stage.stageWidth * 0.55f);
	txt2.y = (self.stage.stageHeight * 0.65f);
	txt2.align = PXTextFieldAlign_Left;
	[txt2 release];

	////////////////////////////
	// Create the reflections //
	////////////////////////////

	txt1Ref = [self newTextField];

	txt1Ref.x = txt1.x;
	txt1Ref.y = txt1.y;
	txt1Ref.align = txt1.align;

	txt1Ref.scaleY = -1.0f;
	txt1Ref.y += 40.0f;
	txt1Ref.alpha = REFLECTION_ALPHA;

	[self addChild:txt1Ref];
	[txt1Ref release];

	txt2Ref = [self newTextField];

	txt2Ref.x = txt2.x;
	txt2Ref.y = txt2.y;
	txt2Ref.align = txt2.align;

	txt2Ref.scaleY = -1.0f;
	txt2Ref.y += 40.0f;
	txt2Ref.alpha = REFLECTION_ALPHA;

	[self addChild:txt2Ref];
	[txt2Ref release];

	////////////////////////////
	// Set the initial values //
	////////////////////////////

	slider1.value = 0.5f;
	slider2.value = 0.5f;

	[self updateTextField:txt1 withValue:slider1.value];
	[self updateTextField:txt2 withValue:slider2.value];
}

- (void) dealloc
{
	// Cleaning up: Release retained objects, remove event listeners, etc.

	[super dealloc];
}

- (PXTextField *)newTextField
{
	PXTextField *txt = [[PXTextField alloc] initWithFont:fontName];

	return txt;
}
- (PXTextField *)textFieldForSlider:(Slider *)slider
{
	if (slider == slider1)
	{
		return txt1;
	}
	else if (slider == slider2)
	{
		return txt2;
	}

	return nil;
}

- (PXTextField *)refForTextField:(PXTextField *)txt
{
	if (txt == txt1)
	{
		return txt1Ref;
	}
	else if (txt == txt2)
	{
		return txt2Ref;
	}

	return nil;
}

//

- (void) sliderDidBeginDrag:(Slider *)slider
{
	PXTextField *targetTxt = [self textFieldForSlider:slider];

	targetTxt.textColor = 0x00a8ff;
	[self refForTextField:targetTxt].textColor = targetTxt.textColor;
}
- (void) sliderDidEndDrag:(Slider *)slider
{
	PXTextField *targetTxt = [self textFieldForSlider:slider];

	targetTxt.textColor = 0;
	[self refForTextField:targetTxt].textColor = targetTxt.textColor;
	
}
- (void) slider:(Slider *)slider didChangeValue:(float)value
{
	PXTextField *targetTxt = [self textFieldForSlider:slider];

	[self updateTextField:targetTxt withValue:value];
}

///

- (void) updateTextField:(PXTextField *)textField withValue:(float)value
{
	textField.text = [NSString stringWithFormat:@"%i%%", (int)(value * 100.0f)];
	
	[self refForTextField:textField].text = textField.text;
}

@end
