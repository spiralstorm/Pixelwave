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

#import "PXSystemTextureFontFuser.h"

#import <CoreText/CoreText.h>

#import "PXEngine.h"
#import "PXRectanglePacker.h"
#import "PXMathUtils.h"

#import "PXTextureModifier.h"

#import "PXSystemFontParser.h"
#import "PXTextureFontOptions.h"

#import "PXTextureFontFuserUtils.h"
#import "PXTextureGlyph.h"

#import "PXDebug.h"

#import "PXTextureData.h"
#import <UIKit/UIKit.h>

typedef struct
{
	void *bitmap;

	unsigned short bitmapWidth;
	unsigned short bitmapHeight;
} PXGlyphBitmapDef;

// Short to avoid padding, should be bool!
static short pxSystemTextureFontFuserInitialCheck = NO;
static short pxSystemTextureFontFuserCanUseCoreText = NO;

@interface PXSystemTextureFontFuser(Private)
- (BOOL) parseFontWithSystemFontName:(NSString *)systemFontName options:(PXTextureFontOptions *)options;
@end

@implementation PXSystemTextureFontFuser

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

	if (![parser isKindOfClass:[PXSystemTextureFontFuser parserType]] ||
		![options isKindOfClass:[PXSystemTextureFontFuser optionsType]])
	{
		return NO;
	}

	if (![PXSystemTextureFontFuser isUsable])
	{
		PXDebugLog(@"System Font ERROR: %@ %@ %@ %@ %@ %@ %@",
				   @"Running iOS less than 3.2. You can not use a system",
				   @"texture font under 3.2. Instead you can set the",
				   @"TextField to use your system font directly by name. This",
				   @"will cause our system to load the font every time it is",
				   @"changed. Note: This is an extremely slow method, and is",
				   @"advised that instead of using system fonts for",
				   @"production, you use a loaded font.");
		
		return NO;
	}
	else
	{
		PXDebugLog(@"System Font WARNING: %@ %@ %@ %@ %@ %@",
				   @"System texture fonts are not available under iOS 3.2",
				   @"Instead you can set the TextField to use your system font",
				   @"directly by name. This will cause our system to load the",
				   @"font every time it is changed. Note: This is an extremely",
				   @"slow method, and is advised that instead of using system",
				   @"fonts for production, you use a loaded font.");
	}

	PXSystemFontParser *sParser = (PXSystemFontParser *)parser;
	PXTextureFontOptions *tfOptions = (PXTextureFontOptions *)options;

	NSString *systemFontName = sParser.origin;

	return [self parseFontWithSystemFontName:systemFontName options:tfOptions];
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

+ (BOOL) isUsable
{
	if (!pxSystemTextureFontFuserInitialCheck)
	{
		pxSystemTextureFontFuserInitialCheck = YES;
		
#ifdef __IPHONE_3_2
		NSString *reqSysVer = @"3.2";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
		{
			pxSystemTextureFontFuserCanUseCoreText = YES;
		}
#endif
	}
	
	return pxSystemTextureFontFuserCanUseCoreText;
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
	return [PXSystemFontParser class];
}

+ (Class) optionsType
{
	return [PXTextureFontOptions class];
}

- (BOOL) parseFontWithSystemFontName:(NSString *)systemFontName options:(PXTextureFontOptions *)tfOptions
{
	if (!tfOptions)
	{
		return NO;
	}

	NSString *string = tfOptions.characters;

	float _fontSize = tfOptions.size * PXEngineGetContentScaleFactor();
	UIFont *uiFont = [UIFont fontWithName:systemFontName size:_fontSize];

	if (!uiFont)
	{
		PXDebugLog (@"PXSystemFontLoader Error - Could not load system font:%@\n", systemFontName);
		
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

	textureInfo->size.width  = 0.0f;
	textureInfo->size.height = 0.0f;
	textureFontInfo->baseLine = 0.0f;
	textureFontInfo->fontSize = tfOptions.size;

	CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)uiFont.fontName);
	CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithNameAndSize((CFStringRef)systemFontName, _fontSize);
	CTFontRef iFont = CTFontCreateWithGraphicsFont(cgFont, 0, NULL, fontDescriptor);

	CFStringRef iString = (CFStringRef)string;

	UniChar *characters;
    CGGlyph *glyphs;
    CFIndex count;

    if (iFont == NULL || iString == NULL)
	{
		PXDebugLog (@"PXSystemFontLoader Error - Core text could not load for font %@\n", systemFontName);

		if (cgFont)
		{
			CGFontRelease(cgFont);
			cgFont = nil;
		}
		if (iFont)
		{
			CFRelease(iFont);
			iFont = nil;
		}
		if (fontDescriptor)
		{
			CFRelease(fontDescriptor);
			fontDescriptor = nil;
		}

		return NO;
	}

    // Get our string length.
    count = CFStringGetLength(iString);

    // Allocate our buffers for characters and glyphs.
    characters = (UniChar *)malloc(sizeof(UniChar) * count);

	if (!characters)
	{
		CFRelease(fontDescriptor);
		CGFontRelease(cgFont);
		CFRelease(iFont);

		PXDebugLog (@"PXSystemFontLoader Error - Could not allocate enough memory for font %@\n", systemFontName);

		return NO;
	}

    glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * count);

	if (!glyphs)
	{
		CFRelease(fontDescriptor);
		CGFontRelease(cgFont);
		free (characters);
		CFRelease(iFont);

		PXDebugLog (@"PXSystemFontLoader Error - Could not allocate enough memory for font %@\n", systemFontName);

		return NO;
	}

    // Get the characters from the string.
    CFStringGetCharacters(iString, CFRangeMake(0, count), characters);

    // Get the glyphs for the characters.
    CTFontGetGlyphsForCharacters(iFont, characters, glyphs, count);

	// The value of the baseline, we shift it over by 6 to convert it to pixel
	// coordinates.
	int ascender = CTFontGetAscent(iFont);
	textureFontInfo->baseLine = ascender;

    // Do something with the glyphs here, if a character is unmapped
	_PXGlyphDef glyphDefs[count];

	int glyphWidth;
	int glyphHeight;

	CGRect rectangles[count];
	CGSize advances[count];
	CTFontGetBoundingRectsForGlyphs(iFont, kCTFontHorizontalOrientation, glyphs, rectangles, count);
	CTFontGetAdvancesForGlyphs(iFont, kCTFontHorizontalOrientation, glyphs, advances, count);

	unsigned index;
	_PXGlyphDef *curGlyphDef;
	CGRect *curRect;
	CGSize *curAdvance;
	CGGlyph *glyph;
	CGContextRef context;
	UniChar *curChar;

	for (index = 0, curGlyphDef = glyphDefs, curRect = rectangles, curAdvance = advances, glyph = glyphs, curChar = characters;
		 index < count;
		 ++index, ++curGlyphDef, ++curRect, ++curAdvance, ++glyph, ++curChar)
	{
		curRect->origin.x = floorf(curRect->origin.x);
		curRect->origin.y = floorf(curRect->origin.y);
		curRect->size.width  = ceilf(curRect->size.width);
		curRect->size.height = ceilf(curRect->size.height);

		curRect->size.width  += 2;
		curRect->size.height += 2;

		// Find the origin, advance and size of the bitmap and glyph
		curGlyphDef->origin = CGPointMake(curRect->origin.x, curRect->origin.y);
		curGlyphDef->advance = CGPointMake(curAdvance->width, curAdvance->height);

		glyphWidth  = curRect->size.width;// + fabsf(curRect->origin.x);
		glyphHeight = curRect->size.height;// + fabsf(curRect->origin.y);

		if (glyphWidth <= 0 || glyphHeight <= 0)
		{
			curGlyphDef->bitmapGlyph = 0;
			continue;
		}

		glyphWidth = MAX(glyphWidth, glyphHeight);

		glyphWidth = PXMathNextPowerOfTwo(glyphWidth);

		glyphHeight = glyphWidth;

		curGlyphDef->bitmapGlyph = calloc(1, sizeof(PXGlyphBitmapDef));
		((PXGlyphBitmapDef *)curGlyphDef->bitmapGlyph)->bitmap = calloc(glyphWidth * glyphHeight, sizeof(GLubyte));
		((PXGlyphBitmapDef *)curGlyphDef->bitmapGlyph)->bitmapWidth  = glyphWidth;
		((PXGlyphBitmapDef *)curGlyphDef->bitmapGlyph)->bitmapHeight = glyphHeight;

		CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
		context = CGBitmapContextCreate(((PXGlyphBitmapDef *)curGlyphDef->bitmapGlyph)->bitmap,
										glyphWidth,
										glyphHeight,
										8,
										glyphHeight,
										gray,
										kCGImageAlphaNone);

		CGContextSetFont(context, cgFont);
		CGContextSetFontSize(context, _fontSize);
		CGContextSetGrayFillColor(context, 1.0, 1.0);

		CGColorSpaceRelease(gray);
		CGContextShowGlyphsAtPoint(context, -curRect->origin.x, (glyphHeight) - curRect->origin.y - curRect->size.height, glyph, 1);

		CGContextRelease(context);
	}

	CGSize texSize = [PXRectanglePacker packRectangles:rectangles count:count padding:2];

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

	// The pointer to the new glyph we are going to make.
	PXTextureGlyph *newGlyph;

	float one_texWidth  = 1.0f / textureInfo->size.width;
	float one_texHeight = 1.0f / textureInfo->size.height;

	unsigned glyphPixelOriginX = 0;
	unsigned glyphPixelOriginY = 0;

	curGlyphDef = glyphDefs;
	curRect = rectangles;
	glyph = glyphs;
	curChar = characters;
	GLubyte *glyphPixels = 0;
	GLubyte *texturePixelLocationToDrawGlyph = 0;
	int nTexWidth = textureInfo->size.width;
	unsigned yPix = 0;

	// Iterate through each character so that we can build the glyph sprite
	// sheet.   We could not do this in our previous loop, because we did not
	// know the proper size to make it the texture to copy the bitmaps into.
	void *bitmap;
	unsigned short bitmapWidth;
//	unsigned short bitmapHeight;

	[textureData release];
	textureData = [[PXTextureData alloc] _initWithoutGLName];

	if (textureInfo->bytes)
	{
		for (index = 0; index < count; ++index, ++curRect, ++curGlyphDef, ++glyph, ++curChar)
		{
			glyphPixelOriginX = curRect->origin.x;
			glyphPixelOriginY = curRect->origin.y;

			glyphWidth  = curRect->size.width;
			glyphHeight = curRect->size.height;

			// This is a tricky, yet awsome little loop.  It goes through each of
			// the rows of the bitmap, copying the whole row at a time into the
			// larger texture.  We find where the origin is previous to this, and
			// start pasting at that origin.  We can not copy the entire bitmap at
			// once, because we are copying a small bitmap into a large texture, and
			// you can not memcpy multiple locations.
			bitmap = curGlyphDef->bitmapGlyph;

			if (bitmap)
			{
				glyphPixels  = ((PXGlyphBitmapDef *)curGlyphDef->bitmapGlyph)->bitmap;
				bitmapWidth  = ((PXGlyphBitmapDef *)curGlyphDef->bitmapGlyph)->bitmapWidth;
			//	bitmapHeight = ((PXGlyphBitmapDef *)curGlyphDef->bitmapGlyph)->bitmapHeight; not used

				texturePixelLocationToDrawGlyph = textureInfo->bytes +
										(glyphPixelOriginX + (glyphPixelOriginY * nTexWidth));

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
					glyphPixels += bitmapWidth;
				}

				free (((PXGlyphBitmapDef *)curGlyphDef->bitmapGlyph)->bitmap);
				free (curGlyphDef->bitmapGlyph);
			}

			// Make a new glyph and assign it's values.
			newGlyph = [PXTextureGlyph new];

			if (!newGlyph)
			{
				continue;
			}

			newGlyph.textureData = textureData;
			// The advance is how far away from the origin should the next character
			// lay.
			newGlyph->_advance		= curGlyphDef->advance;
			// The bounds of the glyph.  The vertical origin is taken from the
			// ascender so that we move it to the correct space of the baseline.
			newGlyph->_bounds		= CGRectMake(curGlyphDef->origin.x,
												 ascender - (glyphHeight) - curGlyphDef->origin.y,
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
		}

		// TODO Later: Add support for kerning system fonts.
		/*CFDataRef kernTable = CTFontCopyTable(iFont, kCTFontTableKern, kCTFontTableOptionNoOptions);

		if (kernTable)
		{
			const UInt8 *bytes = CFDataGetBytePtr(kernTable);
			UInt8 *curByte = (UInt8 *)(bytes);
			UInt16 *chunks = (UInt16 *)(bytes);
			unsigned byteCount = CFDataGetLength(kernTable);
	//		unsigned chunkCount = byteCount >> 1;

			PXDebugLog (@"Kern table byte count = %u\n", byteCount);

			unsigned short version = *((unsigned short *)(curByte));
			curByte += sizeof(unsigned short);
			unsigned short nTables = *((unsigned short *)(curByte));
			curByte += sizeof(unsigned short);
			PXDebugLog (@"version = %X nTables = %u\n", version, nTables);

			UInt16 rowWidth = chunks[0];
			UInt16 leftOffsetTable = chunks[1];
			UInt16 rightOffsetTable = chunks[2];
		//	UInt16 *array = &(chunks[3]);

			PXDebugLog (@"rowWidth = %i, leftOffsetTable = %i, rightOffsetTable = %i\n",
				   rowWidth,
				   leftOffsetTable,
				   rightOffsetTable);

			CFRelease(kernTable);
			kernTable = NULL;
		}*/
	}

    // Free our buffers
	free(characters);
	free(glyphs);

	CFRelease(fontDescriptor);
	CGFontRelease(cgFont);
	CFRelease(iFont);

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
