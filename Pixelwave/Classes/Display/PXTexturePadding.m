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

#import "PXTexturePadding.h"

/**
 * A simple object representing the white-space (if any)
 * to be included around a PXTexture.
 */
@implementation PXTexturePadding

#pragma mark -
#pragma mark init/dealloc
#pragma mark -

- (id) init
{
	return [self initWithTop:0.0f right:0.0f bottom:0.0f left:0.0f];
}

- (id) initWithTop:(float)top right:(float)right bottom:(float)bottom left:(float)left
{
	self = [super init];
	
	if (self)
	{
		_padding = _PXTexturePaddingMake(top, right, bottom, left);
	}
	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	return [[PXTexturePadding allocWithZone:zone] initWithTop:_padding.top
														right:_padding.right
													   bottom:_padding.bottom
														 left:_padding.left];
}

#pragma mark -
#pragma mark properties
#pragma mark -

- (float) top
{
	return _padding.top;
}
- (void) setTop:(float)top
{
	_padding.top = MAX(0.0f, top);
}
- (float) right
{
	return _padding.right;
}
- (void) setRight:(float)right
{
	_padding.right = MAX(0.0f, right);
}
- (float) bottom
{
	return _padding.bottom;
}
- (void) setBottom:(float)bottom
{
	_padding.bottom = MAX(0.0f, bottom);
}
- (float) left
{
	return _padding.left;
}
- (void) setLeft:(float)left
{
	_padding.left = MAX(0.0f, left);
}

- (void) setTop:(float)top right:(float)right bottom:(float)bottom left:(float)left
{
	_padding = _PXTexturePaddingMake(top, right, bottom, left);
}

#pragma mark -
#pragma mark static methods
#pragma mark -

+ (PXTexturePadding *)texturePaddingWithTop:(float)top right:(float)right bottom:(float)bottom left:(float)left
{
	return [[[PXTexturePadding alloc] initWithTop:top right:right bottom:bottom left:left] autorelease];
}

@end

#pragma mark -
#pragma mark c methods
#pragma mark -

_PXTexturePadding _PXTexturePaddingMake(float top, float right, float bottom, float left)
{
	_PXTexturePadding retVal;

	retVal.top    = top;
	retVal.right  = right;
	retVal.bottom = bottom;
	retVal.left   = left;

	return retVal;
}
