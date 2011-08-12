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

#include <CoreGraphics/CGGeometry.h>

@class PXTextureData;

@interface PXTextureGlyph : NSObject
{
@public
	CGPoint _advance;
	CGRect _bounds;
	CGRect _textureBounds;
@private
	PXTextureData *textureData;
}

/**
 * The texture data that will be used for the graphical representation of this
 * texture glpyh.
 */
@property (nonatomic, retain) PXTextureData *textureData;

/**
 * The advance describes the position this glyph will move the next glyph; as
 * in, if you were to draw two glyphs next to eachother on the horizontal
 * plane, then the x-advance would be the distance from the first glyph to the
 * next. Thus, you would increment the current drawing position by the x value
 * of the advance.
 *
 * **Note:**
 * These values are in PIXELS and pixelwave uses POINTS for its
 * coordinate system. Thus, prior to displaying on the screen, you must
 * convert each of these values to POINTS. This can be done by dividing
 * each of the values by the contentScaleFactor you are using. 
 */
@property (nonatomic) CGPoint advance;

/**
 * The bounds describe the size and origin of the glyph. Meaning, the glyph
 * should start at position (bounds.origin.x, bounds.origin.y) and it will 
 * consume the size of (bounds.size.width, bounds.size.height).
 * 
 * **Note:**
 * These values are in PIXELS and pixelwave uses POINTS for its
 * coordinate system. Thus, prior to displaying on the screen, you must
 * convert each of these values to POINTS. This can be done by dividing
 * each of the values by the contentScaleFactor you are using. 
 */
@property (nonatomic) CGRect bounds;

/**
 * The texture bounds describes box, whos values range between 0.0f and 1.0f,
 * that describe where on the texture this glyph's data is representing.
 */
@property (nonatomic) CGRect textureBounds;

@end
