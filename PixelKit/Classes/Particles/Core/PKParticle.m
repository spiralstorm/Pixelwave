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

#import "PKParticle.h"

/**
 * 
 */
@implementation PKParticle

- (id) init
{
	self = [super init];

	if (self)
	{
		[self reset];
	}

	return self;
}

- (void) reset
{
	x = 0.0f;
	y = 0.0f;

	velocityX = 0.0f;
	velocityY = 0.0f;

	r = 0xFF;
	g = 0xFF;
	b = 0xFF;
	a = 0xFF;

	lifetime = 0.0f;
	age = 0.0f;
	energy = 1.0f;
	
	graphic = nil;
	userData = NULL;

	scaleX = 1.0f;
	scaleY = 1.0f;

	rotation = 0.0f;
	angularSpeed = 0.0f;

	blendSource = GL_SRC_ALPHA;
	blendDestination = GL_ONE_MINUS_SRC_ALPHA;
	
	sMin = 0.0f;
	sMax = 1.0f;
	tMin = 0.0f;
	tMax = 1.0f;
	
	isExpired = NO;
	wasJustCreated = YES;
}

@end
