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

@class PXLinkedList;

/**
 * The protocol required to make a new parser.
 */
@protocol PXParser<NSObject>
@required
+ (BOOL) isApplicableForData:(NSData *)data origin:(NSString *)origin;
+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions;
@end

@interface PXParser : NSObject
{
@protected
	NSData *data;
	NSString *origin;
}

/**
 * The loaded data.
 */
@property (nonatomic, readonly) NSData *data;
/**
 * The origin of the loaded data. This is only available when one is provided
 * from the start.
 */
@property (nonatomic, readonly) NSString *origin;

// Registration
+ (void) registerParser:(Class)parser forBaseClass:(Class)baseClass;

// Unregistration
+ (void) unregisterParser:(Class)parser forBaseClass:(Class)baseClass;
+ (void) unregisterAllParsersForBaseClass:(Class)baseClass;
+ (void) unregisterAllParsers;

// Getting
+ (PXLinkedList *)parsersForBaseClass:(Class)baseClass;
+ (Class) parserForData:(NSData *)data
				 origin:(NSString *)origin
			  baseClass:(Class)baseClass;

+ (NSArray *)supportedFileExtensions;

@end

@interface PXParser(PrivateButPublic)
- (id) _initWithData:(NSData *)data origin:(NSString *)origin;

- (void) _log:(NSString *)message;
@end

@interface PXParser(Override)
- (BOOL) _initialize;
- (BOOL) _parse;
@end
