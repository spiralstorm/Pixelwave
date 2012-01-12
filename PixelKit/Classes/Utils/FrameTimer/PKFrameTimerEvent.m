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

#import "PKFrameTimerEvent.h"

#include "PXPrivateUtils.h"

NSString * const PKFrameTimerEvent_Tick = @"tick";

@implementation PKFrameTimerEvent

@synthesize deltaTime = _deltaTime;

- (id) initWithType:(NSString *)type deltaTime:(float)deltaTime
{
	self = [super initWithType:type bubbles:NO cancelable:NO];

	if (self)
	{
		_deltaTime = deltaTime;
	}

	return self;
}

#pragma mark NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	PXEvent *event = [[[self class] allocWithZone:zone] initWithType:_type deltaTime:_deltaTime];

	event->_currentTarget = _currentTarget;
	event->_target = _target;
	event->_eventPhase = _eventPhase;

	event->_defaultPrevented = _defaultPrevented;
	event->_stopPropagationLevel = _stopPropagationLevel;

	event->_bubbles = _bubbles;
	event->_cancelable = _cancelable;

	return event;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"[Event type=\"%@\" bubbles=%@ cancelable=%@ deltaTime=%f]",
			_type,
			PX_BOOL_TO_STRING(_bubbles),
			PX_BOOL_TO_STRING(_cancelable),
			_deltaTime];
}

#pragma mark Pooled Reset

- (void) reset
{
	[super reset];
	
	_deltaTime = 0.0f;
}

@end
