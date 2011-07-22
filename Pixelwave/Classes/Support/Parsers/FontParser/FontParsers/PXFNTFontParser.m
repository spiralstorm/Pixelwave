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

#import "PXFNTFontParser.h"

#import "PXFNTTextureFontFuser.h"
#include "regex.h"

@implementation PXFNTFontParser

- (BOOL) _initialize
{
	return YES;
}

- (void) dealloc
{
	[super dealloc];
}

+ (BOOL) isApplicableForData:(NSData *)data origin:(NSString *)origin
{
	// Check the first few bytes for what I thought was the header.
	unsigned length = 64;

	// There is no way that this can be a FNT file if it is that small.
	if ([data length] < length)
	{
		return NO;
	}

	char bytes[length];

	// Grabbing the first 63 bytes, the 64'th will be a null terminator
	[data getBytes:bytes length:length - 1];
	bytes[length - 1] = '\0';

	const char *utf8String = bytes;

	// Make a new string with just those bytes, this way we can test if our
	// 'header' is anywhere in there.
	NSString *string = [NSString stringWithUTF8String:utf8String];

	if (string)
	{
		// Range of the theoretical header?
		NSRange range = [[string lowercaseString] rangeOfString:@"info face="];

		// Does our header exist?
		if (range.location != NSNotFound && range.length > 0)
		{
			return YES;
		}
	}

	return NO;
}

+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	[extensions addObject:@"fnt"];
}

- (Class) defaultFuser
{
	return [PXFNTTextureFontFuser class];
}

#pragma mark -
#pragma mark Override

- (BOOL) _parse
{
	return YES;
}

@end
