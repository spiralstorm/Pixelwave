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

#import "PXTextureModifiers.h"

#import "PXTextureModifier.h"

#import "PXDebug.h"

#import "PXTextureModifier8888.h"
#import "PXTextureModifier4444.h"
#import "PXTextureModifier565.h"
#import "PXTextureModifier888.h"
#import "PXTextureModifier5551.h"
#import "PXTextureModifierA8.h"
#import "PXTextureModifierL8.h"
#import "PXTextureModifierLA88.h"

/**
 * PXTextureModifiers creates a texture modifier from a premade list of
 * modifiers.
 */
@implementation PXTextureModifiers

/**
 * Makes a texture modifier that will convert your texture to the desired
 * format!
 *
 * @param format The desired texture foramt.
 *
 * @return A texture modifier that will convert your texture to the desired format.
 */
+ (id<PXTextureModifier>) textureModifierToPixelFormat:(PXTextureDataPixelFormat)format
{
	switch (format)
	{
		case PXTextureDataPixelFormat_RGBA8888:
			return [[[PXTextureModifier8888 alloc] init] autorelease];
		case PXTextureDataPixelFormat_RGBA4444:
			return [[[PXTextureModifier4444 alloc] init] autorelease];
		case PXTextureDataPixelFormat_RGBA5551:
			return [[[PXTextureModifier5551 alloc] init] autorelease];
		case PXTextureDataPixelFormat_RGB565:
			return [[[PXTextureModifier565 alloc] init] autorelease];
		case PXTextureDataPixelFormat_RGB888:
			return [[[PXTextureModifier888 alloc] init] autorelease];
		case PXTextureDataPixelFormat_L8:
			return [[[PXTextureModifierL8 alloc] init] autorelease];
		case PXTextureDataPixelFormat_A8:
			return [[[PXTextureModifierA8 alloc] init] autorelease];
		case PXTextureDataPixelFormat_LA88:
			return [[[PXTextureModifierLA88 alloc] init] autorelease];
		case PXTextureDataPixelFormat_RGB_PVRTC2:
			break;
		case PXTextureDataPixelFormat_RGB_PVRTC4:
			break;
		case PXTextureDataPixelFormat_RGBA_PVRTC2:
			break;
		case PXTextureDataPixelFormat_RGBA_PVRTC4:
			break;
	}

	PXDebugLog(@"Converting to the pixel format [%d] is not supported at this time.\n", format);

	return nil;
}

@end
