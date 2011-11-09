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

#import "PXTextureLoader.h"

#import "PXEngine.h"
#include "PXMathUtils.h"

#import "PXTextureData.h"
#import "PXTextureParser.h"

#import "PXTextureModifier.h"

id<PXTextureModifier> pxTextureLoaderDefaultModifier = nil;

@interface PXTextureLoader(Private)
- (id) initWithContentsOfFile:(NSString *)path
						orURL:(NSURL *)url
					modifier:(id<PXTextureModifier>)_modifier;
- (NSString *)updatePath:(NSString *)path;
@end

/**
 * A PXTextureLoader loads images synchronously and creates #PXTextureData
 * objects.
 *
 * Once instantiated with a valid file path, objects of the #PXTextureLoader
 * class hold a copy of the loaded data and can be used to generate
 * PXTextureData instances.
 *
 * For most uses generating more than one #PXTextureData object is unnecessary
 * as a single PXTextureData may be shared among many PXTexture display
 * objects.
 *
 * Once a PXTextureData instance has been created, the #PXTextureLoader instance
 * may be safely deallocated by calling `release`.
 * Since PXTextureLoader keeps a copy of the loaded data, it is
 * advisable to release all unneeded instances as soon as a #PXTextureData
 * object has been created in order to free up memory.
 *
 * The following image formats are supported natively:
 * 
 * - .tiff and .tif
 * - .jpeg and .jpg
 * - .bmp and .BMPf
 * - .ico
 * - .cur
 * - .xmb
 * - .png (uses libpng)
 * - .pvr
 * - .pvrtc
 *
 * **Example**:
 * The following code sample loads a png file and renders it to the screen:
 * 
 *	// Create a loader object to load and parse the png from the application
 *	// bundle.
 *	PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:@"logo.png"];
 *	// Turn the loaded data to an OpenGL texture
 *	PXTextureData *textureData = [loader newTextureData];
 *	// The loader is no longer needed
 *	[loader release];
 *	loader = nil;
 *
 *	// Create a PXTexture display object to render the texture data to the
 *	// screen.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[textureData release];
 *	textureData = nil;
 *
 *	// Add the display object to the display list so it can be rendered
 *	[self addChild:texture];
 *	[texture release];
 */
@implementation PXTextureLoader

#pragma mark Utility Initializers

/**
 * Creates a new PXTextureLoader instance containing the loaded image data.
 * Returns `nil` if the file could not be found, or the image format
 * isn't supported.
 *
 * @param path The path of the image file to load. The file path may be absolute or
 * relative to	the application bundle. The path may also omit the file
 * extension, and Pixelwave will try to find a valid image with that name.
 *
 * **Example:**
 *	PXTextureLoader *textureLoader = [[PXTextureLoader alloc] initWithContentsOfFile:@"image.png"];
 *	PXTextureData *textureData = [textureLoader newTextureData];
 *
 *	// Add a copy of the texture to the display hierarchy.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 *	[textureData release];
 *	[textureLoader release];
 */
- (id) initWithContentsOfFile:(NSString *)path
{
	return [self initWithContentsOfFile:path orURL:nil modifier:[PXTextureLoader defaultModifier]];
}
/**
 * Creates a new PXTextureLoader instance containing the loaded image data.
 * Returns `nil` if the file could not be found, or the image format
 * isn't supported.
 *
 * @param path The path of the image file to load. The file path may be absolute or
 * relative to	the application bundle. The path may also omit the file
 * extension, and Pixelwave will try to find a valid image with that name.
 * @param modifier A modifier is used to modify the loaded bytes, a backup is kept so can
 * set this to `nil` after getting a new sound, and still have
 * your previously loaded data.
 *
 * **Example:**
 *	PXTextureLoader *textureLoader = [[PXTextureLoader alloc] initWithContentsOfFile:@"image.png"
 *	                                                                        modifier:[PXTextureModifiers textureModifierToPixelFormat:PXTextureDataPixelFormat_RGBA5551]];
 *	// This texture data will be stored as a 5551 texture; as in, 5 bytes for
 *	// red, green, and blue and only 1 byte for alpha.
 *	PXTextureData *textureData = [textureLoader newTextureData];
 *
 *	// Add a copy of the texture to the display hierarchy.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 *	[textureData release];
 *	[textureLoader release];
 */
- (id) initWithContentsOfFile:(NSString *)path modifier:(id<PXTextureModifier>)_modifier
{
	return [self initWithContentsOfFile:path orURL:nil modifier:_modifier];
}

/**
 * Creates a new PXTextureLoader instance containing the loaded image data.
 * Returns `nil` if the file at the url could not be found, or the
 * image format isn't supported.
 *
 * @param url The url of the image to load.
 *
 * **Example:**
 *	PXTextureLoader *textureLoader = [[PXTextureLoader alloc] initWithContentsOfURL:[NSURL URLWithString:@"www.myWebsite.com/image.png"]];
 *	PXTextureData *textureData = [textureLoader newTextureData];
 *
 *	// Add a copy of the texture to the display hierarchy.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 *	[textureData release];
 *	[textureLoader release];
 */
- (id) initWithContentsOfURL:(NSURL *)url
{
	return [self initWithContentsOfFile:nil orURL:url modifier:[PXTextureLoader defaultModifier]];
}
/**
 * Creates a new PXTextureLoader instance containing the loaded image data.
 * Returns `nil` if the file at the url could not be found, or the
 * image format isn't supported.
 *
 * @param url The url of the image to load.
 * @param modifier A modifier is used to modify the loaded bytes, a backup is kept so can
 * set this to `nil` after getting a new sound, and still have
 * your previously loaded data.
 *
 * **Example:**
 *	PXTextureLoader *textureLoader = [[PXTextureLoader alloc] initWithContentsOfURL:[NSURL URLWithString:@"www.myWebsite.com/image.png"]
 *	                                                                       modifier:[PXTextureModifiers textureModifierToPixelFormat:PXTextureDataPixelFormat_RGBA5551]];
 *	// This texture data will be stored as a 5551 texture; as in, 5 bytes for
 *	// red, green, and blue and only 1 byte for alpha.
 *	PXTextureData *textureData = [textureLoader newTextureData];
 *
 *	// Add a copy of the texture to the display hierarchy.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 *	[textureData release];
 *	[textureLoader release];
 */
- (id) initWithContentsOfURL:(NSURL *)url modifier:(id<PXTextureModifier>)_modifier
{
	return [self initWithContentsOfFile:nil orURL:url modifier:_modifier];
}

#pragma mark Designated Initializer

- (id) initWithContentsOfFile:(NSString *)path
						orURL:(NSURL *)url
					modifier:(id<PXTextureModifier>)modifier
{
	self = [super _initWithContentsOfFile:path orURL:url];

	if (self)
	{
		// Initialize the content scale factor
		contentScaleFactor = 1.0f;

		if (path)
		{
			path = [self updatePath:path];
			if (!path)
			{
				[self release];
				return nil;
			}
			
			[self _setOrigin:path];
		}

		if (![self _load])
		{
			[self release];
			return nil;
		}

		// Make a new texture parser
		textureParser = [[PXTextureParser alloc] initWithData:data
													 modifier:modifier
													   origin:origin];

		// If this is nil, then we couldn't load the data
		if (!textureParser)
		{
			[self release];
			return nil;
		}

		// Set the content scale factor
		textureParser.contentScaleFactor = contentScaleFactor;
	}

	return self;
}

- (void) dealloc
{
	// Release the parser
	[textureParser release];
	textureParser = nil;

	// Release the modifier
	self.modifier = nil;

	[super dealloc];
}

/**
 * Use this method to change the automatic contentScaleFactor adjustment
 * that happens when an image is loaded in. It is not advised to use this
 * method unless you know what you're doing.
 */
- (void) setContentScaleFactor:(float)val
{
	textureParser.contentScaleFactor = val;
}

- (void) setModifier:(id<PXTextureModifier>)_modifier
{
	textureParser.modifier = _modifier;
}

- (id<PXTextureModifier>)modifier
{
	return textureParser.modifier;
}

/*
 * Auto-completes the extension of the file if one wasn't provided.
 * This method also checks for a file with the @2x extension in it and returns
 * its name if it finds it. Otherwise it returns the original path.
 */
- (NSString *)updatePath:(NSString *)path
{
	// If no file extension was provided, try to find one
	NSString *resolvedPath = [PXTextureLoader resolvePathForImageFile:path];
	
	if (resolvedPath)
		path = resolvedPath;

	float scaleFactor = 0.0f;
	path = [PXLoader pathForRetinaVersionOfFile:path retScale:&scaleFactor];
	if (!PXMathIsOne(scaleFactor))
	{
		// View scale factor
		// TODO: Why are we using PXEngineGetContentScaleFactor rather then
		// scaleFactor?
		contentScaleFactor = PXEngineGetContentScaleFactor();
	}

	return path;
}

/**
 * Creates a new PXTextureData object containing a copy of the loaded image
 * data. Note that all returned copies must be released by the caller.
 *
 * @return The new texture data.
 */
- (PXTextureData *)newTextureData
{
	return [textureParser newTextureData];
}

#pragma mark Utility Methods

/**
 * Given an image name (with an extension or not), this method tries to find a
 * valid path for it.
 * If it doesn't find an exact match to the fileName, it
 * tries to find siblings with the same name and a supported extension.
 * Returns `nil` if nothing was found.
 */
+ (NSString *)resolvePathForImageFile:(NSString *)fileName
{
	// If the provided file exists, no need to look further
	if ([PXLoader fileExistsAtPath:fileName])
		return fileName;
	
	// Otherwise, try to see if there's a different sibling file with the
	// same name but a different extension that we can read.
	
	// Grab the path components.
	NSString *basePath = [fileName stringByDeletingLastPathComponent];
	NSString *baseName = [fileName lastPathComponent];
	
	// Grab all the valid extensions (all lower case).
	NSArray *extensions = [PXTextureParser supportedFileExtensions];
	
	// Check away...
	return [PXLoader findFileAtPath:basePath withBaseName:baseName validExtensions:extensions];
}

+ (void) setDefaultModifier:(id<PXTextureModifier>)modifier
{
	id<PXTextureModifier> temp = [modifier retain];
	[pxTextureLoaderDefaultModifier release];
	pxTextureLoaderDefaultModifier = temp;
}
+ (id<PXTextureModifier>) defaultModifier
{
	return pxTextureLoaderDefaultModifier;
}

//////////////////////
// Creation methods //
//////////////////////

/**
 * Creates a PXTextureLoader instance containing the loaded image data. Returns
 * `nil` if the file could not be found, or the image format isn't
 * supported.
 *
 * @param path The path of the image file to load. The file path may be absolute or
 * relative to	the application bundle. The path may also omit the file
 * extension, and Pixelwave will try to find a valid image with that name.
 *
 * @return The resulting, `autoreleased`, #PXTextureLoader object.
 *
 *
 * **Example:**
 *	PXTextureLoader *textureLoader = [PXTextureLoader textureLoaderWithContentsOfFile:@"image.png"];
 *	PXTextureData *textureData = [textureLoader newTextureData];
 *
 *	// Add a copy of the texture to the display hierarchy.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 *	[textureData release];
 */
+ (PXTextureLoader *)textureLoaderWithContentsOfFile:(NSString *)path
{
	return [[[PXTextureLoader alloc] initWithContentsOfFile:path] autorelease];
}
/**
 * Creates a PXTextureLoader instance containing the loaded image data. Returns
 * `nil` if the file could not be found, or the image format isn't
 * supported.
 *
 * @param path The path of the image file to load. The file path may be absolute or
 * relative to	the application bundle. The path may also omit the file
 * extension, and Pixelwave will try to find a valid image with that name.
 * @param modifier A modifier is used to modify the loaded bytes, a backup is kept so can
 * set this to `nil` after getting a new sound, and still have
 * your previously loaded data.
 *
 * @return The resulting, `autoreleased`, #PXTextureLoader object.
 *
 * **Example:**
 *	PXTextureLoader *textureLoader = [PXTextureLoader textureLoaderWithContentsOfFile:@"image.png"
 *	                                                                         modifier:[PXTextureModifiers textureModifierToPixelFormat:PXTextureDataPixelFormat_RGBA5551]];
 *	// This texture data will be stored as a 5551 texture; as in, 5 bytes for
 *	// red, green, and blue and only 1 byte for alpha.
 *	PXTextureData *textureData = [textureLoader newTextureData];
 *
 *	// Add a copy of the texture to the display hierarchy.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 *	[textureData release];
 */
+ (PXTextureLoader *)textureLoaderWithContentsOfFile:(NSString *)path modifier:(id<PXTextureModifier>)modifier
{
	return [[[PXTextureLoader alloc] initWithContentsOfFile:path modifier:modifier] autorelease];
}
/**
 * Creates a PXTextureLoader instance containing the loaded image data. Returns
 * `nil` if the file at the url could not be found, or the image
 * format isn't supported.
 *
 * @param url The url of the image to load.
 *
 * @return The resulting, `autoreleased`, #PXTextureLoader object.
 *
 * **Example:**
 *	PXTextureLoader *textureLoader = [PXTextureLoader textureLoaderWithContentsOfURL:[NSURL URLWithString:@"www.myWebsite.com/image.png"]];
 *	PXTextureData *textureData = [textureLoader newTextureData];
 *
 *	// Add a copy of the texture to the display hierarchy.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 *	[textureData release];
 */
+ (PXTextureLoader *)textureLoaderWithContentsOfURL:(NSURL *)url
{
	return [[[PXTextureLoader alloc] initWithContentsOfURL:url] autorelease];
}
/**
 * Creates a PXTextureLoader instance containing the loaded image data. Returns
 * `nil` if the file at the url could not be found, or the image
 * format isn't supported.
 *
 * @param url The url of the image to load.
 * @param modifier A modifier is used to modify the loaded bytes, a backup is kept so can
 * set this to `nil` after getting a new sound, and still have
 * your previously loaded data.
 *
 * @return The resulting, `autoreleased`, #PXTextureLoader object.
 *
 * **Example:**
 *	PXTextureLoader *textureLoader = [PXTextureLoader textureLoaderWithContentsOfURL:[NSURL URLWithString:@"www.myWebsite.com/image.png"]
 *	                                                                        modifier:[PXTextureModifiers textureModifierToPixelFormat:PXTextureDataPixelFormat_RGBA5551]];
 *	// This texture data will be stored as a 5551 texture; as in, 5 bytes for
 *	// red, green, and blue and only 1 byte for alpha.
 *	PXTextureData *textureData = [textureLoader newTextureData];
 *
 *	// Add a copy of the texture to the display hierarchy.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 *	[textureData release];
 */
+ (PXTextureLoader *)textureLoaderWithContentsOfURL:(NSURL *)url modifier:(id<PXTextureModifier>)modifier
{
	return [[[PXTextureLoader alloc] initWithContentsOfURL:url modifier:modifier] autorelease];
}

@end
