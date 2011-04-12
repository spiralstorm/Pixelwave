//
//  PXTextureAtlas.m
//  TextureAtlas
//
//  Created by Oz Michaeli on 9/21/10.
//  Copyright 2010 Spiralstorm Games. All rights reserved.
//

#import "PXAtlasFrame.h"
#import "PXTexture.h"
#import "PXTextureData.h"

#import "PXTextureAtlas.h"
#import "PXPoint.h"

#import "PXTextureAtlasParser.h"

@implementation PXTextureAtlas

- (id) init
{
	if(self = [super init])
	{
		frames = [NSMutableDictionary new];
	}
	
	return self;
}

// TODO: Handle @2x files
- (id)initWithContentsOfFile:(NSString *)path
{
	return [self initWithContentsOfFile:path modifier:nil];
}
- (id)initWithContentsOfFile:(NSString *)path modifier:(id<PXTextureModifier>)modifier
{
	path = [[NSBundle mainBundle] pathForResource:path ofType:nil];
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	PXTextureAtlasParser *parser = [[PXTextureAtlasParser alloc] initWithData:data
																	 modifier:modifier
																	   origin:path];
	
	[self release];
	
	if(!parser)
	{
		return nil;
	}
	
	self = [parser newTextureAtlas];
	
	return self;
}

- (void) dealloc
{
	[frames release]; frames = nil;
	
	[super dealloc];
}

//
// Properties
//

#pragma mark Properties

- (NSArray *)allNames
{
	return [frames allKeys];
}
- (NSArray *)allFrames
{
	return [frames allValues];
}

- (NSArray *)textureDatas
{
	// Loops through all the frames and creates a unique list of all the
	// texture datas used
	
	NSMutableArray *arr = [NSMutableArray new];
	
	NSEnumerator *e = [frames objectEnumerator];
	
	PXAtlasFrame *frame;
	PXTextureData *td;
	
	while(frame = [e nextObject])
	{
		td = frame.textureData;
		
		if(![arr containsObject:td])
		{
			[arr addObject:td];
		}
	}
	
	return [arr autorelease];
}

//
// Functions
//

#pragma mark Standard container methods (add/remove/read)

- (void) addFrame:(PXAtlasFrame *)frame withName:(NSString *)name
{
	// If one already exists, remove it
	[self removeFrame:name];
	
	[frames setObject:frame forKey:name];
}

- (void) removeFrame:(NSString *)name
{
	PXAtlasFrame *frame = (PXAtlasFrame *)[frames objectForKey:name];
	if(!frame) return;
	
	[frames removeObjectForKey:name];
}

- (PXAtlasFrame *)frameWithName:(NSString *)name
{
	return (PXAtlasFrame *)[frames objectForKey:name];
}

#pragma mark Utility

/////////////
// Utility //
/////////////

// Adding
- (PXAtlasFrame *)addFrameWithName:(NSString *)name
						  clipRect:(PXClipRect *)clipRect
					   textureData:(PXTextureData *)textureData
{
	PXAtlasFrame *frame = [[PXAtlasFrame alloc] initWithClipRect:clipRect
													 textureData:textureData
														  anchor:nil];
	
	[self addFrame:frame withName:name];
	
	[frame release];
	
	return frame;
}

- (PXAtlasFrame *)addFrameWithName:(NSString *)name
						  clipRect:(PXClipRect *)clipRect
					   textureData:(PXTextureData *)textureData
						   anchorX:(float)anchorX
						   anchorY:(float)anchorY
{
	PXPoint *anchor = [[PXPoint alloc] initWithX:anchorX andY:anchorY];
	PXAtlasFrame *frame = [[PXAtlasFrame alloc] initWithClipRect:clipRect
													 textureData:textureData
														  anchor:anchor];
	
	[self addFrame:frame withName:name];
	
	[frame release];
	[anchor release];
	
	return frame;
	
}

// Reading

- (PXTexture *)textureForFrame:(NSString *)name
{
	PXAtlasFrame *frame = [self frameWithName:name];
	if(!frame) return nil;
	
	PXTexture *texture = [PXTexture texture];
	[frame setToTexture:texture];
	
	return texture;
}

- (void) setFrame:(NSString *)name toTexture:(PXTexture *)texture
{
	PXAtlasFrame *frame = [self frameWithName:name];
	if(!frame) return;
	
	[frame setToTexture:texture];
}

// Static

+ (PXTextureAtlas *)textureAtlas
{
	return [[[PXTextureAtlas alloc] init] autorelease];
}

@end