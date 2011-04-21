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

#import "PXLoader.h"

#import "PXTextureAtlasParser.h"

@interface PXTextureAtlas(Private)
- (id)initWithData:(NSData *)data
	   scaleFactor:(float)scaleFactor
		  modifier:(id<PXTextureModifier>)modifier
			origin:(NSString *)origin;
@end

@implementation PXTextureAtlas

- (id) init
{
	self = [super init];
	if (self)
	{
		frames = [NSMutableDictionary new];
	}
	
	return self;
}

/////////////////////////
// Loading initalizers //
/////////////////////////

// We've decided not to include initWithContentsOfURL because this method could
// potentially take a long time, and it can't be performed on a background
// thread since it's making GL textures. As such, the best solution for the
// user is to load the URL into an NSData and pass it in like that.
// ...Yes, we could make a PXTextureAtlasLoader, but I think that would be
// overkill... I mean, why would you want to load a texture atlas directly from
// a URL in a production app?

- (id) initWithContentsOfFile:(NSString *)path
{
	return [self initWithContentsOfFile:path modifier:nil];
}

- (id) initWithContentsOfFile:(NSString *)path modifier:(id<PXTextureModifier>)modifier
{
	// Convert to an absolute path
	path = [PXLoader absolutePathFromPath:path];
	
	// Figure out if there's an @#x version of the file (Ex. Atlas@2x.json).
	// If so, use its path and content scaling factor.
	
	float scaleFactor = 1.0f;
	path = [PXLoader pathForRetinaVersionOfFile:path retScale:&scaleFactor];
	
	// Load the data from the HD
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	return [self initWithData:data
				  scaleFactor:scaleFactor
					 modifier:modifier
					   origin:path];
	
}

- (id) initWithData:(NSData *)data
{
	return [self initWithData:data modifier:nil];
}
- (id) initWithData:(NSData *)data modifier:(id<PXTextureModifier>)modifier
{
	return [self initWithData:data
				  scaleFactor:1.0
					 modifier:modifier
					   origin:nil];
}

// Actual loading initializer
- (id) initWithData:(NSData *)data
	    scaleFactor:(float)scaleFactor
	 	   modifier:(id<PXTextureModifier>)modifier
			 origin:(NSString *)origin
{
	PXTextureAtlasParser *parser = [[PXTextureAtlasParser alloc] initWithData:data
														   contentScaleFactor:scaleFactor
																	 modifier:modifier
																	   origin:origin];

	[self release];

	if (!parser)
	{
		return nil;
	}

	self = [parser newTextureAtlas];
	[parser release]; // TODO: Oz, I added this line, look over it?

	return self;
}

- (void) dealloc
{
	[frames release];
	frames = nil;
	
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
	
	while (frame = [e nextObject])
	{
		td = frame.textureData;
		
		if (![arr containsObject:td])
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
	if (!frame)
		return;
	
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
	PXPoint *anchor = [[PXPoint alloc] initWithX:anchorX y:anchorY];
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
	if (!frame)
		return nil;
	
	PXTexture *texture = [PXTexture texture];
	[frame setToTexture:texture];
	
	return texture;
}

- (void) setFrame:(NSString *)name toTexture:(PXTexture *)texture
{
	PXAtlasFrame *frame = [self frameWithName:name];
	if (!frame)
		return;
	
	[frame setToTexture:texture];
}

// Static

+ (PXTextureAtlas *)textureAtlas
{
	return [[[PXTextureAtlas alloc] init] autorelease];
}

@end