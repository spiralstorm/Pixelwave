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

#import "PKSpeedLimitAction.h"

#import "PKParticle.h"

#include "PXMathUtils.h"

@implementation PKSpeedLimitAction

@synthesize limit;
@synthesize isMinimum;

- (id) initWithLimit:(float)_limit isMinimum:(BOOL)_isMinimum
{
	self = [super init];

	if (self)
	{
		self.limit = _limit;
		self.isMinimum = _isMinimum;
	}

	return self;
}

- (void) setLimit:(float)value;
{
	limit = value;
	limitSq = limit * limit;
}

- (void) updateParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter deltaTime:(float)dt
{
	float vx = particle->velocityX;
	float vy = particle->velocityY;

	float speedSq = vx * vx + vy * vy;

	if (((isMinimum == YES) && (speedSq < limitSq)) || ((isMinimum == NO) && (speedSq > limitSq)))
	{
		// If the particle isn't moving, and it should have a minimum speed, set
		// its velocity to the minimum speed with a random direction;
		if (PXMathIsZero(speedSq))
		{
			if (isMinimum == YES)
			{
				float angle = PXMathFloatInRange(-M_PI, M_PI);

				particle->velocityX = limit * cosf(angle);
				particle->velocityY = limit * sinf(angle);
			}

			return;
		}

		float scale = limit / sqrtf(speedSq);

		particle->velocityX = vx * scale;
		particle->velocityY = vy * scale;
	}
}

+ (PKSpeedLimitAction *)speedLimitActionWithLimit:(float)limit isMinimum:(BOOL)isMinimum
{
	return [[[PKSpeedLimitAction alloc] initWithLimit:limit isMinimum:isMinimum] autorelease];
}

@end
