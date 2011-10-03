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

@class PXAtlasFrame;
@class PXTexture;
@class PXClipRect;
@class PXTextureData;

@protocol PXTextureModifier;

//
//                    +NMMMMMMMMMMN~       
//                  :MMMMMMMMMMMMMMM8,     
//                 8MMMMMMMMMMMMMMMMMM     
//                ~MMMMMMMMMMMMMMMMMMMM~   
//               $MMMMMMMMMMMMMMMMMMMMMM   
//              ZMMMMMMMMMMMMMMMMMMMMMMM~  
//            :MMMMMMMMMMMMMMMMMMMMMMMMMI  
//            $MMMMMMMMMMMMMMMMMMMMMMMMMZ  
//            :MMMMMMMMMMMMMMMMMMMMMMMMM=  
//            OMMOMMMMMMMMMMMMMMMMMMMMMM   
//            MMN NMMMMMMMMMMMMMMMMMMMMM?  
//          :MMM$  MMMMMMMMMMMMMMMMMMMZI?  
//          MMMM:   =MMMMMMMMMMMMMMMMMMD   
//         ~MMMD      ZMMMMMMMMMMMMI,NM:   
//         OMMMM          MNMMMMI    IMN   
//         DMMMMM         $MMMMMM~   ,MM,  
//          MMMMMMM$=     MMMMMMMM8   MMM~ 
//           8MMMMMMMM+  IMMMMMMMMZ   MMMD 
//            DMMMMMMMMMMMMMMMMMM$    NMMM?
//             ,DMMMMMMMMMMMMMMMM     MMMMO
//              ,MMMMMMMMMMMOZM+?8NMMMMMMN~
//              +MMMMMMMMMMMMMMMMMMMMMMM   
//              8MMMMMMMMMMMMMMMMMMMMO     
//             ~MMMMMMMMMMMMMMMMD$=        
//             +MMMMMMMMMMMMMN=            
//             ZMMMMMMMMMMMM~              
//            ~MMMMMMMMMMMM                
//            MMMMMMMMMMMZ                 
//          OMMMMMMMMMMM,                  
//         8MMMMMMMMMMMMMMMMMMMMMMMMD=     
//        MMMMMMMMMMMMMMMMMMMMMMMMMMMM     
//        OMMMMMMMMMMMMMMMMMMMMMMMMMMM     
//        =MMMMMMMMMMMMMMMMMMMMMMMMMM$     
//          MMMMMMMMMMMMMMM= 8MMMMMD       
//           MMMMMMMMMI     ?MMMMMM        
//            MMMMMMMMM+    OMMMM          
//  M      ,MMMMDMMMMMMM    NMMD,          
// MMMMMMMMMMMMMMMMMMMMM  OMMMM            
// MMMMNMMMMMMMMMMMMMMMM ,MMMMMD+          
// MM8     ,M8MMMMMMMMMZ IMMMMMMMM8+       
// MMMN           MMMM    ,    ?$=:        
// ?DNZ                                    

@interface PXTextureAtlas : NSObject
{
@private
	NSMutableDictionary *frames;
}

/**
 * A list of all the PXTextureData objects associated
 * with the texture atlas. The list is a collection of all
 * the unique texture datas references within the frames
 * of the texture atlas.
 */
@property (nonatomic, readonly) NSArray *textureDatas;
/**
 * A list of the names (NSString objects) of all the frames within the
 * texture atlas.
 */
@property (nonatomic, readonly) NSArray *allNames;
/**
 * A list of all the frames (PXTextureAtlas objects) within the texture atlas.
 */
@property (nonatomic, readonly) NSArray *allFrames;

- (id) initWithContentsOfFile:(NSString *)path;
- (id) initWithContentsOfFile:(NSString *)path modifier:(id<PXTextureModifier>)modifier;
- (id) initWithData:(NSData *)data;
- (id) initWithData:(NSData *)data modifier:(id<PXTextureModifier>)modifier;

- (void) addFrame:(PXAtlasFrame *)frame withName:(NSString *)name;
- (void) removeFrame:(NSString *)name;

- (PXAtlasFrame *)frameWithName:(NSString *)name;

/////////////
// Utility //
/////////////

// Adding
- (PXAtlasFrame *)addFrameWithName:(NSString *)name
						  clipRect:(PXClipRect *)clipRect
					   textureData:(PXTextureData *)textureData;

- (PXAtlasFrame *)addFrameWithName:(NSString *)name
						  clipRect:(PXClipRect *)clipRect
					   textureData:(PXTextureData *)textureData
						   anchorX:(float)anchorX
						   anchorY:(float)anchorY;

// Reading
- (PXTexture *)textureForFrame:(NSString *)name;
- (void) setFrame:(NSString *)name toTexture:(PXTexture *)texture;

// Creation methods
+ (PXTextureAtlas *)textureAtlas;
+ (PXTextureAtlas *)textureAtlasWithContentsOfFile:(NSString *)path modifier:(id<PXTextureModifier>)modifier;
@end

@class PXRegexPattern;

@interface PXTextureAtlas (Utils)
- (NSArray *)framesWithNames:(NSArray *)names;
- (NSArray *)framesWithPattern:(PXRegexPattern *)pattern;
- (NSArray *)sequentialFramesWithPrefix:(NSString *)prefix suffix:(NSString *)suffix;
- (NSArray *)sequentialFramesWithPrefix:(NSString *)prefix suffix:(NSString *)suffix inRange:(NSRange)range;
// TODO: Add a [sequentialFramesWithPattern:range:] which will sort the list with all the groups in the pattern.
@end
