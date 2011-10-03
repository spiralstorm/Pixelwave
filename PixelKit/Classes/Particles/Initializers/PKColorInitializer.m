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

#import "PKColorInitializer.h"
#import "PKParticle.h"

#include "PXMathUtils.h"

@implementation PKColorInitializer

- (id) init
{
	return [self initWithMinColor:0xFFFFFF maxColor:0xFFFFFF];
}

- (id) initWithMinColor:(unsigned int)_minColor maxColor:(unsigned int)_maxColor
{
	self = [super init];

	if (self)
	{
		self.minColor = _minColor;
		self.maxColor = _maxColor;
	}

	return self;
}

- (void) setMinColor:(unsigned int)color
{
	minColor.asUInt = color;
}

- (unsigned int) minColor
{
	return minColor.asUInt;
}

- (void) setMaxColor:(unsigned int)color
{
	maxColor.asUInt = color;
}

- (unsigned int) maxColor
{
	return maxColor.asUInt;
}

- (void) initializeParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter
{
#define PKColorInitializerRandomizeColorFromVariance(_store_, _min_, _max_) \
{ \
	int __val__ = PXMathIntInRange(_min_, _max_); \
	PXMathClamp(__val__, 0x00, 0xFF); \
	_store_ = (__val__); \
}

	PKColorInitializerRandomizeColorFromVariance(particle->r, minColor.asARGB.r, maxColor.asARGB.r);
	PKColorInitializerRandomizeColorFromVariance(particle->g, minColor.asARGB.g, maxColor.asARGB.g);
	PKColorInitializerRandomizeColorFromVariance(particle->b, minColor.asARGB.b, maxColor.asARGB.b);
}

+ (PKColorInitializer *)colorInitializerWithMinColor:(unsigned int)minColor maxColor:(unsigned int)maxColor
{
	return [[[PKColorInitializer alloc] initWithMinColor:minColor maxColor:maxColor] autorelease];
}

@end
