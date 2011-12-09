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

#include <CoreGraphics/CGGeometry.h>

#include "PXGraphicsTypes.h"

@class PXTextureData;
@class PXMatrix;

@interface PXGraphics : NSObject
{
@protected
	unsigned int vertexCount;
	void *vCanvas;

	bool wasBuilt;

	CGSize previousSize;
}

@property (nonatomic, readonly) unsigned int vertexCount;

- (void) beginFill:(unsigned int)color alpha:(float)alpha;
- (void) beginFillWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix repeat:(BOOL)repeat smooth:(BOOL)smooth;

// Colors must be of type 'NSNumber' that are unsigned integers
// Alphas must be of type 'NSNumber' that are floats
// Ratios must be of type 'NSNumber' that are floats
- (void) beginFillWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio;

- (void) endFill;

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color alpha:(float)alpha pixelHinting:(BOOL)pixelHinting scaleMode:(PXLineScaleMode)scaleMode caps:(PXCapsStyle)caps joints:(PXJointStyle)joints miterLimit:(float)miterLimit;
- (void) lineStyleWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix repeat:(BOOL)repeat smooth:(BOOL)smooth;
// Colors must be of type 'NSNumber' that are unsigned integers
// Alphas must be of type 'NSNumber' that are floats
// Ratios must be of type 'NSNumber' that are floats
- (void) lineStyleWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio;

- (void) moveToX:(float)x y:(float)y;
- (void) lineToX:(float)x y:(float)y;
- (void) curveToControlX:(float)controlX controlY:(float)controlY anchorX:(float)anchorX anchorY:(float)anchorY;

// Need to be of type PXGraphicsData
- (void) drawGraphicsData:(NSArray *)graphicsData;

// The commands describe how to read the data
- (void) drawPathWithCommands:(PXPathCommand *)commands count:(unsigned int)count data:(float *)data;
- (void) drawPathWithCommands:(PXPathCommand *)commands count:(unsigned int)count data:(float *)data winding:(PXPathWinding)winding;

- (void) clear;

- (void) drawRectWithX:(float)x y:(float)y width:(float)width height:(float)height;
- (void) drawRoundRectWithX:(float)x y:(float)y width:(float)width height:(float)height ellipseWidth:(float)ellipseWidth;
- (void) drawRoundRectWithX:(float)x y:(float)y width:(float)width height:(float)height ellipseWidth:(float)ellipseWidth ellipseHeight:(float)ellipseHeight;
- (void) drawCircleWithX:(float)x y:(float)y radius:(float)radius;
- (void) drawEllipseWithX:(float)x y:(float)y width:(float)width height:(float)height;

@end

@interface PXGraphics(PrivateButPublic)
- (void) _setWinding:(PXPathWinding)winding;

- (void) _measureLocalBounds:(CGRect *)retBounds;
- (void) _measureLocalBounds:(CGRect *)retBounds useStroke:(BOOL)useStroke;
- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y;
- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag;
- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag useStroke:(BOOL)useStroke;

- (void) _renderGL;
@end
