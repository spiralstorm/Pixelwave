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

#import "PKParticleEffectParser.h"

#import "PXTextureLoader.h"
#import "PXTextureData.h"

#import "TBXMLNSDataAdditions.h"
#import "TBXMLParticleAdditions.h"

#include "PXMathUtils.h"
#include "PXDebug.h"

#import "PXTextureModifiers.h"

@interface PKParticleEffectParser (Private)
- (id) _initWithData:(NSData *)_data origin:(NSString *)_origin premultiplyAlpha:(BOOL)premultiply;
@end

@implementation PKParticleEffectParser

- (id) init
{
	PXDebugLog (@"PKParticleEffectParser must be instantiated with data and origin");

    [self release];
    return nil;
}

- (id) initWithData:(NSData *)_data origin:(NSString *)_origin premultiplyAlpha:(BOOL)_premultiply
{
	self = [super init];

	if (self != nil)
	{
		// Find the real type of parser to use.
		Class realClass = [PXParser parserForData:_data
										   origin:_origin
										baseClass:[PKParticleEffectParser class]];

		// If no real parser exists, then we can't do anything
		if (realClass == nil)
		{
			[self release];
			return nil;
		}

		// Make the new parser.
		PKParticleEffectParser *newParser = [[realClass alloc] _initWithData:_data origin:_origin premultiplyAlpha:_premultiply];

		// Release ourself, as we are going to become the real parser
		[self release];

		// Become the real parser, and allocate any data we need
		self = newParser;
		//	if (self)
		//	{
		//	}
	}

	return self;
}

- (id) _initWithData:(NSData *)_data origin:(NSString *)_origin premultiplyAlpha:(BOOL)_premultiply
{
	// Set the data and origin
	self = [super _initWithData:_data origin:_origin];

	if (self)
	{
		premultiply = _premultiply;

		// Parse the data. If we fail at parsing, give up - there is nothing
		// else we can do.
		if ([self _parse] == NO)
		{
			[self release];
			return nil;
		}
	}

	return self;
}

- (void) dealloc
{
	[self _setLoadedData:NULL];

	[super dealloc];
}

- (BOOL) _parse
{
	return NO;
}

- (PKParticleEffect *)newParticleEffect
{
	return nil;
}

- (void) _setLoadedData:(void *)_data
{
	loadedData = _data;
}

+ (PXTextureData *)_newTextureDataFromTextureString:(NSString *)textureString orPath:(NSString *)path premultiplyAlpha:(BOOL)premultiply
{
	NSLog (@"premultiply = %@\n", (premultiply ? @"YES" : @"NO"));
	PXTextureData *textureData = nil;

	id <PXTextureModifier> modifier = nil;

	if (premultiply == YES)
	{
		modifier = [PXTextureModifiers textureModifierToPremultiplyAlpha];
	}

	if (textureString)
	{
		// If the data exists, extract it
		NSData *data = [TBXMLNSDataAdditions dataWithBase64EncodedString:textureString];
		data = [TBXMLNSDataAdditions gzipInflate:data];
		textureData = [[PXTextureData alloc] initWithData:data modifier:modifier];
	}
	else
	{
		// Otherwise find the file, and load it.
		PXTextureLoader *texLoader = [[PXTextureLoader alloc] initWithContentsOfFile:path modifier:modifier];
		textureData = [texLoader newTextureData];
		[texLoader release];
	}

	return textureData;
}

@end
