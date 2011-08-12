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

@class PXRegexPattern;

@interface PXRegexMatcher : NSObject
{
@protected
	PXRegexPattern *pattern;

	NSString *input;
@private
//	int currentGroupIndex;

	void *pMatchesPtr;
	unsigned pMatchesCount;
	int oldCurDist;
	int curDist;

	const char *origString;
	const char *curString;

	unsigned origStringLength;

	BOOL useBeginingOfLineFlag;
}

/**
 * The regex pattern for the matcher to match. Value must be non-nil
 */
@property (nonatomic, retain) PXRegexPattern *pattern;
/**
 * The string to match the regex to.
 */
@property (nonatomic, copy) NSString *input;
/**
 * Returns the number of capturing groups in this matcher's pattern.
 *
 * Group zero denotes the entire pattern by convention. It is not included in
 * this count.
 */
@property (nonatomic, readonly) unsigned groupCount;

/**
 * A list of every group found.
 */
@property (nonatomic, readonly) NSArray *groups;

- (id) initWithPattern:(PXRegexPattern *)pattern;

//-- ScriptName: RegexMatcher
//-- ScriptArg[0]: nil
//-- ScriptArg[1]: nil
- (id) initWithPattern:(PXRegexPattern *)pattern input:(NSString *)input;

//-- ScriptName: restart
- (void) restart;

//-- ScriptIgnore
- (BOOL) next;
//-- ScriptName: next
//-- ScriptArg[0]: -1
- (BOOL) nextFromIndex:(int)start;

//-- ScriptIgnore
- (int) start;
//-- ScriptName: start
//-- ScriptArg[0]: 0
- (int) startOfGroupAtIndex:(int)index;

//-- ScriptIgnore
- (int) end;
//-- ScriptName: end
//-- ScriptArg[0]: 0
- (int) endOfGroupAtIndex:(int)index;

//-- ScriptIgnore
- (NSRange) range;
//-- ScriptName: range
//-- ScriptArg[0]: 0
- (NSRange) rangeOfGroupAtIndex:(int)index;

//-- ScriptIgnore
- (NSString *)group;
//-- ScriptName: group
//-- ScriptArg[0]: 0
- (NSString *)groupAtIndex:(int)index;

//-- ScriptIgnore
+ (PXRegexMatcher *)regexMatcherWithRegex:(NSString *)regex;
//-- ScriptIgnore
+ (PXRegexMatcher *)regexMatcherWithRegex:(NSString *)regex input:(NSString *)input;
//-- ScriptName: makeWithRegex
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: PXRegexPatternFlag_Extended | PXRegexPatternFlag_NewLine
+ (PXRegexMatcher *)regexMatcherWithRegex:(NSString *)regex input:(NSString *)input flags:(unsigned)flags;

@end
