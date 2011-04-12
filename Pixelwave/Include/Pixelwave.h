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

#ifndef _PIXEL_WAVE_H_
#define _PIXEL_WAVE_H_

/**
 *	@defgroup TopLevel Top Level
 *		The Top Level module holds the functions and classes with global
 *		visibility
 *	@defgroup Cocoa Cocoa
 *		The Cocoa module holds all classes which are necessary to connect
 *		Pixelwave with Cocoa Touch
 *	@defgroup Geom Geom
 *		The Geom module holds all geometry related classes
 *	@defgroup Events Events
 *		The Events module holds classes related to event dispatching and event
 *		types
 *	@defgroup Display Display
 *		The Display module holds all classes related to rendering and the
 *		display list
 *	@defgroup Media Media
 *		The Media module holds all classes related to audio
 *	@defgroup Text Text
 *		The Text module holds all classes related to displaying text
 *	@defgroup Loaders Loaders
 *		The Loaders module holds all classes related to loading assets
 *	@defgroup Utils Utils
 *		The Top Level module holds the functions and classes with global
 *		visibility 
 */

#ifdef __cplusplus
extern "C" {
#endif

// General
#import "PXSettings.h"
	
// Top Level
#import "PXTopLevel.h"
#import "PXMath.h"
	
// Cocoa
#import "PXView.h"

// Display
#import "PXDisplayObject.h"
#import "PXStage.h"
#import "PXShape.h"
#import "PXGraphics.h"
#import "PXSprite.h"
#import "PXSimpleSprite.h"
#import "PXTexture.h"
#import "PXClipRect.h"
#import "PXTexturePadding.h"
#import "PXTextureData.h"
#import "PXSimpleButton.h"
	
// Events
#import "PXEventDispatcher.h"
#import "PXEvent.h"
#import "PXTouchEvent.h"
#import "PXStageOrientationEvent.h"
	
// Geometry
#import "PXTransform.h"
#import "PXColorTransform.h"
#import "PXMatrix.h"
#import "PXRectangle.h"
#import "PXPoint.h"
#import "PXVector3D.h"
	
// Media
#import "PXSoundMixer.h"
#import "PXSoundListener.h"
#import "PXSoundTransform.h"
#import "PXSoundTransform3D.h"
#import "PXSound.h"
#import "PXSoundChannel.h"
	
// Text
#import "PXFont.h"
#import "PXTextField.h"
#import "PXTextureFontOptions.h"

// Loaders
#import "PXTextureLoader.h"
#import "PXSoundLoader.h"
#import "PXFontLoader.h"

// Utils

// - TextureAtlas
#import "PXTextureAtlas.h"
#import "PXAtlasFrame.h"
	
// - Modifiers
#import "PXSoundModifier.h"
#import "PXTextureModifier.h"
#import "PXSoundModifiers.h"
#import "PXTextureModifiers.h"

// - Regex
#import "PXRegexMatcher.h"
#import "PXRegexPattern.h"

// Debug
#import "PXDebug.h"

#ifdef __cplusplus
}
#endif

#endif
