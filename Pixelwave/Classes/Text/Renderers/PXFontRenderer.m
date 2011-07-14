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

#import "PXFontRenderer.h"

#import "PXGL.h"
#import "PXTextField.h"
#import "PXMathUtils.h"

@implementation PXFontRenderer

- (id) init
{
	self = [super init];

	if (self)
	{
		// Initialize the variables.
		_textField = nil;

		shiftX = 0.0f;
		shiftY = 0.0f;
	}

	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void) _updateAlignment
{
	// Now that we have been validated, it is a good idea to update the
	// alignment bounds.
	// Figure out the location based off the alignment.
	_bounds.origin.x = -PXMathContentRoundf(_bounds.size.width  * _textField->_alignHorizontal);
	_bounds.origin.y = -PXMathContentRoundf(_bounds.size.height * _textField->_alignVertical);

	// Setting the alignment will update the bounds.
	shiftX = PXMathContentRoundf(_bounds.origin.x - shiftX);
	shiftY = PXMathContentRoundf(_bounds.origin.y - shiftY);
}

- (void) _validate
{
	shiftX = 0.0f;
	shiftY = 0.0f;

	[self _updateAlignment];
}

- (BOOL) smoothing
{
	return NO;
}

- (void) setSmoothing:(BOOL)val
{
}

@end
