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

/**
 *	@ingroup Display
 *
 *	A PXSprite is a concrete display object that can contain children and has a
 *	graphics object.
 *
 *	@see PXSimpleSprite
 *	@see PXGraphics
 */
@implementation PXSprite

- (id) init
{
	self = [super init];
	if (self)
	{
		_renderMode = PXRenderMode_BatchAndManageStates;
		_graphics = nil;
	}

	return self;
}

- (PXGraphics *)graphics
{
	if (!_graphics)
		_graphics = [[PXGraphics alloc] init];

	_renderMode = PXRenderMode_BatchAndManageStates;

	return _graphics;
}

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	*retBounds = CGRectZero;
	[_graphics _measureLocalBounds:retBounds];
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	return [_graphics _containsPointWithLocalX:x localY:y shapeFlag:shapeFlag];
}

- (void) _renderGL
{
	//Render the graphics object
	if (_graphics)
		[_graphics _renderGL];
}

- (void) dealloc
{
	if (_graphics)
	{
		[_graphics release];
		_graphics = nil;
	}

	[super dealloc];
}

@end
