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
	PXDisplayObject *hitTestState;

	_PXSimpleButtonVisibleState visibleState;

	PXLinkedList *listOfTouches;

	BOOL enabled;
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
 *	A PXDisplayObject that specifies the hit area for the button. If
 *	<code>nil</code> is specified then no interaction can exist on this button.
 */
@property (nonatomic, retain) PXDisplayObject *hitTestState;
/**
 *	Whether the button is enabled (pressable).
 *	@b Default: <code>YES</code>.
 */
@property (nonatomic, assign) BOOL enabled;

//-- ScriptName: SimpleButton
//-- ScriptArg[0]: nil
//-- ScriptArg[1]: nil
//-- ScriptArg[2]: nil
- (id) initWithUpState:(PXDisplayObject *)upState
			 downState:(PXDisplayObject *)downState
		  hitTestState:(PXDisplayObject *)hitTestState;

//-- ScriptName: make
//-- ScriptArg[0]: nil
//-- ScriptArg[1]: nil
//-- ScriptArg[2]: nil
+ (PXSimpleButton *)simpleButtonWithUpState:(PXDisplayObject *)upState
								  downState:(PXDisplayObject *)downState
							   hitTestState:(PXDisplayObject *)hitTestState;

@end
