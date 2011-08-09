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

#ifndef _PX_SETTINGS_H_
#define _PX_SETTINGS_H_

#include "PXHeaderUtils.h"

/*
 * Global properties that can be tweaked / read by the user.
 */

////////////////
// Versioning //
////////////////

typedef struct
{
	int major;		// Significant changes
	int minor;		// Incremental changes
	int revision;	// Bug fixes
} PXVersion;

extern PXVersion pxVersion;

#define PXGenericObject id

///////////////
// Debugging //
///////////////

// Uncomment the #ifdef and #endif around PX_DEBUG_MODE if you want don't want
// debugging capabilities to be enabled in release builds.

//#ifdef PIXELWAVE_DEBUG

// Enables various debugging capabilities in the engine, comment this out if you
// never want debugging capabilities.
#define PX_DEBUG_MODE

//#define PX_AL_DEBUG_MODE

//#endif

//////////
// Misc //
//////////

PXExtern const float PXEngineTouchRadius;
PXExtern const float PXEngineTouchRadiusSquared;
PXExtern const float PXEngineTapDuration;

// Should the engine randomize the timer when it starts out? Why not.
#define PX_SEED_RAND_WITH_TIME_ON_INIT 1

// Internal linked lists
#define PX_LINKED_LISTS_USE_POOLED_NODES YES

// Debugging
#define PX_ENGINE_IDLE_TIME_INCLUDES_BETWEEN_SYSTEM_CALLS 0

// Text
PXExtern NSString * const PXTextFieldDefaultFont;

// Using libpng or CoreImage
#define PX_TEXTURE_PARSER_USE_LIBPNG 1

///////////////////
// Screen colors //
///////////////////

#define PX_VIEW_DEFAULT_COLOR_QUALITY PXViewColorQuality_High

// Point color conversion.
// Faster if this is set to 0, however less accurate when it comes to floating
#define PX_ACCURATE_COLOR_TRANSFORMATION_MODE 1

#endif //_PX_SETTINGS_H_
