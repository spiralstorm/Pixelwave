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

#import "PXPooledObject.h"

@class PXPoint;

// TODO: Change to PXRectangle...
#define PXRectToCGRect(_rect_) CGRectMake ((_rect_).x, (_rect_).y, (_rect_).width, (_rect_).height)
#define PXRectFromCGRect(_rect_) [PXRectangle rectangleWithX:(_rect_).origin.x y:(_rect_).origin.y width:(_rect_).size.width height:(_rect_).size.height]

@interface PXRectangle : NSObject <NSCopying, PXPooledObject>
{
/// @cond DX_IGNORE
@private
	float x, y, width, height;
/// @endcond
}

/**
 *	The <code>topLeft</code> corner's horizontal coordinate.
 */
@property (nonatomic, assign) float x;
/**
 *	The <code>topLeft</code> corner's vertical coordinate.
 */
@property (nonatomic, assign) float y;
/**
 *	The width in pixels.
 */
@property (nonatomic, assign) float width;
/**
 *	The height in pixels.
 */
@property (nonatomic, assign) float height;

/**
 *	The <code>topLeft</code> corner's vertical coordinate.
 */
@property (nonatomic, assign) float top;
/**
 *	The <code>bottomRight</code> corner's vertical coordinate.
 */
@property (nonatomic, assign) float bottom;
/**
 *	The <code>left</code> corner's horizontal coordinate.
 */
@property (nonatomic, assign) float left;
/**
 *	The <code>right</code> corner's horizontal coordinate.
 */
@property (nonatomic, assign) float right;

/**
 *	A point with the values of the <code>width</code> and <code>height</code>
 *	properties.
 */
@property (nonatomic, assign) PXPoint *size;
/**
 *	A point with the values of the rectangle's bottom-right corner cordinates.
 */
@property (nonatomic, assign) PXPoint *bottomRight;
/**
 *	A point with the values of the rectangle's top-left corner cordinates.
 */
@property (nonatomic, assign) PXPoint *topLeft;

//-- ScriptName: Rectangle
//-- ScriptArg[0]: 0.0f
//-- ScriptArg[1]: 0.0f
//-- ScriptArg[2]: 0.0f
//-- ScriptArg[3]: 0.0f
- (id) initWithX:(float)x y:(float)y width:(float)width height:(float)height;

//-- ScriptName: set
//-- ScriptArg[0]: 0.0f
//-- ScriptArg[1]: 0.0f
//-- ScriptArg[2]: 0.0f
//-- ScriptArg[3]: 0.0f
- (void) setX:(float)x y:(float)y width:(float)width height:(float)height;

//-- ScriptName: contains
- (BOOL) containsX:(float)x y:(float)y;
//-- ScriptName: containsPoint
- (BOOL) containsPoint:(PXPoint *)point;
//-- ScriptName: containsRect
- (BOOL) containsRect:(PXRectangle *)rect;
//-- ScriptName: equals
- (BOOL) isEqualToRect:(PXRectangle *)rect;
//-- ScriptName: isEmpty
- (BOOL) isEmpty;

//-- ScriptName: inflate
- (void) inflateWithX:(float)dx y:(float)dy;
//-- ScriptName: inflatePoint
- (void) inflateWithPoint:(PXPoint *)point;

//-- ScriptName: intersection
- (PXRectangle *)intersectionWithRect:(PXRectangle *)toIntersect;

//-- ScriptName: intersects
- (BOOL) intersectsWithRect:(PXRectangle *)toIntersect;

//-- ScriptName: offset
- (void) offsetWithX:(float)dx y:(float)dy;
//-- ScriptName: offsetPoint
- (void) offsetWithPoint:(PXPoint *)point;
//-- ScriptName: setEmpty
- (void) setEmpty;

//-- ScriptName: union
- (PXRectangle *)unionWithRect:(PXRectangle *)rect;

//-- ScriptName: make
//-- ScriptArg[0]: 0.0f
//-- ScriptArg[1]: 0.0f
//-- ScriptArg[2]: 0.0f
//-- ScriptArg[3]: 0.0f
+ (PXRectangle *)rectangleWithX:(float)x y:(float)y width:(float)width height:(float)height;

@end
