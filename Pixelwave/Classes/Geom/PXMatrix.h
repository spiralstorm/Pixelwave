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

// Most stuff taken from: http://www.senocular.com/flash/tutorials/transformmatrix/

@class PXPoint;

@interface PXMatrix : NSObject <NSCopying, PXPooledObject>
{
@private
	float a, b, c, d, tx, ty;
}

/**
 * The value that affects the positioning of pixels along the x-axis when
 * scaling or rotating the matrix.
 */
@property (nonatomic) float a;
/**
 * The value that affects the positioning of pixels along the y-axis when
 * skewing or rotating the matrix.
 */
@property (nonatomic) float b;
/**
 * The value that affects the positioning of pixels along the x-axis when
 * skewing or rotating the matrix.
 */
@property (nonatomic) float c;
/**
 * The value that affects the positioning of pixels along the y-axis when
 * scaling or rotating the matrix.
 */
@property (nonatomic) float d;
/**
 * The value that affects the positioning of pixels along the x-axis when
 * translating the matrix.
 */
@property (nonatomic) float tx;
/**
 * The value that affects the positioning of pixels along the y-axis when
 * translating the matrix.
 */
@property (nonatomic) float ty;

//-- ScriptName: Matrix
//-- ScriptArg[0]: 1.0f
//-- ScriptArg[1]: 0.0f
//-- ScriptArg[2]: 0.0f
//-- ScriptArg[3]: 1.0f
//-- ScriptArg[4]: 0.0f
//-- ScriptArg[5]: 0.0f
- (id) initWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;

//-- ScriptName: set
//-- ScriptArg[0]: 1.0f
//-- ScriptArg[1]: 0.0f
//-- ScriptArg[2]: 0.0f
//-- ScriptArg[3]: 1.0f
//-- ScriptArg[4]: 0.0f
//-- ScriptArg[5]: 0.0f
- (void) setA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;

//-- ScriptName: concat
- (void) concat:(PXMatrix *)m;
//-- ScriptName: identity
- (void) identity;
//-- ScriptName: invert
- (void) invert;
//-- ScriptName: rotate
- (void) rotate:(float)angle;
//-- ScriptName: scale
- (void) scaleX:(float)sx y:(float)sy;
//-- ScriptName: translate
- (void) translateX:(float)dx y:(float)dy;

//-- ScriptName: createBox
- (void) createBoxWithScaleX:(float)scaleX
					  scaleY:(float)scaleY
					rotation:(float)rotation
						  tx:(float)tx
						  ty:(float)ty;

//-- ScriptName: transformPoint
- (PXPoint *)transformPoint:(PXPoint *)point;
//-- ScriptName: deltaTranfsormPoint
- (PXPoint *)deltaTransformPoint:(PXPoint *)point;

//-- ScriptName: make
//-- ScriptArg[0]: 1.0f
//-- ScriptArg[1]: 0.0f
//-- ScriptArg[2]: 0.0f
//-- ScriptArg[3]: 1.0f
//-- ScriptArg[4]: 0.0f
//-- ScriptArg[5]: 0.0f
+ (PXMatrix *)matrixWithA:(float)a b:(float)b c:(float)c d:(float)d tx:(float)tx ty:(float)ty;

//-- ScriptName: MatrixIdentity
+ (PXMatrix *)identityMatrix;

@end
