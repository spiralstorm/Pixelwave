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

#import "PXAtlasFrame.h"
#import "PXTexture.h"
#import "PXTextureData.h"

#import "PXTextureAtlas.h"
#import "PXPoint.h"

#import "PXLoader.h"

#import "PXTextureAtlasParser.h"

@interface PXTextureAtlas(Private)
- (id) initWithData:(NSData *)data
	   scaleFactor:(float)scaleFactor
		  modifier:(id<PXTextureModifier>)modifier
			origin:(NSString *)origin;
@end

/**
 * Abstracts the concept of a texture atlas
 * (several images arranged into one larger image) into
 * a simple object containing a 'frame' for each sub-image.
 *
 * The PXTextureAtlas class supports atlases backed by one
 * or multiple images.
 *
 * Frames within the texture atlas are represented by the
 * PXAtlasFrame class. Each frame contains information about
 * a sub image within the atlas, such as its position within
 * the master image, angular offset, anchor position, etc.
 * 
 * *CREATION*
 * 
 * A Texture atlas can be created manually, requiring the user
 * to specify the master image and a PXAtlasFrame object for each
 * subimage within. Alternatively a texture atlas definition file
 * can be loaded and used to create the texture atlas. Currently
 * the following texture atlas format are supported:
 *
 * - Zwoptex (.plist)
 * - TexturePacker (.json)
 *
 * *USAGE*
 *
 * Once a texture atlas has been created (either manually or
 * with an external file), using it is quite simple. To quickly create
 * a PXTexture containing a specific subimage, use the #textureForFrame:
 * method, specifying the name of the frame to use.
 *
 * To set a specific sub-image in the atlas to a PXTexture that already 
 * exists use the #setFrame:toTexture: method instead.
 *
 * If more control is needed, the actual PXAtlasFrame object can be
 * grabbed with the #frameWithName: method and inspected as necessary.
 *
 * @see PXAtlasFrame
 * @see initWithContentsOfFile:
 * @see initWithData:
 */
@implementation PXTextureAtlas

/**
 * Initializes an empty texture atlas. The texture atlas
 * can be populated with frames using the addFrame:withName: and
 * removeFrame: methods.
 *
 * @see addFrame:withName:
 * @see removeFrame:
 */
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

/**
 * Loads the texture atlas definition file specified by <code>path</code>
 * and initializes the texture atlas with it.
 * 
 * @param path An absolute path or one relative to the resource bundle, representing the
 * texture atlas definition file to load.
 *
 * @see initWithContentsOfFile:modifier:
 */
- (id) initWithContentsOfFile:(NSString *)path
{
	return [self initWithContentsOfFile:path modifier:nil];
}

/**
 * Loads the texture atlas definition file specified by <code>path</code>
 * and initializes the texture atlas with it. Also allows to specify an
 * optional PXTextureModifier, which will be applied to the entire loaded texture
 * atlas image.
 *
 * @param path An absolute path or one relative to the resource bundle, representing the
 * texture atlas definition file to load.
 *
 * @param modifier An optional modifier, to be applied to the loaded atlas image. Default value
 * is <code>nil</code>
 */
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

/**
 * Initializes and populates the texture atlas with data representing
 * a texture atlas definition file.
 *
 * @param data An NSDate object representing the bytes of a texture definition file.
 */
- (id) initWithData:(NSData *)data
{
	return [self initWithData:data modifier:nil];
}
/**
 * Initializes and populates the texture atlas with data representing
 * a texture atlas definition file. Also allows for an optional PXTextureModifier.
 *
 * @param data An NSDate object representing the bytes of a texture definition file.
 *
 * @param modifier An optional PXTextureModifier to be applied to the loaded atlas texture data.
 */
- (id) initWithData:(NSData *)data modifier:(id<PXTextureModifier>)modifier
{
	return [self initWithData:data
				  scaleFactor:1.0
					 modifier:modifier
					   origin:nil];
}

// Private: Actual loading initializer
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
	[parser release];

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
	
	while ((frame = [e nextObject]))
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

/**
 * Adds the given frame to the atlas. Useful when creating a custom
 * PXTextureAtlas object (as opposed to loading one from file).
 *
 * @param frame The frame to add to the atlas. The frame object is retained
 * by the atlas and can be safely released by the caller after this
 * method is called.
 *
 * @param name The name to associate the given frame with. This is the name
 * used to dereference the frame later on. If the name specified
 * is already associated with a different frame, that frame is
 * removed and is replaced by the one passed in.
 *
 * @see initWithContentsOfFile:
 * @see addFrameWithName:clipRect:textureData:
 * @see addFrameWithName:clipRect:textureData:anchorX:anchorY:
 */
- (void) addFrame:(PXAtlasFrame *)frame withName:(NSString *)name
{
	// If one already exists, remove it
	[self removeFrame:name];
	
	[frames setObject:frame forKey:name];
}

/**
 * Removes the frame associated with the given name. If a frame with that
 * name doesn't exist, nothing happens.
 *
 * Note: Once a frame is removed from the texture atlas, the atlas's retain on it is released.
 * If you need to keep a reference to the frame you're about to remove, it's best to get the
 * reference before calling this method via the #frameWithName: method.
 */
- (void) removeFrame:(NSString *)name
{
	PXAtlasFrame *frame = (PXAtlasFrame *)[frames objectForKey:name];
	if (!frame)
		return;
	
	[frames removeObjectForKey:name];
}

/**
 * Returns the frame associated with the given name.
 * returns <code>nil</code> if the given name isn't associated with
 * any frame.
 */
- (PXAtlasFrame *)frameWithName:(NSString *)name
{
	return (PXAtlasFrame *)[frames objectForKey:name];
}

#pragma mark Utility

/////////////
// Utility //
/////////////

/**
 * A utility method for quickly adding a frame without the
 * need to create and manage a PXAtlasFrame object.
 *
 * @param name The name to associate the frame with.
 * @param clipRect A PXClipRect object representing the location of the sub-image
 * represented by this frame, within the atlas image.
 * @param textureData A PXTextureData object representing the master atlas image.
 *
 * @see addFrameWithName:clipRect:textureData:anchorX:anchorY:
 * @see addFrame:withName:
 * @see [PXAtlasFrame initWithClipRect:textureData:]
 */
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

/**
 * A utility method for quickly adding a frame without the
 * need to create and manage a PXAtlasFrame object.
 *
 * @param name The name to associate the frame with.
 * @param clipRect A PXClipRect object representing the location of the sub-image
 * represented by this frame, within the atlas image.
 * @param textureData A PXTextureData object representing the master atlas image.
 * @param anchorX The anchorX value (in percent) to set for the created frame.
 * @param anchorY The anchorY value (in percent) to set for the created frame.
 *
 * @see addFrame:withName:
 * @see addFrameWithName:clipRect:textureData:
 * @see [PXAtlasFrame initWithClipRect:textureData:anchor:]
 */
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

/**
 * A utility method for quickly creating a PXTexture object
 * representing the frame with the given name.
 *
 * @param name The name of the frame to use.
 *
 * @return An autoreleased PXTexture object representing the frame associated
 * with the given name. If name is <code>nil</code>, or isn't associated with
 * any frame in the atlas, <code>nil</code> is returned.
 *
 * @see [PXAtlasFrame setToTexture:]
 */
- (PXTexture *)textureForFrame:(NSString *)name
{
	PXAtlasFrame *frame = [self frameWithName:name];
	if (!frame)
		return nil;
	
	PXTexture *texture = [PXTexture texture];
	[frame setToTexture:texture];
	
	return texture;
}

/**
 * A utility method for quickly modifying the given PXTexture object
 * to represent the frame with the given name.
 *
 * @param name The name of the frame to use. If a frame isn't associated with that name,
 * nothing happens.
 * @param texture A PXTexture object who's contents will be modified to represent the
 * given frame.
 *
 * @see [PXAtlasFrame setToTexture:]
 */
- (void) setFrame:(NSString *)name toTexture:(PXTexture *)texture
{
	PXAtlasFrame *frame = [self frameWithName:name];
	if (!frame)
		return;
	
	[frame setToTexture:texture];
}

// Static

/**
 * A utility method for quickly creating an empty texture atlas.
 *
 * @return An empty, autoreleased PXTextureAtlas object.
 */
+ (PXTextureAtlas *)textureAtlas
{
	return [[[PXTextureAtlas alloc] init] autorelease];
}

/**
 * A utility method for quickly creating a texture atlas with
 * the contents of an atlas definition file on the hard drive.
 *
 * @return An autoreleased PXTextureAtlas object.
 */

+ (PXTextureAtlas *)textureAtlasWithContentsOfFile:(NSString *)path modifier:(id<PXTextureModifier>)modifier
{
	return [[[PXTextureAtlas alloc] initWithContentsOfFile:path modifier:modifier] autorelease];
}

@end
