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

#import "PXTopLevel.h"

// PX_TEXTURE_PARSER_USE_LIBPNG is defined in settings.
#import "PXSettings.h"

// Parsers
#import "PXParser.h"

// PXParser - Texture
#import "PXCGTextureParser.h"
#import "PXPVRTextureParser.h"

#if(PX_TEXTURE_PARSER_USE_LIBPNG)
#import "PXPNGTextureParser.h"
#endif

// PXParser - Sound
#import "PXAVSoundParser.h"
#import "PXALSoundParser.h"

// PXParser - Text
#import "PXFreeTypeFontParser.h"
#import "PXSystemFontParser.h"
#import "PXFNTFontParser.h"

// PXParser - TextureAtlas
#import "PXTPAtlasParser.h"
#import "PXZwopAtlasParser.h"
#import "PXAnimationAtlasParser.h"

// Font Fusers
#import "PXFontFuser.h"

// Font Fusers - Texture
#import "PXFreeTypeTextureFontFuser.h"
#import "PXSystemTextureFontFuser.h"
#import "PXFNTTextureFontFuser.h"

// Loaders with default modifiers
#import "PXTextureLoader.h"
#import "PXSoundLoader.h"

double pxTopLevelStartTime;

#pragma mark Implemetations

void _PXTopLevelInitialize( )
{
	pxTopLevelStartTime = [NSDate timeIntervalSinceReferenceDate];

	// These are stacks, it will always try the last one inserted, and work
	// it's way to the front until it finds a valid one.

	///////////////////////////// Add the Parsers \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	[PXParser registerParser:[PXCGTextureParser class]		forBaseClass:[PXTextureParser class]];
	[PXParser registerParser:[PXPVRTextureParser class]		forBaseClass:[PXTextureParser class]];
#if(PX_TEXTURE_PARSER_USE_LIBPNG)
	[PXParser registerParser:[PXPNGTextureParser class]		forBaseClass:[PXTextureParser class]];
#endif

	[PXParser registerParser:[PXAVSoundParser class]		forBaseClass:[PXSoundParser class]];
	[PXParser registerParser:[PXALSoundParser class]		forBaseClass:[PXSoundParser class]];

	[PXParser registerParser:[PXFreeTypeFontParser class]	forBaseClass:[PXFontParser class]];
	[PXParser registerParser:[PXSystemFontParser class]		forBaseClass:[PXFontParser class]];
	[PXParser registerParser:[PXFNTFontParser class]		forBaseClass:[PXFontParser class]];

	[PXParser registerParser:[PXTPAtlasParser class]		forBaseClass:[PXTextureAtlasParser class]];
	[PXParser registerParser:[PXZwopAtlasParser class]		forBaseClass:[PXTextureAtlasParser class]];
	[PXParser registerParser:[PXAnimationAtlasParser class]	forBaseClass:[PXTextureAtlasParser class]];

	////////////////////////////// Add the Fusers \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	[PXFontFuser registerFontFuser:[PXFreeTypeTextureFontFuser class]];
	[PXFontFuser registerFontFuser:[PXSystemTextureFontFuser class]];
	[PXFontFuser registerFontFuser:[PXFNTTextureFontFuser class]];
}

void _PXTopLevelDealloc()
{
	[PXParser unregisterAllParsers];
	[PXFontFuser unregisterAllFontFusers];

	[PXTextureLoader setDefaultModifier:nil];
	[PXSoundLoader setDefaultModifier:nil];
}

double PXGetTimerSec( )
{
	return [NSDate timeIntervalSinceReferenceDate] - pxTopLevelStartTime;
}

long PXGetTimer( )
{
	return (long)(([NSDate timeIntervalSinceReferenceDate] - pxTopLevelStartTime) * 1000);
}
