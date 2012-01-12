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

#import "PKDesignerFlow.h"

#import "PKParticleEmitter.h"

#include "PXMathUtils.h"

@implementation PKDesignerFlow

@synthesize rate;
@synthesize max;
@synthesize duration;

- (id) init
{
    self = [super init];

    if (self)
	{
        duration = -1.0f;
    }

    return self;
}

- (void) setRate:(float)_rate
{
	rate = fabsf(_rate);

	// If it is zero, then we use 0 as the emission DT - this is a special check
	// later.
	if (PXMathIsZero(rate))
		emissionDT = 0.0f;
	else
		emissionDT = 1.0f / rate;
}

- (unsigned int) updateWithEmitter:(PKParticleEmitter *)emitter deltaTime:(float)dt
{
	if (running == NO)
		return 0;

	unsigned int addCount = 0;

	float localEmissionDT = dt;

	BOOL shouldAdd = NO;

	if (duration < 0.0f)
	{
		// INFINATE
		shouldAdd = YES;
	}
	else
	{
		if (durationAccum >= duration)
		{
			// The duration accumulator is greater than the duration, so we are
			// done emitting... but may have some particles still floating out
			// there to update.
			if (PXArrayBufferCount(emitter.particles) == 0)
			{
				completed = YES;
				return 0;
			}
		}
		else
		{
			// If the duration is smaller, then we still have time to add
			// particles!
			shouldAdd = YES;
		}

		if (durationAccum + dt > duration)
		{
			localEmissionDT = duration - durationAccum;
		}

		// Add to the accumulator.
		durationAccum += dt;
	}

	if (shouldAdd)
	{
		// If we can add, and the DT is not zero, then lets find out how much we
		// should add.
		emissionAccum += localEmissionDT;
		addCount = roundf(emissionAccum / emissionDT);

		if (max > 0)
		{
			// If the max particle count is greater than 0, then we have a cap,
			// lets see if it is outside the cap and if so, readjust the add
			// count. This count is useful for efficency and the desigener
			// requires one.
			unsigned int currentCount = PXArrayBufferCount(emitter.particles);

			if (currentCount + addCount > max)
			{
				addCount = max - currentCount;
			}
		}

		emissionAccum -= emissionDT * addCount;
	}

	return addCount;
}

- (BOOL) complete
{
	return completed;
}

@end
