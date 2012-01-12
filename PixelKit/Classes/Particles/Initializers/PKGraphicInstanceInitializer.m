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

#import "PKGraphicInstanceInitializer.h"
#import "PKParticle.h"

#import "Pixelwave.h"

@implementation PKGraphicInstanceInitializer

@synthesize instanceType;

- (id) init
{
	return [self initWithInstanceType:nil usePooledInstances:YES];
}

- (id) initWithInstanceType:(Class)_instanceType usePooledInstances:(BOOL)usePooledInstances
{
    self = [super init];

    if (self)
	{
		instanceType = _instanceType;

		if (usePooledInstances)
		{
			pooledInstances = [[PXLinkedList alloc] init];
		}
    }

    return self;
}

- (void) dealloc
{
	[pooledInstances release];
	pooledInstances = nil;

	[super dealloc];
}

- (BOOL) usePooledInstances
{
	return (pooledInstances != nil);
}

#pragma mark -

- (void) initializeParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter
{
	PXDisplayObject *graphic = nil;

	if (pooledInstances)
	{
		if (pooledInstances.count > 0)
		{
			graphic = [pooledInstances.lastObject retain];
			[pooledInstances removeLastObject];
		}
	}

	if (!graphic)
	{
		graphic = [[instanceType alloc] init];
	}

	particle->graphic = graphic;
}

- (void) disposeParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter
{
	// We do two similar loops to avoid the if statements inside the loop
	if (pooledInstances != nil)
	{
		PXDisplayObject *graphic;
		graphic = (PXDisplayObject *)particle->graphic;
		[pooledInstances addObject:graphic];
		[graphic release];

		particle->graphic = nil;
	}
	else
	{
		[((PXDisplayObject *)particle->graphic) release];
		particle->graphic = nil;
	}
}

- (Class) graphicType
{
	return instanceType;
}

+ (PKGraphicInstanceInitializer *)graphicInstanceInitializerWithInstanceType:(Class)instanceType usePooledInstances:(BOOL)usePooledInstances
{
	return [[[PKGraphicInstanceInitializer alloc] initWithInstanceType:instanceType usePooledInstances:usePooledInstances] autorelease];
}

@end
