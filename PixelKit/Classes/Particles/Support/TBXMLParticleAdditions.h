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

#import "TBXML.h"

#import <CoreGraphics/CGGeometry.h>
#import "PKColor.h"

// This is a category that has been added to the TBML class.  Reading specific attributes from a
// particle emitter XML config file is not something the TBXML class should be altered for.  This
// is a perfect opportunity to create a category on top of TBXML that adds specfic features that
// meet our needs when processing the particle config files.
//
// The new methods below grab data from specific attributes that we know will contain the information
// we need in a particle config file and returns values that are specific to our implementation such 
// as Color4f and Vector4f
//
// These changes will only work when processing the particle config files and a further category would
// need to be made to process other types of data if necessary
//
@interface TBXMLParticleAdditions : NSObject

// Returns a int value from the processes element
+ (float) intValue:(TBXML *)tbxml fromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

// Returns a float value from the processes element
+ (float) floatValue:(TBXML *)tbxml fromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

// Returns a bool value from the processes element
+ (BOOL) boolValue:(TBXML *)tbxml fromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

// Returns a vector2f structure from the processes element
+ (CGPoint) point:(TBXML *)tbxml fromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

// Returns a color4f structure from the processes element
+ (PKColor) color:(TBXML *)tbxml fromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

@end
