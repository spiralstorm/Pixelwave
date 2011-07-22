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

#import "PXTextureFontRenderer.h"

#import "PXEngine.h"
#import "PXExceptionUtils.h"

#import "PXTextureFont.h"
#import "PXTextField.h"
#import "PXTextureGlyph.h"
#import "PXTextureData.h"

#import "PXPoint.h"

#import "PXTextureGlyphBatch.h"

@implementation PXTextureFontRenderer

- (id) init
{
	// Need to use the initWithFont method.
	PXThrow(PXException, @"PXTextureFontRenderer must be inited using initWithFont:");

	[self release];

	return nil;
}

- (id) initWithFont:(PXTextureFont *)_font
{
	self = [super init];

	if (self)
	{
		// Set our font.
		font = _font;

		enableColors = NO;
		glNameToTextureGlyphBatch = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (void) dealloc
{
	[glNameToTextureGlyphBatch release];
	glNameToTextureGlyphBatch = nil;

	[super dealloc];
}

- (void) _validate
{
	// If we don't have a text field, we can't validate (the text field holds
	// the validation information).
	if (!_textField)
		return;

	// Free up past memory used
	[glNameToTextureGlyphBatch removeAllObjects];

	// If we do not have any characters in our string, then we have nothing to
	// do.
	unsigned characterCount = [_textField->_text length];
	if (characterCount == 0)
		return;

	unichar characters[characterCount];
	[_textField->_text getCharacters:characters];

	unichar lastCharacter = 0;
	unichar *character = NULL;

	PXTextureGlyph *glyph = nil;
	PXPoint *kern = nil;

	unsigned index;
	NSString *glStrName = nil;
	PXTextureGlyphBatch *textureGlyphBatch;
	PXTextureData *textureData;

	// The multiplication amount is our size over the font size.  So if we
	// wanted it bigger, we will see it bigger, just as if we want it smaller,
	// then we will see it smaller.
	float multVal = (_textField->_fontSize) / ((font->_fontSize));
	float pixMult = 1.0f / PXEngineGetContentScaleFactor();
	multVal *= pixMult;

	{
	NSMutableString *realString = [[NSMutableString alloc] init];

	for (index = 0, character = characters; index < characterCount; ++index, ++character)
	{
		glyph = [font glyphFromCharacter:*character];

		// If no glyph exists for the character, then continue.
		if (!glyph)
			continue;

		textureData = glyph.textureData;
		if (!textureData)
			continue;

		glStrName = [NSString stringWithFormat:@"%u", textureData->_glName];

		textureGlyphBatch = [glNameToTextureGlyphBatch objectForKey:glStrName];

		if (!textureGlyphBatch)
		{
			textureGlyphBatch = [[PXTextureGlyphBatch alloc] init];
			textureGlyphBatch->_textureData = textureData;
			[glNameToTextureGlyphBatch setObject:textureGlyphBatch forKey:glStrName];
			[textureGlyphBatch release];
		}

		++(textureGlyphBatch->_charactersInSet);

		[realString appendString:[NSString stringWithCharacters:character length:1]];
	}

	characterCount = [realString length];
	if (characterCount == 0)
	{
		[realString release];
		return;
	}
	[realString getCharacters:characters];

	[realString release];
	}

	// We allocate 6 vertices for each character, minus 2 because the first
	// character does not need a previous vertex, just as the last character
	// does not need a next.  If there is only one character, then it needs
	// neither, thus this is always the correct amount.
	NSEnumerator *enumerator = nil;
    id obj = nil;

	enumerator = [glNameToTextureGlyphBatch objectEnumerator];
	unsigned charactersInSet = 0;
    while (obj = [enumerator nextObject])
	{
		textureGlyphBatch = (PXTextureGlyphBatch *)obj;

		charactersInSet = textureGlyphBatch->_charactersInSet;
		// This will also set the vertices
		textureGlyphBatch.vertexCount = (charactersInSet * 6) - 2;
	}

	float x = 0.0f;
	float y = 0.0f;

	PXMathRange rangeX;
	PXMathRange rangeY;
	PXMathRange rangeS;
	PXMathRange rangeT;

	float xBorder = 1.0f;
	float yBorder = 2.0f;

	NSString *curGLStrName = nil;

	float letterSpacing = _textField->_letterSpacing;
	float maxHeight = 0;

	BOOL isFirst = NO;
	BOOL isLast = NO;
	BOOL allowedToKern = _textField->_kerning;

	lastCharacter = 0;
	textureGlyphBatch = nil;

	// For each character we need to make a texture box for it.
	for (index = 0, character = characters; index < characterCount; ++index, ++character)
	{
		glyph = [font glyphFromCharacter:*character];

		if (allowedToKern)
		{
			kern = [font kerningPointFromFirstCharacter:lastCharacter secondCharacter:*character];

			if (kern)
			{
				x += (kern.x * multVal);
			}
		}

		if ((int)(glyph->_bounds.size.width)  != 0 &&
			(int)(glyph->_bounds.size.height) != 0)
		{
			textureData = glyph.textureData;
			if (!textureData)
				continue;

			glStrName = [NSString stringWithFormat:@"%u", textureData->_glName];

			if (![glStrName isEqualToString:curGLStrName])
			{
				textureGlyphBatch = [glNameToTextureGlyphBatch objectForKey:glStrName];
				curGLStrName = glStrName;
			}

			if (!textureGlyphBatch)
				continue;

//			if (index == 0)
//			{
//				// OLD WAY
//				//rangeX.min = xBorder;
//
//				// FIXING
//				float firstOffset = glyph->_bounds.origin.x * multVal;
//
//				if (firstOffset < 0.0f)
//				{
//					firstOffset = 0.0f;
//					x += firstOffset;
//				}
//
//				rangeX.min = xBorder + firstOffset;
//			}
//			else
				rangeX.min = x + (glyph->_bounds.origin.x * multVal);

			rangeY.min = y + (glyph->_bounds.origin.y * multVal);

			rangeX.max = rangeX.min + (glyph->_bounds.size.width  * multVal);
			rangeY.max = rangeY.min + (glyph->_bounds.size.height * multVal);

			rangeS.min = glyph->_textureBounds.origin.x;
			rangeT.min = glyph->_textureBounds.origin.y;

			rangeS.max = rangeS.min + glyph->_textureBounds.size.width;
			rangeT.max = rangeT.min + glyph->_textureBounds.size.height;

			if (maxHeight < rangeY.max)
				maxHeight = rangeY.max;

			isFirst = (textureGlyphBatch->_usedCharactersInSet == 0);
			isLast = (textureGlyphBatch->_usedCharactersInSet == textureGlyphBatch->_charactersInSet - 1);

			textureGlyphBatch->_usedVertexCount += PXTextureGlyphBatchConcatBox(&(textureGlyphBatch->_currentVertex),
																					rangeX,
																					rangeY,
																					rangeS,
																					rangeT,
																					isFirst,
																					isLast);
			++(textureGlyphBatch->_usedCharactersInSet);
		}

		// Move the x position.
		x += (glyph->_advance.x * multVal) + letterSpacing;

		lastCharacter = *character;
	}

	enumerator = [glNameToTextureGlyphBatch objectEnumerator];
	while (obj = [enumerator nextObject])
	{
		textureGlyphBatch = (PXTextureGlyphBatch *)obj;

		textureGlyphBatch.vertexCount = textureGlyphBatch->_usedVertexCount;
	}

	_bounds.size.width  = roundf(rangeX.max + xBorder);
	_bounds.size.height = roundf(maxHeight + yBorder);

	[super _validate];
}

- (BOOL) smoothing
{
	return smoothingType == GL_LINEAR;
}
- (void) setSmoothing:(BOOL)val
{
	smoothingType = val ? GL_LINEAR : GL_NEAREST;
}

- (void) _updateAlignment
{
	[super _updateAlignment];

	// We need to update the vertices to correspond with the new bounds.
	unsigned index;
	PXGLColoredTextureVertex *vertex;

	NSEnumerator *enumerator = [glNameToTextureGlyphBatch objectEnumerator];
    id obj;
	PXTextureGlyphBatch *textureGlyphBatch;

    while (obj = [enumerator nextObject])
	{
		textureGlyphBatch = (PXTextureGlyphBatch *)obj;

		if (!textureGlyphBatch)
			continue;
		if (!textureGlyphBatch->_vertices || textureGlyphBatch->_vertexCount == 0)
			continue;

		for (index = 0, vertex = textureGlyphBatch->_vertices;
			 index < textureGlyphBatch->_vertexCount;
			 ++index, ++vertex)
		{
			vertex->x += shiftX;
			vertex->y += shiftY;
		}
	}
}

- (void) _renderGL
{
	if (!_textField)
	{
		return;
	}

	// Enable the texture, and draw the vertices with the correct color.
//	PXGLShadeModel(GL_SMOOTH);
	PXGLEnable(GL_TEXTURE_2D);
	PXGLEnableClientState(GL_TEXTURE_COORD_ARRAY);
//	PXGLDisableClientState(GL_POINT_SIZE_ARRAY_OES);

	if (enableColors)
	{
		PXGLEnableClientState(GL_COLOR_ARRAY);
	}
	else
	{
		PXGLDisableClientState(GL_COLOR_ARRAY);
	}

	NSEnumerator *enumerator = [glNameToTextureGlyphBatch objectEnumerator];
    id obj;
	PXTextureGlyphBatch *textureGlyphBatch;
	
	PXTextureData *textureData = nil;

    while (obj = [enumerator nextObject])
	{
		textureGlyphBatch = (PXTextureGlyphBatch *)obj;

		if (!textureGlyphBatch)
			continue;

		if (textureGlyphBatch->_vertices == NULL ||
			textureGlyphBatch->_vertexCount == 0 ||
			textureGlyphBatch->_textureData == nil)
		{
			continue;
		}

		textureData = textureGlyphBatch->_textureData;

		PXGLBindTexture(GL_TEXTURE_2D, textureData->_glName);

		// Smoothing?
		if (smoothingType != textureData->_smoothingType)
		{
			PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, smoothingType);
			PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, smoothingType);
			textureData->_smoothingType = smoothingType;
		}

		PXGLVertexPointer(2, GL_FLOAT, sizeof(PXGLColoredTextureVertex), &(textureGlyphBatch->_vertices->x));
		PXGLTexCoordPointer(2, GL_FLOAT, sizeof(PXGLColoredTextureVertex), &(textureGlyphBatch->_vertices->s));

		if (enableColors)
		{
			PXGLColorPointer(2, GL_UNSIGNED_BYTE, sizeof(PXGLColoredTextureVertex), &(textureGlyphBatch->_vertices->r));
		}

		PXGLDrawArrays(GL_TRIANGLE_STRIP, 0, textureGlyphBatch->_vertexCount);
	}
}

@end
