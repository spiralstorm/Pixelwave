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

#import "PXFNTTextureFontFuser.h"

#import "PXEngine.h"
#import "PXDebug.h"

#import "PXTextureFontOptions.h"

#import "PXTextureFont.h"
#import "PXFNTFontParser.h"
#import "PXTextureLoader.h"

#import "PXRegexMatcher.h"
#import "PXRegexPattern.h"
#import "PXTextureData.h"

#import "PXTextureGlyph.h"
#import "PXPoint.h"

#include "PXPrivateUtils.h"

typedef struct
{
	float baseLine;
	float fontSize;
	float ascender;

	int kernAmount;

	unsigned textureID;

	unichar kernFirst;
	unichar kernSecond;

	unichar curChar;
	unichar padding;

	NSString *key;
	NSString *string;
	NSString *fileName;

	NSNumber *number;

	NSNumberFormatter *numberFormatter;

	NSArray *digitList;

	PXTextureGlyph *newGlyph;
} PXFNTTextureFontExtractionInfo;

#pragma mark -
#pragma mark C Functions Declarations
#pragma mark -

PXInline PXFNTTextureFontExtractionInfo *PXFNTTextureFontExtractionInfoMake();
PXInline void PXFNTTextureFontExtractionInfoFree(PXFNTTextureFontExtractionInfo *info);

PXInline void PXFNTTextureFontFuserExtractInformation(PXRegexMatcher *matcher,
											 PXFNTTextureFontExtractionInfo *info,
											 void (*PXFNTTextureFontExtractionFunction)(PXFNTTextureFontExtractionInfo *));

PXInline void PXFNTTextureFontFuserHandleColumnInfo(PXFNTTextureFontExtractionInfo *info);
PXInline void PXFNTTextureFontFuserHandleColumnCommon(PXFNTTextureFontExtractionInfo *info);
PXInline void PXFNTTextureFontFuserHandleColumnPage(PXFNTTextureFontExtractionInfo *info);
PXInline void PXFNTTextureFontFuserHandleColumnChars(PXFNTTextureFontExtractionInfo *info);
PXInline void PXFNTTextureFontFuserHandleColumnChar(PXFNTTextureFontExtractionInfo *info);
PXInline void PXFNTTextureFontFuserHandleColumnKerning(PXFNTTextureFontExtractionInfo *info);

#pragma mark -
#pragma mark Fuser Private Declaration
#pragma mark -

@interface PXFNTTextureFontFuser(Private)
- (BOOL) parseFontWithParser:(PXFNTFontParser *)parser;
@end

#pragma mark -
#pragma mark Fuser Implementation
#pragma mark -

@implementation PXFNTTextureFontFuser

#pragma mark -
#pragma mark Override
#pragma mark -

- (BOOL) initializeFuser
{
	if (![super initializeFuser])
	{
		return NO;
	}
	
	if (![parser isKindOfClass:[PXFNTTextureFontFuser parserType]])
	{
		return NO;
	}

	// Release the dictionaries if they exist. This is done, just incase you
	// were using this class before; as in, if you have called this function at
	// least twice.
	[charToLoaderID release];
	[loaderIDToLoader release];

	// Allocate the dictionaries
	charToLoaderID = [[NSMutableDictionary alloc] init];
	loaderIDToLoader = [[NSMutableDictionary alloc] init];

	return [self parseFontWithParser:((PXFNTFontParser *)parser)];
}

- (void) dealloc
{
	// Store the loader ID by the character. These double dictionaries are done
	// for speed.
	[charToLoaderID release];
	charToLoaderID = nil;
	
	// Store the loader by the loader ID which is defined by the character
	// dictionary above. These double dictionaries are done for speed.
	[loaderIDToLoader release];
	loaderIDToLoader = nil;
	
	[super dealloc];
}

- (PXFont *)newFont
{
	// Allocate the new font.
	PXTextureFont *textureFont = [[PXTextureFont alloc] init];

	// If we couldn't allocate it, then we have larger issues.
	if (!textureFont)
	{
		return nil;
	}

	// A key for the loader ID to represent the texture data now, not just the
	// loader. We didn't do this before, as we didn't want to actually make the
	// datas until we were done loading.
	NSMutableDictionary *loaderIDToTextureData = [[NSMutableDictionary alloc] init];

	PXTextureLoader *textureLoader;
	PXTextureData *textureData;
	NSString *loaderID;
	PXTextureGlyph *glyph;

	float one_texWidth  = 0.0f;
	float one_texHeight = 0.0f;

	NSEnumerator *enumerator;
	NSString *key;

	// Enumerate through the the loader ID's to grab the loader and make a new
	// texture data, assigning it to the new dictionary that references the key
	// to the data. This way, when we iterate through the glyphs, we can assign
	// their texture data. Plus, now we make the texture data, and only create
	// it once.
	enumerator = [loaderIDToLoader keyEnumerator];
	while (key = [enumerator nextObject])
	{
		textureLoader = [loaderIDToLoader objectForKey:key];
		textureData = [textureLoader newTextureData];

		if (textureData)
		{
			[loaderIDToTextureData setObject:textureData forKey:key];
			[textureData release];
		}
	}

	enumerator = [charToGlyph keyEnumerator];

	float one_contentScaleFactor;
	PXTextureData *lastTextureData = nil;

	while (key = [enumerator nextObject])
	{
		glyph = [charToGlyph objectForKey:key];

		loaderID = [charToLoaderID objectForKey:key];

		if (loaderID)
		{
			textureData = [loaderIDToTextureData objectForKey:loaderID];

			// We check last off of now, so that when a change occurs we can
			// update the values (this is done, so we do not need to calculate
			// it out every time, instead it calculates it some of the time).
			if (lastTextureData != textureData)
			{
				lastTextureData = textureData;

				one_contentScaleFactor = 1.0f / textureData.contentScaleFactor;

				one_texWidth  = 1.0f / (textureData.width  * one_contentScaleFactor);
				one_texHeight = 1.0f / (textureData.height * one_contentScaleFactor);
			}

			// Set the glyph's texture data
			if (textureData)
			{
				glyph.textureData = textureData;

				// The glyph's texture bounds range from 0.0f to 1.0f, so we
				// need to take their normal bounds and divide them by their
				// total texture bounds (multiply by one over the total).
				glyph->_textureBounds.origin.x    *= one_texWidth;
				glyph->_textureBounds.origin.y    *= one_texHeight;
				glyph->_textureBounds.size.width  *= one_texWidth;
				glyph->_textureBounds.size.height *= one_texHeight;
			}
		}

		// Add the glyph to the texture font.
		[textureFont setGlyph:glyph forString:key];
	}

	// Set the kerning data for the texture font (if any exists).
	enumerator = [charToKernPoint keyEnumerator];
    while (key = [enumerator nextObject])
	{
		[textureFont setKerningPoint:[charToKernPoint objectForKey:key]
							forString:key];
	}

	// Set the base line
	textureFont->_baseLine = baseLine;
	textureFont->_fontSize = fontSize;

	// Release the dictionary we made during this method.
	[loaderIDToTextureData release];

	return textureFont;
}

+ (Class) parserType
{
	return [PXFNTFontParser class];
}

+ (Class) optionsType
{
	return [PXTextureFontOptions class];
}

- (BOOL) parseFontWithParser:(PXFNTFontParser *)fntParser
{
	NSData *data = fntParser.data;

	// If the data doesn't exist, then we can't do anything.
	if (!data)
	{
		return NO;
	}

	// String of the bytes.
	NSString *fileString = [[NSString alloc] initWithBytes:[data bytes]
													length:[data length]
												  encoding:NSUTF8StringEncoding];

	// If the string doesn't exist, then there is nothing we can' do
	if (!fileString)
	{
		return NO;
	}

	// Make a new info for extraction. The info file contains information needed
	// about what objects to make for each round of parsing.
	PXFNTTextureFontExtractionInfo *info = PXFNTTextureFontExtractionInfoMake();

	// If we failed to make an info, then we have larger issues at hand; but
	// there is nothing we can do.
	if (!info)
	{
		[fileString release];
		fileString = nil;
		return NO;
	}

	// Make a number formatter for the info
	info->numberFormatter = [[NSNumberFormatter alloc] init];

	//PXRegexPattern *keyPattern = [[PXRegexPattern alloc] initWithRegex:@"^(\\w+)\\s(.*)$"];
	//PXRegexPattern *linePattern = [[PXRegexPattern alloc] initWithRegex:@"(\\w*)=(([0-9-]+,[0-9,-]+)|([0-9-]+)|\"([^\"]*)\")"];
	PXRegexPattern *keyPattern = [PXRegexPattern patternWithRegex:@"^(\\w+)\\s(.*)$"];
	PXRegexPattern *linePattern = [PXRegexPattern patternWithRegex:@"(\\w*)=(([0-9-]+,[0-9,-]+)|([0-9-]+)|\"([^\"]*)\")"];
	
	// If we failed to make something, free up what we had, and give up.
	//if (!info->numberFormatter || !keyPattern || !keyMatcher || !linePattern || !lineMatcher)
	if (!info->numberFormatter || !keyPattern || !linePattern)
	{
		[fileString release];

		PXFNTTextureFontExtractionInfoFree(info);
		info = NULL;

		//[keyPattern release];
		//[keyMatcher release];
		//[linePattern release];
		//[lineMatcher release];

		return NO;
	}

	NSString *line;
	NSString *loaderID;
	NSString *charKey;

	NSString *columnKey = nil;
	int numCharsInColumnKey;

	PXTextureFontOptions *tfOptions = nil;

	if ([options isKindOfClass:[PXTextureFontOptions class]])
	{
		tfOptions = (PXTextureFontOptions *)options;
	}
	
	//keyMatcher.string = fileString;
	PXRegexMatcher *keyMatcher = [[PXRegexMatcher alloc] initWithPattern:keyPattern input:fileString];
	PXRegexMatcher *lineMatcher = [[PXRegexMatcher alloc] initWithPattern:linePattern];

	PXPoint *kernPoint = nil;
	PXTextureLoader *textureLoader;

	float contentScaleFactor = PXEngineGetContentScaleFactor() / fntParser.contentScaleFactor;

	// Grab the next match - If none exist, we are done parsing the file
	while ([keyMatcher next])
	{
		// Get the key
		columnKey = [[keyMatcher groupAtIndex:1] lowercaseString];
		// Then the rest of the line
		line = [keyMatcher groupAtIndex:2];

		// Set the normal
		lineMatcher.input = line;

		// Checking the number of characters in the key to do a quick comparison
		// to elliminate many possibilities. This is an attempt to save some
		// time on string comparisons. It isn't perfect, but will do for now.
		numCharsInColumnKey = [columnKey length];
		switch(numCharsInColumnKey)
		{
			case 4:
				if ([columnKey isEqualToString:@"info"])
				{
					// Grab the info line and parse it.
					PXFNTTextureFontFuserExtractInformation(lineMatcher,
															info,
															PXFNTTextureFontFuserHandleColumnInfo);
				}
				else if ([columnKey isEqualToString:@"page"])
				{
					// Grab the page line and parse it.
					PXFNTTextureFontFuserExtractInformation(lineMatcher,
															info,
															PXFNTTextureFontFuserHandleColumnPage);

					// A page has information about a texture. Seeing as we are
					// in the load step,and now the new step, we are only going
					// to make a loader (and not the texture data yet).
					textureLoader = nil;
					if (info->fileName)
					{
						textureLoader = [[PXTextureLoader alloc] initWithContentsOfFile:info->fileName];
					}

					if (textureLoader)
					{
						// Make a new loader id, with the id of the texture
						// (this is the id given to us by the file.
						loaderID = [[NSString alloc] initWithFormat:@"%u", info->textureID];
						[loaderIDToLoader setObject:textureLoader forKey:loaderID];
						[loaderID release];

						// If options exist, inform the loader!
						if (tfOptions)
						{
							textureLoader.modifier = tfOptions.textureModifier;
						}

						// The loader is in the dictionary, so we can release
						// the extra copy.
						[textureLoader release];
					}

					// When parsing the page, we retained the file name, now it
					// is time to release it.
					[info->fileName release];
					info->fileName = nil;
				}
				else if ([columnKey isEqualToString:@"char"])
				{
					// Grab the char line and parse it.
					// The char line in this case is the same as a glyph, so
					// make the glyph to store the data we are parsing.
					info->newGlyph = [[PXTextureGlyph alloc] init];
					if (info->newGlyph)
					{
						// Initialize the y advance to 0, as y is an optional
						// value, and we may not parse it.
						info->newGlyph->_advance.y = 0.0f;

						// Parse the info.
						PXFNTTextureFontFuserExtractInformation(lineMatcher,
																info,
																PXFNTTextureFontFuserHandleColumnChar);

						// The values we get are not scaled to the content, so
						//we have to scale them.
						info->newGlyph->_advance.x *= contentScaleFactor;
						info->newGlyph->_advance.y *= contentScaleFactor;

						info->newGlyph->_bounds.origin.x *= contentScaleFactor;
						info->newGlyph->_bounds.origin.y *= contentScaleFactor;
						info->newGlyph->_bounds.size.width  *= contentScaleFactor;
						info->newGlyph->_bounds.size.height *= contentScaleFactor;

						// Add the glyph using the character we got as the key
						[self setGlyph:info->newGlyph forCharacter:info->curChar];

						// Set the loader ID and character ID of the glyph so
						// that we can properly associate the character with the
						// loader to set the texture (via the texture data using
						// the ID) of it.
						loaderID = [[NSString alloc] initWithFormat:@"%u", info->textureID];
						charKey = [[NSString alloc] initWithCharacters:(&(info->curChar)) length:1];

						// Add it to the dictionary for quick lookup
						[charToLoaderID setObject:loaderID forKey:charKey];

						// Release the crap we just allocated.
						[loaderID release];
						[charKey release];

						// Release the glyph (it is in the dictionary now).
						[info->newGlyph release];
						info->newGlyph = nil;
					}
				}
				break;
			case 5:
				if ([columnKey isEqualToString:@"chars"])
				{
					// Grab the chars line and parse it.
					// Note:	We don't actually really use this - we figure
					//			this out for ourselves.
				//	PXFNTTextureFontFuserExtractInformation(lineMatcher,
				//											info,
				//											PXFNTTextureFontFuserHandleColumnChars);
				}
				break;
			case 6:
				if ([columnKey isEqualToString:@"common"])
				{
					// Grab the common line and parse it.
					// The common line holds information about the size of the
					// font and base line.
					PXFNTTextureFontFuserExtractInformation(lineMatcher,
															info,
															PXFNTTextureFontFuserHandleColumnCommon);
				}
				break;
			case 7:
				if ([columnKey isEqualToString:@"kerning"])
				{
					// Grab the kerning line and parse it.
					PXFNTTextureFontFuserExtractInformation(lineMatcher,
															info,
															PXFNTTextureFontFuserHandleColumnKerning);

					// Make kerning information which we can understand later.
					kernPoint = [[PXPoint alloc] initWithX:info->kernAmount y:0.0f];

					// Add it to the list
					[self setKernPoint:kernPoint forFirstCharacter:info->kernFirst secondCharacter:info->kernSecond];

					// Release it, as the above line will also retain it.
					[kernPoint release];
				}
				break;
			default:
				break;
		}
	}

	// Store the information for later use.
	baseLine = info->baseLine;
	fontSize = info->fontSize;

	// Release information we made earlier.
	[fileString release];

	[info->numberFormatter release];
	info->numberFormatter = nil;

	PXFNTTextureFontExtractionInfoFree(info);
	info = NULL;

	//[keyPattern release];
	//[linePattern release];
	
	[keyMatcher release];
	[lineMatcher release];

	// We succeeded!
	return YES;
}

@end

#pragma mark -
#pragma mark C Functions Implementations
#pragma mark -

PXInline PXFNTTextureFontExtractionInfo *PXFNTTextureFontExtractionInfoMake()
{
	PXFNTTextureFontExtractionInfo *info = calloc(1, sizeof(PXFNTTextureFontExtractionInfo));

	return info;
}
PXInline void PXFNTTextureFontExtractionInfoFree(PXFNTTextureFontExtractionInfo *info)
{
	// Free the info, if it exists.
	if (info)
	{
		free(info);
	}
}

PXInline void PXFNTTextureFontFuserExtractInformation(PXRegexMatcher *matcher,
													PXFNTTextureFontExtractionInfo *info,
													void (*PXFNTTextureFontExtractionFunction)(PXFNTTextureFontExtractionInfo *))
{
	// Can't do much if the needed information doesn't exist
	if (!matcher || !info || !PXFNTTextureFontExtractionFunction)
		return;

	NSString *workingString;

	// While we have a match
	while ([matcher next])
	{
		info->key = [matcher groupAtIndex:1];

		// See if the match is a digit list
		workingString = [matcher groupAtIndex:3];
		if (workingString.length > 0)
		{
			info->digitList = [workingString componentsSeparatedByString:@","];
		}

		// see if the match is a number
		workingString = [matcher groupAtIndex:4];
		if (workingString.length > 0)
		{
			info->number = [info->numberFormatter numberFromString:workingString];
		}

		// see if the match is a string
		workingString = [matcher groupAtIndex:5];
		if (workingString.length > 0)
		{
			info->string = workingString;
		}

		// Use the given function to extract the information
		PXFNTTextureFontExtractionFunction(info);

		// Reset the information we got.
		info->key = nil;
		info->digitList = nil;
		info->number = nil;
		info->string = nil;
	}
}

PXInline void PXFNTTextureFontFuserHandleColumnInfo(PXFNTTextureFontExtractionInfo *info)
{
	// Checking the number of characters in the key to do a quick comparison
	// to elliminate many possibilities. This is an attempt to save some
	// time on string comparisons. It isn't perfect, but will do for now.
	unsigned charCount = [info->key length];
	switch (charCount)
	{
		case 4:
			if ([info->key isEqualToString:@"size"])
			{
				// Grab the font size.
				info->fontSize = [info->number floatValue];
			}
			break;
		default:
			break;
	}
}
PXInline void PXFNTTextureFontFuserHandleColumnCommon(PXFNTTextureFontExtractionInfo *info)
{
	// Checking the number of characters in the key to do a quick comparison
	// to elliminate many possibilities. This is an attempt to save some
	// time on string comparisons. It isn't perfect, but will do for now.
	unsigned charCount = [info->key length];
	switch (charCount)
	{
		case 4:
			if ([info->key isEqualToString:@"base"])
			{
				// Grab the base line
				info->baseLine = [info->number intValue];
			}
			break;
		case 10:
			if ([info->key isEqualToString:@"lineHeight"])
			{
				// Grab the line height
				info->ascender = [info->number intValue];
			}
		default:
			break;
	}
}
PXInline void PXFNTTextureFontFuserHandleColumnPage(PXFNTTextureFontExtractionInfo *info)
{
	// Checking the number of characters in the key to do a quick comparison
	// to elliminate many possibilities. This is an attempt to save some
	// time on string comparisons. It isn't perfect, but will do for now.
	unsigned charCount = [info->key length];
	switch (charCount)
	{
		case 2:
			if ([info->key isEqualToString:@"id"])
			{
				// Grab the texture (by id) that we need to load
				info->textureID = [info->number unsignedIntValue];
			}
			break;
		case 4:
			if ([info->key isEqualToString:@"file"])
			{
				// Grab the file name of the texture we need to load
				[info->fileName release];
				info->fileName = [info->string retain];
			}
			break;
		default:
			break;
	}
}
PXInline void PXFNTTextureFontFuserHandleColumnChars(PXFNTTextureFontExtractionInfo *info)
{
}
PXInline void PXFNTTextureFontFuserHandleColumnChar(PXFNTTextureFontExtractionInfo *info)
{
	// Checking the number of characters in the key to do a quick comparison
	// to elliminate many possibilities. This is an attempt to save some
	// time on string comparisons. It isn't perfect, but will do for now.
	unsigned charCount = [info->key length];
	switch (charCount)
	{
		case 1:
			if ([info->key isEqualToString:@"x"])
			{
				// Grab the x location of the glyph
				info->newGlyph->_textureBounds.origin.x = (float)([info->number intValue]);
			}
			else if ([info->key isEqualToString:@"y"])
			{
				// Grab the y location of the glyph
				info->newGlyph->_textureBounds.origin.y = (float)([info->number intValue]);
			}
			break;
		case 2:
			if ([info->key isEqualToString:@"id"])
			{
				// Grab the character of the glyph
				info->curChar = [info->number unsignedShortValue];
			}
			break;
		case 4:
			if ([info->key isEqualToString:@"page"])
			{
				// Grab the texture (by id) that this glyph will use
				info->textureID = [info->number unsignedIntValue];
			}
			break;
		case 5:
			if ([info->key isEqualToString:@"width"])
			{
				// Grab the width of the glyph
				info->newGlyph->_bounds.size.width = [info->number intValue];
				info->newGlyph->_textureBounds.size.width = (float)([info->number intValue]);
			}
			break;
		case 6:
			if ([info->key isEqualToString:@"height"])
			{
				// Grab the height of the glyph
				info->newGlyph->_bounds.size.height = [info->number intValue];
				info->newGlyph->_textureBounds.size.height = (float)([info->number intValue]);
			}
			break;
		case 7:
			if ([info->key isEqualToString:@"xoffset"])
			{
				// Grab the x offset of the glyph
				info->newGlyph->_bounds.origin.x = (float)([info->number intValue]);
			}
			else if ([info->key isEqualToString:@"yoffset"])
			{
				// Grab the y offset of the glyph
				//info->newGlyph->_bounds.origin.y = info->ascender - (float)([info->number intValue]);
				info->newGlyph->_bounds.origin.y = (float)([info->number intValue]);
			}
			break;
		case 8:
			if ([info->key isEqualToString:@"xadvance"])
			{
				// Grab the x advance of the glyph
				info->newGlyph->_advance.x = (float)([info->number intValue]);
			}
			else if ([info->key isEqualToString:@"yadvance"])
			{
				// Grab the y advance of the glyph
				info->newGlyph->_advance.y = (float)([info->number intValue]);
			}
		default:
			break;
	}
}
PXInline void PXFNTTextureFontFuserHandleColumnKerning(PXFNTTextureFontExtractionInfo *info)
{
	// Checking the number of characters in the key to do a quick comparison
	// to elliminate many possibilities. This is an attempt to save some
	// time on string comparisons. It isn't perfect, but will do for now.
	unsigned charCount = [info->key length];
	switch (charCount)
	{
		case 5:
			if ([info->key isEqualToString:@"first"])
			{
				// Grab the first character of the kern
				info->kernFirst = [info->number intValue];
			}
			break;
		case 6:
			if ([info->key isEqualToString:@"second"])
			{
				// Grab the second character of the kern
				info->kernSecond = [info->number intValue];
			}
			else if ([info->key isEqualToString:@"amount"])
			{
				// Grab the amount ot kern by
				info->kernAmount = [info->number intValue];
			}
			break;
		default:
			break;
	}
}
