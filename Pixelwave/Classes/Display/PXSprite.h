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

#import "PXDisplayObjectContainer.h"

@class PXGraphics;
@class PXLinkedList;

@interface PXSprite : PXDisplayObjectContainer
{
@public
	PXGraphics *_graphics;

@protected
	BOOL hitAreaIsRect;
	PXDisplayObject *hitArea;
	CGRect hitAreaRect;
}

/**
 * The graphics object that belongs to the sprite where vector drawing is done.
 */
@property (nonatomic, readonly) PXGraphics *graphics;

/**
 * Assigns another #PXDisplayObject or #PXRectangle as the hit area of the sprite. If the `hitArea`
 * is `nil`, as by default, the contents of the sprite are used as the hit area.
 *
 * The `hitArea` of a sprite describes the area within which it can receive touch events. The value of `hitArea`
 * can be a #PXDisplayObject _or_ a #PXRectangle. You can change the value of this property at any time, and it
 * will take effect immediately. If the `hitArea` is a #PXDisplayObject it doesn't have to be visible or be on the
 * the display list as only its shape is used for hit testing.
 */
@property (nonatomic, retain) id<NSObject> hitArea;

@end
