//
//  PXGenericAtlasParser.m
//  Pixelwave
//
//  Created by Oz Michaeli on 4/21/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PXSimpleAtlasParser.h"

#import "PXTextureAtlas.h"
#import "PXClipRect.h"
#import "PXTexturePadding.h"
#import "PXPoint.h"

#import "PXAtlasFrame.h"

#import "PXLinkedList.h"

@implementation PXSimpleAtlasParser

- (void) dealloc
{
	if (frames)
	{
		free(frames);
		frames = 0;
	}
	
	[names release];
	names = nil;
	
	[textureDatas release];
	textureDatas = nil;
	
	[super dealloc];
}

///////////////////////////
// Setting up the frames //
///////////////////////////

- (void)_setupWithTotalFrames:(ushort)_totalFrames
{
	if(!textureDatas)
		textureDatas = [[PXLinkedList alloc] init];
	
	if(!names)
		names = [[PXLinkedList alloc] init];
	
	[textureDatas removeAllObjects];
	[names removeAllObjects];
	
	totalFrames = _totalFrames;
	frames = realloc(frames, sizeof(PXGenericAtlasParserFrame) * totalFrames);
	
	numFrames = 0;
}
- (PXGenericAtlasParserFrame *)_addFrameWithName:(NSString *)name;
{
	if(numFrames >= totalFrames) return NULL;
	
	PXGenericAtlasParserFrame *frame = &frames[numFrames];
	frame->_nameIndex = numFrames;
	
	[names addObject:name];
	
	++numFrames;
	
	return frame;
}

- (void) _addTextureData:(PXTextureData *)textureData
{
	[textureDatas addObject:textureData];
}

/////////////////////////
// Creating the output //
/////////////////////////

- (PXTextureAtlas *)newTextureAtlas
{
	// Quick exits
	if (!frames)
		return nil;
	if (!names)
		return nil;
	if (!textureDatas)
		return nil;
	
	// Create the atlas. There's no going back now...
	PXTextureAtlas *atlas = [[PXTextureAtlas alloc] init];
	
	// Loop through the frames
	PXClipRect *clipRect = [[PXClipRect alloc] init];
	PXTexturePadding *padding = [[PXTexturePadding alloc] init];
	PXPoint *anchor = [[PXPoint alloc] init];
	PXTextureData *textureData = nil;
	
	PXAtlasFrame *atlasFrame;
	NSString *frameName;
	
	short *rawPadding = NULL;
	CGPoint *rawAnchor = NULL;
	
	BOOL paddingEnabled, anchorEnabled;
	
	int i;
	PXGenericAtlasParserFrame *frame;
	
	for (i = 0, frame = &frames[0]; i < numFrames; ++i, ++frame)
	{
		// 1. Get the name
		frameName = [names objectAtIndex:frame->_nameIndex];
		
		// 2. Get the texture data
		textureData = [textureDatas objectAtIndex:frame->textureDataIndex];
		
		// 3. Get the clip rect
		[clipRect setX:frame->clipRect.origin.x
					 y:frame->clipRect.origin.y
				 width:frame->clipRect.size.width
				height:frame->clipRect.size.height
			  rotation:frame->rotation];
		
		// 4. Get the padding
		paddingEnabled = frame->paddingEnabled;
		if (paddingEnabled)
		{
			rawPadding = frame->padding;
			[padding setTop:rawPadding[0]
					  right:rawPadding[1]
					 bottom:rawPadding[2]
					   left:rawPadding[3]];
		}
		
		// 5. Get the anchor
		anchorEnabled = frame->anchorEnabled;
		if (anchorEnabled)
		{
			rawAnchor = &(frame->anchor);
			[anchor setX:rawAnchor->x y:rawAnchor->y];
		}
		
		// 6. Create the frame object
		atlasFrame = [[PXAtlasFrame alloc] initWithClipRect:clipRect
												textureData:textureData
													 anchor:anchorEnabled ? anchor : nil
													padding:paddingEnabled ? padding : nil];
		
		// 7. Add it to the atlas
		[atlas addFrame:atlasFrame withName:frameName];
		[atlasFrame release];
	}
	
	[clipRect release];
	[padding release];
	[anchor release];
	
	return atlas;
}

@end
