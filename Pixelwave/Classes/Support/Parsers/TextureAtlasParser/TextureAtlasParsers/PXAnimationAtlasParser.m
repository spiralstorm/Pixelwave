//
//  DRAnimationAtlasParser.m
//  DinoRun
//
//  Created by Marco Mustapic on 11/7/12.
//  Copyright (c) 2012 Spiralstorm Games. All rights reserved.
//

#import "PXAnimationAtlasParser.h"
#import "CJSONDeserializer.h"

#import "PXTextureAtlas.h"
#import "PXAtlasFrame.h"
#import "PXClipRect.h"
#import "PXTexturePadding.h"

#import "PXTextureLoader.h"
#import "PXTextureData.h"

#import "PXDebug.h"

@implementation PXAnimationAtlasParser

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
	if (![ext isEqualToString:@"atlas"])
		return NO;
	

	return YES;
}

+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	[extensions addObject:@"atlas"];
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
    
    NSArray * bitmaps = [dict objectForKey:@"bitmaps"];
    for (NSString * bitmapName in bitmaps)
    {
        NSString *imagePath = nil;
        
        imagePath = [PXTextureLoader resolvePathForImageFile:bitmapName];
        if (!imagePath)
            return NO;
        
        PXTextureLoader *loader = [[PXTextureLoader alloc] initWithContentsOfFile:imagePath modifier:modifier];
        
        if (!loader)
            return NO;
        
        // Require the image to be the same contentScaleFactor as the atlas.
        [loader setContentScaleFactor:contentScaleFactor];
        [self _addTextureLoader:loader];
        [loader release];
    }
    
	/////////////////////////
	// Read the frame data //
	/////////////////////////
    
	// We'll have to divide all the coordinate  values stored in the file by
	// the content scale factor to convert them from PIXELS to POINTS.
	float invScaleFactor = 1.0f / contentScaleFactor;
	
	// Start parsing
	PXGenericAtlasParserFrame *cFrame = NULL;
    
	CGRect frame;
    
	// Loop through all the names
	NSString *frameName;
	NSDictionary *frameDict;
    
	for (frameName in framesDict)
	{
		frameDict = [framesDict objectForKey:frameName];
		if (!framesDict)
			return NO;
        
        frame.origin.x = [[frameDict objectForKey:@"x"] floatValue];
        frame.origin.y = [[frameDict objectForKey:@"y"] floatValue];
        frame.size.width = [[frameDict objectForKey:@"width"] floatValue];
        frame.size.height = [[frameDict objectForKey:@"height"] floatValue];
        
		// Convert to points
		frame.origin.x *= invScaleFactor;
		frame.origin.y *= invScaleFactor;
		frame.size.width *= invScaleFactor;
		frame.size.height *= invScaleFactor;
        
		// Register the name
		cFrame = [self _addFrameWithName:frameName];
        
		// Constant
		cFrame->textureDataIndex = [[frameDict objectForKey:@"source"] intValue];
		cFrame->anchorEnabled = NO;		// These aren't supported in this format
        
		// Dynamic
		cFrame->clipRect = frame;
		cFrame->rotation = 0.0f;
		cFrame->paddingEnabled = NO;
        
		++cFrame;
	}
    
	return YES;
}

@end
