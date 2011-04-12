//
//  PXTextureAtlasParser.m
//  Pixelwave
//
//  Created by Oz Michaeli on 4/11/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "PXTextureAtlasParser.h"

#import "PXTextureAtlas.h"
#import "PXTextureModifier.h"

@implementation PXTextureAtlasParser

- (id) initWithData:(NSData *)_data modifier:(id<PXTextureModifier>)_modifier origin:(NSString *)_origin
{
	if(self = [super init])
	{
		// Find the real type of parser to use.
		Class realClass = [PXParser parserForData:_data
										   origin:_origin
										baseClass:PXTextureAtlasParser.class];
		
		// If no real parser exists, then we can't do anything
		if (!realClass)
		{
			[self release];
			return nil;
		}
		
		// Make the new parser.
		PXTextureAtlasParser *newParser = [[realClass alloc] _initWithData:_data
																  modifier:_modifier
																	origin:_origin];
		
		// Release ourself, as we are going to become the real parser
		[self release];
		
		// Become the real parser, and allocate any data we need
		if (self = newParser)
		{
		}
	}
	
	return self;
}

- (id) _initWithData:(NSData *)_data
			modifier:(id<PXTextureModifier>)_modifier
			  origin:(NSString *)_origin
{
	// Set the data and origin
	if (self = [super _initWithData:_data origin:_origin])
	{
		if(![self _parseWithModifier:_modifier])
		{
			[self release];
			return nil;
		}
		
		// Set the modifier to the given one.
		//self.modifier = _modifier;
	}
	
	return self;
}

- (PXTextureAtlas *)newTextureAtlas
{
	return nil;
}

@end
