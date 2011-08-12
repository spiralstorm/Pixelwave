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

#import "PXEvent.h"
#import <UIKit/UITouch.h>

#include "PXHeaderUtils.h"

@class PXPoint;

PXExtern NSString * const PXTouchEvent_Tap;
PXExtern NSString * const PXTouchEvent_TouchDown;
PXExtern NSString * const PXTouchEvent_TouchMove;
PXExtern NSString * const PXTouchEvent_TouchUp;
PXExtern NSString * const PXTouchEvent_TouchCancel;

@interface PXTouchEvent : PXEvent <NSCopying, PXPooledObject>
{
@public
	UITouch *_nativeTouch;

	unsigned _tapCount;

	float _stageX;
	float _stageY;
}

/**
 * The touch object used for keeping track of what finger started the touch.
 */
@property (nonatomic, readonly) UITouch *nativeTouch;

/**
 * Indicates if the touch which triggered this event has been captured by the
 * target. The object which captured the event will usually be a
 * #PXInteractiveObject for which the [PXInteractiveObject captureTouches]
 * property has been set to `YES`. If #captured equals
 * `YES`, the [PXTouchEvent target] property will represent the
 * object which captured this touch.
 */
@property (nonatomic, readonly) BOOL captured;

/**
 * Returns `YES` if the touch is contained within the bounds of the
 * target.
 */
@property (nonatomic, readonly) BOOL insideTarget;

/**
 * The horizontal location in global (stage) coordinates where the touch
 * occured.
 */
@property (nonatomic, readonly) float stageX;
/**
 * The vertical location in global (stage) coordinates where the touch occured.
 */
@property (nonatomic, readonly) float stageY;
/**
 * The horizontal location in local (target) coordinates where the touch
 * occured.
 */
@property (nonatomic, readonly) float localX;
/**
 * The vertical location in local (target) coordinates where the touch occured.
 */
@property (nonatomic, readonly) float localY;

/**
 * The location in global (stage) coordinates where the touch occured.
 */
@property (nonatomic, readonly) PXPoint *stagePosition;
/**
 * The location in local (target) coordinates where the touch occured.
 */
@property (nonatomic, readonly) PXPoint *localPosition;

/**
 * The number of touches that have been repeated in the same place without
 * moving.
 */
@property (nonatomic, readonly) unsigned tapCount;

- (id) initWithType:(NSString *)type
		nativeTouch:(UITouch *)touch
			 stageX:(float)stageX
			 stageY:(float)stageY
		   tapCount:(unsigned)tapCount;
@end
