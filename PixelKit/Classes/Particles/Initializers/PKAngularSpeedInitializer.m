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

#import "PKAngularSpeedInitializer.h"

#import "PKParticle.h"

#include "PXMathUtils.h"

@implementation PKAngularSpeedInitializer

@synthesize range;

- (id) init
{
	return [self initWithRange:PKRangeMake(0.0f, 0.0f)];
}

- (id) initWithRange:(PKRange)_range
{
	self = [super init];

	if (self)
	{
		self.range = _range;
	}

	return self;
}

- (void) setRange:(PKRange)_range
{
	range = PKRangeMake(PXMathToRad(_range.start), PXMathToRad(_range.end));
}

- (PKRange) range
{
	return PKRangeMake(PXMathToDeg(range.start), PXMathToDeg(range.end));
}

- (void) initializeParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter
{
	particle->angularSpeed = PKRangeRandom(range);
}

+ (PKAngularSpeedInitializer *)angularSpeedInitializerWithRange:(PKRange)range
{
	return [[[PKAngularSpeedInitializer alloc] initWithRange:range] autorelease];
}

@end
