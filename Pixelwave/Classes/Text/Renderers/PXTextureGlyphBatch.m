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

#import "PXTextureGlyphBatch.h"
#import "PXTextureData.h"

@implementation PXTextureGlyphBatch

@synthesize vertexCount = _vertexCount;

- (id) init
{
	return [self initWithVertexCount:0];
}

- (id) initWithVertexCount:(unsigned)val
{
	self = [super init];

	if (self)
	{
		_vertices = NULL;
		_vertexCount = 0;

		_charactersInSet = 0;
		_textureData = nil;

		_usedVertexCount = 0;
		_usedCharactersInSet = 0;
		_currentVertex = NULL;

		self.vertexCount = val;
	}

	return self;
}

- (void) dealloc
{
	[self reset];

	[super dealloc];
}

#pragma mark NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	PXTextureGlyphBatch *textureFontInfo = [[[self class] allocWithZone:zone] initWithVertexCount:_vertexCount];

	if (!textureFontInfo)
		return nil;
	
	if (_vertices && textureFontInfo->_vertices)
	{
		memcpy(textureFontInfo->_vertices, _vertices, (_vertexCount * sizeof(PXGLColoredTextureVertex)));
	}
	
	//textureFontInfo.glName = _glName;
	textureFontInfo->_textureData = _textureData;

	return textureFontInfo;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(vertexCount=%u, charactersInSet=%u, glName=%u)",
			_vertexCount,
			_charactersInSet,
			_textureData->_glName];
}

#pragma mark Pooled Reset

- (void) reset
{
	if (_vertices)
	{
		free(_vertices);
		_vertices = 0;
	}

	//_glName = 0;
	_textureData = nil;
	_vertexCount = 0;
}

#pragma mark Properties

- (void) setVertexCount:(unsigned)val
{
	if (_vertices)
	{
		if (val == 0)
		{
			_vertexCount = 0;

			free(_vertices);
			_vertices = NULL;
		}
		else if (_vertexCount != val)
		{
			_vertexCount = val;
			_vertices = realloc(_vertices, _vertexCount * sizeof(PXGLColoredTextureVertex));
		}
	}
	else if (val != 0)
	{
		_vertexCount = val;
		_vertices = calloc(_vertexCount, sizeof(PXGLColoredTextureVertex));
	}

	_currentVertex = _vertices;
}

@end

PXInline_c unsigned PXTextureGlyphBatchConcatBox(PXGLColoredTextureVertex **currentVertex,
												  PXMathRange x,
												  PXMathRange y,
												  PXMathRange s,
												  PXMathRange t,
												  BOOL isFirst,
												  BOOL isLast)
{
	PXGLColoredTextureVertex *vertex = *currentVertex;
	unsigned addedVertexCount = 0;

//	if (!vertex)
//		return 0;

	// If it is not 0, then make an extra top left
	// Top left -> bottom left -> top right -> bottom right
	// If it is not the last (and there isn't only 1 character, then make an
	// extra bottom right.
	// This is done to create degenerate triangles between our letters, thus
	// no textures are distorted; and we create a chain of textures.
	if (!isFirst)
	{
		vertex->x = x.min;
		vertex->y = y.min;
		vertex->s = s.min;
		vertex->t = t.min;

		++vertex;
		++addedVertexCount;
	}

	vertex->x = x.min;
	vertex->y = y.min;
	vertex->s = s.min;
	vertex->t = t.min;

	++vertex;

	vertex->x = x.min;
	vertex->y = y.max;
	vertex->s = s.min;
	vertex->t = t.max;

	++vertex;

	vertex->x = x.max;
	vertex->y = y.min;
	vertex->s = s.max;
	vertex->t = t.min;

	++vertex;

	vertex->x = x.max;
	vertex->y = y.max;
	vertex->s = s.max;
	vertex->t = t.max;

	++vertex;

	addedVertexCount += 4;

	if (!isLast)
	{
		vertex->x = x.max;
		vertex->y = y.max;
		vertex->s = s.max;
		vertex->t = t.max;

		++vertex;
		++addedVertexCount;
	}

	*currentVertex = vertex;

	return addedVertexCount;
}

PXInline_c unsigned PXTextureGlyphBatchConcatBoxWithColor(PXGLColoredTextureVertex **currentVertex,
														   PXMathRange x,
														   PXMathRange y,
														   PXMathRange s,
														   PXMathRange t,
														   unsigned char red,
														   unsigned char green,
														   unsigned char blue,
														   unsigned char alpha,
														   BOOL isFirst,
														   BOOL isLast)
{
	PXGLColoredTextureVertex *vertex = *currentVertex;
	unsigned addedVertexCount = 0;
	
	//	if (!vertex)
	//		return 0;
	
	// If it is not 0, then make an extra top left
	// Top left -> bottom left -> top right -> bottom right
	// If it is not the last (and there isn't only 1 character, then make an
	// extra bottom right.
	// This is done to create degenerate triangles between our letters, thus
	// no textures are distorted; and we create a chain of textures.
	if (!isFirst)
	{
		vertex->x = x.min;	vertex->y = y.min;
		vertex->s = s.min;	vertex->t = t.min;
		vertex->r = red;	vertex->g = green;	vertex->b = blue;	vertex->a = alpha;
		
		++vertex;
		++addedVertexCount;
	}
	
	vertex->x = x.min;	vertex->y = y.min;
	vertex->s = s.min;	vertex->t = t.min;
	vertex->r = red;	vertex->g = green;	vertex->b = blue;	vertex->a = alpha;
	
	++vertex;
	
	vertex->x = x.min;	vertex->y = y.max;
	vertex->s = s.min;	vertex->t = t.max;
	vertex->r = red;	vertex->g = green;	vertex->b = blue;	vertex->a = alpha;

	++vertex;

	vertex->x = x.max;	vertex->y = y.min;
	vertex->s = s.max;	vertex->t = t.min;
	vertex->r = red;	vertex->g = green;	vertex->b = blue;	vertex->a = alpha;

	++vertex;
	
	vertex->x = x.max;	vertex->y = y.max;
	vertex->s = s.max;	vertex->t = t.max;
	vertex->r = red;	vertex->g = green;	vertex->b = blue;	vertex->a = alpha;

	++vertex;
	
	addedVertexCount += 4;
	
	if (!isLast)
	{
		vertex->x = x.max;	vertex->y = y.max;
		vertex->s = s.max;	vertex->t = t.max;
		vertex->r = red;	vertex->g = green;	vertex->b = blue;	vertex->a = alpha;

		++vertex;
		++addedVertexCount;
	}

	*currentVertex = vertex;

	return addedVertexCount;
}
