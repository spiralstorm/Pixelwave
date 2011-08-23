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

#import "PXInteractiveObject.h"

typedef enum
{
	_PXSimpleButtonVisibleState_Up = 0,
	_PXSimpleButtonVisibleState_Down
} _PXSimpleButtonVisibleState;

@interface PXSimpleButton : PXInteractiveObject
{
@protected
	PXDisplayObject *downState;
	PXDisplayObject *upState;
	PXDisplayObject *hitTestState;

	_PXSimpleButtonVisibleState visibleState;

	PXLinkedList *pxSimpleButtonTouchList;

	BOOL enabled;
	BOOL isPressed;
	BOOL hitAreaIsRect;

	CGRect hitAreaRect;

	float autoInflateAmount;
}

/// @name Setting the button's visual states

/**
 * A PXDisplayObject that specifies the visual down state for the button.
 */
@property (nonatomic, retain) PXDisplayObject *downState;
/**
 * A PXDisplayObject that specifies the visual up state for the button.
 */
@property (nonatomic, retain) PXDisplayObject *upState;
/**
 * A PXDisplayObject or PXRectangle that specifies the hit area for the button.
 * If `nil` is specified then no interaction can exist on this button. If
 * neither a PXDisplayObject nor PXRectangle are specified, a debug message will
 * be printed and it will be treated as though `nil` were passed instead.
 *
 * @warning: The hit test state will never be rendered. It is only used to
 * represent the button's touchable area.
 */
@property (nonatomic, retain) id<NSObject> hitTestState;

/// @name Setting the button's hit area

/**
 * The amount of padding (in points) to apply to the rectangular hit area when
 * the button is pressed down.
 * 
 * To turn off automatic inflation of the hit area simply set this value to 0. A
 * negative value will deflate the hit area when the button is pressed instead.
 *
 * _Default:_ 60.0
 *
 * @warning The bounds of the button's hit area will only be inflated if the
 * #hitTestState of the button is an object of type #PXRectangle. If
 * #hitTestState is a #PXDisplayObject instead, this value will simply be
 * ignored.
 */
@property (nonatomic, assign) float autoInflateAmount;

/// @see Controlling user interaction

/**
 * Whether the button is enabled (pressable).
 * **Default:** `YES`.
 */
@property (nonatomic, assign) BOOL enabled;

/// @name Creating and initializing Buttons

//-- ScriptName: SimpleButton
//-- ScriptArg[0]: nil
//-- ScriptArg[1]: nil
//-- ScriptArg[2]: nil
- (id) initWithUpState:(PXDisplayObject *)upState
			 downState:(PXDisplayObject *)downState
		  hitTestState:(id<NSObject>)hitTestState;

//-- ScriptIgnore
- (id) initWithUpState:(PXDisplayObject *)upState
			 downState:(PXDisplayObject *)downState
	hitRectWithPadding:(float)hitRectPadding;

- (id) initWithUpState:(PXDisplayObject *)upState
			 downState:(PXDisplayObject *)downState;

//-- ScriptIgnore
+ (PXSimpleButton *)simpleButtonWithUpState:(PXDisplayObject *)upState
								  downState:(PXDisplayObject *)downState
						 hitRectWithPadding:(float)hitRectPadding;
//-- ScriptName: make
//-- ScriptArg[0]: nil
//-- ScriptArg[1]: nil
//-- ScriptArg[2]: nil
+ (PXSimpleButton *)simpleButtonWithUpState:(PXDisplayObject *)upState
								  downState:(PXDisplayObject *)downState
							   hitTestState:(id<NSObject>)hitTestState;

@end
