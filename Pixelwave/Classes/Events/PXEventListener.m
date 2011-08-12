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

#import "PXEventListener.h"

#import "PXEvent.h"
#import "PXExceptionUtils.h"

/**
 * Acts as a wrapper for an Objective-C method. Used
 * when adding and removing event listeners from the #PXEventDispatcher class.
 * 
 * @see PXListener
 * @see [PXEventDispatcher addEventListenerOfType:listener:useCapture:priority:]
 */
@implementation PXEventListener

/**
 */
- (id) initWithTarget:(PXGenericObject)target selector:(SEL)selector
{
	// Check params
	if (!target)
	{
		PXThrowNilParam(target);
		[self release];
		return nil;
	}
	if (!selector)
	{
		PXThrowNilParam(selector);
		[self release];
		return nil;
	}

	// Make sure the selector is valid
	if (![target respondsToSelector:selector])
	{
		NSString *str = [NSString stringWithFormat:@"Selector doesn't exist '%@:%@'", NSStringFromClass([target class]), NSStringFromSelector(selector)];
		PXThrow(PXArgumentException, str);
		[self release];
		return nil;
	}

	self = [super init];

	if (self)
	{
		// TODO Later: Check if the function accepts type of PXEvent?
		
		_target = target;
		_selector = selector;
		_listenerRef = (PXEventListenerFuncRef)[_target methodForSelector:_selector];
	}
	
	return self;
}

- (void) dealloc
{
	_target = nil;

	_selector = nil;
	_listenerRef = nil;

	[super dealloc];
}

+ (PXEventListener *)eventListenerWithTarget:(PXGenericObject)target
									selector:(SEL)selector
{
	return [[[PXEventListener alloc] initWithTarget:target
										selector:selector] autorelease];
}

@end
