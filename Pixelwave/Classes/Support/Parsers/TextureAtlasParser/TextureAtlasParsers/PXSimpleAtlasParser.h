//
//  PXGenericAtlasParser.h
//  Pixelwave
//
//  Created by Oz Michaeli on 4/21/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PXTextureAtlasParser.h"
#import <CoreGraphics/CoreGraphics.h>

typedef struct
{
	CGRect clipRect;
	CGPoint anchor;
	float rotation;
	short padding[4];
	
	ushort textureDataIndex;
	ushort _nameIndex; // Private
	
	BOOL paddingEnabled, anchorEnabled;
}PXGenericAtlasParserFrame;

/**
 *	This class can be subclassed and used to efficiently parse standard atlases
 */

@class PXLinkedList;
@class PXTextureData;

@interface PXSimpleAtlasParser : PXTextureAtlasParser {
@private
	// The texture data of the atlas
	PXLinkedList *textureDatas;
	
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
- (void) _addTextureData:(PXTextureData *)textureData;
@end