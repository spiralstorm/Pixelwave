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

#import "PXTextureFont.h"

#import "PXPoint.h"

#import "PXTextureFontRenderer.h"
#import "PXTextureGlyph.h"
#import "PXTextureData.h"

/**
 * A PXTextureFont object represents a texture containing a parsed font.  The
 * texture is packed to try and use the least space possible.
 *
 * The following code creates a texture filled with every letter, ',' and '!'
 * from the Helvetica font with size of 30.0f.  Then the texture that is
 * created gets displayed.
 *
 *	PXFontOptions *fontOptions = [PXFontOptions fontOptionsWithSize:30.0f
 *	                                                  characterSets:PXFontCharacterSet_AllLetters
 *	                                              specialCharacters:@",!"];
 *	PXTextureFont *textureFont = [PXTextureFont registerSystemFontWithFont:@"Helvetica"
 *	                                                                  name:@"fontName"
 *	                                                           fontOptions:fontOptions];
 *
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureFont.textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 * @see PXFont
 */
@implementation PXTextureFont

- (id) init
{
	self = [super init];

	if (self)
	{
		// Default font information.
		_baseLine =  0.0f;
		_fontSize = 12.0f;

		// A dictionary to store our glyphs 
		characterToGlyph = [[NSMutableDictionary alloc] init];
		charactersToKern = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (void) dealloc
{
	// Release the dictionary.
	[characterToGlyph release];
	characterToGlyph = nil;

	// Release the dictionary.
	[charactersToKern release];
	charactersToKern = nil;

	[super dealloc];
}

- (NSArray *)textureDatas
{
	if ([characterToGlyph count] == 0)
	{
		return nil;
	}

	NSMutableArray *list = [[NSMutableArray alloc] init];

	PXTextureGlyph *glyph;
	PXTextureData *textureData;

	NSEnumerator *enumerator = [characterToGlyph objectEnumerator];
    id obj;

    while ((obj = [enumerator nextObject]))
	{
		glyph = (PXTextureGlyph *)obj;
		textureData = glyph.textureData;

		if ([list containsObject:textureData])
			continue;

		[list addObject:textureData];
	}

	return [list autorelease];
}

- (PXFontRenderer *)_newFontRenderer
{
	return [[PXTextureFontRenderer alloc] initWithFont:self];
}


- (PXTextureGlyph *)glyphFromCharacter:(unichar)character
{
	NSString *key = [[NSString alloc] initWithCharacters:&character length:1];

	PXTextureGlyph *glyph = [characterToGlyph objectForKey:key];

	[key release];

	return glyph;
}
- (PXPoint *)kerningPointFromFirstCharacter:(unichar)firstCharacter
						  secondCharacter:(unichar)secondCharacter
{
	unichar characters[] = {firstCharacter, secondCharacter};
	NSString *key = [[NSString alloc] initWithCharacters:characters length:2];

	PXPoint *point = [charactersToKern objectForKey:key];

	[key release];

	return point;
}

- (void) setGlyph:(PXTextureGlyph *)glyph forString:(NSString *)string
{
	[characterToGlyph setObject:glyph forKey:string];
}
- (void) setGlyph:(PXTextureGlyph *)glyph forCharacter:(unichar)character
{
	NSString *key = [[NSString alloc] initWithCharacters:&character length:1];

	[characterToGlyph setObject:glyph forKey:key];

	[key release];
}

- (void) setKerningPoint:(PXPoint *)kerningPoint forString:(NSString *)string
{
	[charactersToKern setObject:kerningPoint forKey:string];
}
- (void) setKerningPoint:(PXPoint *)kerningPoint
	   forFirstCharacter:(unichar)firstCharacter
		 secondCharacter:(unichar)secondCharacter
{
	unichar characters[] = {firstCharacter, secondCharacter};
	NSString *key = [[NSString alloc] initWithCharacters:characters length:2];

	[charactersToKern setObject:kerningPoint forKey:key];

	[key release];
}

@end
