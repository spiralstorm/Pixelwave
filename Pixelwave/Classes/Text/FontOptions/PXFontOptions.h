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

#import "PXPooledObject.h"

typedef enum
{
	PXFontCharacterSet_None				= 0x00,
	PXFontCharacterSet_LowerCase		= 0x01,
	PXFontCharacterSet_UpperCase		= 0x02,
	PXFontCharacterSet_AllLetters		= 0x03, // LowerCase | UpperCase
	PXFontCharacterSet_Numerals			= 0x04,
	PXFontCharacterSet_Punctuation		= 0x08
} PXFontCharacterSet;

@interface PXFontOptions : NSObject <NSCopying, PXPooledObject>
{
@protected
	NSString *characters;
}

/**
 * The characters used for the font.
 *
 * **Default:** `(PXFontCharacterSet_AllLetters | PXFontCharacterSet_Numerals | PXFontCharacterSet_Punctuation)`
 * 
 * @warning NO duplicate characters will ever exist in the font options
 * characters. If a duplicate is given, it is stripped out
 * automatically. Also space (character 32) is always defined in a set;
 * thus it does not need to be given.
 *
 */
@property (nonatomic, copy) NSString *characters;

//-- ScriptName: FontOptions
//-- ScriptArg[0]: PXFontCharacterSet_None
//-- ScriptArg[1]: nil
- (id) initWithCharacterSets:(unsigned)characterSets
		   specialCharacters:(NSString *)specialCharacters;

//-- ScriptName: defaultCharacterSets
+ (unsigned) defaultCharacterSets;
//-- ScriptName: defaultSpecialCharacters
+ (NSString *)defaultSpecialCharacters;

//-- ScriptName: charactersFromSets
+ (NSString *)charactersFromCharacterSets:(unsigned)characterSets;

//-- ScriptName: make
//-- ScriptArg[0]: PXFontCharacterSet_None
//-- ScriptArg[1]: nil
+ (PXFontOptions *)fontOptionsWithCharacterSets:(unsigned)characterSets
							  specialCharacters:(NSString *)specialCharacters;

@end
