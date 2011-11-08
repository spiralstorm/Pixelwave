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

#import "PXGraphics.h"

@implementation PXGraphics

- (id) init
{
	self = [super init];

	if (self)
	{
		//vGraphicsUtil = 
	}

	return self;
}

- (void) dealloc
{
	// TODO: Free vGraphicsUtil properly

	[super dealloc];
}
#pragma mark -
#pragma mark Fill
#pragma mark -

- (void) beginFill:(unsigned int)color
{
	[self beginFill:color alpha:1.0f];
}

- (void) beginFill:(unsigned int)color alpha:(float)alpha
{
	// TODO: Implement
}

- (void) beginFillWithTextureData:(PXTextureData *)textureData
{
	[self beginFillWithTextureData:textureData matrix:nil];
}

- (void) beginFillWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix
{
	[self beginFillWithTextureData:textureData matrix:matrix repeat:YES];
}

- (void) beginFillWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix repeat:(BOOL)repeat
{
	[self beginFillWithTextureData:textureData matrix:matrix repeat:repeat smooth:NO];
}

- (void) beginFillWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix repeat:(BOOL)repeat smooth:(BOOL)smooth
{
	// TODO: Implement
}

- (void) beginFillWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios
{
	[self beginFillWithGradientType:type colors:colors alphas:alphas ratios:ratios matrix:nil];
}

- (void) beginFillWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix
{
	[self beginFillWithGradientType:type colors:colors alphas:alphas ratios:ratios matrix:matrix spreadMethod:PXSpreadMethod_Pad];
}

- (void) beginFillWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod
{
	[self beginFillWithGradientType:type colors:colors alphas:alphas ratios:ratios matrix:matrix spreadMethod:spreadMethod interpolationMethod:PXInterpolationMethod_RGB];
}

- (void) beginFillWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod
{
	[self beginFillWithGradientType:type colors:colors alphas:alphas ratios:ratios matrix:matrix spreadMethod:spreadMethod interpolationMethod:interpolationMethod focalPointRatio:0.0f];
}

- (void) beginFillWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio
{
	// TODO: Implement
}

- (void) endFill
{
	// TODO: Implement
}

#pragma mark -
#pragma mark Lines
#pragma mark -

- (void) lineStyle
{
	[self lineStyleWithThickness:NAN];
}

- (void) lineStyleWithThickness:(float)thickness
{
	[self lineStyleWithThickness:thickness color:0x000000];
}

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color
{
	[self lineStyleWithThickness:thickness color:color alpha:1.0f];
}

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color alpha:(float)alpha
{
	[self lineStyleWithThickness:thickness color:color alpha:alpha pixelHinting:NO];
}

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color alpha:(float)alpha pixelHinting:(BOOL)pixelHinting
{
	[self lineStyleWithThickness:thickness color:color alpha:alpha pixelHinting:pixelHinting scaleMode:PXLineScaleMode_Normal];
}

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color alpha:(float)alpha pixelHinting:(BOOL)pixelHinting scaleMode:(PXLineScaleMode)scaleMode
{
	[self lineStyleWithThickness:thickness color:color alpha:alpha pixelHinting:pixelHinting scaleMode:scaleMode caps:PXCapsStyle_None];
}

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color alpha:(float)alpha pixelHinting:(BOOL)pixelHinting scaleMode:(PXLineScaleMode)scaleMode caps:(PXCapsStyle)caps
{
	[self lineStyleWithThickness:thickness color:color alpha:alpha pixelHinting:pixelHinting scaleMode:scaleMode caps:caps joints:PXJointStyle_Round];
}

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color alpha:(float)alpha pixelHinting:(BOOL)pixelHinting scaleMode:(PXLineScaleMode)scaleMode caps:(PXCapsStyle)caps joints:(PXJointStyle)joints
{
	[self lineStyleWithThickness:thickness color:color alpha:alpha pixelHinting:pixelHinting scaleMode:scaleMode caps:caps joints:joints miterLimit:3.0f];
}

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color alpha:(float)alpha pixelHinting:(BOOL)pixelHinting scaleMode:(PXLineScaleMode)scaleMode caps:(PXCapsStyle)caps joints:(PXJointStyle)joints miterLimit:(float)miterLimit
{
	// TODO: Implement
}

- (void) lineStyleWithTextureData:(PXTextureData *)textureData
{
	[self lineStyleWithTextureData:textureData matrix:nil];
}

- (void) lineStyleWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix
{
	[self lineStyleWithTextureData:textureData matrix:nil repeat:YES];
}

- (void) lineStyleWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix repeat:(BOOL)repeat
{
	[self lineStyleWithTextureData:textureData matrix:nil repeat:repeat smooth:NO];
}

- (void) lineStyleWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)matrix repeat:(BOOL)repeat smooth:(BOOL)smooth
{
	// TODO: Implemenet
}

- (void) lineStyleWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios
{
	[self lineStyleWithGradientType:type colors:colors alphas:alphas ratios:ratios matrix:nil];
}

- (void) lineStyleWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix
{
	[self lineStyleWithGradientType:type colors:colors alphas:alphas ratios:ratios matrix:matrix spreadMethod:PXSpreadPad];
}

- (void) lineStyleWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod
{
	[self lineStyleWithGradientType:type colors:colors alphas:alphas ratios:ratios matrix:matrix spreadMethod:spreadMethod interpolationMethod:PXInterpolationMethod_RGB];
}

- (void) lineStyleWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod
{
	[self lineStyleWithGradientType:type colors:colors alphas:alphas ratios:ratios matrix:matrix spreadMethod:spreadMethod interpolationMethod:interpolationMethod focalPointRatio:0.0f];
}

- (void) lineStyleWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio
{
	// TODO: Implement
}

#pragma mark -
#pragma mark Draw
#pragma mark -

- (void) moveToX:(float)x y:(float)y
{
	// TODO: Implement
}

- (void) lineToX:(float)x y:(float)y
{
	// TODO: Implement
}

- (void) curveToControlX:(float)controlX controlY:(float)controlY anchorX:(float)anchorX anchorY:(float)anchorY
{
	// TODO: Implement
}

// Need to be of type PXGraphicsData
- (void) drawGraphicsData:(NSArray *)graphicsData
{
	// TODO: Implement
}

- (void) drawPathWithCommands:(PXPathCommand *)commands count:(unsigned int)count data:(float *)data
{
	[self drawPathWithCommands:commands count:count data:data winding:PXGraphicsPathWinding_EvenOdd];
}

- (void) drawPathWithCommands:(PXPathCommand *)commands count:(unsigned int)count data:(float *)data winding:(PXGraphicsPathWinding)winding
{
	// TODO: Implement
}

- (void) clear
{
	// TODO: Implement
}

#pragma mark -
#pragma mark Utility
#pragma mark -

- (void) drawRectWithX:(float)x y:(float)y width:(float)width height:(float)height
{
	// TODO: Implement
}

- (void) drawRoundRectWithX:(float)x y:(float)y width:(float)width height:(float)height ellipseWidth:(float)ellipseWidth
{
	return [self drawRoundRectWithX:x y:y width:width height:height ellipseWidth:ellipseWidth ellipseHeight:NAN];
}

- (void) drawRoundRectWithX:(float)x y:(float)y width:(float)width height:(float)height ellipseWidth:(float)ellipseWidth ellipseHeight:(float)ellipseHeight
{
	// TODO: Implement
}

- (void) drawCircleWithX:(float)x y:(float)y radius:(float)radius
{
	// TODO: Implement
}

- (void) drawEllipseWithX:(float)x y:(float)y width:(float)width height:(float)height
{
	// TODO: Implement
}

#pragma mark -
#pragma mark Override
#pragma mark -

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	// TODO: Implement
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y
{
	// TODO: Implement
	return NO;
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	// TODO: Implement
	return NO;
}

- (void) _renderGL
{
	// TODO: Implement
}

@end
