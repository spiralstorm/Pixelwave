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

#import "PXParser.h"

#import "PXDebug.h"

#import "PXLinkedList.h"

#include "PXPrivateUtils.h"

// A dictionary containing an array of adapater classes for the base class.
static NSMutableDictionary *pxParsers = nil;

#pragma mark -
#pragma mark C Definitions
#pragma mark -

// Makes the dictionary if it doesn't exist
PXInline void PXParsersMake();
// Frees the dictionary if it exists but is empty.
PXInline void PXParsersRelease();
// Frees the dictionary if it exists.
PXInline void PXParsersFree();

PXInline PXLinkedList *PXParserGetArray(Class baseClass);

PXInline void PXParserRemoveBaseClass(Class baseClass);

/*
 * The PXParser is a registration class to assign PXParsers to their base
 * classes. A PXParser example is PXTextureParser (being the base class) and
 * PXPNGTextureParser being the actual parser. This is the parser used if an
 * image being loaded is a png. The parsers are kept in order, thus if you add
 * a new parser in that takes PNG data, then your parser will get fired and
 * ours will be ignored.
 */
@implementation PXParser

@synthesize data;
@synthesize origin;

- (id) _initWithData:(NSData *)_data origin:(NSString *)_origin
{
	self = [super init];

	if (self)
	{
		data = [_data retain];
		origin = [_origin copy];

		if (![self _initialize])
		{
			[self release];
			return self;
		}
	}

	return self;
}

- (void) dealloc
{
	[data release];
	data = nil;
	[origin release];
	origin = nil;

	[super dealloc];
}

- (void) _log:(NSString *)message
{
	// We can do a useful log message that includes the origin.
	PXDebugLog(@"[%@] %@\n", origin, message);
}

#pragma mark Overridable

- (BOOL) _initialize
{
	return YES;
}
- (BOOL) _parse
{
	return NO;
}

+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	// Each parser should implement their own version
	[extensions addObject:[NSString stringWithFormat:@"NOT IMPLEMENTED FOR: %@", NSStringFromClass([self class])]];
}


#pragma mark -
#pragma mark Static Methods
#pragma mark -

/**
 * Registers the parser with it's base class. Ex. if you wanted to make a
 * custom texture parser, you would register it with the base class of
 * PXTextureParser.
 *
 * @param parser The parser you wish to register.
 * @param baseClass The base class you are registering it for.
 */
+ (void) registerParser:(Class)parser forBaseClass:(Class)baseClass
{
	if (![parser conformsToProtocol:@protocol(PXParser)])
	{
		PXDebugLog(@"Attempting to register an parser that does not conform to the parser protocol.'");

		return;
	}

	PXLinkedList *array = PXParserGetArray(baseClass);

	[array insertObject:parser atIndex:0];
}

// Unregirstration
/**
 * Unregisters the parser from the base class.
 *
 * @param parser The parser you wish to un-register.
 * @param baseClass The base class you are un-registering it for.
 */
+ (void) unregisterParser:(Class)parser forBaseClass:(Class)baseClass
{
	PXLinkedList *array = PXParserGetArray(baseClass);

	[array removeObject:parser];
}
/**
 * Unregisters all parser for the given base class.
 *
 * @param baseClass The base class to unregister everything from.
 */
+ (void) unregisterAllParsersForBaseClass:(Class)baseClass
{
	PXParserRemoveBaseClass(baseClass);
}
/**
 * Unregisters all parsers from all base classes.
 */
+ (void) unregisterAllParsers
{
	PXParsersFree();
}

// Getting
/**
 * Returns a linkedlist of parsers for the given base class. Note, this is not
 * a copy, but the actual list.
 *
 * @param baseClass The base class for grabbing the parsers.
 * @return A linkedlist of parsers for the given base class. Note, this is not a
 * copy, but the actual list.
 */
+ (PXLinkedList *)parsersForBaseClass:(Class)baseClass
{
	return PXParserGetArray(baseClass);
}

/**
 * Finds the parser that is associated with the type of data and origin of the
 * base class type.
 *
 * @param data The data to find an associative parser for.
 * @param origin The origin the data came from.
 * @param baseClass The base class for the search.
 * @return IF a parser is found, then the parser will be the correct one associated
 * with the data. Otherwise `nil` is returned instead.
 */
+ (Class) parserForData:(NSData *)data
				 origin:(NSString *)origin
			  baseClass:(Class)baseClass;
{
	Class class;

	// Grab the array of loaders from the base type
	PXLinkedList *classes = [PXParser parsersForBaseClass:baseClass];

	// For each class, figure out if it can use this data, if it can, return it.
	for (class in classes)
	{
		// Can the class we found use the data we have?
		// NOTE:	No check on calling this method, as you could not have
		//			registered an parser that does not have it. Please see the
		//			registration method for more information.
		if ([class isApplicableForData:data origin:origin])
		{
			return class;
		}
	}

	// No class for that data was found
	return nil;
}

/**
 * A list of all the file types supported by this parser. Each extension
 * always is lower-case.
 */
+ (NSArray *)supportedFileExtensions
{
	//PXLinkedList *ret = [[PXLinkedList alloc] init];
	PXLinkedList *extensions = [[PXLinkedList alloc] init];
	
	// Get all the supported file extensions from the parsers
	PXLinkedList *parsers = [PXParser parsersForBaseClass:[self class]];
	
	NSMutableSet *set = [[NSMutableSet alloc] init];
	
	for (Class parserType in parsers)
	{
		// Check for redundant extensions
		[extensions removeAllObjects];
		[parserType appendSupportedFileExtensions:extensions];
		for (NSString *ext in extensions)
		{
			ext = [ext lowercaseString];
			
			// Redundant objects are ignored by sets.
			[set addObject:ext];
		}
	}
	
	[extensions release];
	
	NSArray *retVal = [set allObjects];
	[set release];
	return retVal;
}

@end

#pragma mark -
#pragma mark C Implementation
#pragma mark -

// Makes the dictionary if it doesn't exist
PXInline void PXParsersMake()
{
	if (!pxParsers)
	{
		pxParsers = [[NSMutableDictionary alloc] init];
	}
}
// Frees the dictionary if it exists but is empty.
PXInline void PXParsersRelease()
{
	if ([pxParsers count] == 0)
	{
		PXParsersFree();
	}
}

PXInline void PXParsersFree()
{
	[pxParsers release];

	pxParsers = nil;
}

PXInline PXLinkedList *PXParserGetArray(Class baseClass)
{
	if (!baseClass)
	{
		return nil;
	}

	PXParsersMake();

	NSString *key = NSStringFromClass(baseClass);

	PXLinkedList *parsers = [pxParsers objectForKey:key];

	if (!parsers)
	{
		parsers = [[PXLinkedList alloc] init];

		[pxParsers setObject:parsers forKey:key];

		[parsers release];
	}

	return parsers;
}

PXInline void PXParserRemoveBaseClass(Class baseClass)
{
	NSString *key = NSStringFromClass(baseClass);

	if (key)
	{
		[pxParsers removeObjectForKey:key];
	}

	PXParsersRelease();
}
