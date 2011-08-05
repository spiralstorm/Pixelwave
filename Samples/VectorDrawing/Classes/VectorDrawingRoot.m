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

#import "VectorDrawingRoot.h"

@implementation VectorDrawingRoot

- (void) initializeAsRoot
{
	// Make the background black
	self.stage.backgroundColor = 0x000000;
	
	period = 0.0f;
	circleShape = YES;

	// An optimizatoin - we are only listening to touch events on the stage.
	self.stage.touchChildren = NO;
	
	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame)];
	[self.stage addEventListenerOfType:PXTouchEvent_Tap listener:PXListener(onTap)];
}

- (void) dealloc
{
	[self removeEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame)];
	[self.stage removeEventListenerOfType:PXTouchEvent_Tap listener:PXListener(onTap)];

	[super dealloc];
}

- (void) onTap
{
	circleShape = !circleShape;
}

- (void) onFrame
{
	// Grab a reference to the root's Graphics object.
	// All vector drawing is done via the graphics object.
	PXGraphics *g = self.graphics;

	// Clear the previous frame
	[g clear];

	static const unsigned int count = 100;

	float cX, cY;
	float radius;
	float t;

	period += 0.05f;

	for (unsigned int index = 0; index < count; ++index)
	{
		t = index / (float)count;

		// Set the style of the line
		[g lineStyleWithThickness:7.0f * t + 1
							color:0xFF0000 
							alpha:(index + 1.0f) / count];

		cX = self.stage.stageWidth  * t * 0.7f + 40.0;
		cY = self.stage.stageHeight * 0.5f + sinf(t * M_PI * 2.0f * 2.0f - period) * 60.0f;

		radius = t * 50.0f + 25.0f;

		if (circleShape)
		{
			// Draw a circle with the specified line style
			[g drawCircleWithX:cX y:cY radius:radius];
		}
		else
		{
			// Rects are drawn starting at the top-left so offset the pos
			// a bit
			cX -= radius;
			cY -= radius;

			// Draw a rect with the specified line style
			[g drawRectWithX:cX y:cY width:radius * 2.0f height:radius * 2.0f];
		}
	}
}

@end
