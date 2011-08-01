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

#import "PXTPAtlasParser.h"
#import "CJSONDeserializer.h"

#import "PXTextureAtlas.h"
#import "PXAtlasFrame.h"
#import "PXClipRect.h"
#import "PXTexturePadding.h"

#import "PXTextureLoader.h"
#import "PXTextureData.h"

#import "PXDebug.h"

// How much TexturePacker rotates the image when it says 'rotated'
#define PX_TP_ROTATION_AMOUNT 90.0f

@interface PXTPAtlasParser(Private)
+ (BOOL) parseBool:(NSDictionary *)dict key:(NSString *)key ret:(BOOL *)ret;
+ (BOOL) parseInt:(NSDictionary *)dict key:(NSString *)key ret:(int *)ret;
+ (BOOL) parseCGRect:(NSDictionary *)dict key:(NSString *)key ret:(CGRect *)ret;
+ (BOOL) parseCGSize:(NSDictionary *)dict key:(NSString *)key ret:(CGSize *)ret;
@end

@implementation PXTPAtlasParser

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
	
	[str release];
	
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
	/////////////////////////
	// Parse the JSON data //
	/////////////////////////
	
	NSError *error = nil;
	NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
	
	if (error)
	{
		NSString *localOrigin = self.origin;
		localOrigin = [[localOrigin pathComponents] lastObject];

		PXDebugLog(@"Couldn't parse file:%@ reason:%@\n", localOrigin ? localOrigin : @"JSON", error);
		return NO;
	}
	
	NSDictionary *framesDict = [dict objectForKey:@"frames"];
	
	if (!framesDict)
		return NO;
	
	int numFrames = [framesDict count];
	
	// No frames, no service.
	if (numFrames <= 0)
		return NO;
	
	[self _setupWithTotalFrames:numFrames];
	
	
	////////////////////////////////
	// Read the texture data info //
	////////////////////////////////

	// Release the old one if it exists

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

	[self _addTextureLoader:loader];
	[loader release];

	/////////////////////////
	// Read the frame data //
	/////////////////////////

	// We'll have to divide all the coordinate  values stored in the file by
	// the content scale factor to convert them from PIXELS to POINTS.
	float invScaleFactor = 1.0f / contentScaleFactor;
	
	// Start parsing
	PXGenericAtlasParserFrame *cFrame = NULL;

	CGRect frame;
	BOOL rotated;
	BOOL trimmed;
	CGRect spriteSourceSize;
	CGSize sourceSize;

	// Loop through all the names
	NSString *frameName;
	NSDictionary *frameDict;

	for (frameName in framesDict)
	{		
		frameDict = [framesDict objectForKey:frameName];
		if (!framesDict)
			return NO;

		if (![PXTPAtlasParser parseCGRect:frameDict key:@"frame" ret:&frame])
			return NO;
		if (![PXTPAtlasParser parseBool:frameDict key:@"rotated" ret:&rotated])
			return NO;
		if (![PXTPAtlasParser parseBool:frameDict key:@"trimmed" ret:&trimmed])
			return NO;
		if (![PXTPAtlasParser parseCGRect:frameDict key:@"spriteSourceSize" ret:&spriteSourceSize])
			return NO;
		if (![PXTPAtlasParser parseCGSize:frameDict key:@"sourceSize" ret:&sourceSize])
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

		// Register the name
		cFrame = [self _addFrameWithName:frameName];

		// Constant
		cFrame->textureDataIndex = 0;	// This format only does a single image
		cFrame->anchorEnabled = NO;		// These aren't supported in this format

		// Dynamic
		cFrame->clipRect = frame;
		cFrame->rotation = rotated ? PX_TP_ROTATION_AMOUNT : 0.0f;
		cFrame->paddingEnabled = trimmed;

		// Apply padding if needed
		if (trimmed)
		{
			// Calculates the padding values (Also converts to points).
			float *padding = cFrame->padding;
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

+ (BOOL) parseBool:(NSDictionary *)dict key:(NSString *)key ret:(BOOL *)ret
{
	if (!ret)
		return NO;

	id val = [dict objectForKey:key];
	if (![val isKindOfClass:[NSNumber class]])
		return NO;

	*ret = [(NSNumber *)val boolValue];

	return YES;
}
+ (BOOL) parseInt:(NSDictionary *)dict key:(NSString *)key ret:(int *)ret
{
	if (!ret)
		return NO;

	id val = [dict objectForKey:key];
	if (![val isKindOfClass:[NSNumber class]])
		return NO;

	*ret = [(NSNumber *)val intValue];

	return YES;
}
+ (BOOL) parseCGRect:(NSDictionary *)dict key:(NSString *)key ret:(CGRect *)ret
{
	if (!ret)
		return NO;

	id val = [dict objectForKey:key];
	if (![val isKindOfClass:[NSDictionary class]])
	{
		return NO;
	}

	NSDictionary *rectDict = val;

	int x, y, w, h;

	if (![PXTPAtlasParser parseInt:rectDict key:@"x" ret:&x])
		return NO;
	if (![PXTPAtlasParser parseInt:rectDict key:@"y" ret:&y])
		return NO;
	if (![PXTPAtlasParser parseInt:rectDict key:@"w" ret:&w])
		return NO;
	if (![PXTPAtlasParser parseInt:rectDict key:@"h" ret:&h])
		return NO;

	ret->origin.x = x;
	ret->origin.y = y;
	ret->size.width = w;
	ret->size.height = h;

	return YES;
}
+ (BOOL) parseCGSize:(NSDictionary *)dict key:(NSString *)key ret:(CGSize *)ret
{
	if (!ret)
		return NO;

	id val = [dict objectForKey:key];
	if (![val isKindOfClass:[NSDictionary class]])
	{
		return NO;
	}

	NSDictionary *rectDict = val;

	int w, h;

	if (![PXTPAtlasParser parseInt:rectDict key:@"w" ret:&w])
		return NO;
	if (![PXTPAtlasParser parseInt:rectDict key:@"h" ret:&h])
		return NO;

	ret->width = w;
	ret->height = h;

	return YES;
}

@end
