//
//  PXGenericAtlasParser.h
//  Pixelwave
//
//  Created by Oz Michaeli on 4/21/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PXTextureAtlasParser.h"
#import <CoreGraphics/CoreGraphics.h>

@class PXLinkedList;
@class PXTextureData;
@class PXTextureLoader;

typedef struct
{
	CGRect clipRect;
	CGPoint anchor;
	float rotation;
	float padding[4];

	ushort textureDataIndex;
	ushort _nameIndex; // Private

	BOOL paddingEnabled, anchorEnabled;
} PXGenericAtlasParserFrame;

/**
 *	This class can be subclassed and used to efficiently parse standard atlases
 */

@interface PXSimpleAtlasParser : PXTextureAtlasParser
{
@private
	// The texture data of the atlas
	NSMutableArray *textureLoaders;
	
	// The list of all the frame names
	NSMutableArray *names;
	
	// The frame list
	ushort totalFrames, numFrames;
	PXGenericAtlasParserFrame *frames;
}

@end

@interface PXSimpleAtlasParser(Protected)
- (void) _setupWithTotalFrames:(ushort)totalFrames;
- (PXGenericAtlasParserFrame *)_addFrameWithName:(NSString *)name;
- (void) _addTextureLoader:(PXTextureLoader *)textureLoader;
@end
