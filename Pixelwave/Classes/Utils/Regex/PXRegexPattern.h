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

@class PXRegexMatcher;

typedef enum
{
	PXRegexPatternFlag_Basic			= 0x00,
	PXRegexPatternFlag_Extended			= 0x01,
	PXRegexPatternFlag_IgnoreCase		= 0x02,
	PXRegexPatternFlag_NewLine			= 0x04,
	PXRegexPatternFlag_NoSub			= 0x08,
} PXRegexPatternFlag;

@interface PXRegexPattern : NSObject <NSCopying>
{
@public
	void *_regexPtr;

@protected
	NSString *regex;
	unsigned flags;
}

/**
 * A list of `PXRegexPatternFlag` flags that will define how the
 * regex is compiled.
 */
@property (nonatomic, readonly) unsigned flags;

/**
 * The compiled regex pattern.
 */
@property (nonatomic, readonly) NSString *regex;

/**
 * Returns the number of capturing groups in this matcher's pattern.
 *
 * Group zero denotes the entire pattern by convention. It is not included in
 * this count.
 */
@property (nonatomic, readonly) unsigned capturingGroupCount;

- (PXRegexMatcher *)matcher;
//-- ScriptName: newMatcher
//-- ScriptArg[0]: nil
- (PXRegexMatcher *)matcherWithInput:(NSString *)input;

//-- ScriptName: matches
+ (BOOL) matchesRegex:(NSString *)regex input:(NSString *)input;

//-- ScriptIgnore
+ (PXRegexPattern *)patternWithRegex:(NSString *)regex;
//-- ScriptName: make
//-- ScriptArg[0]: required
//-- ScriptArg[1]: PXRegexPatternFlag_Extended | PXRegexPatternFlag_NewLine
+ (PXRegexPattern *)patternWithRegex:(NSString *)regex flags:(unsigned)flags;

// Returns a literal pattern String for the specified String.
+ (NSString *)quoteString:(NSString *)input;
// Splits the given input sequence around matches of this pattern.
+ (NSArray *)splitString:(NSString *)input;
+ (NSArray *)splitString:(NSString *)input limit:(int)limit;
@end

// TODO Later: Make it so that patterns are managed and cached
@interface PXRegexPattern(PrivateButPublic)
- (id) _initWithRegex:(NSString *)regex flags:(unsigned)flags;
@end
