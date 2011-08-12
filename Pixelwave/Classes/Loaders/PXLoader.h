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

typedef enum
{
	PXLoaderOriginType_File = 0,
	PXLoaderOriginType_URL
} PXLoaderOriginType;

@interface PXLoader : NSObject
{
@protected
	NSData *data;

	PXLoaderOriginType originType;
	NSString *origin;
}

/**
 * The origin type either `PXLoaderOriginType_File` or
 * `PXLoaderOriginType_URL`
 */
@property (nonatomic, readonly) PXLoaderOriginType originType;
/**
 * The origin of the loaded data.
 */
@property (nonatomic, readonly) NSString *origin;
/**
 * The loaded data.
 */
@property (nonatomic, readonly) NSData *data;

- (id) initWithContentsOfFile:(NSString *)path;
- (id) initWithContentsOfURL:(NSURL *)url;

// Utility methods
+ (NSString *)absolutePathFromPath:(NSString *)path;
+ (BOOL) fileExistsAtPath:(NSString *)path;
+ (NSString *)pathForSiblingOfFile:(NSString *)path withName:(NSString *)fileName;
+ (NSString *)pathForSiblingOfFile:(NSString *)path withExtension:(NSString *)extension;
+ (NSString *)pathForRetinaVersionOfFile:(NSString *)path retScale:(float *)outScale;
+ (NSString *)findFileAtPath:(NSString *)basePath withBaseName:(NSString *)baseName validExtensions:(NSArray *)extensions;

@end

@interface PXLoader(Protected)
- (id) _initWithContentsOfFile:(NSString *)path orURL:(NSURL *)url;

- (BOOL) _load;
- (void) _setOrigin:(NSString *)origin;
- (void) _log:(NSString *)message;
@end
