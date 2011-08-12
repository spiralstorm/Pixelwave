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

#import "PXFreeTypeFontParser.h"

// Freetype
#include "ft2build.h"
#include FT_FREETYPE_H
#include FT_GLYPH_H

@interface PXFreeTypeFontParser (Private)
- (FT_Error) openLibrary;
- (FT_Error) loadFace;
@end

@implementation PXFreeTypeFontParser

- (BOOL) _initialize
{
	_vLibrary = NULL;
	_vFace = NULL;

	return YES;
}

- (void) dealloc
{
	// Convert the library and face to a format that free type would understand.
	FT_Library library = (FT_Library)_vLibrary;
	FT_Face face = (FT_Face)_vFace;

	if (face)
	{
		// Free the face memory
		FT_Done_Face(face);
	}
	_vFace = NULL;

	if (library)
	{
		// Free the library memory
		FT_Done_FreeType(library);
	}
	_vLibrary = NULL;

	[super dealloc];
}

+ (BOOL) isApplicableForData:(NSData *)data origin:(NSString *)origin
{
	return YES;
}
+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	[extensions addObject:@"ttf"];
	[extensions addObject:@"otf"];
	[extensions addObject:@"pfm"];
	[extensions addObject:@"afm"];
	[extensions addObject:@"inf"];
	[extensions addObject:@"cff"];
	[extensions addObject:@"bdf"];
	[extensions addObject:@"pfr"];
}

- (FT_Error) openLibrary
{
	if (_vLibrary)
		return 0;

	// Initialize the library
	FT_Library *libraryPtr = (FT_Library *)(&_vLibrary);
	FT_Error error = FT_Init_FreeType(libraryPtr);

	return error;
}

- (FT_Error) loadFace
{
	// If the face is already loaded, then return no error
	if (_vFace || !data)
	{
		return 0;
	}

	FT_Library library = (FT_Library)_vLibrary;
	FT_Face *facePtr = (FT_Face *)(&_vFace);

	// Get information about the data.
	int byteCount = [data length];
	const void *bytes = [data bytes];

	// Load the new face into memory.
	FT_Error error = FT_New_Memory_Face(library, bytes, byteCount, 0, facePtr);

	// If an error occured, free the memory already used.
	if (error)
	{
		FT_Done_FreeType(library);
		_vLibrary = NULL;
		_vFace = NULL;
	}

	// Return the error code, 0 is succesfull!
	return error;
}

#pragma mark -
#pragma mark Override

- (BOOL) _parse
{
	FT_Error error;

	// Open the library.
	error = [self openLibrary];
	if (error)
	{
		[self _log:@"couldn't make a freetype library for font"];

		return NO;
	}

	error = [self loadFace];
	if (error == FT_Err_Unknown_File_Format)
	{
		[self _log:@"couldn't read - unknown format"];

		return NO;
	}
	else if (error)
	{
		[self _log:@"was corrupt"];

		return NO;
	}

	return YES;
}

@end
