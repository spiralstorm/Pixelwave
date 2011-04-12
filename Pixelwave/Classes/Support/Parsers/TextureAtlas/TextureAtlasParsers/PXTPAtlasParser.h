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
	BOOL paddingEnabled;
	short padding[4];
	ushort nameIndex;
	
	BOOL _byte_padding;
}PXTPAtlasParserFrame;

// TexturePacker file format reader
@class PXTextureData;

@interface PXTPAtlasParser : PXTextureAtlasParser <PXParser> {
@private
	PXTextureData *textureData;
	int numFrames;
	PXTPAtlasParserFrame *frames;
	NSMutableArray *names;
}

@end
