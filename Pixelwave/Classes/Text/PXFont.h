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

@class PXFontRenderer;
@class PXFontOptions;

// Using 72 pixels per inch to match system fonts, even though the original
// iPhone was 163 ppi, and the iPhone4 is 326 ppi.  This is OK because it's how
// system fonts are handled too.
#define _PX_FONT_PIXELS_PER_INCH 72

@interface PXFont : NSObject
{
}

//-- ScriptName: Font
- (id) initWithData:(NSData *)data options:(PXFontOptions *)options;
//-- ScriptName: FontWithSystemFont
- (id) initWithSystemFont:(NSString *)systemFont options:(PXFontOptions *)options;

#pragma mark Registering

//-- ScriptName: registerFont
+ (PXFont *)registerFont:(PXFont *)font withName:(NSString *)name;

//-- ScriptName: registerFontWithContentsOfFile
+ (PXFont *)registerFontWithContentsOfFile:(NSString *)path
									  name:(NSString *)name
								   options:(PXFontOptions *)options;
//-- ScriptName: registerFontWithContentsOfURL
+ (PXFont *)registerFontWithContentsOfURL:(NSURL *)url
									 name:(NSString *)name
								  options:(PXFontOptions *)options;
//-- ScriptName: registerFontWithData
+ (PXFont *)registerFontWithData:(NSData *)data
							name:(NSString *)name
						 options:(PXFontOptions *)options;
//-- ScriptIgnore
+ (PXFont *)registerFontWithSystemFont:(NSString *)systemFont
							   options:(PXFontOptions *)options;
//-- ScriptName: registerFontWithSytstemFont
+ (PXFont *)registerFontWithSystemFont:(NSString *)systemFont
								  name:(NSString *)name
							   options:(PXFontOptions *)options;

#pragma mark Un-registering

//-- ScriptName: unregisterFont
+ (void) unregisterFontWithName:(NSString *)name;
//-- ScriptName: unregisterAllFonts
+ (void) unregisterAllFonts;

#pragma mark Getting

//-- ScriptName: getFont
+ (PXFont *)fontWithName:(NSString *)name;

#pragma mark Checking

//-- ScriptName: containsFont
+ (BOOL) containsFontWithName:(NSString *)name;

+ (NSArray *)availableSystemFonts;
+ (BOOL) isSystemFontAvailable:(NSString *)name;

#pragma mark Creating

//-- ScriptName: makeWithContentsOfFile
+ (PXFont *)fontWithContentsOfFile:(NSString *)path options:(PXFontOptions *)options;
//-- ScriptName: makeWithContentsOfURL
+ (PXFont *)fontWithContentsOfURL:(NSURL *)url options:(PXFontOptions *)options;
//-- ScriptName: makeWithData
+ (PXFont *)fontWithData:(NSData *)data options:(PXFontOptions *)options;
//-- ScriptName: makeWithSystemFont
+ (PXFont *)fontWithSystemFont:(NSString *)systemFontName options:(PXFontOptions *)options;
@end

@interface PXFont(PrivateButPublic)
- (PXFontRenderer *)_newFontRenderer;
@end
