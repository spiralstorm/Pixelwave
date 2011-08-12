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

#import "PXFontParser.h"

#import "PXExceptionUtils.h"
#import "PXDebug.h"

#import "PXFont.h"
#import "PXFontOptions.h"

#import "PXFontFuser.h"

/**
 * A PXFontParser takes data, from either the system or given, and parses it
 * into information needed to render the font.
 *
 * **Example:**
 *	NSData *data = [[NSData alloc] initWithContentsOfFile:@"font.fnt"];
 *	PXFontParser *fontParser = [[PXFontParser alloc] initWithData:data options:nil];
 *	PXFont *font = [fontParser newFont];
 *
 *	[PXFont registerFont:font withName:@"font"];
 *	// The font is now registered as the name "font", so any time you want to
 *	// reference it, you can use "font.
 *
 *	[font release];
 *	[fontParser release];
 *	[data release];
 */
@implementation PXFontParser

@synthesize options;
@synthesize contentScaleFactor;

- (id) init
{
	PXDebugLog (@"Can not instanciate a font parser without data and options.");
	[self release];
	return nil;
}

/**
 * Makes a new font parser that parses the data described in the system font
 * and allows you to create a new font.
 *
 * @param systemFont The system font to parse.
 * @param options The options that describe what type of font you want back. If
 * `nil` is supplied, then the default type of font for the font
 * type is used. If no default type is found, then no new font can be made.
 *
 * **Example:**
 *	PXTextureFontOptions *fontOptions = [[PXTextureFontOptions alloc] initWithSize:24.0f
 *	                                                                 characterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                             specialCharacters:@",.!?"]];
 *	PXFontParser *fontParser = [[PXFontParser alloc] initWithSystemFont:@"helvetica" options:fontOptions];
 *	PXFont *font = [fontParser newFont];
 *
 *	[PXFont registerFont:font withName:@"helvetica24"];
 *	// The font is now registered as the name "helvetica24", so any time you
 *	// want to reference it, you can use "font.
 *
 *	[font release];
 *	[fontParser release];
 *	[fontOptions release];
 */
- (id) initWithSystemFont:(NSString *)systemFont options:(PXFontOptions *)_options
{
	return [self initWithData:nil options:_options origin:systemFont];
}

/**
 * Makes a new font parser that parses the given data and allows you to create
 * a new font. This version also stores the origin, in case you need/want it.
 *
 * @param data The loaded data.
 * @param options The options that describe what type of font you want back. If
 * `nil` is supplied, then the default type of font for the font
 * type is used. If no default type is found, then no new font can be made.
 * @param origin The origin of the font.
 *
 * **Example:**
 *	NSData *data = [[NSData alloc] initWithContentsOfFile:@"font.fnt"];
 *	PXFontParser *fontParser = [[PXFontParser alloc] initWithData:data options:nil origin:@"font.fnt"];
 *	PXFont *font = [fontParser newFont];
 *
 *	[PXFont registerFont:font withName:@"font"];
 *	// The font is now registered as the name "font", so any time you want to
 *	// reference it, you can use "font.
 *
 *	[font release];
 *	[fontParser release];
 *	[data release];
 */
- (id) initWithData:(NSData *)_data options:(PXFontOptions *)_options origin:(NSString *)_origin
{
	return [self initWithData:_data options:_options origin:_origin contentScaleFactor:1.0f];
}
/**
 * Makes a new font parser that parses the given data and allows you to create
 * a new font. This version also stores the origin, in case you need/want it.
 *
 * @param data The loaded data.
 * @param options The options that describe what type of font you want back. If
 * `nil` is supplied, then the default type of font for the font
 * type is used. If no default type is found, then no new font can be made.
 * @param origin The origin of the font.
 * @param contentScaleFactor The content scale factor of the parsed font.
 *
 * **Example:**
 *	NSData *data = [[NSData alloc] initWithContentsOfFile:@"font.fnt"];
 *	PXFontParser *fontParser = [[PXFontParser alloc] initWithData:data options:nil origin:@"font.fnt"];
 *	PXFont *font = [fontParser newFont];
 *
 *	[PXFont registerFont:font withName:@"font"];
 *	// The font is now registered as the name "font", so any time you want to
 *	// reference it, you can use "font.
 *
 *	[font release];
 *	[fontParser release];
 *	[data release];
 */
- (id) initWithData:(NSData *)_data options:(PXFontOptions *)_options origin:(NSString *)_origin contentScaleFactor:(float)_contentScaleFactor
{
	self = [super init];

	if (self)
	{
		// Find the real type of parser to use.
		Class realClass = [PXParser parserForData:_data
										   origin:_origin
										baseClass:[PXFontParser class]];

		// If no real parser exists, then we can't do anything
		if (!realClass)
		{
			[self release];
			return nil;
		}

		// Make the new parser.
		PXFontParser *newParser = [[realClass alloc] _initWithData:_data
														   options:_options
															origin:_origin
												contentScaleFactor:_contentScaleFactor];

		// Release ourself, as we are going to become the real parser
		[self release];

		// Become the real parser, and allocate any data we need
		self = newParser;
	//	if (self)
	//	{
	//	}
	}

	return self;
}

- (id) _initWithData:(NSData *)_data
			 options:(PXFontOptions *)_options
			  origin:(NSString *)_origin
  contentScaleFactor:(float)_contentScaleFactor
{
	// Set the data and origin
	self = [super _initWithData:_data origin:_origin];

	if (self)
	{
		contentScaleFactor = _contentScaleFactor;

		// Copy the options, as we can not assume that they will not change on
		// the users side.
		options = [_options copy];

		// Parse the data. If we fail at parsing, give up - there is nothing
		// else we can do.
		if (![self _parse])
		{
			[self release];
			return nil;
		}

		Class fuserType = nil;

		// If no options exist, try to find the default fuser.
		if (!options)
		{
			fuserType = [self defaultFuser];
		}
		else
		{
			fuserType = [PXFontFuser fontFuserTypeForParser:[self class] options:[options class]];
		}

		if (fuserType)
		{
			fontFuser = [[fuserType alloc] initWithParser:self options:options];
		}
		
		if (!fontFuser)
		{
			[self release];
			return nil;
		}
	}

	return self;
}

- (void) dealloc
{
	// Release the copied options
	[options release];
	options = nil;

	// Release the allcoated font
	[fontFuser release];
	fontFuser = nil;

	[super dealloc];
}

/**
 * Creates a new PXFont object containing all information needed to view the
 * font.
 *
 * @return The new PXFont object.
 */
- (PXFont *)newFont
{
	// Return the new font generated by the font fuser.
	return [fontFuser newFont];
}

- (Class) defaultFuser
{
	return nil;
}

- (BOOL) _parse
{
	return NO;
}

@end
