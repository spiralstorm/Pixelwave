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

#import "PXFreeTypeTextureFontFuser.h"

#import "PXFreeTypeFontParser.h"
#import "PXTextureFontOptions.h"

#import "PXTextureModifier.h"

#import "PXTextureFontFuserUtils.h"

// Freetype
#include "ft2build.h"
#include FT_FREETYPE_H
#include FT_GLYPH_H
//#include FT_SYSTEM_H

#import "PXEngine.h"
#import "PXRectanglePacker.h"

#import "PXTextureGlyph.h"
#import "PXFont.h"
#import "PXTextureData.h"
#import "PXPoint.h"

@interface PXFreeTypeTextureFontFuser(Private)
- (BOOL) _parseFontWithOptions:(PXTextureFontOptions *)tfOptions parser:(PXFreeTypeFontParser *)ftParser;
@end

@implementation PXFreeTypeTextureFontFuser

#pragma mark -
#pragma mark Override

- (BOOL) initializeFuser
{
	if (![super initializeFuser])
	{
		return NO;
	}

	if (!options)
	{
		return NO;
	}

	if (![parser isKindOfClass:[PXFreeTypeTextureFontFuser parserType]] ||
		![options isKindOfClass:[PXFreeTypeTextureFontFuser optionsType]])
	{
		return NO;
	}

	PXFreeTypeFontParser *ftParser = (PXFreeTypeFontParser *)parser;
	PXTextureFontOptions *tfOptions = (PXTextureFontOptions *)options;
	
	return [self _parseFontWithOptions:tfOptions parser:ftParser];
}

- (void) dealloc
{
	[textureData release];
	textureData = nil;
	
	if (vTextureFontInfo)
	{
		PXTextureFontTextureInfo *textureFontInfo = (PXTextureFontTextureInfo *)(vTextureFontInfo);
		PXTextureFontTextureInfoFree(textureFontInfo);
		vTextureFontInfo = NULL;
	}
	
	[super dealloc];
}

- (PXFont *)newFont
{
	PXTextureFontTextureInfo *textureFontInfo = (PXTextureFontTextureInfo *)(vTextureFontInfo);

	return PXTextureFontUtilsNewFont(textureFontInfo,
									 textureData,
									 charToGlyph,
									 charToKernPoint,
									 PXEngineGetContentScaleFactor());
}

+ (Class) parserType
{
	return [PXFreeTypeFontParser class];
}

+ (Class) optionsType
{
	return [PXTextureFontOptions class];
}

- (BOOL) _parseFontWithOptions:(PXTextureFontOptions *)tfOptions parser:(PXFreeTypeFontParser *)ftParser
{
	if (!ftParser)
	{
		return NO;
	}

	void *vFace = ftParser->_vFace;
	void *vLibrary = ftParser->_vLibrary;

	if (!vFace || !vLibrary)
	{
		return NO;
	}

	PXTextureFontTextureInfo *textureFontInfo;

	if (vTextureFontInfo)
	{
		textureFontInfo = (PXTextureFontTextureInfo *)(vTextureFontInfo);
		PXTextureFontTextureInfoFree(textureFontInfo);
		vTextureFontInfo = NULL;
	}

	textureFontInfo = PXTextureFontTextureInfoMake();
	if (!textureFontInfo)
	{
		return NO;
	}
	vTextureFontInfo = textureFontInfo;

	PXParsedTextureData *textureInfo = textureFontInfo->textureInfo;
	if (!textureInfo)
	{
		return NO;
	}

	FT_Face face = (FT_Face)vFace;

	textureInfo->size.width  = 0.0f;
	textureInfo->size.height = 0.0f;
	textureFontInfo->baseLine = 0.0f;
	textureFontInfo->fontSize = tfOptions.size;

	// Free type keeps it's information in a different format, we need to
	// convert it to pixels, so we shift it over to inform free type the size we
	// want.
	unsigned ftFontSize = textureFontInfo->fontSize * 64.0f; // << 6

	// We set the character size, at some point we need to know how many pixels
	// per inch we are using...
	FT_UInt ftPixelsPerInch = _PX_FONT_PIXELS_PER_INCH * PXEngineGetContentScaleFactor();
	FT_Set_Char_Size(face, ftFontSize, ftFontSize, ftPixelsPerInch, ftPixelsPerInch);

	// We need the string in an array of characters, so lets make that array!
	NSString *string = tfOptions.characters;
	unsigned characterCount = [string length];
	unichar characters[characterCount];
	[string getCharacters:characters];

	unsigned index = 0;

	_PXGlyphDef glyphDefs[characterCount];
	FT_Glyph glyph;
	FT_BitmapGlyph glyphBitmap;
	FT_Bitmap bitmap;
	int glyphWidth;
	int glyphHeight;

	_PXGlyphDef *curGlyphDef = glyphDefs;
	unichar *curChar = characters;

	CGRect rectangles[characterCount];
	CGRect *curRect = rectangles;
	for (index = 0; index < characterCount; ++index, ++curChar, ++curGlyphDef, ++curRect)
	{
		// If the glyph does not exist in the font file, we should inform the
		// user.
		if (FT_Load_Glyph(face, FT_Get_Char_Index(face, *curChar), FT_LOAD_DEFAULT))
		{
			[ftParser _log:[NSString stringWithFormat:@"no glyph for character %c", *curChar]];
			continue;
		}

		// If the glyph could not be retrieved for some strange reason, we
		// should inform the user.
		if (FT_Get_Glyph(face->glyph, &(glyph)))
		{
			[ftParser _log:[NSString stringWithFormat:@"failed to retrieve glyph for character %c", *curChar]];
			continue;
		}

		// Render the glyph to it's bitmap.
		FT_Glyph_To_Bitmap(&(glyph), ft_render_mode_normal, 0, 1);
		glyphBitmap = (FT_BitmapGlyph)(glyph);
		curGlyphDef->bitmapGlyph = glyphBitmap;
		bitmap = glyphBitmap->bitmap;

		// Find the origin, advance and size of the bitmap and glyph
		curGlyphDef->origin = CGPointMake(glyphBitmap->left, glyphBitmap->top);
		curGlyphDef->advance = CGPointMake(((face->glyph->advance.x) >> 6), ((face->glyph->advance.y) >> 6));
		glyphWidth  = bitmap.width;
		glyphHeight = bitmap.rows;

		curRect->size.width = glyphWidth;
		curRect->size.height = glyphHeight;
	}

	CGSize texSize = [PXRectanglePacker packRectangles:rectangles count:characterCount padding:2];

	textureInfo->size.width  = texSize.width;
	textureInfo->size.height = texSize.height;

	// How many pixels are going to be in our texture, we need to allocate
	// enough memory for our texture, so the first step would be to figure out
	// how many bytes we need.  Thankfully, we only need one byte per pixel,
	// because we only care about it's alpha value.  Color, etc. will be a
	// multiple there of later derived by you in the color multiplier or other.
	unsigned tpc = textureInfo->size.width * textureInfo->size.height;

	// We calloc the memory so that we make sure every byte is 0 before using
	// it.  Thus if we don't fill in those bytes (if no texture belongs there),
	// then it is a 0 instead of whatever it used to be.

	textureInfo->byteCount = tpc;
	textureInfo->pixelFormat = PXTextureDataPixelFormat_A8;
	textureInfo->bytes = calloc(textureInfo->byteCount, sizeof(unsigned char));
	unsigned yPix = 0;

	float one_texWidth  = 1.0f / textureInfo->size.width;
	float one_texHeight = 1.0f / textureInfo->size.height;

	// The value of the baseline, we shift it over by 6 to convert it to pixel
	// coordinates.
	int ascender = (face->size->metrics.ascender >> 6);
	textureFontInfo->baseLine = ascender;

	GLubyte *glyphPixels = 0;
	GLubyte *texturePixelLocationToDrawGlyph = 0;
	int nTexWidth = textureInfo->size.width;
	unsigned glyphPixelOriginX = 0;
	unsigned glyphPixelOriginY = 0;

	// The pointer to the new glyph we are going to make.
	PXTextureGlyph *newGlyph;

	FT_Vector kerning;
	PXPoint *newKerningPoint;

	[textureData release];
	textureData = [[PXTextureData alloc] _initWithoutGLName];

	BOOL useKerning = FT_HAS_KERNING(face);

	unsigned innerKernIndex;
	unichar *innerKernChar;
	FT_Error error;
	FT_UInt leftGlyphID;
	FT_UInt rightGlyphID;

	if (textureInfo->bytes)
	{
		// Iterate through each character so that we can build the glyph sprite
		// sheet.   We could not do this in our previous loop, because we did not
		// know the proper size to make it the texture to copy the bitmaps into.
		for (index = 0, curRect = rectangles, curChar = characters, curGlyphDef = glyphDefs;
			 index < characterCount;
			 ++index, ++curRect, ++curChar, ++curGlyphDef)
		{
			glyphPixelOriginX = curRect->origin.x;
			glyphPixelOriginY = curRect->origin.y;

			bitmap = ((FT_BitmapGlyph)(curGlyphDef->bitmapGlyph))->bitmap;
			glyphPixels = bitmap.buffer;
			texturePixelLocationToDrawGlyph = textureInfo->bytes +
												(glyphPixelOriginX + (glyphPixelOriginY * nTexWidth));

			glyphWidth  = bitmap.width;
			glyphHeight = bitmap.rows;

			// This is a tricky, yet awsome little loop.  It goes through each of
			// the rows of the bitmap, copying the whole row at a time into the
			// larger texture.  We find where the origin is previous to this, and
			// start pasting at that origin.  We can not copy the entire bitmap at
			// once, because we are copying a small bitmap into a large texture, and
			// you can not memcpy multiple locations.
			for (yPix = 0; yPix < glyphHeight; ++yPix)
			{
				// Copy the row into the larger texture.
				memcpy(texturePixelLocationToDrawGlyph, glyphPixels, glyphWidth);
				// Increment the texture pointer by one row.
				texturePixelLocationToDrawGlyph += nTexWidth;
				// Increment the glyph bitmap pointer by one row.
				glyphPixels += glyphWidth;
			}

			// Make a new glyph and assign it's values.
			newGlyph = [PXTextureGlyph new];

			newGlyph.textureData = textureData;

			// The advance is how far away from the origin should the next character
			// lay.
			newGlyph->_advance		= curGlyphDef->advance;
			// The bounds of the glyph.  The vertical origin is taken from the
			// ascender so that we move it to the correct space of the baseline.
			newGlyph->_bounds		= CGRectMake(curGlyphDef->origin.x,
												 ascender - curGlyphDef->origin.y,
												 glyphWidth,
												 glyphHeight);

			// The texture bounds is where on the texture (values from 0.0f to 1.0f)
			// the texture lyes, and how big it is.
			newGlyph->_textureBounds = CGRectMake((float)(glyphPixelOriginX) * one_texWidth,
												 (float)(glyphPixelOriginY) * one_texHeight,
												 (float)(glyphWidth)  * one_texWidth,
												 (float)(glyphHeight) * one_texHeight);

			// Lets add the glyph to the dictionary, we can then release it as the
			// dictionary will keep the retain.
			[self setGlyph:newGlyph forCharacter:*curChar];
			[newGlyph release];

			if (useKerning)
			{
				leftGlyphID = FT_Get_Char_Index(face, *curChar);

				for (innerKernIndex = 0, innerKernChar = characters;
					 innerKernIndex < characterCount;
					 ++innerKernIndex, ++innerKernChar)
				{
					rightGlyphID =  FT_Get_Char_Index(face, *innerKernChar);

					error = FT_Get_Kerning(face,					// handle to face object
										   leftGlyphID,				// left glyph index
										   rightGlyphID,			// right glyph index
										   FT_KERNING_DEFAULT,		// kerning mode
										   &kerning );				// target vector

					if (!error)
					{
						if (kerning.x == 0 && kerning.y == 0)
						{
							continue;
						}

						newKerningPoint = [[PXPoint alloc] initWithX:(kerning.x >> 6) y:(kerning.y >> 6)];

						[self setKernPoint:newKerningPoint forFirstCharacter:*curChar secondCharacter:*innerKernChar];

						[newKerningPoint release];
					}
				}
			}

			FT_Done_Glyph(curGlyphDef->bitmapGlyph);
		}
	}

	id<PXTextureModifier> modifier = tfOptions.textureModifier;
	if (modifier)
	{
		PXParsedTextureData *textureInfo = textureFontInfo->textureInfo;
		PXParsedTextureData *newInfo = [modifier newModifiedTextureDataFromData:textureInfo];

		if (newInfo && newInfo->bytes)
		{
			PXParsedTextureDataFree(textureFontInfo->textureInfo);
			textureFontInfo->textureInfo = newInfo;
		}
	}

	return YES;
}

@end
