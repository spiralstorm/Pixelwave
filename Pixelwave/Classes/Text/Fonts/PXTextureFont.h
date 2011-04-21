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

#import "PXFont.h"

@class PXTextureGlyph;
@class PXPoint;
@class PXLinkedList;

@interface PXTextureFont : PXFont
{
/// @cond DX_IGNORE
@public
	float _baseLine;
	float _fontSize;

@protected
	NSMutableDictionary *characterToGlyph;
	NSMutableDictionary *charactersToKern;
/// @endcond
}

/**
 *	A list holding references to every PXTextureData used to make up the
 *	PXTextureFont object
 */
@property (nonatomic, readonly) PXLinkedList *textureDatas;

@end

@interface PXTextureFont(Mutable)
- (PXTextureGlyph *)glyphFromCharacter:(unichar)character;
- (PXPoint *)kerningPointFromFirstCharacter:(unichar)firstCharacter
secondCharacter:(unichar)secondCharacter;

- (void) setGlyph:(PXTextureGlyph *)glyph forString:(NSString *)string;
- (void) setGlyph:(PXTextureGlyph *)glyph forCharacter:(unichar)character;

- (void) setKerningPoint:(PXPoint *)kerningPoint forString:(NSString *)string;
- (void) setKerningPoint:(PXPoint *)kerningPoint
	   forFirstCharacter:(unichar)firstCharacter
		 secondCharacter:(unichar)secondCharacter;
@end