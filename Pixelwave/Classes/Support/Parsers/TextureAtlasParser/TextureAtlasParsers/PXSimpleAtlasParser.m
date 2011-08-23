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

#import "PXSimpleAtlasParser.h"

#import "PXTextureAtlas.h"
#import "PXClipRect.h"
#import "PXTexturePadding.h"
#import "PXPoint.h"

#import "PXTextureLoader.h"

#import "PXAtlasFrame.h"

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

	[textureLoaders release];
	textureLoaders = nil;

	[super dealloc];
}

///////////////////////////
// Setting up the frames //
///////////////////////////

- (void)_setupWithTotalFrames:(ushort)_totalFrames
{
	if (!textureLoaders)
		textureLoaders = [[NSMutableArray alloc] init];

	if (!names)
		names = [[NSMutableArray alloc] init];

	[textureLoaders removeAllObjects];
	[names removeAllObjects];

	totalFrames = _totalFrames;
	frames = realloc(frames, sizeof(PXGenericAtlasParserFrame) * totalFrames);

	numFrames = 0;
}
- (PXGenericAtlasParserFrame *)_addFrameWithName:(NSString *)name;
{
	if (numFrames >= totalFrames)
		return NULL;

	PXGenericAtlasParserFrame *frame = &frames[numFrames];
	frame->_nameIndex = numFrames;

	[names addObject:name];

	++numFrames;

	return frame;
}

- (void) _addTextureLoader:(PXTextureLoader *)textureLoader
{
	[textureLoaders addObject:textureLoader];
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
	if (!textureLoaders)
		return nil;

	// Convert all the loaders to TextureData objects
	NSMutableArray *textureDatas = [[NSMutableArray alloc] init];

	PXTextureData *textureData = nil;

	BOOL allTexturesAreValid = YES;

	for (PXTextureLoader *textureLoader in textureLoaders)
	{
		textureData = [textureLoader newTextureData];

		if (textureData)
		{
			[textureDatas addObject:textureData];
			[textureData release];
		}
		else
		{
			allTexturesAreValid = NO;
			break;
		}
	}

	// If any of the textures couldn't be loaded, the atlas can't be created.
	if (!allTexturesAreValid)
	{
		[textureDatas release];
		textureDatas = nil;
		
		return nil;
	}

	// Create the atlas. There's no going back now...
	PXTextureAtlas *atlas = [[PXTextureAtlas alloc] init];

	// Loop through the frames
	PXClipRect *clipRect = [[PXClipRect alloc] init];
	PXTexturePadding *padding = [[PXTexturePadding alloc] init];
	PXPoint *anchor = [[PXPoint alloc] init];

	PXAtlasFrame *atlasFrame;
	NSString *frameName;

	float *rawPadding = NULL;
	CGPoint *rawAnchor = NULL;

	BOOL paddingEnabled, anchorEnabled;

	int i;
	PXGenericAtlasParserFrame *frame;

	for (i = 0, frame = frames + i; i < numFrames; ++i, ++frame)
	{
		if (!frame)
			continue;

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
	[textureDatas release];

	return atlas;
}

@end
