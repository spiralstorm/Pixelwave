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

#import "PXRegexMatcher.h"

#import "PXExceptionUtils.h"
#import "PXDebug.h"

#import "PXRegexPattern.h"

#import "PXRegexUtils.h"
#include "regex.h"

@interface PXRegexMatcher(Private)
- (void) disposePattern;
@end

/**
 * A PXRegexMatcher uses a regex pattern to find matches in a given string.
 *
 * **Example:**
 *	PXRegexPattern *pattern = [[PXRegexPattern alloc] initWithRegex:@"^(\\w+)\\s(.*)$"];
 *	PXRegexMatcher *matcher = [[PXRegexMatcher alloc] initWithPattern:pattern string:@"person name:Steve age:56"];
 *
 *	// The matcher will hold onto the pattern for you
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
 * @see PXRegexPattern
 */
@implementation PXRegexMatcher

@synthesize pattern;
@synthesize input;

- (id) init
{
	PXThrow(PXException, @"RegexMatcher must be initialized with non-nil pattern");
	
	[self release];
	return nil;
}

- (id) initWithPattern:(PXRegexPattern *)_pattern
{
	return [self initWithPattern:_pattern input:nil];
}

/**
 * Creates a new regex matcher that matches the given pattern to the string.
 *
 * @param pattern The regex pattern.
 * @param string The string to parse.
 *
 * **Example:**
 *	PXRegexPattern *pattern = [[PXRegexPattern alloc] initWithRegex:@"^(\\w+)\\s(.*)$"];
 *	PXRegexMatcher *matcher = [[PXRegexMatcher alloc] initWithPattern:pattern string:@"person name:Steve age:56"];
 *
 *	// The matcher will hold onto the pattern for you
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
 */
- (id) initWithPattern:(PXRegexPattern *)_pattern input:(NSString *)_input
{
	if (!_pattern)
	{
		PXThrowNilParam(pattern);
		[self release];
		return nil;
	}

	self = [super init];

	if (self)
	{
		// Set my regex pointer to nil
		pMatchesPtr = nil;

		self.input = _input;
		self.pattern = _pattern;
	}

	return self;
}

- (void) dealloc
{
	// Release the retains we kept.
	//self.pattern = nil;
	[self disposePattern];
	self.input = nil;

	[super dealloc];
}

- (void) setPattern:(PXRegexPattern *)_pattern
{
	if (_pattern == pattern)
		return;

	if (!_pattern)
	{
		PXThrowNilParam(pattern);
		return;
	}

	[_pattern retain];
	// Release the last pattern, then retain the new one
	[self disposePattern];

	pattern = [_pattern retain];
	[_pattern release];
	
	// We have 0 matches, as we just changed patterns.
	pMatchesCount = 0;
	
	// If the pattern exists, free the last pointer we had and set the matches
	// count.
	if (pattern)
	{
		pMatchesCount = pattern.capturingGroupCount + 1;
		pMatchesPtr = calloc(pMatchesCount, sizeof(regmatch_t));
	}
	
	// Restart the regex info, new data has arrived!
	[self restart];
}

- (void) disposePattern
{
	[pattern release];
	pattern = nil;
	
	// If the matches pointer exists currently, free it so we can make a new
	// one.
	if (pMatchesPtr)
	{
		free(pMatchesPtr);
		pMatchesPtr = NULL;
	}
}

- (void) setInput:(NSString *)val
{	
	// Releases the previous string, and copies the new one.
	[input release];
	input = [val copy];

	// Lets grab the array and the length
	origString = [input UTF8String];
	origStringLength = [input length];

	// Restart the regex info, new data has arrived!
	[self restart];
}

- (NSArray *)groups
{
	// Make a new list to store the 
	NSMutableArray *groups = [[NSMutableArray alloc] init];
	
	// Add each match.
	int index;
	for (index = 0; index < pMatchesCount; ++index)
	{
		[groups addObject:[self groupAtIndex:index]];
	}
	
	return [groups autorelease];
}

- (unsigned) groupCount
{
	return pattern.capturingGroupCount;
}

/**
 * Resets the matcher back to the start.
 */
- (void) restart
{
	curDist = 0;
	oldCurDist = 0;
	useBeginingOfLineFlag = YES;
}

/**
 * Finds the next match.
 *
 * @return `YES` if a match was found; otherwise `NO`.
 *
 * **Example:**
 *	PXRegexMatcher *matcher = [PXRegexMatcher regexMatcherWithRegex:@"^(\\w+)\\s(.*)$"
 *	                                                         string:@"person name:Steve age:56"];
 *
 *	// If there are lots of potential matches, a while loop should be used.
 *	if ([matcher next])
 *	{
 *		NSLog (@"%@", [matcher groupAtIndex:0]); // @"person name:Steve age:56"
 *		NSLog (@"%@", [matcher groupAtIndex:1]); // @"person"
 *		NSLog (@"%@", [matcher groupAtIndex:2]); // @"name:Steve age:56"
 *	}
 */
- (BOOL) next
{
	// If no original string existed, then we can't find a next
	if (!origString)
	{
		// Return failure
		return NO;
	}

	// If our current carrot is out of bounds, then ... we can do nothing.
	if (curDist < 0 || curDist >= origStringLength)
	{
		// Return failure
		return NO;
	}

	// Grab a regex match pointer
	regmatch_t *pMatchs = (regmatch_t *)pMatchesPtr;

	// Move the carrot to the correct position.
	curString = origString + curDist;

	// Grab the regex pointer
	regex_t *preg = (regex_t *)(pattern->_regexPtr);

	// Execute the regex, if this was the first time for the line, then we will
	// use the 0 flag, otherwise we will send the 'not begining of line' flag.
	reg_errcode_t error;
	if (useBeginingOfLineFlag)
	{
		error = regexec(preg, curString, pMatchesCount, pMatchs, 0);
		useBeginingOfLineFlag = NO;
	}
	else
	{
		error = regexec(preg, curString, pMatchesCount, pMatchs, REG_NOTBOL);
	}

	// If an error was found, lets return (this method also prints the error).
	if (PXRegexError(error))
	{
		// Return failure
		return NO;
	}

	// Increment the pointer
	oldCurDist = curDist;
	curDist += pMatchs->rm_eo;

	// Return success!
	return YES;
}
/**
 * Resets the matcher back to the start value given, then finds the next match.
 *
 * @param start The character position to start the search. If any value less then 0 is
 * given, we use the current position instead.
 *
 * @return `YES` if a match was found; otherwise `NO`.
 *
 * **Example:**
 *	PXRegexMatcher *matcher = [PXRegexMatcher regexMatcherWithRegex:@"^(\\w+)\\s(.*)$"
 *	                                                         string:@"person name:Steve age:56"];
 *
 *	// If there are lots of potential matches, a while loop should be used.
 *	if ([matcher next])
 *	{
 *		NSLog (@"%@", [matcher groupAtIndex:0]); // @"person name:Steve age:56"
 *		NSLog (@"%@", [matcher groupAtIndex:1]); // @"person"
 *		NSLog (@"%@", [matcher groupAtIndex:2]); // @"name:Steve age:56"
 *	}
 *
 *	// Send 0 this time, so we can grab our results again.
 *	if ([matcher nextFromIndex:0])
 *	{
 *		NSLog (@"%@", [matcher groupAtIndex:0]); // @"person name:Steve age:56"
 *		NSLog (@"%@", [matcher groupAtIndex:1]); // @"person"
 *		NSLog (@"%@", [matcher groupAtIndex:2]); // @"name:Steve age:56"
 *	}
 */
- (BOOL) nextFromIndex:(int)start
{
	// If you are out of bounds, give up and send no... there is no way a match
	// can exist.
	if (start >= origStringLength)
	{
		return NO;
	}

	if (curDist == start)
	{
		// If we are equal to the current match, don't do anything
	}
	else if (start < 0)
	{
		// If it is less then 0, then we are being informed to use the current
		// position.
	//	start = curDist;
	}
	else
	{
		// Update the position
		oldCurDist = 0;
		curDist = start;

		if (start == 0)
		{
			// If it is 0, inform us that we are at the start of a line.
			useBeginingOfLineFlag = YES;
		}
		else
		{
			// Otherwise we are somewhere in the line, so we shouldn't use the
			// begining of line flag.
			useBeginingOfLineFlag = NO;
		}
	}

	// Now that we moved the position to the correct spot, lets return next.
	return [self next];
}

/**
 * Finds the start of the fist group (match at group 0 is always the whole
 * line).
 *
 * @return The starting character position of the match.
 *
 * **Example:**
 *	NSString *string = @"person name:Steve age:56";
 *
 *	const char *utf8String = [string UTF8String];
 *	int start;
 *	int end;
 *	unsigned curLength;
 *
 *	PXRegexMatcher *matcher = [PXRegexMatcher regexMatcherWithRegex:@"^(\\w+)\\s(.*)$"
 *	                                                         string:string];
 *
 *	// If there are lots of potential matches, a while loop should be used.
 *	if ([matcher next])
 *	{
 *		start = [matcher start];
 *		end = [matcher end];
 *
 *		curLength = end - start;
 *		char matchedString[curLength + 1];
 *		memcpy(matchedString, utf8String, curLength);
 *		matchedString[curLength + 1] = '\0';
 *
 *		NSLog (@"%@", [NSString stringWithUTF8String:matchedString]); // @"person name:Steve age:56"
 *	}
 */
- (int) start
{
	// Start of group 0
	return [self startOfGroupAtIndex:0];
}
/**
 * Finds the start of the indexed group (match at group 0 is always the whole
 * line).
 *
 * @param index The index of the group you wish to retrieve information about.
 *
 * @return The starting character position of the match.
 *
 * **Example:**
 *	NSString *string = @"person name:Steve age:56";
 *
 *	const char *utf8String = [string UTF8String];
 *	int start;
 *	int end;
 *	unsigned curLength;
 *
 *	PXRegexMatcher *matcher = [PXRegexMatcher regexMatcherWithRegex:@"^(\\w+)\\s(.*)$"
 *	                                                         string:string];
 *
 *	// If there are lots of potential matches, a while loop should be used.
 *	if ([matcher next])
 *	{
 *		start = [matcher startOfGroupAtIndex:1];
 *		end = [matcher endOfGroupAtIndex:1];
 *
 *		curLength = end - start;
 *		char matchedString[curLength + 1];
 *		memcpy(matchedString, utf8String, curLength);
 *		matchedString[curLength + 1] = '\0';
 *
 *		NSLog (@"%@", [NSString stringWithUTF8String:matchedString]); // @"person"
 *	}
 */
- (int) startOfGroupAtIndex:(int)index
{
	if (index >= pMatchesCount)
		return 0;

	// Get the match as a regex match, then get the regex match at index.
	regmatch_t *pMatches = (regmatch_t *)pMatchesPtr;
	regmatch_t *pMatch = &(pMatches[index]);
	
	// rm_so is the start offset, we add the oldCurDist to correctly offset the
	// string's position.
	return pMatch->rm_so + oldCurDist;
}

/**
 * Finds the end of the fist group (match at group 0 is always the whole line).
 *
 * @return The ending character position of the match.
 *
 * **Example:**
 *	NSString *string = @"person name:Steve age:56";
 *
 *	const char *utf8String = [string UTF8String];
 *	int start;
 *	int end;
 *	unsigned curLength;
 *
 *	PXRegexMatcher *matcher = [PXRegexMatcher regexMatcherWithRegex:@"^(\\w+)\\s(.*)$"
 *	                                                         string:string];
 *
 *	// If there are lots of potential matches, a while loop should be used.
 *	if ([matcher next])
 *	{
 *		start = [matcher start];
 *		end = [matcher end];
 *
 *		curLength = end - start;
 *		char matchedString[curLength + 1];
 *		memcpy(matchedString, utf8String + start, curLength);
 *		matchedString[curLength + 1] = '\0';
 *
 *		NSLog (@"%@", [NSString stringWithUTF8String:matchedString]); // @"person name:Steve age:56"
 *	}
 */
- (int) end
{
	// End of group 0
	return [self endOfGroupAtIndex:0];
}
/**
 * Finds the end of the indexed group (match at group 0 is always the whole
 * line).
 *
 * @param index The index of the group you wish to retrieve information about.
 *
 * @return The ending character position of the match.
 *
 * **Example:**
 *	NSString *string = @"person name:Steve age:56";
 *
 *	const char *utf8String = [string UTF8String];
 *	int start;
 *	int end;
 *	unsigned curLength;
 *
 *	PXRegexMatcher *matcher = [PXRegexMatcher regexMatcherWithRegex:@"^(\\w+)\\s(.*)$"
 *	                                                         string:string];
 *
 *	// If there are lots of potential matches, a while loop should be used.
 *	if ([matcher next])
 *	{
 *		start = [matcher startOfGroupAtIndex:1];
 *		end = [matcher endOfGroupAtIndex:1];
 *
 *		curLength = end - start;
 *		char matchedString[curLength + 1];
 *		memcpy(matchedString, utf8String + start, curLength);
 *		matchedString[curLength + 1] = '\0';
 *
 *		NSLog (@"%@", [NSString stringWithUTF8String:matchedString]); // @"person"
 *	}
 */
- (int) endOfGroupAtIndex:(int)index
{
	if (index >= pMatchesCount)
		return 0;

	// Get the match as a regex match, then get the regex match at index.
	regmatch_t *pMatches = (regmatch_t *)pMatchesPtr;
	regmatch_t *pMatch = &(pMatches[index]);

	// rm_eo is the end offset, we add the oldCurDist to correctly offset the
	// string's position.
	return pMatch->rm_eo + oldCurDist;
}

/**
 * Finds the range of the fist group (match at group 0 is always the whole
 * line).
 *
 * @param index The index of the group you wish to retrieve information about.
 *
 * @return The range of the characters in the match.
 *
 * **Example:**
 *	NSString *string = @"person name:Steve age:56";
 *
 *	const char *utf8String = [string UTF8String];
 *	NSRange range;
 *
 *	PXRegexMatcher *matcher = [PXRegexMatcher regexMatcherWithRegex:@"^(\\w+)\\s(.*)$"
 *	                                                         string:string];
 *
 *	// If there are lots of potential matches, a while loop should be used.
 *	if ([matcher next])
 *	{
 *		range = [matcher range];
 *
 *		char matchedString[range.length + 1];
 *		memcpy(matchedString, utf8String + range.location, range.length);
 *		matchedString[curLength + 1] = '\0';
 *
 *		NSLog (@"%@", [NSString stringWithUTF8String:matchedString]); // @"person name:Steve age:56"
 *	}
 */
- (NSRange) range
{
	return [self rangeOfGroupAtIndex:0];
}
/**
 * Finds the range of the indexed group (match at group 0 is always the whole
 * line).
 *
 * @return The range of the characters in the match.
 *
 * **Example:**
 *	NSString *string = @"person name:Steve age:56";
 *
 *	const char *utf8String = [string UTF8String];
 *	NSRange range;
 *
 *	PXRegexMatcher *matcher = [PXRegexMatcher regexMatcherWithRegex:@"^(\\w+)\\s(.*)$"
 *	                                                         string:string];
 *
 *	// If there are lots of potential matches, a while loop should be used.
 *	if ([matcher next])
 *	{
 *		range = [matcher rangeOfGroupAtIndex:1];
 *
 *		char matchedString[range.length + 1];
 *		memcpy(matchedString, utf8String + range.location, range.length);
 *		matchedString[curLength + 1] = '\0';
 *
 *		NSLog (@"%@", [NSString stringWithUTF8String:matchedString]); // @"person"
 *	}
 */
- (NSRange) rangeOfGroupAtIndex:(int)index
{
	if (index >= pMatchesCount)
		return NSMakeRange(0, 0);

	// Get the match as a regex match, then get the regex match at index.
	regmatch_t *pMatches = (regmatch_t *)pMatchesPtr;
	regmatch_t *pMatch = &(pMatches[index]);

	// Make the range
	NSRange range;

	// rm_so is the start offset, rm_eo is the end offset.
	range.location = pMatch->rm_so;
	range.length = pMatch->rm_eo - pMatch->rm_so;

	return range;
}

/**
 * Returns the first group that the matcher has found.
 */
- (NSString *)group
{
	return [self groupAtIndex:0];
}
/**
 * Returns the group at `index` that the matcher has found.
 *
 * @param index The index of the group you wish to receieve.
 * 
 * @return The group at `index`.
 */
- (NSString *)groupAtIndex:(int)index
{
	if (index >= pMatchesCount)
		return nil;

	// Get the match as a regex match, then get the regex match at index.
	regmatch_t *pMatches = (regmatch_t *)pMatchesPtr;
	regmatch_t *pMatch = &(pMatches[index]);

	// The length of the string is equal to the end offset minus the start ofset
	unsigned length = pMatch->rm_eo - pMatch->rm_so;

	// We need a null terminating string, so we can add one to our length (which
	// is where the '\0' will go).
	char nullTerminatedCString[length + 1];

	// Get a pointer to the current position of the string
	const char *curStrPos = curString + pMatch->rm_so;

	// Copy the string into the array we made
	memcpy(nullTerminatedCString, curStrPos, length);

	// Add the null terminator
	nullTerminatedCString[length] = '\0';

	// Send the result back as a NSString
	const char *constNullTerminatedCString = nullTerminatedCString;
	return [NSString stringWithUTF8String:constNullTerminatedCString];
}

+ (PXRegexMatcher *)regexMatcherWithRegex:(NSString *)regex
{
	return [PXRegexMatcher regexMatcherWithRegex:regex
										   input:nil
										   flags:PXRegexPatternFlag_Extended | PXRegexPatternFlag_NewLine];
}

/**
 * Creates a regex matcher, that creates a pattern with the regex string, and
 * then matches it to the string. It uses the default regex flags
 * `(PXRegexPatternFlag_Extended | PXRegexPatternFlag_NewLine)`
 *
 * @param regex The regex string to be converted into a pattern.
 * @param string The string to parse.
 *
 * @return The resulting, `autoreleased`, #PXRegexMatcher object.
 *
 */
+ (PXRegexMatcher *)regexMatcherWithRegex:(NSString *)regex input:(NSString *)input
{
	return [PXRegexMatcher regexMatcherWithRegex:regex
										  input:input
										   flags:PXRegexPatternFlag_Extended | PXRegexPatternFlag_NewLine];
}

/**
 * Creates a regex matcher, that creates a pattern with the regex string, and
 * then matches it to the string. It uses given flags.
 *
 * @param regex The regex string to be converted into a pattern.
 * @param string The string to parse.
 * @param flags The flags explaining how to compile the regex.
 *
 * @return The resulting, `autoreleased`, #PXRegexMatcher object.
 *
 */
+ (PXRegexMatcher *)regexMatcherWithRegex:(NSString *)regex input:(NSString *)input flags:(unsigned)flags
{
	//PXRegexPattern *pattern = [[PXRegexPattern alloc] initWithRegex:regex flags:flags];
	//PXRegexMatcher *matcher = [pattern matcherWithString:string];
	//[pattern release];
	//return [matcher autorelease];
	
	PXRegexPattern *pattern = [PXRegexPattern patternWithRegex:regex flags:flags];
	PXRegexMatcher *matcher = [pattern matcherWithInput:input];
	
	return matcher;
}

@end
