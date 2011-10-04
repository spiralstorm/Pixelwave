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

#import "FaderOuter.h"
#import "PKFrameTimer.h"
#import "PKFrameTimerEvent.h"
#import "PXMathUtils.h"

static FaderOuter *sharedFaderOuter = nil;

@interface FadeItem : NSObject
{
@private
	float time, delay;
	PXDisplayObject *displayObject;
}

@property (nonatomic, assign) float time;
@property (nonatomic, assign) float delay;
@property (nonatomic, retain) PXDisplayObject *displayObject;

@end

@implementation FadeItem
@synthesize time, delay, displayObject;
@end

@implementation FaderOuter

- (id) init
{
    self = [super init];

	if (self)
	{
		items = [[PXLinkedList alloc] init];

		[[PKFrameTimer sharedFrameTimer] addEventListenerOfType:PKFrameTimerEvent_Tick listener:PXListener(onTick:)];
	}

	return self;
}

- (void) dealloc
{
	[[PKFrameTimer sharedFrameTimer] removeEventListenerOfType:PKFrameTimerEvent_Tick listener:PXListener(onTick:)];

	[items release];
	items = nil;

	[super dealloc];
}

- (void) fadeOutObject:(PXDisplayObject *)object afterDelay:(float)delay
{
	FadeItem *item = [[FadeItem alloc] init];
	item.displayObject = object;
	item.delay = delay;

	[items addObject:item];
	[item release];
}
- (void) stopAnimationsForObject:(PXDisplayObject *)object
{
	NSMutableArray *toRemove = [[NSMutableArray alloc] init];

	FadeItem *item;

	for (item in items)
	{
		if (item.displayObject == object)
		{
			[toRemove addObject:item];
		}
	}

	for (item in toRemove)
	{
		[items removeObject:item];
	}

	[toRemove release];
}

- (void) onTick:(PKFrameTimerEvent *)event
{
	FadeItem *item;

	float fadeTime = 0.5f;
	float t;

	NSMutableArray *toRemove = [[NSMutableArray alloc] init];

	for (item in items)
	{
		item.time += event.deltaTime;

		if (item.time > item.delay)
		{
			t = (item.time - item.delay) / fadeTime;

			if (t >= 1.0f)
			{
				t = 1.0f;

				[toRemove addObject:item];
			}

			item.displayObject.alpha = PXMathLerpf(1.0f, 0.0f, t);
		}
	}

	for (item in toRemove)
	{
		item.displayObject.visible = NO;
		[items removeObject:item];
	}

	[toRemove release];
}

+ (FaderOuter *)sharedFader
{
	if (!sharedFaderOuter)
	{
		sharedFaderOuter = [[FaderOuter alloc] init];
	}

	return sharedFaderOuter;
}

@end
