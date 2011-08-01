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

#import "PXTextureAtlasParser.h"

#import "PXTextureAtlas.h"
#import "PXTextureModifier.h"

@implementation PXTextureAtlasParser

- (id) initWithData:(NSData *)_data
 contentScaleFactor:(float)_contentScaleFactor
		   modifier:(id<PXTextureModifier>)_modifier
			 origin:(NSString *)_origin
{
	self = [super init];

	if (self)
	{
		// Find the real type of parser to use.
		Class realClass = [PXParser parserForData:_data
										   origin:_origin
										baseClass:[PXTextureAtlasParser class]];

		// If no real parser exists, then we can't do anything
		if (!realClass)
		{
			[self release];
			return nil;
		}

		// Make the new parser.
		PXTextureAtlasParser *newParser = [[realClass alloc] _initWithData:_data
														contentScaleFactor:_contentScaleFactor
																  modifier:_modifier
																	origin:_origin];

		// Release ourself, as we are going to become the real parser
		[self release];

		// Become the real parser, and allocate any data we need
		self = newParser;

		if (self)
		{
		}
	}
	
	return self;
}

- (id) _initWithData:(NSData *)_data
  contentScaleFactor:(float)_contentScaleFactor
			modifier:(id<PXTextureModifier>)_modifier
			  origin:(NSString *)_origin
{
	// Set the data and origin
	self = [super _initWithData:_data origin:_origin];

	if (self)
	{
		contentScaleFactor = _contentScaleFactor;

		if (![self _parseWithModifier:_modifier])
		{
			[self release];
			return nil;
		}
	}

	return self;
}

- (PXTextureAtlas *)newTextureAtlas
{
	return nil;
}

@end
