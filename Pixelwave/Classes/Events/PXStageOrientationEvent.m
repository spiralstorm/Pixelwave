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

#import "PXStageOrientationEvent.h"

#include "PXPrivateUtils.h"

NSString * const PXStageOrientationEvent_OrientationChanging = @"orientationChanging";
NSString * const PXStageOrientationEvent_OrientationChange = @"orientationChange";

@interface PXStageOrientationEvent (Private)
+ (NSString *)orientationName:(PXStageOrientation)orientation;
@end

/**
 * Dispatched by the main stage whenever an
 * orientation change occurs on the device. The event has information needed by
 * the user to handle the change correctly.
 *
 * @see PXStage
 */
@implementation PXStageOrientationEvent

@synthesize beforeOrientation;
@synthesize afterOrientation;

/**
 * Creates a stage orientation event.
 *
 * @param type A string representing the type of the event.
 * @param bubbles Describes whether the event participates in the bubbling phase of the
 * event flow.
 * @param cancelable Describes whether the behavior represented by the event may be canceled.
 * If `YES`, [PXEvent preventDefault:] may be used.
 * @param beforeOrientation The old orientation of the stage.
 * @param afterOrientation The new orientation of the stage.
 */
- (id) initWithType:(NSString *)type
			bubbles:(BOOL)bubbles
		 cancelable:(BOOL)cancelable
  beforeOrientation:(PXStageOrientation)_beforeOrientation
   afterOrientation:(PXStageOrientation)_afterOrientation
{
	self = [super initWithType:type bubbles:bubbles cancelable:cancelable];

	if (self)
	{
		beforeOrientation = _beforeOrientation;
		afterOrientation  = _afterOrientation;
	}

	return self;
}

#pragma mark NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	PXStageOrientationEvent *event = [super copyWithZone:zone];

	event->beforeOrientation = beforeOrientation;
	event->afterOrientation = afterOrientation;

	return event;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"[Event type=\"%@\" bubbles=%@ cancelable=%@ beforeOrientation=%@ afterOrientation=%@]",
			_type,
			PX_BOOL_TO_STRING(_bubbles),
			PX_BOOL_TO_STRING(_cancelable),
			[PXStageOrientationEvent orientationName:beforeOrientation],
			[PXStageOrientationEvent orientationName:afterOrientation]];
}

#pragma mark Pooled Reset

- (void) reset
{
	[super reset];
}

/**
 * Converts an orientation into it's string representation.
 *
 * @param orientation The orientation
 *
 * @return The string representation of the orientation.
 *
 * **Example:**
 *	NSString *orientationString = [PXStageOrientationEvent orientationName:PXStageOrientation_Portrait];
 *	// orientationString = @"portrait"
 */
+ (NSString *)orientationName:(PXStageOrientation)orientation
{
	switch (orientation)
	{
		case PXStageOrientation_Portrait:
			return @"portrait";
		case PXStageOrientation_PortraitUpsideDown:
			return @"portraitUpsideDown";
		case PXStageOrientation_LandscapeLeft:
			return @"landscapeLeft";
		case PXStageOrientation_LandscapeRight:
			return @"landscapeRight";
		default:
			return @"unknown";
	}

	return nil;
}

@end
