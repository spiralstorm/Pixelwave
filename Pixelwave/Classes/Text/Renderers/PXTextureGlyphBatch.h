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

#import "PXPooledObject.h"
#import "PXGL.h"
#include "PXMathUtils.h"

@class PXTextureData;

/*
 * Holds all the info needed for a texture-based font rendered to render
 * a group of glyphs. The properties of this class should be accessed
 * directly (with ->) for speed.
 *
 */
@interface PXTextureGlyphBatch : NSObject<NSCopying, PXPooledObject>
{
@public
	PXGLColoredTextureVertex *_vertices;

	unsigned _vertexCount;
	unsigned _charactersInSet;
	PXTextureData *_textureData;

	PXGLColoredTextureVertex *_currentVertex;
	unsigned _usedCharactersInSet;
	unsigned _usedVertexCount;
}

@property (nonatomic) unsigned vertexCount;

- (id) initWithVertexCount:(unsigned)vertexCount;

@end

#ifndef _PX_TEXTURE_FONT_INFO_H_
#define _PX_TEXTURE_FONT_INFO_H_

#ifdef __cplusplus
extern "C" {
#endif

// Returns the number of vertices added to the list
PXInline_h unsigned PXTextureGlyphBatchConcatBox(PXGLColoredTextureVertex **currentVertex,
												  PXMathRange x,
												  PXMathRange y,
												  PXMathRange s,
												  PXMathRange t,
												  BOOL isFirst,
												  BOOL isLast);

// Returns the number of vertices added to the list
PXInline_h unsigned PXTextureGlyphBatchConcatBoxWithColor(PXGLColoredTextureVertex **currentVertex,
														   PXMathRange x,
														   PXMathRange y,
														   PXMathRange s,
														   PXMathRange t,
														   unsigned char red,
														   unsigned char green,
														   unsigned char blue,
														   unsigned char alpha,
														   BOOL isFirst,
														   BOOL isLast);

#ifdef __cplusplus
}
#endif

#endif
