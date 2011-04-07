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

#import "PXLoader.h"

#import "PXDebug.h"

/**
 *	@ingroup Loaders
 *
 *	A PXLoader is a base loader class that lays out the foundation for each
 *	different type of loader.
 *
 */

/*	Internal Docs:
 *	The loaders have a very simple job. A loader loads raw data and passes it to
 *	the appropriate parser to actually return a usable object.
 */
@implementation PXLoader

@synthesize originType;
@synthesize origin;
@synthesize data;

- (id) init
{
	if (self = [super init])
	{
	}

	return self;
}

/**
 *	Creates a new loader object containing the loaded information as data.
 *	Returns <code>nil</code> if the file could not be found, or the file type
 *	isn't supported.
 *
 *	@param filePath
 *		The path of the file to load. The file path may be absolute or relative
 *		to the application bundle.
 */
- (id) initWithContentsOfFile:(NSString *)path
{
	return [self _initWithContentsOfFile:path orURL:nil];
}

/**
 *	Creates a new loader object containing the loaded information as data.
 *	Returns <code>nil</code> if the file could not be found, or the file type
 *	isn't supported.
 *
 *	@param url
 *		The url of the file to load.
 */
- (id) initWithContentsOfURL:(NSURL *)url
{
	return [self _initWithContentsOfFile:nil orURL:url];
}

- (id) _initWithContentsOfFile:(NSString *)path orURL:(NSURL *)url
{
	if (self = [super init])
	{
		if (path)
		{
			originType = PXLoaderOriginType_File;
			[self _setOrigin:path];
		}
		else
		{
			originType = PXLoaderOriginType_URL;
			[self _setOrigin:[url absoluteString]];
		}
	}

	return self;
}

- (void) dealloc
{
	[self _setOrigin:nil];

	[data release];

	[super dealloc];
}

#pragma mark -
#pragma mark Private Properties

- (void) _setOrigin:(NSString *)_origin
{
	[origin release];

	origin = [_origin copy];
}

#pragma mark -
#pragma mark Protected Methods

- (BOOL) _load
{
	NSError *error = nil;

	if (originType == PXLoaderOriginType_File)
	{
		NSString *absPath = [PXLoader absolutePathFromPath:origin];

		if (!absPath)
		{
			[self _log:[NSString stringWithFormat:@"file not found."]];
			return NO;
		}

		data = [[NSData alloc] initWithContentsOfFile:absPath options:0 error:&error];
	}
	else if (originType == PXLoaderOriginType_URL)
	{
		NSURL *url = [NSURL URLWithString:origin];
		data = [[NSData alloc] initWithContentsOfURL:url options:0 error:&error];
	}

	if (error)
	{
		[self _log:[NSString stringWithFormat:@"error occured: %@", error]];

		return NO;
	}

	return (data ? YES : NO);
}

- (void) _log:(NSString *)message
{
	// We can do a useful log message that includes the origin.
	PXDebugLog(@"[%@] %@\n", origin, message);
}

- (NSString *)_updatePath:(NSString *)path
{
	return path;
}
- (NSURL *)_updateURL:(NSURL *)url
{
	return url;
}

#pragma mark -
#pragma mark Static Methods(Public)

/**
 *	Creates the absolute path from the relative path given. If the path is
 *	already absolute, then it is just returned back.
 *
 *	@param path
 *		The relative path.
 *
 *	@return
 *		The absolute path.
 */
+ (NSString *)absolutePathFromPath:(NSString *)path
{
	NSString *absPath = nil;

	// If the path is already absolute, just return it to them
	if ([path isAbsolutePath])
	{
		absPath = path;
	}
	else
	{
		// Find the absoulte path
		absPath = [[NSBundle mainBundle] pathForResource:path ofType:nil];
	}

	return absPath;
}

@end
