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

#import "PXTextureParser.h"

#import "PXGL.h"

#import "PXDebug.h"

#import "PXParsedTextureData.h"
#import "PXTextureData.h"
#import "PXTextureModifier.h"

#include "PXPrivateUtils.h"

/**
 * A PXTextureParser takes the given data, and parses it into information
 * needed to render the image.
 *
 * **Example:**
 *	NSData *data = [[NSData alloc] initWithContentsOfFile:@"image.png"];
 *	PXTextureParser *textureParser = [[PXTextureParser alloc] initWithData:data];
 *	PXTextureData *textureData = [textureParser newTextureData];
 *
 *	// Add a copy of the texture to the display hierarchy.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 *	[textureData release];
 *	[textureParser release];
 *	[data release];
 */
@implementation PXTextureParser

@synthesize modifier;
@synthesize contentScaleFactor;

- (id) init
{
	PXDebugLog (@"TextureParser must be instantiated with data, modifier, and origin");
	[self release];
	return nil;
}
/**
 * Makes a new texture parser takes the given data, and parses it into
 * information needed to render the image.
 *
 * @param data The loaded data.
 * @param modifier A modifier is used to modify the loaded bytes, a backup is kept so can
 * set this to `nil` after getting a new texture data, and still
 * have your previously loaded data.
 * @param origin The origin of the font.
 *
 * **Example:**
 *	NSData *data = [[NSData alloc] initWithContentsOfFile:@"image.png"];
 *	PXTextureParser *textureParser = [[PXTextureParser alloc] initWithData:data
 *	                                                              modifier:[PXTextureModifiers textureModifierToPixelFormat:PXTextureDataPixelFormat_RGBA5551]
 *	                                                                origin:@"image.png"];
 *	// This texture data will be stored as a 5551 texture; as in, 5 bytes for
 *	// red, green, and blue and only 1 byte for alpha.
 *	PXTextureData *textureData = [textureParser newTextureData];
 *
 *	// Add a copy of the texture to the display hierarchy.
 *	PXTexture *texture = [[PXTexture alloc] initWithTextureData:textureData];
 *	[self addChild:texture];
 *	[texture release];
 *
 *	[textureData release];
 *	[textureParser release];
 *	[data release];
 */
- (id) initWithData:(NSData *)_data
		   modifier:(id<PXTextureModifier>)_modifier
			 origin:(NSString *)_origin
{
	self = [super init];

	if (self)
	{
		// Find the real type of parser to use.
		Class realClass = [PXParser parserForData:_data
											 origin:_origin
										  baseClass:[PXTextureParser class]];

		// If no real parser exists, then we can't do anything
		if (!realClass)
		{
			[self release];
			return nil;
		}

		// Make the new parser.
		PXTextureParser *newParser = [[realClass alloc] _initWithData:_data
															 modifier:_modifier
															   origin:_origin];

		// Release ourself, as we are going to become the real parser
		[self release];

		// Become the real parser, and allocate any data we need
		self = newParser;
	//	if ()
	//	{
	//	}
	}
	
	return self;
}

- (id) _initWithData:(NSData *)_data
		   modifier:(id<PXTextureModifier>)_modifier
			  origin:(NSString *)_origin
{
	// Set the data and origin
	self = [super _initWithData:_data origin:_origin];

	if (self)
	{
		// Make the texture info (it's bytes and other)
		textureInfo = PXParsedTextureDataCreate(0);
		modifiedTextureInfo = NULL;

		// Initialize the content scale factor to 1.0
		contentScaleFactor = 1.0f;

		// Parse the data. If we fail at parsing, give up - there is nothing
		// else we can do.
		if (!textureInfo || ![self _parse])
		{
			[self release];
			return nil;
		}

		// Set the modifier to the given one.
		self.modifier = _modifier;
	}

	return self;
}

- (void) dealloc
{
	self.modifier = nil;

	// Free the normal and modified info. If either are nil, this won't do
	// anything.
	PXParsedTextureDataFree(textureInfo);
	textureInfo = NULL;
	PXParsedTextureDataFree(modifiedTextureInfo);
	modifiedTextureInfo = NULL;

	[super dealloc];
}

- (BOOL) _parse
{
	return NO;
}

- (void) setModifier:(id <PXTextureModifier>)_modifier
{
	[_modifier retain];
	// See if we are modifiable.
	BOOL isModifiable = self.isModifiable;

	// Free the previous info.
	PXParsedTextureDataFree(modifiedTextureInfo);
	modifiedTextureInfo = NULL;
	[modifier release];
	modifier = nil;

	// If we can be modified and we hvae a legal modifier, lets use it!
	if (isModifiable && _modifier)
	{
		modifier = [_modifier retain];
		modifiedTextureInfo = [modifier newModifiedTextureDataFromData:textureInfo];
	}
	[_modifier release];
}

- (BOOL) isModifiable
{
	return NO;
}

/**
 * Creates a new PXTextureData object containing a copy of the loaded image
 * data. Note that all returned copies must be released by the caller.
 *
 * @return The new texture data.
 */
- (PXTextureData *)newTextureData
{
	// Allocate the texture data
	PXTextureData *textureData = [[PXTextureData alloc] _init];

	// Grab the generated gl name (this was generated when we called _init
	// above)
	GLuint texName = textureData->_glName;

	BOOL success;

	// Grab the previously bound texture, so we can re-bind it after we are done
	GLuint boundTex = PXGLBoundTexture();
	PXGLBindTexture(GL_TEXTURE_2D, texName);
	{
		// Initialize the texture. Note that this also fills in the pixels.
		success = [self _initializeTexture:texName];
	}
	PXGLBindTexture(GL_TEXTURE_2D, boundTex);

	// If we succeeded, inform the texture data to set the correct properties.
	if (success)
	{
		[textureData _setInternalPropertiesWithWidth:textureInfo->size.width
											  height:textureInfo->size.height
								   usingContentWidth:contentSize.width
									   contentHeight:contentSize.height
								  contentScaleFactor:contentScaleFactor
											  format:textureInfo->pixelFormat];
	}
	else
	{
		// There as an error creating the texture
		[textureData release];
		textureData = nil;
	}

	// Return the created texture data.
	return textureData;
}

- (BOOL) _initializeTexture:(GLuint)texName
{
	PXParsedTextureData *curTextureInfo = textureInfo;

	// If we have modified data, lets use that instead.
	if (modifiedTextureInfo && modifiedTextureInfo->bytes)
	{
		curTextureInfo = modifiedTextureInfo;
	}

	if ([PXTextureData expandEdges])
	{
		[self _expandEdges:curTextureInfo];
	}

	GLsizei width = curTextureInfo->size.width;
	GLsizei height = curTextureInfo->size.height;
	const GLvoid *byteData = (GLvoid *)(curTextureInfo->bytes);
	PXTextureDataPixelFormat pixelFormat = curTextureInfo->pixelFormat;

	GLint align;

	// Figure out the pixel format, and set the data in gl
	switch (pixelFormat)
	{
		case PXTextureDataPixelFormat_RGBA8888:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, byteData);
			break;
		case PXTextureDataPixelFormat_RGBA4444:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, byteData);
			break;
		case PXTextureDataPixelFormat_RGBA5551:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, byteData);
			break;
		case PXTextureDataPixelFormat_RGB565:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, byteData);
			break;
		case PXTextureDataPixelFormat_RGB888:
			// TODO: Figure out why 1 and 2 pixel wide images do not display properly without this.
			glGetIntegerv(GL_UNPACK_ALIGNMENT, &align);
			glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, byteData);
			glPixelStorei(GL_UNPACK_ALIGNMENT, align);
			break;
		case PXTextureDataPixelFormat_L8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, byteData);
			break;
		case PXTextureDataPixelFormat_A8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, byteData);
			break;
		case PXTextureDataPixelFormat_LA88:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, width, height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, byteData);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@""];
			break;
	}

	// If there was an error, inform the user
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
	{
		PXDebugLog(@"error [0x%X] occured while uploading texture to gl.\n", err);

		return NO;
	}

	return YES;
}

- (void) _expandEdges:(PXParsedTextureData *)_data
{
	if (_data)
	{
		// If our content size is not equal to our real size, and we have bytes
		// to work with, add the border. The border will consist of a copy of
		// the last pixel in the last row or column.
		unsigned texWidth  = _data->size.width;
		unsigned texHeight = _data->size.height;
		unsigned contentWidth  = contentSize.width;
		unsigned contentHeight = contentSize.height;
		if (((texWidth != contentWidth) || (texHeight != contentHeight)) &&
			_data->bytes && _data->byteCount > 0)
		{
			unsigned bytesPerPixel = 1;
			switch (_data->pixelFormat)
			{
				case PXTextureDataPixelFormat_RGBA8888:
					bytesPerPixel = 4;
					break;
				case PXTextureDataPixelFormat_RGBA4444:
					bytesPerPixel = 2;
					break;
				case PXTextureDataPixelFormat_RGBA5551:
					bytesPerPixel = 2;
					break;
				case PXTextureDataPixelFormat_RGB565:
					bytesPerPixel = 2;
					break;
				case PXTextureDataPixelFormat_RGB888:
					bytesPerPixel = 3;
					break;
				case PXTextureDataPixelFormat_L8:
					bytesPerPixel = 1;
					break;
				case PXTextureDataPixelFormat_A8:
					bytesPerPixel = 1;
					break;
				case PXTextureDataPixelFormat_LA88:
					bytesPerPixel = 2;
					break;
				default:
					break;
			}

			unsigned char *copyPtr = NULL;
			unsigned char *bytePtr = NULL;

			// Copy the right side.
			if (texWidth != contentWidth)
			{
				// If the widths are not equal, copy a column
				unsigned count = (texWidth - contentWidth) + 1;
				unsigned bytesAcross = texWidth * bytesPerPixel;
				
				copyPtr = _data->bytes + ((contentWidth - 1) * bytesPerPixel);
				bytePtr = copyPtr + bytesPerPixel;
				
				for (unsigned index = 1; index < count; ++index)
				{
					PXStridedMemcpy(bytePtr, copyPtr, bytesPerPixel, contentHeight, bytesAcross, bytesAcross);
					bytePtr += bytesPerPixel;
				}
			}
			// Copy the bottom
			if (texHeight != contentHeight)
			{
				// If the heights are not equal, copy a row
				unsigned count = (texHeight - contentHeight) + 1;
				unsigned bytesDown = texWidth * bytesPerPixel;

				copyPtr = _data->bytes + ((contentHeight - 1) * bytesDown);
				bytePtr = copyPtr + bytesDown;

				size_t copySize = bytesPerPixel * texWidth;
				for (unsigned index = 1; index < count; ++index)
				{
					memcpy(bytePtr, copyPtr, copySize);
					bytePtr += bytesDown;
				}
			}
		}
	}
}

@end
