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

#import "PXFont.h"

#import "PXDebug.h"
#import "PXExceptionUtils.h"

#import "PXLinkedList.h"

#import "PXFontOptions.h"
#import "PXFontParser.h"
#import "PXFontLoader.h"

#import <UIKit/UIFont.h>

NSMutableDictionary *pxFonts = nil;

/**
 * The base class for all fonts.
 *
 * Also lets the user register fonts and query for available system fonts.
 *
 * @see PXTextField
 * @see PXTextureFont
 */
@implementation PXFont

- (id) init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

/**
 * Makes a new font that has parses the data given.
 *
 * @param data The data to parse.
 * @param options The options that describe what type of font you want back. If
 * `nil` is supplied, then the default type of font for the font
 * type is used. If no default type is found, then no new font can be made.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	NSData *data = [[NSData alloc] initWithContentsOfFile:@"font.ttf"];
 *	PXTextureFont *font = [PXFont initWithData:data options:fontOptions];
 *	// font retain count = 1
 *	[PXFont registerFont:font withName:@"font1"];
 *	// font retain count = 2
 *	[font release];
 *	// font retain count = 1
 *	[fontOptions release];
 *	[data release];
 *
 *	// Size 12 font loaded from a true type font file, it contains all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "font1".
 */
- (id) initWithData:(NSData *)data options:(PXFontOptions *)options
{
	self = [super init];

	if (self)
	{
		PXFontParser *fontParser = [[PXFontParser alloc] initWithData:data
																 options:options];
		PXFont *newFont = [fontParser newFont];

		[fontParser release];

		[self release];

		self = newFont;
	//	if (self)
	//	{
	//	}
	}

	return self;
}
/**
 * Makes a new font that has parses the data described in the system font.
 *
 * @param systemFont The system font to parse.
 * @param options The options that describe what type of font you want back. If
 * `nil` is supplied, then the default type of font for the font
 * type is used. If no default type is found, then no new font can be made.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXTextureFont *font = [PXFont initWithSystemFont:@"helvetica" options:fontOptions];
 *	// font retain count = 1
 *	[PXFont registerFont:font withName:@"helvetica"];
 *	// font retain count = 2
 *	[font release];
 *	// font retain count = 1
 *	[fontOptions release];
 *
 *	// Size 12 font, helvetica, will be parsed. It will contain all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "helvetica".
 */
- (id) initWithSystemFont:(NSString *)systemFont options:(PXFontOptions *)options
{
	self = [super init];

	if (self)
	{
		PXFontParser *fontParser = [[PXFontParser alloc] initWithSystemFont:systemFont
																	   options:options];
		PXFont *newFont = [fontParser newFont];

		[fontParser release];

		[self release];

		self = newFont;
	//	if (self)
	//	{
	//	}
	}

	return self;
}

- (void) dealloc
{
	[super dealloc];
}

#pragma mark -
#pragma mark Methods

- (PXFontRenderer *)_newFontRenderer
{
	return nil;
}

////////////////////
// Static Methods //
////////////////////

#pragma mark -
#pragma mark Static Methods

/**
 * Registers a font to the font library with the given name.  To access this
 * font again use [PXFont fontWithName:]
 *
 * @param font The font to be registered.
 * @param name The name you wish to reference the font by.
 *
 * @return The registered font.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithSystemFont:@"helvetica" options:fontOptions];
 *
 *	// If the loading failed, don't register anything
 *	if (!fontLoader)
 *	{
 *		// Handle this problem
 *	}
 *	PXTextureFont *font = (PXTextureFont *)([fontLoader newFont]);
 *	// font retain count = 1
 *	[fontLoader release];
 *	[fontOptions release];
 *
 *	// Register the font, then release our copy.
 *	[PXFont registerFont:font withName:@"font1"];
 *	// font retain count = 2
 *	[font release];
 *	// font retain count = 1
 *	// Size 12 Helvetica font with all letters, numbers and special characters
 *	// ',.' will now be registered under the name "font1".
 */
+ (PXFont *)registerFont:(PXFont *)font withName:(NSString *)name
{
	if (!font)
	{
		PXDebugLog(@"PXFont:registerFont withName: Error - Attempting to register a nil font with name:%@", name);

		return nil;
	}

	// If our dictionary doesn't exist, then make a new one.
	if (!pxFonts)
	{
		pxFonts = [NSMutableDictionary new];
	}
	else if ([pxFonts objectForKey:name])
	{
		PXDebugLog(@"PXFont:registerFont withName: Error - Attempting to register a font with a name (%@) %@",
				   name, @"that is already taken.  Canceling registration.");
		return nil;
	}

	// Add the font to the dictionary.
	[pxFonts setObject:font forKey:name];

	return font;
}

/**
 * Loads, parses and registers a font to the font library with the given name.
 * To access this font again use [PXFont fontWithName:]
 *
 * @param path The location of the font to load.
 * @param name The name you wish to reference the font by.
 * @param options The options that describe how to parse the font.
 *
 * @return The registered font.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXTextureFont *font = [PXFont registerFontWithContentsOfFile:@"font.ttf" name:@"font1" options:fontOptions];
 *	// font retain count = 1
 *	[fontOptions release];
 *
 *	// Size 12 font loaded from a true type font file, it contains all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "font1".
 */
+ (PXFont *)registerFontWithContentsOfFile:(NSString *)path
									  name:(NSString *)name
								   options:(PXFontOptions *)options
{
	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithContentsOfFile:path
																	options:options];
	PXFont *font = [fontLoader newFont];

	[PXFont registerFont:font withName:name];

	[font release];
	[fontLoader release];

	return font;
}

/**
 * Loads, parses and registers a font to the font library with the given name.
 * To access this font again use [PXFont fontWithName:]
 *
 * @param url The location of the font to load.
 * @param name The name you wish to reference the font by.
 * @param options The options that describe how to parse the font.
 *
 * @return The registered font.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXTextureFont *font = [PXFont registerFontWithContentsOfURL:[NSURL URLWithString:@"www.myWebsite.com/font.ttf"]
 *	                                                       name:@"font1"
 *	                                                    options:fontOptions];
 *	// font retain count = 1
 *	[fontOptions release];
 *
 *	// Size 12 font loaded from a true type font file, it contains all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "font1".
 */
+ (PXFont *)registerFontWithContentsOfURL:(NSURL *)url
									 name:(NSString *)name
								  options:(PXFontOptions *)options
{
	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithContentsOfURL:url
																   options:options];
	PXFont *font = [fontLoader newFont];

	[PXFont registerFont:font withName:name];

	[font release];
	[fontLoader release];

	return font;
}
/**
 * Parses and registers a font to the font library with the given name. To
 * access this font again use [PXFont fontWithName:]
 *
 * @param data The loaded font data.
 * @param name The name you wish to reference the font by.
 * @param options The options that describe how to parse the font.
 *
 * @return The registered font.
 *
 * **Example:**
 *	NSData *data = [[NSData alloc] initWithContentsOfFile:@"font.ttf"];
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXTextureFont *font = [PXFont registerFontWithData:data name:@"font1" options:fontOptions];
 *	// font retain count = 1
 *	[data release];
 *	[fontOptions release];
 *
 *	// Size 12 font loaded from a true type font file, it contains all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "font1".
 */
+ (PXFont *)registerFontWithData:(NSData *)data
							name:(NSString *)name
						 options:(PXFontOptions *)options
{
	PXFont *font = [[PXFont alloc] initWithData:data options:options];

	[PXFont registerFont:font withName:name];

	[font release];

	return font;
}
/**
 * Parses and registers a font to the font library with the same name. To
 * access this font again use [PXFont fontWithName:]
 *
 * @param systemFont The system font to parse. Note: The name of this font will be the same
 * as the system font.
 * @param options The options that describe how to parse the font.
 *
 * @return The registered font.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXTextureFont *font = [PXFont registerFontWithSystemFont:@"helvetica" options:fontOptions];
 *	// font retain count = 1
 *	[fontOptions release];
 *
 *	// Size 12 font, helvetica, will be parsed. It will contain all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "helvetica".
 */
+ (PXFont *)registerFontWithSystemFont:(NSString *)systemFont
							   options:(PXFontOptions *)options
{
	return [PXFont registerFontWithSystemFont:systemFont
										 name:systemFont
									  options:options];
}
/**
 * Parses and registers a font to the font library with the given name. To
 * access this font again use [PXFont fontWithName:]
 *
 * @param systemFont The system font to parse.
 * @param name The name you wish to reference the font by.
 * @param options The options that describe how to parse the font.
 *
 * @return The registered font.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXTextureFont *font = [PXFont registerFontWithSystemFont:@"helvetica" name:@"font1" options:fontOptions];
 *	// font retain count = 1
 *	[fontOptions release];
 *
 *	// Size 12 font, helvetica, will be parsed. It will contain all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "font1".
 */
+ (PXFont *)registerFontWithSystemFont:(NSString *)systemFont
								  name:(NSString *)name
							   options:(PXFontOptions *)options
{
	PXFont *font = [[PXFont alloc] initWithSystemFont:systemFont options:options];

	[PXFont registerFont:font withName:name];

	[font release];

	return font;
}

/**
 * Unregisters a registered font with the font library associated with the
 * given name.
 *
 * @param name The name of a previously registered font.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithSystemFont:@"helvetica" options:fontOptions];
 *
 *	// If the loading failed, don't register anything
 *	if (!fontLoader)
 *	{
 *		// Handle this problem
 *	}
 *	PXTextureFont *font = (PXTextureFont *)([fontLoader newFont]);
 *	// font retain count = 1
 *	[fontLoader release];
 *	[fontOptions release];
 *
 *	// Register the font, then release our copy.
 *	[PXFont registerFont:font withName:@"font1"];
 *	// font retain count = 2
 *	[font release];
 *	// font retain count = 1
 *	// Size 12 Helvetica font with all letters, numbers and special characters
 *	// ',.' will now be registered under the name "font1".
 *
 *	[PXFont unregisterFontWithName:@"font1"];
 *	// font retain count = 0
 *	font = nil;
 */
+ (void) unregisterFontWithName:(NSString *)name
{
	// If we never made a dictionary, we obviously can't remove anything.
	if (!pxFonts)
	{
		PXDebugLog(@"PXFont:unregisterFontWithName withName: Error - Attempting to unregister a nil font with a name (%@)",
				   name);

		return;
	}

	// Remove the font
	[pxFonts removeObjectForKey:name];

	// If no fonts exist, then we can release our dictionary, we aren't storing
	// anything anyway.
	if ([pxFonts count] == 0)
	{
		[pxFonts release];
		pxFonts = nil;
	}
}

/**
 * Unregisters all registered fonts with the font library.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXFontLoader *systemFontLoader = [[PXFontLoader alloc] initWithSystemFont:@"helvetica" options:fontOptions];
 *	PXFontLoader *externalFontLoader = [[PXFontLoader alloc] initWithContentsOfFile:@"font.ttf" options:fontOptions];
 *
 *	// If the loading failed, don't register anything
 *	if (!systemFontLoader)
 *	{
 *		// Handle this problem
 *	}
 *	if (!externalFontLoader)
 *	{
 *		// Handle this problem
 *	}
 *
 *	PXTextureFont *systemFont = (PXTextureFont *)([systemFontLoader newFont]);
 *	PXTextureFont *externalFont = (PXTextureFont *)([externalFontLoader newFont]);
 *	// systemFont retain count = 1, externalFont retain count = 1
 *
 *	[systemFontLoader release];
 *	[externalFontLoader release];
 *	[fontOptions release];
 *
 *	// Register the font, then release our copy.
 *	[PXFont registerFont:systemFont   withName:@"systemFont"];
 *	[PXFont registerFont:externalFont withName:@"externalFont"];
 *	[systemFont release];
 *	[externalFont release];
 *
 *	[PXFont unregisterAllFonts];
 *	// systemFont retain count = 0, externalFont retain count = 0
 *	systemFont = nil;
 *	externalFont = nil;
 */
+ (void) unregisterAllFonts
{
	// Remove all of the fonts, and release our dictionary.
	[pxFonts removeAllObjects];
	[pxFonts release];
	pxFonts = nil;
}

/**
 * Returns a registered font with the given name.
 *
 * @param name The name of a font previously registered by you.
 *
 * @return The registered font.  If no font was registered with that name, then
 * `nil` will be returned instead.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithSystemFont:@"helvetica" options:fontOptions];
 *
 *	// If the loading failed, don't register anything
 *	if (!fontLoader)
 *	{
 *		// Handle this problem
 *	}
 *	PXTextureFont *font = (PXTextureFont *)([fontLoader newFont]);
 *	// font retain count = 1
 *	[fontLoader release];
 *	[fontOptions release];
 *
 *	// Register the font, then release our copy.
 *	[PXFont registerFont:font withName:@"font1"];
 *	// font retain count = 2
 *	[font release];
 *	// font retain count = 1
 *	// Size 12 Helvetica font with all letters, numbers and special characters
 *	// ',.' will now be registered under the name "font1".
 *
 *	PXFont *registeredFont = [PXFont fontWithName:@"font1"];
 *	// registeredFont will now be the same as font
 */
+ (PXFont *)fontWithName:(NSString *)name
{
	// If no fonts exist, then just return, as no font exists at that name.
	if (!pxFonts)
		return nil;

	// Return the font at that name.
	return [pxFonts objectForKey:name];
}

/**
 * Returns whether or not a font is registered by that name.
 *
 * @param name The name of a font previously registered by you.
 *
 * @return `YES` if a font by that name was registered, otherwise
 * `NO`.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithSystemFont:@"helvetica" options:fontOptions];
 *
 *	// If the loading failed, don't register anything
 *	if (!fontLoader)
 *	{
 *		// Handle this problem
 *	}
 *	PXTextureFont *font = (PXTextureFont *)([fontLoader newFont]);
 *	// font retain count = 1
 *	[fontLoader release];
 *	[fontOptions release];
 *
 *	// Register the font, then release our copy.
 *	[PXFont registerFont:font withName:@"font1"];
 *	// font retain count = 2
 *	[font release];
 *	// font retain count = 1
 *	// Size 12 Helvetica font with all letters, numbers and special characters
 *	// ',.' will now be registered under the name "font1".
 *
 *	[PXFont containsFontWithName:@"font1"]; // YES
 *	[PXFont containsFontWithName:@"font2"]; // NO
 */
+ (BOOL) containsFontWithName:(NSString *)name
{
	return ([PXFont fontWithName:name] == nil) ? NO : YES;
}

/**
 * A list of names of all the available system fonts. These are the font names
 * that can always be passed into the PXTextField.font property without
 * registering	them as font before hand.
 *
 * @see [PXTextField font]
 */
+ (NSArray *)availableSystemFonts
{
	NSMutableArray *list = [[NSMutableArray alloc] init];

	NSArray *familyNames = [UIFont familyNames];
	NSArray *fontNames;

	NSString *familyName;
	NSString *fontName;

	for (familyName in familyNames)
	{
		fontNames = [UIFont fontNamesForFamilyName:familyName];

		for (fontName in fontNames)
		{
			[list addObject:fontName];
		}
	}

	return [list autorelease];
}

/**
 * Checks if the given font name is available. If it is available it can
 * be safely passed to the PXTextField.font property
 *
 * @see [PXTextField font]
 */
+ (BOOL) isSystemFontAvailable:(NSString *)name
{
	NSArray *list = [PXFont availableSystemFonts];

	return [list containsObject:name];
}

/**
 * Makes a font by loading the file and parsing the data.
 *
 * @param path The location of the font to load.
 * @param options The options that describe what type of font you want back. If
 * `nil` is supplied, then the default type of font for the font
 * type is used. If no default type is found, then no new font can be made.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXTextureFont *font = [PXFont fontWithContentsOfFile:@"font.ttf" options:fontOptions];
 *
 *	[PXFont registerFont:font withName:@"font1"];
 *
 *	[fontOptions release];
 *
 *	// Size 12 font loaded from a true type font file, it contains all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "font1".
 */
+ (PXFont *)fontWithContentsOfFile:(NSString *)path options:(PXFontOptions *)options
{
	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithContentsOfFile:path options:options];

	// If the loading failed, don't register anything
	if (!fontLoader)
		return nil;

	// Grab a new instance of it and release the loader.
	PXFont *font = [fontLoader newFont];
	[fontLoader release];

	// Return the pointer to the font.
	return [font autorelease];
}
/**
 * Makes a font by loading the file and parsing the data.
 *
 * @param url The location of the font to load.
 * @param options The options that describe what type of font you want back. If
 * `nil` is supplied, then the default type of font for the font
 * type is used. If no default type is found, then no new font can be made.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXTextureFont *font = [PXFont fontWithContentsOfURL:[NSURL URLWithString:@"www.myWebsite.com/font.ttf"] options:fontOptions];
 *
 *	[PXFont registerFont:font withName:@"font1"];
 *
 *	[fontOptions release];
 *
 *	// Size 12 font loaded from a true type font file, it contains all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "font1".
 */
+ (PXFont *)fontWithContentsOfURL:(NSURL *)url options:(PXFontOptions *)options
{
	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithContentsOfURL:url options:options];

	// If the loading failed, don't register anything
	if (!fontLoader)
		return nil;

	// Grab a new instance of it and release the loader.
	PXFont *font = [fontLoader newFont];
	[fontLoader release];

	// Return the pointer to the font.
	return [font autorelease];
}
/**
 * Makes a font that has parses the data given.
 *
 * @param data The data to parse.
 * @param options The options that describe what type of font you want back. If
 * `nil` is supplied, then the default type of font for the font
 * type is used. If no default type is found, then no new font can be made.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	NSData *data = [[NSData alloc] initWithContentsOfFile:@"font.ttf"];
 *	PXTextureFont *font = [PXFont fontWithData:data options:fontOptions];
 *
 *	[PXFont registerFont:font withName:@"font1"];
 *
 *	[fontOptions release];
 *	[data release];
 *
 *	// Size 12 font loaded from a true type font file, it contains all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "font1".
 */
+ (PXFont *)fontWithData:(NSData *)data options:(PXFontOptions *)options
{
	// Return the pointer to the font.
	return [[[PXFont alloc] initWithData:data options:options] autorelease];
}

/**
 * Makes a font that has parses the data described in the system font.
 *
 * @param systemFont The system font to parse.
 * @param options The options that describe what type of font you want back. If
 * `nil` is supplied, then the default type of font for the font
 * type is used. If no default type is found, then no new font can be made.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:12.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",."]];
 *
 *	PXTextureFont *font = [PXFont fontWithSystemFont:@"helvetica" options:fontOptions];
 *	[PXFont registerFont:font withName:@"helvetica"];
 *	[fontOptions release];
 *
 *	// Size 12 font, helvetica, will be parsed. It will contain all letters,
 *	// numbers and special characters ',.' (assuming those glyphs could be found
 *	// in the file) will now be registered under the name "helvetica".
 */
+ (PXFont *)fontWithSystemFont:(NSString *)systemFontName options:(PXFontOptions *)options
{
	// Return the pointer to the font.
	return [[[PXFont alloc] initWithSystemFont:systemFontName options:options] autorelease];
}

@end
