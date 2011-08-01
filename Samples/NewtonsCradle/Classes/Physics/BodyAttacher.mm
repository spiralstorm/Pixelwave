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

#import "BodyAttacher.h"

#import "Box2D.h"
#import "Box2DUtils.h"

#import "PXMathUtils.h"

@implementation BodyAttacher

@synthesize body;

- (id) init
{
	self = [super init];

	if (self)
	{
		body = NULL;
	}

	return self;
}

- (void) dealloc
{
	body = NULL;

	[super dealloc];
}

// (Overriden) Synchronizes the display object to match the position and
// rotation of the physics body. This method gets invoked once per frame
// by the NewtonsCradleRoot class.
- (void) update
{
	if (!body || !displayObject)
	{
		return;
	}
	
	b2Vec2 position = body->GetPosition();
	float  angle    = body->GetAngle();
	
	// We need to convert Box2D's position units (meters) to Pixelwave's
	// position units (points).
	displayObject.x = MetersToPoints(position.x) + xOffset;
	displayObject.y = MetersToPoints(position.y) + yOffset;
	
	// We also need to convert Box2D's angle units (radians) to Pixelwave's
	// angle units (degrees).
	displayObject.rotation = PXMathToDeg(angle) + rotationOffset;
}

@end
