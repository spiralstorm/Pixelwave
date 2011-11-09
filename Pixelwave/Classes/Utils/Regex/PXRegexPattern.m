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

#import "PXRegexPattern.h"

#include "PXPrivateUtils.h"

#import "PXRegexMatcher.h"

#import "PXExceptionUtils.h"

#import "PXRegexUtils.h"
#include "regex.h"

#import "PXDebug.h"

@interface PXRegexPattern (Private)
- (void) updateRegexPtr;
- (void) freeRegexPtr;
- (void) _setFlags:(unsigned)val;
@end

/**
 * A PXRegexPattern creates a compiled regex string from the given info. This
 * is used to find matches later. A PXRegexPattern object is immutable.
 *
 * **Example:**
 *	PXRegexPattern *pattern = [[PXRegexPattern alloc] initWithRegex:@"^(\\w+)\\s(.*)$"];
 *	PXRegexMatcher *matcher = [[PXRegexMatcher alloc] initWithPattern:pattern string:@"person name:Steve age:56"];
 *	[pattern release];
 *
 *	// If there are lots of potential matches, a while loop should be used.
 *	if ([matcher next])
 *	{
 *		NSLog (@"%@", [matcher groupAtIndex:0]); // @"person name:Steve age:56"
 *		NSLog (@"%@", [matcher groupAtIndex:1]); // @"person"
 *		NSLog (@"%@", [matcher groupAtIndex:2]); // @"name:Steve age:56"
 *	}
 *
 *	[matcher release];
 *
 * @see PXRegexMatcher
 */
@implementation PXRegexPattern

//@synthesize regex;
@synthesize flags;
@synthesize regex;

- (id) init
{
	PXThrow(PXException, @"RegexPatterns objects should not be initialized directly. Use [PXRegexPattern patternWithRegex:] instead");
	
	[self release];
	return nil;
}

/*
 * Creates a new regex pattern.
 *
 * @param pattern The regex to compile. If regex is not `nil` then it
 * immediately compiles the regex.
 * @param flags The flags explaining how to compile the regex.
 */
- (id) _initWithRegex:(NSString *)_regex flags:(unsigned)_flags
{
	self = [super init];

	if (self)
	{
		[self _setFlags:_flags];
		regex = [_regex copy];

		[self updateRegexPtr];
	}

	return self;
}

- (void) dealloc
{
	//self.regex = nil;
	[regex release];
	regex = nil;
	[self updateRegexPtr];

	[super dealloc];
}

#pragma mark NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] _initWithRegex:regex flags:flags];
}

- (NSString *)description
{
	NSMutableString *flagString = [[NSMutableString alloc] init];

	[flagString appendString:@"Basic"];

	if (PX_IS_BIT_ENABLED(flags, PXRegexPatternFlag_Extended))
	{
		[flagString appendString:@"| Extended"];
	}
	if (PX_IS_BIT_ENABLED(flags, PXRegexPatternFlag_IgnoreCase))
	{
		[flagString appendString:@"| IgnoreCase"];
	}
	if (PX_IS_BIT_ENABLED(flags, PXRegexPatternFlag_NewLine))
	{
		[flagString appendString:@"| NewLine"];
	}
	if (PX_IS_BIT_ENABLED(flags, PXRegexPatternFlag_NoSub))
	{
		[flagString appendString:@"| NoSub"];
	}

	NSString *description = [NSString stringWithFormat:@"[regex=%@, flags=(%@)]", regex, flagString];
	[flagString release];

	return description;
}

#pragma mark -
#pragma mark Properties
#pragma mark -

/*
- (void) setRegex:(NSString *)_regex
{
	[regex release];
	regex = [_regex copy];

	[self updateRegexPtr];
}
*/

- (void) _setFlags:(unsigned)val
{
	flags = 0;

	if (PX_IS_BIT_ENABLED(val, PXRegexPatternFlag_Extended))
	{
		PX_ENABLE_BIT(flags, REG_EXTENDED);
	}
	if (PX_IS_BIT_ENABLED(val, PXRegexPatternFlag_IgnoreCase))
	{
		PX_ENABLE_BIT(flags, REG_ICASE);
	}
	if (PX_IS_BIT_ENABLED(val, PXRegexPatternFlag_NewLine))
	{
		PX_ENABLE_BIT(flags, REG_NEWLINE);
	}
	if (PX_IS_BIT_ENABLED(val, PXRegexPatternFlag_NoSub))
	{
		PX_ENABLE_BIT(flags, REG_NOSUB);
	}

	//[self updateRegexPtr];
}

- (unsigned) flags
{
	unsigned retFlags = 0;

	if (PX_IS_BIT_ENABLED(flags, REG_EXTENDED))
	{
		PX_ENABLE_BIT(retFlags, PXRegexPatternFlag_Extended);
	}
	if (PX_IS_BIT_ENABLED(flags, REG_ICASE))
	{
		PX_ENABLE_BIT(retFlags, PXRegexPatternFlag_IgnoreCase);
	}
	if (PX_IS_BIT_ENABLED(flags, REG_NEWLINE))
	{
		PX_ENABLE_BIT(retFlags, PXRegexPatternFlag_NewLine);
	}
	if (PX_IS_BIT_ENABLED(flags, REG_NOSUB))
	{
		PX_ENABLE_BIT(retFlags, PXRegexPatternFlag_NoSub);
	}

	return retFlags;
}

- (unsigned) capturingGroupCount
{
	if (!_regexPtr)
	{
		return 0;
	}

	regex_t *rt = ((regex_t *)(_regexPtr));

	return rt->re_nsub;
}

#pragma mark -
#pragma mark Private Methods
#pragma mark -

- (void) updateRegexPtr
{
	// Free the regex pointer
	[self freeRegexPtr];

	// If we have a regex, then lets use it!
	if (regex)
	{
		// Allocate enough memory
		_regexPtr = calloc(1, sizeof(regex_t));

		// If we could not allocate enough memory, give up
		if (!_regexPtr)
			return;

		// Grab a pointer to the c-string
		const char *cStr = [regex UTF8String];

		// compile the regex
		int error = regcomp(((regex_t *)(_regexPtr)), cStr, flags);

		// If an error occured while compiling, this method will inform the user
		if (PXRegexError(error))
		{
			PXDebugLog(@"Could not compile the regex pattern:%@\n", regex);
			// An error occured, free the data we made!
			[self freeRegexPtr];
		}
	}
}

- (void) freeRegexPtr
{
	// If the pointer exists
	if (_regexPtr)
	{
		// Then inform regex to free the data it is using.
		regfree(_regexPtr);

		// Free the memory we allocated, then set it to NULL so we don't do it
		// again next time this is called.
		free(_regexPtr);
		_regexPtr = NULL;
	}
}

#pragma mark -
#pragma mark Methods
#pragma mark -

/**
 * Creates a new PXRegexMatcher object without specifying the input string to
 * match.
 *
 * @return The new PXRegexMatcher object.
 */
- (PXRegexMatcher *)matcher
{
	return [[[PXRegexMatcher alloc] initWithPattern:self] autorelease];
}

/**
 * Creates a new PXRegexMatcher object containing all information needed to
 * match your strings with the compiled regex.
 *
 * @param string The string to find matches for.
 *
 * @return The new PXRegexMatcher object.
 */
- (PXRegexMatcher *)matcherWithInput:(NSString *)input
{
	return [[[PXRegexMatcher alloc] initWithPattern:self input:input] autorelease];
}

#pragma mark -
#pragma mark Static Methods
#pragma mark -

/**
 * Creates a regex pattern with the default flags
 * `(PXRegexPatternFlag_Extended | PXRegexPatternFlag_NewLine)`
 *
 * @param pattern The regex to compile. If regex is not `nil` then it
 * immediately compiles the regex.
 *
 * @return The resulting, `autoreleased`, @PXRegexPattern object.
 */
+ (PXRegexPattern *)patternWithRegex:(NSString *)regex
{
	return [PXRegexPattern patternWithRegex:regex
									  flags:PXRegexPatternFlag_Extended | PXRegexPatternFlag_NewLine];
}

/**
 * Creates a regex pattern.
 *
 * @param pattern The regex to compile. If regex is not `nil` then it
 * immediately compiles the regex.
 * @param flags The flags explaining how to compile the regex.
 *
 * @return The resulting, `autoreleased`, @PXRegexPattern object.
 */
+ (PXRegexPattern *)patternWithRegex:(NSString *)regex flags:(unsigned)flags
{
	PXRegexPattern *pattern = [[PXRegexPattern alloc] _initWithRegex:regex flags:flags];	
	
	return [pattern autorelease];
}

/**
 * Not yet implemented
 */
+ (NSString *)quoteString:(NSString *)input
{
	// TODO: Implement
	return nil;
}

/**
 * Invokes #splitString:limit: using 0 as the limit.
 */
+ (NSArray *)splitString:(NSString *)input
{
	return [PXRegexPattern splitString:input limit:0];
}

/**
 * Not yet implemented
 */
+ (NSArray *)splitString:(NSString *)input limit:(int)limit
{
	// TODO: Implement
	return nil;
}

// TODO: Implement
+ (BOOL) matchesRegex:(NSString *)regex input:(NSString *)input
{
	return NO;
}

@end
