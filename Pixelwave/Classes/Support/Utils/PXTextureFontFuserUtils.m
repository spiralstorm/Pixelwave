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

#import "PXTextureFontFuserUtils.h"

#import <Foundation/Foundation.h>

#import "PXGL.h"

#import "PXTextureFont.h"
#import "PXTextureData.h"

PXInline_c PXTextureFontTextureInfo *PXTextureFontTextureInfoMake()
{
	PXTextureFontTextureInfo *info = calloc(1, sizeof(PXTextureFontTextureInfo));

	if (info)
	{
		info->textureInfo = PXParsedTextureDataCreate(0);

		if (!info->textureInfo)
		{
			free (info);
			info = NULL;
		}
	}

	return info;
}

PXInline_c void PXTextureFontTextureInfoFree(PXTextureFontTextureInfo *info)
{
	if (info)
	{
		PXParsedTextureDataFree(info->textureInfo);
		info->textureInfo = NULL;

		free(info);
	}
}

PXFont *PXTextureFontUtilsNewFont(PXTextureFontTextureInfo *info,
								  PXTextureData *textureData,
								  NSDictionary *charToGlyph,
								  NSDictionary *charToKernPoint,
								  float contentScaleFactor)
{
	if (!textureData || !info)
	{
		return nil;
	}

	if (![textureData _makeGLName])
	{
		return nil;
	}

	PXParsedTextureData *textureInfo = info->textureInfo;
	if (!(textureInfo) || !(textureInfo->bytes))
	{
		return nil;
	}

	PXTextureFont *textureFont = [[PXTextureFont alloc] init];

	if (!textureFont)
	{
		return nil;
	}

	NSEnumerator *enumerator;
	NSString *key;

	enumerator = [charToGlyph keyEnumerator];

    while (key = [enumerator nextObject])
	{
		[textureFont setGlyph:[charToGlyph objectForKey:key]
					 forString:key];
	}

	enumerator = [charToKernPoint keyEnumerator];

    while (key = [enumerator nextObject])
	{
		[textureFont setKerningPoint:[charToKernPoint objectForKey:key]
							forString:key];
	}

	GLuint texName = textureData->_glName;

	GLsizei width = textureInfo->size.width;
	GLsizei height = textureInfo->size.height;
	const GLvoid *byteData = (GLvoid *)(textureInfo->bytes);
	PXTextureDataPixelFormat pixelFormat = textureInfo->pixelFormat;

	GLuint boundTex = PXGLBoundTexture();
	PXGLBindTexture(GL_TEXTURE_2D, texName);
	{
		GLint align;

		textureData->_smoothingType = GL_NEAREST;
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, textureData->_smoothingType);
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, textureData->_smoothingType);

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
	}
	PXGLBindTexture(GL_TEXTURE_2D, boundTex);

	[textureData _setInternalPropertiesWithWidth:textureInfo->size.width
										  height:textureInfo->size.height
							   usingContentWidth:textureInfo->size.width
								   contentHeight:textureInfo->size.height
							  contentScaleFactor:contentScaleFactor
										  format:textureInfo->pixelFormat];

	textureFont->_baseLine = info->baseLine;
	textureFont->_fontSize = info->fontSize;

	return textureFont;
}
