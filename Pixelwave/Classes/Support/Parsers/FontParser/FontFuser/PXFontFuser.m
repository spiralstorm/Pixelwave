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

#import "PXFontFuser.h"

#import "PXDebug.h"

#import "PXFreeTypeTextureFontFuser.h"
#import "PXSystemTextureFontFuser.h"

#include "PXPrivateUtils.h"

// Dictionary that holds the keys for the parsers
static NSMutableDictionary *pxFontFuserKeyFromParsers = nil;
// Dictionary that holds the keys for the options
static NSMutableDictionary *pxFontFuserKeyFromOptions = nil;
// Dictionary that holds the fusers for the combination of the two keys above.
static NSMutableDictionary *pxFontFusers = nil;

#pragma mark -
#pragma mark C Definitions

// Makes the key dictionaries if they don't exist
PXInline void PXFontFuserMakeKeys();
// Frees the dictionaries if they do exist.
PXInline void PXFontFuserFreeKeys();

// Grabs the key defined for the class in the dictionary, if one doesn't exist,
// it produces one for it.
PXInline NSString *PXFontFuserKeySegmentFromClass(Class classType, NSMutableDictionary *dictionary);
// Grabs the combined key for the font fusers dictionary defined by the two
// classes.
PXInline NSString *PXFontFuserKey(Class parserType, Class optionType);
// Grabs the combined key for the font fusers dictionary defined by the single
// fuser. This just grabs the two classes (parser and options) and returns the
// PXFontFuserKey method using both of them. 
PXInline NSString *PXFontFuserKeyFromFuser(Class fuser);

// Grabs the class for the font fuser using the two classes as the key. They
// combine together to make a single key which is then used to search into the
// dictionary.
PXInline Class PXFontFuserGetFuser(Class fontParser, Class fontOptions);

#pragma mark -
@interface PXFontFuser(Private)
+ (void) makeDictionaries;
+ (void) releaseDictionaries;
@end

#pragma mark -
@implementation PXFontFuser

- (id) init
{
	PXDebugLog(@"FontFuser should be initialized with parser and options");
	[self release];
	return nil;
}

- (id) initWithParser:(PXFontParser *)_parser options:(PXFontOptions *)_options
{
	self = [super init];

	if (self)
	{
		parser = _parser;
		options = _options;

		if (![self initializeFuser])
		{
			[self release];
			return nil;
		}
	}

	return self;
}

- (void) dealloc
{
	parser = nil;
	options = nil;

	[super dealloc];
}

#pragma mark -
#pragma mark Static Methods (Public)
#pragma mark -

+ (void) makeDictionaries
{
	// If the dictionary is not made, make it!
	if (!pxFontFusers)
	{
		pxFontFusers = [[NSMutableDictionary alloc] init];
	}
}

+ (void) releaseDictionaries
{
	// Release all the information if there is nothing left to store.
	if ([pxFontFusers count] == 0)
	{
		PXFontFuserFreeKeys();

		[pxFontFusers release];
		pxFontFusers = nil;
	}
}

+ (void) registerFontFuser:(Class)fontFuser
{
	// Make the dictionaries, if they alreaday exist then this won't do anything
	[PXFontFuser makeDictionaries];

	// Grab the key, if one doesn't exist, make one!
	NSString *key = PXFontFuserKeyFromFuser(fontFuser);

	// If the key couldn't be found or made, then you can't use this fuser!
	if (!key)
	{
		return;
	}

	// If the fuser doesn't exist, add it with the given key!
	if (![pxFontFusers objectForKey:key])
	{
		[pxFontFusers setObject:fontFuser forKey:key];
	}
}

+ (void) unregisterFontFuser:(Class)fontFuser
{
	// Grab the key, if one doesn't exist, make one!
	NSString *key = PXFontFuserKeyFromFuser(fontFuser);

	// If the key couldn't be found or made, then you can't use this fuser!
	if (!key)
	{
		return;
	}

	// Remove the fuser with the key
	[pxFontFusers removeObjectForKey:key];

	// "Release" the dictionaries. If they are null, they will deallocate.
	[PXFontFuser releaseDictionaries];
}
+ (void) unregisterAllFontFusers
{
	// Remove all instances of the fusers
	[pxFontFusers removeAllObjects];

	// Release the dictionaries
	[PXFontFuser releaseDictionaries];
}

/*
+ (PXFontFuser *)newFontFuserWithParser:(Class)parser options:(Class)options
{
	// Grab the class using the parser and options as two keys
	Class fontFuserClass = PXFontFuserGetFuser(parser, options);

	// Return a newly made instance of the class
	return [[fontFuserClass alloc] init];
}
*/

+ (Class) fontFuserTypeForParser:(Class)parser options:(Class)options
{
	return PXFontFuserGetFuser(parser, options);
}
#pragma mark -
#pragma mark Overrideable
#pragma mark -

/*
- (BOOL) initializeWithParser:(PXParser *)_parser options:(PXFontOptions *)_options
{
	parser = _parser;
	options = _options;

	return YES;
}
 */
- (BOOL) initializeFuser
{
	return YES;
}

- (PXFont *)newFont
{
	return nil;
}
+ (Class) parserType
{
	return nil;
}
+ (Class) optionsType
{
	return nil;
}

@end

#pragma mark -
#pragma mark C Implementations
#pragma mark -

// Makes the key dictionaries if they don't exist
PXInline void PXFontFuserMakeKeys()
{
	// If the dictionaries don't exist, make them!
	if (!pxFontFuserKeyFromParsers)
	{
		pxFontFuserKeyFromParsers = [[NSMutableDictionary alloc] init];
	}
	if (!pxFontFuserKeyFromOptions)
	{
		pxFontFuserKeyFromOptions = [[NSMutableDictionary alloc] init];
	}
}

// Frees the dictionaries if they do exist.
PXInline void PXFontFuserFreeKeys()
{
	// Release the dictionaries, then set them to nil so if this is called
	// multiple times, nothing bad will happen!

	[pxFontFuserKeyFromParsers release];
	pxFontFuserKeyFromParsers = nil;

	[pxFontFuserKeyFromOptions release];
	pxFontFuserKeyFromOptions = nil;
}

// Grabs the key defined for the class in the dictionary, if one doesn't exist,
// it produces one for it.
PXInline NSString *PXFontFuserKeySegmentFromClass(Class classType, NSMutableDictionary *dictionary)
{
	// If either the class type doesn't exist, or the dictionary, just return,
	// there is nothing we can do!
	if (!classType || !dictionary)
	{
		return nil;
	}

	// Grab the string representation of the class.
	NSString *className = NSStringFromClass(classType);

	// The key for the class in the dictionary.
	NSString *key = [dictionary objectForKey:className];

	// If it doesn't exist, lets assign it a new one!
	if (!key)
	{
		// The key is going to be a single unicode character, we will start with
		// 33 '!', so it is easier to read and debug.
		unichar keyChar = [dictionary count] + 33;

		// The key has to be a string :-(, so convert the unichar to a string.
		key = [NSString stringWithCharacters:&keyChar length:1];

		// Add the class name to the dictionary 
		[dictionary setObject:key forKey:className];
	}

	return key;
}

// Grabs the combined key for the font fusers dictionary defined by the two
// classes.
PXInline NSString *PXFontFuserKey(Class parserType, Class optionType)
{
	// Make the key dictionaries, if they already exist then nothing will
	// happen.
	PXFontFuserMakeKeys();

	// Grab the grab the key for each part.
	NSString *parserKey = PXFontFuserKeySegmentFromClass(parserType, pxFontFuserKeyFromParsers);
	NSString *optionKey = PXFontFuserKeySegmentFromClass(optionType, pxFontFuserKeyFromOptions);

	if (!optionKey)
	{
		optionKey = @"no";
	}
	if (!parserKey)
	{
		return NULL;
	}

	// Combine the keys into a single key
	return [NSString stringWithFormat:@"%@%@", parserKey, optionKey];
}

// Grabs the combined key for the font fusers dictionary defined by the single
// fuser. This just grabs the two classes (parser and options) and returns the
// PXFontFuserKey method using both of them.
PXInline NSString *PXFontFuserKeyFromFuser(Class fuser)
{
	Class fontParser;
	Class fontOptions;

	SEL parserTypeSel = @selector(parserType);
	SEL optionsTypeSel = @selector(optionsType);

	// See if the fuser responds to the two needed methods.
	if ([fuser respondsToSelector:parserTypeSel] &&
		[fuser respondsToSelector:optionsTypeSel])
	{
		// If it does, grab the two classes.
		fontParser = [fuser parserType];
		fontOptions = [fuser optionsType];
	}

	// Return the combined key
	return PXFontFuserKey(fontParser, fontOptions);
}

// Grabs the class for the font fuser using the two classes as the key. They
// combine together to make a single key which is then used to search into the
// dictionary.
PXInline Class PXFontFuserGetFuser(Class fontParser, Class fontOptions)
{
	// Grab the combined key
	NSString *key = PXFontFuserKey(fontParser, fontOptions);

	// If the key doesn't exist, nor does the class!
	if (!key)
	{
		return NULL;
	}

	// Grab the fuser from the combined key set.
	return [pxFontFusers objectForKey:key];
}
