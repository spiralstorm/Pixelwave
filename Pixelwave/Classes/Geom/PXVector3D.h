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

@interface PXVector3D : NSObject <NSCopying, PXPooledObject>
{
@private
	float w;
	float x;
	float y;
	float z;
}

/**
 *	The length of the line segment from (0, 0, 0) to this point.
 */
@property (nonatomic, readonly) float length;
/**
 *	The squared length of the line segment from (0, 0, 0) to this point.
 */
@property (nonatomic, readonly) float lengthSquared;

/**
 *	The angle of rotation.
 */
@property (nonatomic, assign) float w;
/**
 *	The horizontal coordinate.
 */
@property (nonatomic, assign) float x;
/**
 *	The vertical coordinate.
 */
@property (nonatomic, assign) float y;
/**
 *	The depth coordinate.
 */
@property (nonatomic, assign) float z;

//-- ScriptIgnore
- (id) initWithX:(float)x y:(float)y z:(float)z;
//-- ScriptName: Vector3D
//-- ScriptArg[0]: 0.0f
//-- ScriptArg[1]: 0.0f
//-- ScriptArg[2]: 0.0f
//-- ScriptArg[3]: 0.0f
- (id) initWithX:(float)x y:(float)y z:(float)z w:(float)w;

//-- ScriptIgnore
- (void) setX:(float)x y:(float)y z:(float)z;
//-- ScriptName: set
//-- ScriptArg[0]: 0.0f
//-- ScriptArg[1]: 0.0f
//-- ScriptArg[2]: 0.0f
//-- ScriptArg[3]: 0.0f
- (void) setX:(float)x y:(float)y z:(float)z w:(float)w;

//-- ScriptName: add
- (PXVector3D *)addVector:(PXVector3D *)vector;
//-- ScriptName: subtract
- (PXVector3D *)subtractVector:(PXVector3D *)vector;
//-- ScriptName: crossProduct
- (PXVector3D *)crossProductWithVector:(PXVector3D *)vector;
//-- ScriptName: decrementBy
- (void) decrementByVector:(PXVector3D *)vector;
//-- ScriptName: dotProduct
- (float) dotProductWithVector:(PXVector3D *)vector;
//-- ScriptName: isEqual
- (BOOL) equalsVector:(PXVector3D *)vector useAllFour:(BOOL)allFour;
//-- ScriptName: incrementBy
- (void) incrementByVector:(PXVector3D *)vector;
//-- ScriptName: nearEquals
- (BOOL) nearEqualsVector:(PXVector3D *)vector tolerance:(float)tolerance useAllFour:(BOOL)allFour;
//-- ScriptName: negate
- (void) negate;
//-- ScriptName: normalize
- (float) normalize;
//-- ScriptName: project
- (void) project;
//-- ScriptName: scaleBy
- (void) scaleBy:(float)scalar;

//-- ScriptName: getAngle
+ (float) angleBetweenVectorA:(PXVector3D *)vectorA vectorB:(PXVector3D *)vectorB;
//-- ScriptName: getDistance
+ (float) distanceBetweenVectorA:(PXVector3D *)vectorA vectorB:(PXVector3D *)vectorB;
//-- ScriptName: getDistanceSquared
+ (float) distanceSquaredBetweenVectorA:(PXVector3D *)vectorA vectorB:(PXVector3D *)vectorB;

//-- ScriptIgnore
+ (PXVector3D *)vector3DWithX:(float)x y:(float)y z:(float)z;
//-- ScriptName: make
//-- ScriptArg[0]: 0.0f
//-- ScriptArg[1]: 0.0f
//-- ScriptArg[2]: 0.0f
//-- ScriptArg[3]: 0.0f
+ (PXVector3D *)vector3DWithX:(float)x y:(float)y z:(float)z w:(float)w;

@end
