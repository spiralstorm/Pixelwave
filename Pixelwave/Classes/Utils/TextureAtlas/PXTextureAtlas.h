/*
 *  _____                       ___                                            
 * /\  _ `\  __                /\_ \                                           
 * \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
 *  \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
 *   \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
 *    \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
 *     \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
 *       
 *       www.pixelwave.org + www.spiralstormgames.com
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
 * Copyright (c) 2010 Spiralstorm Games http://www.spiralstormgames.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

//
//  PXTextureAtlas.h
//  TextureAtlas
//
//  Created by Oz Michaeli on 9/21/10.
//  Copyright 2010 Spiralstorm Games. All rights reserved.
//

@class PXAtlasFrame;
@class PXTexture;

@interface PXTextureAtlas : NSObject
{
@private
	NSMutableDictionary *frames;
}

@property (nonatomic, readonly) NSArray *textureDatas;
@property (nonatomic, readonly) NSArray *allNames;
@property (nonatomic, readonly) NSArray *allFrames;

- (void) addFrame:(PXAtlasFrame *)frame named:(NSString *)name;
- (void) removeFrame:(NSString *)name;

- (PXAtlasFrame *)frameNamed:(NSString *)name;

/////////////
// Utility //
/////////////

// Adding
- (PXAtlasFrame *)addFrameNamed:(NSString *)name
					   clipRect:(PXClipRect *)clipRect
					textureData:(PXTextureData *)textureData;

- (PXAtlasFrame *)addFrameNamed:(NSString *)name
					   clipRect:(PXClipRect *)clipRect
					textureData:(PXTextureData *)textureData
						anchorX:(float)anchorX
						anchorY:(float)anchorY;

// Reading
- (PXTexture *)textureForFrame:(NSString *)name;
- (void) setFrame:(NSString *)name toTexture:(PXTexture *)texture;

// Creation methods
+ (PXTextureAtlas *)textureAtlas;
@end