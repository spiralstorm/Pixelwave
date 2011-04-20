//
//  PXTexPacAtlasParser.m
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PXTPAtlasParser.h"
#import "CJSONDeserializer.h"

#import "PXTextureAtlas.h"
#import "PXAtlasFrame.h"
#import "PXClipRect.h"
#import "PXTexturePadding.h"

#import "PXTextureLoader.h"
#import "PXTextureData.h"

// How much TexturePacker rotates the image when it says 'rotated'
#define PX_TP_ROTATION_AMOUNT 90.0f

@interface PXTPAtlasParser(Private)
- (BOOL)parseBool:(NSDictionary *)dict key:(NSString *)key ret:(BOOL *)ret;
- (BOOL)parseInt:(NSDictionary *)dict key:(NSString *)key ret:(int *)ret;
- (BOOL)parseRect:(NSDictionary *)dict key:(NSString *)key ret:(CGRect *)ret;
- (BOOL)parseSize:(NSDictionary *)dict key:(NSString *)key ret:(CGSize *)ret;
@end

@implementation PXTPAtlasParser

- (void) dealloc
{
	if (frames)
	{
		free(frames);
		frames = 0;
	}

	[names release];
	names = nil;

	[textureData release];
	textureData = nil;

	[super dealloc];
}

- (PXTextureAtlas *)newTextureAtlas
{
	// Quick exits
	if (!frames)
		return nil;
	if (!names)
		return nil;
	if (!textureData)
		return nil;

	// Create the atlas. There's no going back now...
	PXTextureAtlas *atlas = [[PXTextureAtlas alloc] init];

	// Loop through the frames
	PXClipRect *clipRect = [[PXClipRect alloc] init];
	PXTexturePadding *padding = [[PXTexturePadding alloc] init];
	PXAtlasFrame *atlasFrame;
	NSString *frameName;

	short *rawPadding = NULL;

	int i;
	PXTPAtlasParserFrame *frame = frames;

	for (i = 0; i < numFrames; ++i, ++frame)
	{
		// 1. Get the name
		frameName = [names objectAtIndex:frame->nameIndex];
		
		// 2. Get the clip rect
		[clipRect setX:frame->clipRect.origin.x
					 Y:frame->clipRect.origin.y
				 width:frame->clipRect.size.width
				height:frame->clipRect.size.height
			  rotation:frame->rotation];

		// 3. Get the padding
		if (frame->paddingEnabled)
		{
			rawPadding = frame->padding;
			[padding setTop:rawPadding[0]
					  right:rawPadding[1]
					 bottom:rawPadding[2]
					   left:rawPadding[3]];
		}

		// 4. Create the frame object
		atlasFrame = [[PXAtlasFrame alloc] initWithClipRect:clipRect
												textureData:textureData
													 anchor:nil
													padding:(frame->paddingEnabled) ? padding : nil];

		// 5. Add it to the atlas
		[atlas addFrame:atlasFrame withName:frameName];
		[atlasFrame release];
	}

	[clipRect release];
	[padding release];

	return atlas;
}

////
////
////

// Right now this just does a silly check to see if a certain string exists
// within the file to see if it's the right type. Unfortunately the JSON file
// format doesn't have any good unique features we can use.
+ (BOOL) isApplicableForData:(NSData *)data origin:(NSString *)origin
{
	if (!data)
		return NO;

	// If this file came straight from memory (not loaded from a URL), we don't
	// know what it's called and as such can't figure out the name of the image.
	// This is only a restriction with the current JSON file, and can be removed
	// when the file format changes.
	if (!origin)
		return NO;

	NSString *ext = [[origin pathExtension] lowercaseString];
	if (![ext isEqualToString:@"json"])
		return NO;

	// Check for a string we know has to be in there
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSRange range = [str rangeOfString:@"\"spriteSourceSize\":"];

	[str release]; // TODO: Oz, I added this line, look over it?

	if (range.length == 0)
		return NO;

	return YES;
}
+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	[extensions addObject:@"json"];
}

- (BOOL) _parseWithModifier:(id<PXTextureModifier>)modifier
{
	////////////////////////////
	// Parse the texture data //
	////////////////////////////

	// Release the old one if it exists
	if (textureData)
	{
		[textureData release];
		textureData = nil;
	}

	NSString *imagePath = nil;
	
	// Limitations due to current JSON file not storing the image name:
	{
		// Since the current JSON file format doesn't tell us the name of the image
		// file, we can't load it unless the atlas was loaded from the hard-drive
		if (!origin)
			return NO;
		
		// Since the current JSON file doesn't tell us the name of the image,
		// we have to assume that it's the same as the atlas file name. But since
		// we don't know the extension we have to try all the possible ones.
		imagePath = [PXTextureLoader resolvePathForImageFile:[origin stringByDeletingPathExtension]];		
		if (!imagePath)
			return NO;
	}

	// Dilemma: Should we get the contentScaleFactor from the file name of the
	// atlas or from the file name of the images?
	// Here we just use the file name of the atlas...
	PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:imagePath modifier:modifier];

	if (!loader)
		return NO;

	// Require the image to be the same contentScaleFactor as the atlas.
	[loader setContentScaleFactor:contentScaleFactor];

	textureData = [loader newTextureData];
	[loader release];

	if (!textureData)
		return NO;

	/////////////////////////
	// Parse the JSON data //
	/////////////////////////

	// We'll have to divide all the coordinate  values stored in the files by
	// the content scale factor to convert them from PIXELS to POINTS.
	float invScaleFactor = 1.0f / contentScaleFactor;

	NSError *error = nil;
	NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];

	if (error)
		return NO;

	NSDictionary *framesDict = [dict objectForKey:@"frames"];

	if (!framesDict)
		return NO;
	
	// Create the array of frames
	if (frames)
	{
		free(frames);
	}

	numFrames = [framesDict count];
	frames = (PXTPAtlasParserFrame *)malloc(sizeof(PXTPAtlasParserFrame) * numFrames);

	// Create the array of names
	if (names)
	{
		[names release];
	}

	names = [[NSMutableArray alloc] init];

	PXTPAtlasParserFrame *cFrame = frames;

	//

	CGRect frame;
	BOOL rotated;
	BOOL trimmed;
	CGRect spriteSourceSize;
	CGSize sourceSize;
	ushort nameIndex;

	// Loop through all the names
	NSString *frameName;
	NSDictionary *frameDict;

	for (frameName in framesDict)
	{		
		frameDict = [framesDict objectForKey:frameName];
		if (!framesDict)
			return NO;

		if (![self parseRect:frameDict key:@"frame" ret:&frame])
			return NO;
		if (![self parseBool:frameDict key:@"rotated" ret:&rotated])
			return NO;
		if (![self parseBool:frameDict key:@"trimmed" ret:&trimmed])
			return NO;
		if (![self parseRect:frameDict key:@"spriteSourceSize" ret:&spriteSourceSize])
			return NO;
		if (![self parseSize:frameDict key:@"sourceSize" ret:&sourceSize])
			return NO;

		// Convert to points
		frame.origin.x *= invScaleFactor;
		frame.origin.y *= invScaleFactor;
		frame.size.width *= invScaleFactor;
		frame.size.height *= invScaleFactor;

		// When an image is rotated, TexturePacker doesn't rotate the clip
		// coordinates. That means we have to do it.
		if (rotated)
		{
			float tmp = frame.size.width;

			frame.size.width = frame.size.height;
			frame.size.height = tmp;
		}

		// Add the name to the names list and grab its index
		nameIndex = [names count];
		[names addObject:frameName];

		cFrame->nameIndex = nameIndex;
		cFrame->clipRect = frame;
		cFrame->rotation = rotated ? PX_TP_ROTATION_AMOUNT : 0.0f;
		cFrame->paddingEnabled = trimmed;

		// Apply padding if needed
		if (trimmed)
		{
			// Calculates the padding values (Also converts to points).
			short *padding = cFrame->padding;
			// Top
			padding[0] = (spriteSourceSize.origin.y) * invScaleFactor;
			// Right
			padding[1] = (sourceSize.width - (spriteSourceSize.origin.x + spriteSourceSize.size.width)) * invScaleFactor;
			// Bottom
			padding[2] = (sourceSize.height - (spriteSourceSize.origin.y + spriteSourceSize.size.height)) * invScaleFactor;
			// Left
			padding[3] = (spriteSourceSize.origin.x) * invScaleFactor;
		}

		++cFrame;
	}

	return YES;
}

/////////////
// Parsing //
/////////////

- (BOOL)parseBool:(NSDictionary *)dict key:(NSString *)key ret:(BOOL *)ret
{
	id val = [dict objectForKey:key];
	if (![val isKindOfClass:NSNumber.class])
		return NO;

	*ret = [(NSNumber *)val boolValue];

	return YES;
}
- (BOOL)parseInt:(NSDictionary *)dict key:(NSString *)key ret:(int *)ret
{
	id val = [dict objectForKey:key];
	if (![val isKindOfClass:NSNumber.class])
		return NO;

	*ret = [(NSNumber *)val intValue];

	return YES;
}
- (BOOL)parseRect:(NSDictionary *)dict key:(NSString *)key ret:(CGRect *)ret
{
	id val = [dict objectForKey:key];
	if (![val isKindOfClass:NSDictionary.class])
	{
		return NO;
	}

	NSDictionary *rectDict = val;

	int x, y, w, h;

	if (![self parseInt:rectDict key:@"x" ret:&x])
		return NO;
	if (![self parseInt:rectDict key:@"y" ret:&y])
		return NO;
	if (![self parseInt:rectDict key:@"w" ret:&w])
		return NO;
	if (![self parseInt:rectDict key:@"h" ret:&h])
		return NO;

	ret->origin.x = x;
	ret->origin.y = y;
	ret->size.width = w;
	ret->size.height = h;

	return YES;
}
- (BOOL)parseSize:(NSDictionary *)dict key:(NSString *)key ret:(CGSize *)ret
{
	id val = [dict objectForKey:key];
	if (![val isKindOfClass:NSDictionary.class])
	{
		return NO;
	}

	NSDictionary *rectDict = val;

	int w, h;

	if (![self parseInt:rectDict key:@"w" ret:&w])
		return NO;
	if (![self parseInt:rectDict key:@"h" ret:&h])
		return NO;

	ret->width = w;
	ret->height = h;

	return YES;
}

@end
