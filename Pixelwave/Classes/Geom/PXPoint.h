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

#define PXPointToCGPoint(_point_) CGPointMake ((_point_).x, (_point_).y)
#define PXPointFromCGPoint(_point_) [PXPoint pointWithX:(_point_).x andY:(_point_).y]

@interface PXPoint : NSObject <NSCopying, PXPooledObject>
{
/// @cond DX_IGNORE
@private
	float x, y;
/// @endcond
}

/**
 *	The horizontal coordinate.
 */
@property (nonatomic, assign) float x;
/**
 *	The vertical coordinate.
 */
@property (nonatomic, assign) float y;
/**
 *	The length of the line segment from (0, 0) to this point.
 */
@property (nonatomic, readonly) float length;

//-- ScriptName: Point
//-- ScriptArg[0]: 0.0f
//-- ScriptArg[1]: 0.0f
- (id) initWithX:(float)x andY:(float)y;

//-- ScriptName: set
//-- ScriptArg[0]: 0.0f
//-- ScriptArg[1]: 0.0f
- (void) setX:(float)x andY:(float)y;

// Flash methods
//-- ScriptName: add
- (PXPoint *)addPoint:(PXPoint *)point;
//-- ScriptName: subtract
- (PXPoint *)subtractPoint:(PXPoint *)point;

//-- ScriptName: isEqual
- (BOOL) isEqualToPoint:(PXPoint *)point;
//-- ScriptIgnore
- (void) normalize;
//-- ScriptName: normalize
//-- ScriptArg[0]: 1.0f
- (void) normalizeWithLength:(float)length;
//-- ScriptName: offset
- (void) offsetWithX:(float)dx andY:(float)dy;

//-- ScriptName: distance
+ (float) distanceBetweenPoint:(PXPoint *)pt1 andPoint:(PXPoint *)pt2;
//-- ScriptName: angleBetween
+ (float) angleBetweenPoint:(PXPoint *)pt1 andPoint:(PXPoint *)pt2;

//-- ScriptName: interpolate
+ (PXPoint *)pointByInterpolatingBetweenPoint:(PXPoint *)pt1 andPoint:(PXPoint *)pt2 withCoefficientOfInterpolation:(float)f;
//-- ScriptName: polar
+ (PXPoint *)pointUsingPolarCoordWithLen:(float)len andAngle:(float)angle;
//-- ScriptName: make
//-- ScriptArg[0]: 0.0f
//-- ScriptArg[1]: 0.0f
+ (PXPoint *)pointWithX:(float)x andY:(float)y;

@end
