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

#include "PXSettings.h"

@class PXEvent;

typedef void (*PXEventListenerFuncRef)(id, SEL, PXEvent *);

/*@
 * Quickly generates a PXEventListener object for a given method
 * signature.
 * assumes that the method exists within the current class (`self`)
 *
 * _Example:_
 * In this example the method `onTouch:` is assigned as a
 * listener to the stage's `touchDown` event
 *	[self.stage addEventListenerForType:PXTouchEvent_TouchDown listener:PXListener(onTouchDown:)];
 *	//...
 *	- (void) onTouchDown:(PXTouchEvent *)event
 *	{
 *		// handle event
 *	}
 *
 * @param methodSignature a valid method signature
 * @see [PXEventDispatcher addEventListenerOfType:listener:]
 */
#define PXListener(_selector_) [[[PXEventListener alloc] initWithTarget:self selector:@selector(_selector_)] autorelease]

// Utility macros
#define _PXEventListenerInvoke(_listener_, _event_) _listener_->_listenerRef(_listener_->_target, _listener_->_selector, _event_)
#define _PXEventListenersAreEqual(_a_, _b_) (((_a_)->_target == (_b_)->_target) && ((_a_)->_selector == (_b_)->_selector))

@interface PXEventListener : NSObject
{
@public
	PXGenericObject _target;
	SEL _selector;
	PXEventListenerFuncRef _listenerRef;
	int _priority;
}

//-- ScriptName: EventListener
- (id) initWithTarget:(PXGenericObject)target
			 selector:(SEL)selector;

//-- ScriptName: make
+ (PXEventListener *)eventListenerWithTarget:(PXGenericObject)target
									selector:(SEL)selector;

@end
