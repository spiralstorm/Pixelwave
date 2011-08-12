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

#import "PXEngine.h"

#import "PXDebug.h"

/**
 * A PXLoader is a base loader class that lays out the foundation for each
 * different type of loader.
 *
 */

/*	Internal Docs:
 * The loaders have a very simple job. A loader loads raw data and passes it to
 * the appropriate parser to actually return a usable object.
 */
@implementation PXLoader

@synthesize originType;
@synthesize origin;
@synthesize data;

- (id) init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

/**
 * Creates a new loader object containing the loaded information as data.
 * Returns `nil` if the file could not be found, or the file type
 * isn't supported.
 *
 * @param filePath The path of the file to load. The file path may be absolute or relative
 * to the application bundle.
 */
- (id) initWithContentsOfFile:(NSString *)path
{
	return [self _initWithContentsOfFile:path orURL:nil];
}

/**
 * Creates a new loader object containing the loaded information as data.
 * Returns `nil` if the file could not be found, or the file type
 * isn't supported.
 *
 * @param url The url of the file to load.
 */
- (id) initWithContentsOfURL:(NSURL *)url
{
	return [self _initWithContentsOfFile:nil orURL:url];
}

- (id) _initWithContentsOfFile:(NSString *)path orURL:(NSURL *)url
{
	self = [super init];

	if (self)
	{
		if (path)
		{
			originType = PXLoaderOriginType_File;
			[self _setOrigin:path];
		}
		else if (url)
		{
			originType = PXLoaderOriginType_URL;
			[self _setOrigin:[url absoluteString]];
		}
		else
		{
			[self release];
			return nil;
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

// This method loads the file stored in 'origin' into the 'data' variable.
// If the file isn't found, or there's a different error, NO is returned.
// YES is returned on success.
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

#pragma mark -
#pragma mark Static Methods(Public)

/**
 * Creates the absolute path from the relative path given. If the path is
 * already absolute, then it is just returned back.
 *
 * @param path The relative path.
 *
 * @return The absolute path.
 */
+ (NSString *)absolutePathFromPath:(NSString *)path
{
	NSString *absPath = nil;

	if ([path isAbsolutePath])
	{
		// If the path is already absolute (location on the HD)
		// just return it to them.
		absPath = path;
	}
	else
	{
		// The user only provided a file name... the only place to check for
		// the full path is the bundle
		absPath = [[NSBundle mainBundle] pathForResource:path ofType:nil];
	}

	return absPath;
}

+ (BOOL) fileExistsAtPath:(NSString *)path
{
	path = [self absolutePathFromPath:path];
	
	NSFileManager *manager = [NSFileManager new];
	BOOL exists = [manager fileExistsAtPath:path];
	[manager release];
	
	return exists;
}

/**
 * Looks for a sibling of the current file, with the given name.
 */
+ (NSString *)pathForSiblingOfFile:(NSString *)path withName:(NSString *)fileName
{
	return [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
}

/**
 * Looks for a sibling of the current file, with the same name but a different
 * extension.
 */
+ (NSString *)pathForSiblingOfFile:(NSString *)path withExtension:(NSString *)extension;
{
	NSString *fileName = [[[path lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:extension];
	return [self pathForSiblingOfFile:path withName:fileName];
}

+ (NSString *)pathForRetinaVersionOfFile:(NSString *)path retScale:(float *)outScale
{
	if (!path)
		return nil;

	float scaleFactor = 1.0f;

	// Device scale factor
	int screenScaleFactor = PXEngineGetMainScreenScale();

	// If the screen scale factor is larger then 1, then we should check for
	// alternate images.
	if (screenScaleFactor > 1)
	{
		// Find the extension for the file, and the part before the extension so
		// that we can add the @#x in front of it, where # is a variable that is
		// the content scaling factor (in integer form), and the char 'x'. This
		// is Apple's convention for file naming. The xPath is the combination
		// of these strings.
		NSString *extension = [path pathExtension];
		NSString *preExtension = [path stringByDeletingPathExtension];
		NSString *appendString = [NSString stringWithFormat:@"@%dx.", screenScaleFactor];
		NSString *xPath = [[preExtension stringByAppendingString:appendString] stringByAppendingString:extension];

		// If we find a file with this naming convetion, we need to use that
		// file instead, however if we don't, then use the original.
		if ([PXLoader fileExistsAtPath:xPath])
		{
			path = xPath;
			scaleFactor = screenScaleFactor;
		}
	}

	if (outScale)
		*outScale = scaleFactor;

	return path;
}

/**
 * Tries to find a file at the given path with the given base name and one of
 * the provided extensions.
 * 
 * @param basePath The directory in which the file is to be found
 * @param baseName The name of the file to be found not including its extension
 * @param extensions Valid extensions to match against the files in basePath
 *
 * @return The path to the found file or nil if one couldn't be found.
 */
+ (NSString *)findFileAtPath:(NSString *)basePath withBaseName:(NSString *)baseName validExtensions:(NSArray *)extensions
{
	if (![basePath isAbsolutePath])
	{
		basePath = [[NSBundle mainBundle] resourcePath];
	}
	
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSArray *files = [fm contentsOfDirectoryAtPath:basePath error:nil];
	[fm release];
	
	if (!files)
		return nil;
	
	// Looping variables
	//NSString *path = nil;
	NSString *fileName = nil;
	NSString *ext = nil;
	
	for (fileName in files)
	{
		//fileName = [path lastPathComponent];
		// See if the file names match
		if ([baseName isEqualToString:[fileName stringByDeletingPathExtension]])
		{
			// See if the extension matches
			ext = [[fileName pathExtension] lowercaseString];
			if ([extensions containsObject:ext])
			{
				return [basePath stringByAppendingPathComponent:fileName];
			}
			
		}
	}
	
	return nil;
}

@end
