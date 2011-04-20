//
//  PXTexPacAtlasParser.h
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PXTextureAtlasParser.h"

#import <CoreGraphics/CoreGraphics.h>

typedef struct
{
	CGRect clipRect;
	float rotation;
	short padding[4];

	ushort nameIndex;
	BOOL paddingEnabled;
	BOOL _byte_padding;
}PXTPAtlasParserFrame;

// TexturePacker file format reader
@class PXTextureData;

@interface PXTPAtlasParser : PXTextureAtlasParser<PXParser>
{
@private
	// The texture data of the atlas
	PXTextureData *textureData;

	// The frame list
	int numFrames;
	PXTPAtlasParserFrame *frames;

	// The list of all the frame names
	NSMutableArray *names;
}

@end
