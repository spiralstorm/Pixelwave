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

#import "PXZwopAtlasParser.h"
#import "PXTextureLoader.h"

#import "PXRegexPattern.h"
#import "PXRegexMatcher.h"

PXRegexMatcher *pxZwopAtlasParserSizeMatcher = nil;
PXRegexMatcher *pxZwopAtlasParserRectMatcher = nil;
NSNumberFormatter *pxZwopAtlasParserNumberFormatter = nil;

@interface PXZwopAtlasParser(Private)
+ (void) beginParse;
+ (void) endParse;

+ (BOOL) parseIntFromString:(NSString *)string ret:(int *)ret;
+ (BOOL) parseBool:(NSDictionary *)dict key:(NSString *)key ret:(BOOL *)ret;
+ (BOOL) parseCGRect:(NSDictionary *)dict key:(NSString *)key ret:(CGRect *)ret;
+ (BOOL) parseCGSize:(NSDictionary *)dict key:(NSString *)key ret:(CGSize *)ret;

+ (NSDictionary *)dictionaryFromData:(NSData *)data;
@end

#define PX_ZWOP_ROTATION_AMOUNT 90.0f

@implementation PXZwopAtlasParser

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
	if (![ext isEqualToString:@"plist"])
		return NO;

	return YES;
}
+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	[extensions addObject:@"plist"];
}

- (BOOL) _parseWithModifier:(id<PXTextureModifier>)modifier
{
	////////////////////
	// Parse the JSON //
	////////////////////
	
	NSDictionary *dict = [PXZwopAtlasParser dictionaryFromData:data];
	
	if (!dict)
		return NO;
	
	NSDictionary *framesDict = [dict objectForKey:@"frames"];
	
	if (!framesDict)
		return NO;
	
	int numFrames = [framesDict count];
	
	// No frames, no service.
	if (numFrames <= 0)
		return NO;
	
	[self _setupWithTotalFrames:numFrames];
	
	///////////////////////////
	// Read the texture data //
	///////////////////////////
	
	// Release the old one if it exists
	//PXTextureData *textureData = nil;
	
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
	
	//textureData = [loader newTextureData];
	[loader release];
	
	//if (!textureData)
	//	return NO;
	
	/////////////////////////
	// Read the frame data //
	/////////////////////////
	
	// We'll have to divide all the coordinate  values stored in the files by
	// the content scale factor to convert them from PIXELS to POINTS.
	float invScaleFactor = 1.0f / contentScaleFactor;

	// Add the texture data at index 0
	//[self _addTextureData:textureData];

	// Start parsing
	PXGenericAtlasParserFrame *cFrame = NULL;

	CGRect frame;
	BOOL rotated;
	BOOL trimmed;
	CGRect spriteColorRect;
	CGSize spriteSourceSize;

	// Loop through all the names
	NSString *frameName;
	NSDictionary *frameDict;

	[PXZwopAtlasParser beginParse];
	for (frameName in framesDict)
	{		
		frameDict = [framesDict objectForKey:frameName];
		if (!framesDict)
			return NO;

		if (![PXZwopAtlasParser parseCGRect:frameDict key:@"textureRect" ret:&frame])
			return NO;
		if (![PXZwopAtlasParser parseBool:frameDict key:@"textureRotated" ret:&rotated])
			return NO;
		if (![PXZwopAtlasParser parseBool:frameDict key:@"spriteTrimmed" ret:&trimmed])
			return NO;
		if (![PXZwopAtlasParser parseCGRect:frameDict key:@"spriteColorRect" ret:&spriteColorRect])
			return NO;
		if (![PXZwopAtlasParser parseCGSize:frameDict key:@"spriteSourceSize" ret:&spriteSourceSize])
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
		cFrame->rotation = rotated ? PX_ZWOP_ROTATION_AMOUNT : 0.0f;
		cFrame->paddingEnabled = trimmed;

		// Apply padding if needed
		if (trimmed)
		{
			// Calculates the padding values (Also converts to points).
			float *padding = cFrame->padding;
			// Top
			padding[0] = (spriteColorRect.origin.y) * invScaleFactor;
			// Right
			padding[1] = (spriteSourceSize.width - (spriteColorRect.origin.x + spriteColorRect.size.width)) * invScaleFactor;
			// Bottom
			padding[2] = (spriteSourceSize.height - (spriteColorRect.origin.y + spriteColorRect.size.height)) * invScaleFactor;
			// Left
			padding[3] = (spriteColorRect.origin.x) * invScaleFactor;
		}

		++cFrame;
	}
	[PXZwopAtlasParser endParse];

	return YES;
}

+ (void) beginParse
{
	if (!pxZwopAtlasParserSizeMatcher)
	{
		PXRegexPattern *pattern = [PXRegexPattern patternWithRegex:@"\\{\\s*([0-9-]+)\\s*,\\s*([0-9-]+)\\s*\\}"];
		pxZwopAtlasParserSizeMatcher = [[PXRegexMatcher alloc] initWithPattern:pattern];
	}
	if (!pxZwopAtlasParserRectMatcher)
	{
		PXRegexPattern *pattern = [PXRegexPattern patternWithRegex:@"\\{\\s*\\{\\s*([0-9-]+)\\s*,\\s*([0-9-]+)\\s*\\}\\s*,\\s*\\{\\s*([0-9-]+)\\s*,\\s*([0-9-]+)\\s*\\}\\s*\\}"];
		pxZwopAtlasParserRectMatcher = [[PXRegexMatcher alloc] initWithPattern:pattern];
	}
	if (!pxZwopAtlasParserNumberFormatter)
	{
		pxZwopAtlasParserNumberFormatter = [[NSNumberFormatter alloc] init];
		[pxZwopAtlasParserNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	}
}
+ (void) endParse
{
	[pxZwopAtlasParserSizeMatcher release];
	pxZwopAtlasParserSizeMatcher = nil;
	[pxZwopAtlasParserRectMatcher release];
	pxZwopAtlasParserRectMatcher = nil;
	[pxZwopAtlasParserNumberFormatter release];
	pxZwopAtlasParserNumberFormatter = nil;
}

+ (BOOL) parseIntFromString:(NSString *)string ret:(int *)ret
{
	if (!ret)
		return NO;

	if (!string)
		return NO;

	*ret = [[pxZwopAtlasParserNumberFormatter numberFromString:string] intValue];
	return YES;
}

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

+ (BOOL) parseCGRect:(NSDictionary *)dict key:(NSString *)key ret:(CGRect *)ret
{
	if (!ret)
		return NO;

	id val = [dict objectForKey:key];
	if (![val isKindOfClass:[NSString class]])
		return NO;

	pxZwopAtlasParserRectMatcher.input = val;

	int x;
	int y;
	int width;
	int height;

	if (![pxZwopAtlasParserRectMatcher next])
	{
		return NO;
	}

	if (![PXZwopAtlasParser parseIntFromString:[pxZwopAtlasParserRectMatcher groupAtIndex:1] ret:&x])
		return NO;
	if (![PXZwopAtlasParser parseIntFromString:[pxZwopAtlasParserRectMatcher groupAtIndex:2] ret:&y])
		return NO;
	if (![PXZwopAtlasParser parseIntFromString:[pxZwopAtlasParserRectMatcher groupAtIndex:3] ret:&width])
		return NO;
	if (![PXZwopAtlasParser parseIntFromString:[pxZwopAtlasParserRectMatcher groupAtIndex:4] ret:&height])
		return NO;

	*ret =  CGRectMake(x, y, width, height);
	return YES;
}
+ (BOOL) parseCGSize:(NSDictionary *)dict key:(NSString *)key ret:(CGSize *)ret
{
	if (!ret)
		return NO;

	id val = [dict objectForKey:key];
	if (![val isKindOfClass:[NSString class]])
		return NO;

	pxZwopAtlasParserSizeMatcher.input = val;

	int width;
	int height;

	if (![pxZwopAtlasParserSizeMatcher next])
	{
		return NO;
	}

	if (![PXZwopAtlasParser parseIntFromString:[pxZwopAtlasParserSizeMatcher groupAtIndex:1] ret:&width])
		return NO;
	if (![PXZwopAtlasParser parseIntFromString:[pxZwopAtlasParserSizeMatcher groupAtIndex:2] ret:&height])
		return NO;

	*ret = CGSizeMake(width, height);
	return YES;
}

+ (NSDictionary *)dictionaryFromData:(NSData *)data
{
	CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault,
															   (CFDataRef)data,
															   kCFPropertyListImmutable,
															   NULL);

	if (!plist)
		return nil;

	if ([(id)plist isKindOfClass:[NSDictionary class]])
	{
		return [(NSDictionary *)plist autorelease];
	}
	else
	{
		CFRelease(plist);
		return nil;
	}

	return nil;
}

@end
