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

#import "PXFontLoader.h"

#import "PXDebug.h"

#import "PXFont.h"
#import "PXFontParser.h"
#import "PXFontOptions.h"

#include "PXMathUtils.h"
#include "PXEngine.h"

@interface PXFontLoader(Private)
- (id) initWithContentsOfFile:(NSString *)path
						orURL:(NSURL *)url
					  options:(PXFontOptions *)options;
- (NSString *)updatePath:(NSString *)path;
@end

/**
 * A PXFontLoader loads font information and creats PXFont objects from the
 * loaded information.
 *
 * The following font formats are supported natively:
 * 
 * - .fnt (AngelCode Texture Font Format)
 * - .ttf
 * - .otf
 * - .pfm
 * - .afm
 * - .inf
 * - .cff
 * - .bdf
 * - .pfr
 *
 * **Example:**
 *	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithContentsOfFile:@"font.fnt" options:nil];
 *	PXFont *font = [fontLoader newFont];
 *	[fontLoader release];
 */
@implementation PXFontLoader

/**
 * Creates a new PXFontLoader instance containing the loaded font data returns
 * `nil` if the file could not be found, or the format isn't
 * supported.
 *
 * @param path The path of the font file to load. The file path may be absolute or
 * relative to	the application bundle.
 *
 * **Example:**
 *	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithContentsOfFile:@"font.fnt"];
 *	PXFont *font = [fontLoader newFont];
 *
 *	[PXFont registerFont:font withName:@"font"];
 *	// The font is now registered as the name "font", so any time you want to
 *	// reference it, you can use "font.
 *
 *	[font release];
 *	[fontLoader release];
 */
- (id) initWithContentsOfFile:(NSString *)path
{
	return [self initWithContentsOfFile:path orURL:nil options:nil];
}
/**
 * Creates a new PXFontLoader instance containing the loaded font data returns
 * `nil` if the file could not be found, or the format isn't
 * supported.
 *
 * @param path The path of the font file to load. The file path may be absolute or
 * relative to	the application bundle.
 * @param options The options defining what form of font you want. Ex. If a
 * #PXTextureFontOption is given, then each glyph of the font
 * would be mapped to a texture. If the font file you are loading already
 * has this information, it is also loaded.
 *
 * **Example:**
 *	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithContentsOfFile:@"font.fnt" options:nil];
 *	PXFont *font = [fontLoader newFont];
 *
 *	[PXFont registerFont:font withName:@"font"];
 *	// The font is now registered as the name "font", so any time you want to
 *	// reference it, you can use "font.
 *
 *	[font release];
 *	[fontLoader release];
 */
- (id) initWithContentsOfFile:(NSString *)path options:(PXFontOptions *)_options
{
	return [self initWithContentsOfFile:path orURL:nil options:_options];
}

/**
 * Creates a new PXFontLoader instance containing the loaded font data returns
 * `nil` if the file could not be found, or the format isn't
 * supported.
 *
 * @param url The url of the font to load.
 *
 * **Example:**
 *	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithContentsOfURL:[NSURL URLWithString:@"www.myWebsite.com/font.fnt"]];
 *	PXFont *font = [fontLoader newFont];
 *
 *	[PXFont registerFont:font withName:@"font"];
 *	// The font is now registered as the name "font", so any time you want to
 *	// reference it, you can use "font.
 *
 *	[font release];
 *	[fontLoader release];
 */
- (id) initWithContentsOfURL:(NSURL *)url
{
	return [self initWithContentsOfFile:nil orURL:url options:nil];
}
/**
 * Creates a new PXFontLoader instance containing the loaded font data returns
 * `nil` if the file could not be found, or the format isn't
 * supported.
 *
 * @param url The url of the font to load.
 * @param options The options defining what form of font you want. Ex. If a
 * #PXTextureFontOption is given, then each glyph of the font
 * would be mapped to a texture. If the font file you are loading already
 * has this information, it is also loaded.
 *
 * **Example:**
 *	PXFontLoader *fontLoader = [[PXFontLoader alloc] initWithContentsOfURL:[NSURL URLWithString:@"www.myWebsite.com/font.fnt"] options:nil];
 *	PXFont *font = [fontLoader newFont];
 *
 *	[PXFont registerFont:font withName:@"font"];
 *	// The font is now registered as the name "font", so any time you want to
 *	// reference it, you can use "font.
 *
 *	[font release];
 *	[fontLoader release];
 */

// TODO: Test this method. I have a feeling it won't work with .fnt files
// since they always try to load their companion images from the hard-drive.
- (id) initWithContentsOfURL:(NSURL *)url options:(PXFontOptions *)_options
{
	return [self initWithContentsOfFile:nil orURL:url options:_options];
}

- (id) initWithContentsOfFile:(NSString *)path
						orURL:(NSURL *)url
					  options:(PXFontOptions *)_options
{
	self = [super _initWithContentsOfFile:path orURL:url];

	if (self)
	{
		contentScaleFactor = 1.0f;

		if (path)
		{
			path = [self updatePath:path];

			if (!path)
			{
				[self release];
				return nil;
			}

			[self _setOrigin:path];
		}

		[self _load];

		fontParser = nil;

		self.options = _options;
	}

	return self;
}

- (void) dealloc
{
	[fontParser release];
	fontParser = nil;

	[super dealloc];
}

- (PXFontOptions *)options
{
	return fontParser.options;
}
- (void) setOptions:(PXFontOptions *)_options
{
	[_options retain];

	// Release the parser, we have new options!
	[fontParser release];
	fontParser = nil;

	// Make a parser with the given options.
	fontParser = [[PXFontParser alloc] initWithData:data
											options:_options
											 origin:origin
								 contentScaleFactor:contentScaleFactor];

	[_options release];
}

/**
 * Creates a new PXFont object containing all information needed to view the
 * font.
 *
 * @return The new PXFont object.
 */
- (PXFont *)newFont
{
	if (!fontParser)
	{
		[self _log:@"Could not create a font."];

		return nil;
	}

	return [fontParser newFont];
}

/*
 * Auto-completes the extension of the file if one wasn't provided.
 * This method also checks for a file with the @2x extension in it and returns
 * its name if it finds it. Otherwise it returns the original path.
 *
 */
- (NSString *)updatePath:(NSString *)path
{
	if (!path)
		return nil;

	float scaleFactor = 0.0f;
	path = [PXLoader pathForRetinaVersionOfFile:path retScale:&scaleFactor];
	if (!PXMathIsOne(scaleFactor))
	{
		contentScaleFactor = PXEngineGetContentScaleFactor();
	}

	return path;
}

/**
 * Creates a PXFontLoader instance containing the loaded font data returns
 * `nil` if the file could not be found, or the format isn't
 * supported.
 *
 * @param path The path of the font file to load. The file path may be absolute or
 * relative to	the application bundle.
 * @param options The options defining what form of font you want. Ex. If a
 * #PXTextureFontOption is given, then each glyph of the font
 * would be mapped to a texture. If the font file you are loading already
 * has this information, it is also loaded.
 *
 * @return The resulting, `autoreleased`, #PXFontLoader object.
 *
 * **Example:**
 *	PXFontLoader *fontLoader = [PXFontLoader fontLoaderWithContentsOfFile:@"font.fnt" options:nil];
 *	PXFont *font = [fontLoader newFont];
 *
 *	[PXFont registerFont:font withName:@"font"];
 *	// The font is now registered as the name "font", so any time you want to
 *	// reference it, you can use "font.
 *
 *	[font release];
 */
+ (PXFontLoader *)fontLoaderWithContentsOfFile:(NSString *)path options:(PXFontOptions *)options
{
	return [[[PXFontLoader alloc] initWithContentsOfFile:path options:options] autorelease];
}
/**
 * Creates a PXFontLoader instance containing the loaded font data returns
 * `nil` if the file could not be found, or the format isn't
 * supported.
 *
 * @param url The url of the font to load.
 * @param options The options defining what form of font you want. Ex. If a
 * #PXTextureFontOption is given, then each glyph of the font
 * would be mapped to a texture. If the font file you are loading already
 * has this information, it is also loaded.
 *
 * @return The resulting, `autoreleased`, #PXFontLoader object.
 *
 * **Example:**
 *	PXFontLoader *fontLoader = [PXFontLoader fontLoaderWithContentsOfURL:[NSURL URLWithString:@"www.myWebsite.com/font.fnt"] options:nil];
 *	PXFont *font = [fontLoader newFont];
 *
 *	[PXFont registerFont:font withName:@"font"];
 *	// The font is now registered as the name "font", so any time you want to
 *	// reference it, you can use "font.
 *
 *	[font release];
 */
+ (PXFontLoader *)fontLoaderWithContentsOfURL:(NSURL *)url options:(PXFontOptions *)options
{
	return [[[PXFontLoader alloc] initWithContentsOfURL:url options:options] autorelease];
}

@end
