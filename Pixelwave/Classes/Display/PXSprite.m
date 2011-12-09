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

#import "PXSprite.h"

#import "PXGraphics.h"
#import "PXRectangle.h"

#include "PXDebug.h"
#include "PXPrivateUtils.h"

/**
 * A PXSprite is a concrete display object that can contain children and has a graphics object.
 *
 * @see PXSimpleSprite
 * @see PXGraphics
 */
@implementation PXSprite

- (id) init
{
	self = [super init];

	if (self)
	{
		_renderMode = PXRenderMode_Off;
		_graphics = nil;
	}

	return self;
}

- (void) dealloc
{
	if (_graphics)
	{
		[_graphics release];
		_graphics = nil;
	}

	self.hitArea = nil;

	[super dealloc];
}

- (PXGraphics *)graphics
{
	if (_graphics == nil)
	{
		_graphics = [[PXGraphics alloc] init];
		_renderMode = PXRenderMode_BatchAndManageStates;
	}

	return _graphics;
}

- (void) setHitArea:(id<NSObject>)_hitArea
{
	[_hitArea retain];
	[hitArea release];
	hitArea = nil;

	hitAreaIsRect = NO;
	PX_DISABLE_BIT(self->_flags, _PXDisplayObjectFlags_useCustomHitArea);
	PX_DISABLE_BIT(self->_flags, _PXDisplayObjectFlags_forceAddToDisplayHitList);

	if ([_hitArea isKindOfClass:[PXDisplayObject class]] == YES)
	{
		hitArea = [(PXDisplayObject *)_hitArea retain];
		PX_ENABLE_BIT(self->_flags, _PXDisplayObjectFlags_useCustomHitArea);
		PX_ENABLE_BIT(self->_flags, _PXDisplayObjectFlags_forceAddToDisplayHitList);
	}
	else if ([_hitArea isKindOfClass:[PXRectangle class]] == YES)
	{
		hitAreaIsRect = YES;
		hitAreaRect = PXRectangleToCGRect((PXRectangle *)_hitArea);
		PX_ENABLE_BIT(self->_flags, _PXDisplayObjectFlags_useCustomHitArea);
		PX_ENABLE_BIT(self->_flags, _PXDisplayObjectFlags_forceAddToDisplayHitList);
	}
	else if (_hitArea != nil)
	{
		PXDebugLog(@"PXDisplayObject ERROR: hitTestState MUST be either a PXRectangle or PXDisplayObject\n");
	}

	[_hitArea release];
}

- (id<NSObject>) hitArea
{
	if (hitAreaIsRect == YES)
		return PXRectangleFromCGRect(hitAreaRect);

	return hitArea;
}

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	return [self _measureLocalBounds:retBounds useStroke:YES];
}

- (void) _measureLocalBounds:(CGRect *)retBounds useStroke:(BOOL)useStroke
{
	*retBounds = CGRectZero;

	if (hitAreaIsRect)
	{
		*retBounds = hitAreaRect;
	}
	else if (hitArea)
	{
		if (useStroke == YES) // For the sake of baackwards compatability
			[hitArea _measureGlobalBounds:retBounds];
		else
			[hitArea _measureGlobalBounds:retBounds useStroke:useStroke];
	}
	else
	{
		[_graphics _measureLocalBounds:retBounds useStroke:useStroke];
	}
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	if (hitAreaIsRect == YES)
	{
		return CGRectContainsPoint(hitAreaRect, CGPointMake(x, y));
	}
	else if (hitArea != nil)
	{
		return [hitArea _hitTestPointWithParentX:x parentY:y shapeFlag:shapeFlag];
	}

	return [_graphics _containsPointWithLocalX:x localY:y shapeFlag:shapeFlag];
}

- (void) _renderGL
{
	// Render the graphics object
	if (_graphics)
	{
		[_graphics _renderGL];
	}
}

/**
 * A utility method for quickly creating a #PXSprite containing
 * the specified child object.
 *
 * @param child A display object to add to the created #PXSprite
 * @return	An autoareleased PXSimpleSprite
 */
+ (PXSprite *)spriteWithChild:(PXDisplayObject *)child
{
	PXSprite *sprite = [[PXSprite alloc] init];

	if (child)
	{
		[sprite addChild:child];
	}

	return [sprite autorelease];
}

/**
 * A utility method for quickly creating a #PXSprite containing
 * the specified children objects.
 *
 * @param children A list of children to add to the created #PXSprite
 * @return	An autoareleased PXSimpleSprite
 */
+ (PXSprite *)spriteWithChildren:(NSArray *)children
{
	PXSprite *sprite = [[PXSprite alloc] init];

	for (NSObject *object in children)
	{
		if ([object isKindOfClass:[PXDisplayObject class]])
		{
			[sprite addChild:(PXDisplayObject *)object];
		}
	}

	return [sprite autorelease];
}

@end
