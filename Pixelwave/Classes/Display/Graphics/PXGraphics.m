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

#import "PXTextureData.h"
#import "PXMatrix.h"

#include "PXDebug.h"

#include "inkVectorGraphics.h"
#include "inkVectorGraphicsUtils.h"

static inline inkMatrix PXGraphicsMakeMatrixFromPXMatrix(PXMatrix *matrix)
{
	if (matrix == nil)
	{
		return inkMatrixIdentity;
	}

	return inkMatrixMake(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
}

static inline inkGradientFill PXGraphicsGradientInfoMake(PXGradientType type, NSArray *colors, NSArray *alphas, NSArray *ratios, PXMatrix *matrix, PXSpreadMethod spreadMethod, PXInterpolationMethod interpolationMethod, float focalPointRatio)
{
	inkGradientFill info;

	memset(&info, 0, sizeof(inkGradientFill));

	// TODO: implement

	/*unsigned int colorCount = [colors count];
	unsigned int alphaCount = [alphas count];

	if (colorCount != alphaCount)
	{
		PXDebugLog(@"PXGraphics Error: There must be equal quantity of colors and alphas.");

		return info;
	}

	if (colorCount != 0)
	{
		info.colors = alloca(sizeof(unsigned int) * info.colorCount);
		info.alphas = alloca(sizeof(float) * info.colorCount);

		unsigned int *curColor = info.colors;
		float *curAlpha = info.alphas;

		for (NSNumber *color in colors)
		{
			*curColor = [color unsignedIntegerValue];
			++curColor;
		}

		for (NSNumber *alpha in alphas)
		{
			*curAlpha = [alpha floatValue];
			++curAlpha;
		}
	}

	info.ratioCount = [ratios count];

	if (info.ratioCount != 0)
	{
		info.ratios = alloca(sizeof(float) * info.ratioCount);

		float *curRatio = info.ratios;

		for (NSNumber *ratio in ratios)
		{
			*curRatio = [ratio floatValue];
			++curRatio;
		}
	}*/

	return info;
}

@implementation PXGraphics

- (id) init
{
	self = [super init];

	if (self)
	{
		vGraphicsUtil = inkCreate();

		if (vGraphicsUtil == nil)
		{
			[self release];
			return nil;
		}
	}

	return self;
}

- (void) dealloc
{
	inkDestroy(vGraphicsUtil);

	[super dealloc];
}

#pragma mark -
#pragma mark Fill
#pragma mark -

- (void) beginFill:(unsigned int)color alpha:(float)alpha
{
	inkBeginFill(vGraphicsUtil, inkSolidFillMake(color, alpha));
}

- (void) beginFillWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)pxMatrix repeat:(BOOL)repeat smooth:(BOOL)smooth
{
	if (textureData == nil)
		return;

	inkMatrix matrix = PXGraphicsMakeMatrixFromPXMatrix(pxMatrix);
	inkBitmapFill fill = inkBitmapFillMake(matrix, inkBitmapInfoMake(textureData.glTextureName, textureData.glTextureWidth, textureData.glTextureHeight), repeat, smooth);

	inkBeginBitmapFill(vGraphicsUtil, fill);
}

- (void) beginFillWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio
{
	inkGradientFill gradientInfo = PXGraphicsGradientInfoMake(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

	inkBeginGradientFill(vGraphicsUtil, gradientInfo);
}

- (void) endFill
{
	inkEndFill(vGraphicsUtil);
}

#pragma mark -
#pragma mark Lines
#pragma mark -

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color alpha:(float)alpha pixelHinting:(BOOL)pixelHinting scaleMode:(PXLineScaleMode)scaleMode caps:(PXCapsStyle)caps joints:(PXJointStyle)joints miterLimit:(float)miterLimit
{
	inkStroke stroke = inkStrokeMake(thickness, pixelHinting, scaleMode, caps, joints, miterLimit);
	inkSolidFill solidFill = inkSolidFillMake(color, alpha);

	inkLineStyle(vGraphicsUtil, stroke, solidFill);
}

- (void) lineStyleWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)pxMatrix repeat:(BOOL)repeat smooth:(BOOL)smooth
{
	if (textureData == nil)
		return;

	inkMatrix matrix = PXGraphicsMakeMatrixFromPXMatrix(pxMatrix);
	inkBitmapFill fill = inkBitmapFillMake(matrix, inkBitmapInfoMake(textureData.glTextureName, textureData.glTextureWidth, textureData.glTextureHeight), repeat, smooth);

	inkBeginBitmapFill(vGraphicsUtil, fill);
}

- (void) lineStyleWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio
{
	inkGradientFill gradientInfo = PXGraphicsGradientInfoMake(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

	inkLineGradientStyle(vGraphicsUtil, gradientInfo);
}

#pragma mark -
#pragma mark Draw
#pragma mark -

- (void) moveToX:(float)x y:(float)y
{
	inkMoveTo(vGraphicsUtil, inkPointMake(x, y));
}

- (void) lineToX:(float)x y:(float)y
{
	inkLineTo(vGraphicsUtil, inkPointMake(x, y));
}

- (void) curveToControlX:(float)controlX controlY:(float)controlY anchorX:(float)anchorX anchorY:(float)anchorY
{
	inkCurveTo(vGraphicsUtil, inkPointMake(controlX, controlY), inkPointMake(anchorX, anchorY));
}

// Need to be of type PXGraphicsData
- (void) drawGraphicsData:(NSArray *)graphicsData
{
	// TODO: Implement
}

- (void) drawPathWithCommands:(PXPathCommand *)commands count:(unsigned int)count data:(float *)data
{
	[self drawPathWithCommands:commands count:count data:data winding:inkPathWinding_EvenOdd];
}

- (void) drawPathWithCommands:(PXPathCommand *)commands count:(unsigned int)count data:(float *)data winding:(PXGraphicsPathWinding)winding
{
	// TODO: Implement
}

- (void) clear
{
	inkClear(vGraphicsUtil);
}

#pragma mark -
#pragma mark Utility
#pragma mark -

- (void) drawRectWithX:(float)x y:(float)y width:(float)width height:(float)height
{
	inkUtilsDrawRect(vGraphicsUtil, inkRectMakev(x, y, width, height));
}

- (void) drawRoundRectWithX:(float)x y:(float)y width:(float)width height:(float)height ellipseWidth:(float)ellipseWidth
{
	return [self drawRoundRectWithX:x y:y width:width height:height ellipseWidth:ellipseWidth ellipseHeight:NAN];
}

- (void) drawRoundRectWithX:(float)x y:(float)y width:(float)width height:(float)height ellipseWidth:(float)ellipseWidth ellipseHeight:(float)ellipseHeight
{
	inkUtilsDrawRoundRect(vGraphicsUtil, inkRectMakev(x, y, width, height), inkSizeMake(ellipseWidth, ellipseHeight));
}

- (void) drawCircleWithX:(float)x y:(float)y radius:(float)radius
{
	inkUtilsDrawCircle(vGraphicsUtil, inkPointMake(x, y), radius);
}

- (void) drawEllipseWithX:(float)x y:(float)y width:(float)width height:(float)height
{
	inkUtilsDrawEllipse(vGraphicsUtil, inkRectMakev(x, y, width, height));
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
