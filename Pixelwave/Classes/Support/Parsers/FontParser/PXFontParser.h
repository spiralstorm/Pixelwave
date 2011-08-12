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

#import "PXParser.h"

#include <CoreGraphics/CGGeometry.h>

@class PXFont;
@class PXFontOptions;
@class PXFontFuser;

@interface PXFontParser : PXParser
{
@protected
	PXFontOptions *options;
	PXFontFuser *fontFuser;

	float contentScaleFactor;
}

/**
 * The options that describe what type of font you want back. If
 * `nil` is supplied, then the default type of font for the font
 * type is used. If no default type is found, then no new font can be made.
 */
@property (nonatomic, readonly) PXFontOptions *options;

/**
 * Returns the content scale factor of the parsed font.
 */
@property (nonatomic, readonly) float contentScaleFactor;

//-- ScriptIgnore
- (id) initWithData:(NSData *)data options:(PXFontOptions *)options origin:(NSString *)origin;
//-- ScriptName: FontParser
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: nil
//-- ScriptArg[3]: 1.0f
- (id) initWithData:(NSData *)data options:(PXFontOptions *)options origin:(NSString *)origin contentScaleFactor:(float)contentScaleFactor;

//-- ScriptName: FontParserWithSystemFont
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
- (id) initWithSystemFont:(NSString *)systemFont options:(PXFontOptions *)options;

//-- ScriptName: newFont
- (PXFont *)newFont;

@end

@interface PXFontParser (Override)
- (id) _initWithData:(NSData *)data
			 options:(PXFontOptions *)options
			  origin:(NSString *)origin
  contentScaleFactor:(float)contentScaleFactor;
- (Class) defaultFuser;
@end

typedef struct
{
	CGPoint advance;
	CGPoint origin;
	CGRect bounds;
	void *bitmapGlyph;
} _PXGlyphDef;
