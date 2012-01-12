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

#import "PKSteadyFlow.h"

#import "PXMathUtils.h"

@implementation PKSteadyFlow

@synthesize rate;

- (id) init
{
	return [self initWithRate:10.0f];
}

- (id) initWithRate:(float)_rate
{
    self = [super init];

    if (self)
	{
		self.rate = _rate;
    }

    return self;
}

- (void) setRate:(float)value
{
	rate = value;

	if (PXMathIsZero(rate))
	{
		rateInv = 0.0f;
	}
	else
	{
		rateInv = 1.0f / rate;
	}
}

- (unsigned int) updateWithEmitter:(PKParticleEmitter *)emitter deltaTime:(float)dt
{
	if (running == NO)
		return 0;

	timeCounter += dt;

	unsigned int count = timeCounter / rateInv;

	if (timeCounter > 0)
		count = MAX(1, count);

	timeCounter -= count * rateInv;

	return count;
}

+ (PKSteadyFlow *)steadyFlowWithRate:(float)rate
{
	return [[[PKSteadyFlow alloc] initWithRate:rate] autorelease];
}

@end
