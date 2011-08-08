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

/// @cond DX_IGNORE
typedef enum
{
	_PXSimpleButtonVisibleState_Up = 0,
	_PXSimpleButtonVisibleState_Down
} _PXSimpleButtonVisibleState;
/// @endcond

@interface PXSimpleButton : PXInteractiveObject
{
/// @cond DX_IGNORE
@protected
	PXDisplayObject *downState;
	PXDisplayObject *upState;
	id<NSObject> hitTestState;

	_PXSimpleButtonVisibleState visibleState;

	PXLinkedList *listOfTouches;

	CGRect autoExpandRect;
	float autoExpandSize;

	BOOL enabled;
@private
	PXEventListener *pxSBOnTouchDown;
	PXEventListener *pxSBOnTouchUp;
	PXEventListener *pxSBOnTouchMove;
	PXEventListener *pxSBOnTouchCancel;
/// @endcond
}

/**
 *	A PXDisplayObject that specifies the visual down state for the button.
 */
@property (nonatomic, retain) PXDisplayObject *downState;
/**
 *	A PXDisplayObject that specifies the visual up state for the button.
 */
@property (nonatomic, retain) PXDisplayObject *upState;
/**
 *	A PXDisplayObject or PXRectangle that specifies the hit area for the button.
 *	If <code>nil</code> is specified then no interaction can exist on this
 *	button. If neither a PXDisplayObject nor PXRectangle are specified, a debug
 *	message will be printed and it will be treated as though <code>nil</code>
 *	were passed instead.
 *
 *	Note:	The hit test state will never be visible. It is only used to check
 *			bounds.
 *
 *	Note:	If this variable is changed when the button is already pressed down,
 *			the rest of the touch interaction already associated with this
 *			button will remain with the same size as the previous hitTestState.
 *			The effect of changing the variable will not take place until no
 *			further touches are interacting with it.
 */
@property (nonatomic, retain) id<NSObject> hitTestState;
/**
 *	Whether the button is enabled (pressable).
 *
 *	@b Default: <code>YES</code>.
 */
@property (nonatomic, assign) BOOL enabled;

/**
 *	A padding around the button that is automatically added to the size if and
 *	only if the hit test state is a <code>PXRectangle</code>. A negative number
 *	will decrease the size of the rectangle.
 *
 *	@b Default: 9.0f.
 */
@property (nonatomic, assign) float autoExpandSize;

//-- ScriptIgnore
- (id) initWithUpState:(PXDisplayObject *)upState
			 downState:(PXDisplayObject *)downState;

//-- ScriptName: SimpleButton
//-- ScriptArg[0]: nil
//-- ScriptArg[1]: nil
//-- ScriptArg[2]: nil
- (id) initWithUpState:(PXDisplayObject *)upState
			 downState:(PXDisplayObject *)downState
		  hitTestState:(id<NSObject>)hitTestState;

//-- ScriptIgnore
+ (PXSimpleButton *)simpleButtonWithUpState:(PXDisplayObject *)upState
								  downState:(PXDisplayObject *)downState;
//-- ScriptName: make
//-- ScriptArg[0]: nil
//-- ScriptArg[1]: nil
//-- ScriptArg[2]: nil
+ (PXSimpleButton *)simpleButtonWithUpState:(PXDisplayObject *)upState
								  downState:(PXDisplayObject *)downState
							   hitTestState:(id<NSObject>)hitTestState;

@end
