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

#import "PKFadeAction.h"

#import "PKParticle.h"

#include "PXMathUtils.h"
#include "PXPrivateUtils.h"

@implementation PKFadeAction

- (id) init
{
	return [self initWithStart:0xFF end:0x00];
}

- (id) initWithStart:(float)_start end:(float)_end
{
	self = [super init];

	if (self)
	{
		self.start = _start;
		self.end = _end;
	}

	return self;
}

- (void) setStart:(float)val
{
	PXMathClamp(val, 0.0f, 1.0f);

	start = PX_COLOR_FLOAT_TO_BYTE(val);
}

- (float) start
{
	return PX_COLOR_BYTE_TO_FLOAT(start);
}

- (void) setEnd:(float)val
{
	PXMathClamp(val, 0.0f, 1.0f);

	end = PX_COLOR_FLOAT_TO_BYTE(val);
}

- (float) end
{
	return PX_COLOR_BYTE_TO_FLOAT(end);
}

- (void) updateParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter deltaTime:(float)dt
{
	particle->a = PXMathLerp(end, start, particle->energy);
}

+ (PKFadeAction *)fadeAction
{
	return [[[PKFadeAction alloc] init] autorelease];
}

+ (PKFadeAction *)fadeActionWithStart:(float)start end:(float)end
{
	return [[[PKFadeAction alloc] initWithStart:start end:end] autorelease];
}

@end
