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

#import "PXFontOptions.h"

#include "PXHeaderUtils.h"
#include "PXPrivateUtils.h"

#define PX_FONT_CHAR_SET_LOWER_CASE		@"abcdefghijklmnopqrstuvwxyz"
#define PX_FONT_CHAR_SET_UPPER_CASE		@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#define PX_FONT_CHAR_SET_NUMERALS		@"0123456789"
#define PX_FONT_CHAR_SET_PUNCTUATION	@"!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"

PXInline int PXFontOptionsCharacterComparer(const void *element1, const void *element2);

@interface PXFontOptions (Private)
- (NSString *)newStringByRemovingDuplicatesFromString:(NSString *)copyString;
@end

/**
 * Defines a set of options to use when creating a new font. These options
 * will decide how the font will be created and what will be stored.
 *
 * **Example:**
 *	PXFontOptions *fontOptions = [[PXFontOptions alloc] initWithCharacterSets:PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals
 *	                                                        specialCharacters:@",.!?"]];
 *
 * @see PXTextureFontOptions
 */
@implementation PXFontOptions

@synthesize characters;

/**
 * Creates a new PXFontOptions with the default values. The font options holds
 * information necessary to build a font properly.
 */
- (id) init
{
	return [self initWithCharacterSets:[PXFontOptions defaultCharacterSets]
					 specialCharacters:[PXFontOptions defaultSpecialCharacters]];
}

/**
 * Creates a new PXFontOptions. The font options holds information necessary to
 * build a font properly.
 *
 * @param characterSets A single or multiple (or'ed together) PXFontCharacterSet(s).
 * @param specialCharacters Any characters not defined in the sets that you wish to include.
 *
 * @warning NO duplicate characters will ever exist in the font options
 * characters. If a duplicate is given, it is stripped out
 * automatically. Also space (character 32) is always defined in a set;
 * thus it does not need to be given.
 */
- (id) initWithCharacterSets:(unsigned)characterSets
		   specialCharacters:(NSString *)specialCharacters
{
	self = [super init];

	if (self)
	{
		self.characters = [NSString stringWithFormat:@"%@%@",
						   [PXFontOptions charactersFromCharacterSets:characterSets],
						   specialCharacters];
	}

	return self;
}

- (void) dealloc
{
	[characters release];
	characters = nil;

	[super dealloc];
}

- (void) reset
{
	self.characters = nil;
}

#pragma mark -
#pragma mark NSObject Overrides

- (id) copyWithZone:(NSZone *)zone
{
	PXFontOptions *options = [[self class] allocWithZone:zone];

	options.characters = characters;

	return options;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(characters=%@)", characters];
}

#pragma mark -
#pragma mark Properties

- (void) setCharacters:(NSString *)_characters
{
	[_characters retain];
	[characters release];
	characters = [self newStringByRemovingDuplicatesFromString:_characters];
	[_characters release];
}

#pragma mark -
#pragma mark Methods

- (NSString *)newStringByRemovingDuplicatesFromString:(NSString *)copyString
{
	// This will make a new string, and append the correct characters based
	// upon the input flag and the special characters.  As duplicates are
	// not wanted, we check for the duplicates and do not add them.  Seeing
	// as we add the flag characters first, and we know no duplicates reside
	// within them, we do not do the check on them.  The check is only done
	// if special characters are going to be added.
	NSMutableString *stringOfCharacters = [[NSMutableString alloc] initWithString:copyString];

	// ALWAYS HAVE SPACE!
	[stringOfCharacters appendString:@" "];

	NSRange range;
	range.location = 0;
	range.length = [stringOfCharacters length];

	unichar chars[range.length];
	unichar noDupChars[range.length];

	unsigned numCharsFound = 0;

	[stringOfCharacters getCharacters:chars range:range];

	mergesort(chars, range.length, sizeof(unichar), PXFontOptionsCharacterComparer);

	unsigned indexOfCurChar;

	unichar *curChar;

	// Can never have the 0th character anyway.
	unichar lastChar = 0;

	// Loop through the characters adding them.
	for (indexOfCurChar = 0, curChar = chars;
		 indexOfCurChar < range.length;
		 ++indexOfCurChar, ++curChar)
	{
		// The characters are sorted, thus the only time we will see a duplicate
		// is if the last one is equal to this one.
		if (lastChar != *curChar)
		{
			lastChar = *curChar;

			noDupChars[numCharsFound] = *curChar;
			++numCharsFound;
		}
	}

	[stringOfCharacters release];

	return [[NSString alloc] initWithCharacters:noDupChars length:numCharsFound];
}

#pragma mark -
#pragma mark Static Methods

/**
 * This is where the default character sets are defined.
 *
 * @return The default character sets.
 */
+ (unsigned) defaultCharacterSets
{
	return (PXFontCharacterSet_AllLetters |
			PXFontCharacterSet_Numerals   |
			PXFontCharacterSet_Punctuation);
}
/**
 * This is where the default special characters are defined.
 *
 * @return The default special characters.
 */
+ (NSString *)defaultSpecialCharacters
{
	return nil;
}

/**
 * Returns a string that contains each character from the given sets.
 *
 * @param characterSets The flags for the character sets (see PXFontCharacterSet).
 *
 * @return Each character from the character sets.
 */
+ (NSString *)charactersFromCharacterSets:(unsigned)characterSets
{
	NSMutableString *stringOfCharacters = [[NSMutableString alloc] init];

	// Append the characters to the new string if the flag is triggered.
	if (PX_IS_BIT_ENABLED(characterSets, PXFontCharacterSet_LowerCase))
	{
		[stringOfCharacters appendString:PX_FONT_CHAR_SET_LOWER_CASE];
	}
	if (PX_IS_BIT_ENABLED(characterSets, PXFontCharacterSet_UpperCase))
	{
		[stringOfCharacters appendString:PX_FONT_CHAR_SET_UPPER_CASE];
	}
	if (PX_IS_BIT_ENABLED(characterSets, PXFontCharacterSet_Numerals))
	{
		[stringOfCharacters appendString:PX_FONT_CHAR_SET_NUMERALS];
	}
	if (PX_IS_BIT_ENABLED(characterSets, PXFontCharacterSet_Punctuation))
	{
		[stringOfCharacters appendString:PX_FONT_CHAR_SET_PUNCTUATION];
	}

	return [stringOfCharacters autorelease];
}

/**
 * Creates a PXFontOptions. The font options holds information necessary to
 * build a font properly.
 *
 * @param characterSets A single or multiple (or'ed together) PXFontCharacterSet(s).
 * @param specialCharacters Any characters not defined in the sets that you wish to include.
 *
 * @warning NO duplicate characters will ever exist in the font options
 * characters. If a duplicate is given, it is stripped out
 * automatically. Also space (character 32) is always defined in a set;
 * thus it does not need to be given.
 */
+ (PXFontOptions *)fontOptionsWithCharacterSets:(unsigned)characterSets
							  specialCharacters:(NSString *)specialCharacters
{
	PXFontOptions *options = [[PXFontOptions alloc] initWithCharacterSets:characterSets
														specialCharacters:specialCharacters];

	return [options autorelease];
}

@end

#pragma mark -
#pragma mark C Implementations

PXInline int PXFontOptionsCharacterComparer(const void *element1, const void *element2)
{
	return ((*((unichar *)element1)) - (*((unichar *)element2)));
}
