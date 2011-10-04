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

#import "PKParticleEffectLoader.h"
#import "PKParticleEffectParser.h"

#import "PKPEXParticleEffectParser.h"
#import "PKPListParticleEffectParser.h"

@interface PKParticleEffectLoader(Private)
- (id) initWithContentsOfFile:(NSString *)path orURL:(NSURL *)url;
@end

/**
 * Loads a particle effect from file or a URL.
 * Like every subclass of PXLoader, the loading process is as follows:
 * # Create an instance of #PKParticleEffectLoader, initializing with file or url.
 * The loading is done synchronously. If it is successful, the instance of #PKParticleEffectLoader
 * is non-nil.
 * # Calling the #newParticleEffect method returns a new #PKParticleEffect object containing the parsed data.
 * # At this point the loader can be discarded.
 *
 * Another, quicker option is the [PKParticleEffect particleEffectWithContentsOfFile:] method, or
 * the URL equivalent.
 *
 * The following particle effect formats are supported:
 *
 * * .pex - ParticleDesigner xml file with embedded particle image.
 * * .plist - Particle designer plist with external particle image.
 */
@implementation PKParticleEffectLoader

+ (void) initialize
{
	// Define the parsers we can use
	[PXParser registerParser:[PKPEXParticleEffectParser class]   forBaseClass:[PKParticleEffectParser class]];
	[PXParser registerParser:[PKPListParticleEffectParser class] forBaseClass:[PKParticleEffectParser class]];
}

- (id) initWithContentsOfFile:(NSString *)path
{
	return [self initWithContentsOfFile:path orURL:nil];
}

- (id) initWithContentsOfURL:(NSURL *)url
{
	return [self initWithContentsOfFile:nil orURL:url];
}

- (id) initWithContentsOfFile:(NSString *)path orURL:(NSURL *)url
{
	self = [super _initWithContentsOfFile:path orURL:url];

	if (self != nil)
	{
		if (path != nil)
		{
			[self _setOrigin:path];
		}

		if ([self _load] == NO)
		{
			[self release];
			return nil;
		}

		// Make a new texture parser
		effectParser = [[PKParticleEffectParser alloc] initWithData:data origin:origin];

		// If this is nil, then we couldn't load the data
		if (effectParser == nil)
		{
			[self release];
			return nil;
		}
	}

	return self;
}

- (void) dealloc
{
	// Release the parser
	[effectParser release];
	effectParser = nil;

	[super dealloc];
}

- (PKParticleEffect *)newParticleEffect
{
	return [effectParser newParticleEffect];
}

+ (PKParticleEffectLoader *)particleEffectLoaderWithContentsOfFile:(NSString *)path
{
	return [[[PKParticleEffectLoader alloc] initWithContentsOfFile:path] autorelease];
}

+ (PKParticleEffectLoader *)particleEffectLoaderWithContentsOfURL:(NSURL *)url
{
	return [[[PKParticleEffectLoader alloc] initWithContentsOfURL:url] autorelease];
}

@end
