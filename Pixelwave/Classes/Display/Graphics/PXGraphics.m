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

#include "PXGL.h"

#include "inkVectorGraphics.h"
#include "inkVectorGraphicsUtils.h"

#import "PXGraphicsPath.h"
#import "PXGraphicsData.h"
#import "PXEngine.h"

const inkRenderer pxGraphicsInkRenderer = {PXGLEnable, PXGLDisable, PXGLEnableClientState, PXGLDisableClientState, PXGLGetBooleanv, PXGLGetFloatv, PXGLGetIntegerv, PXGLPointSize, PXGLLineWidth, PXGLBindTexture, PXGLGetTexParameteriv, PXGLTexParameteri, PXGLVertexPointer, PXGLTexCoordPointer, PXGLColorPointer, PXGLDrawArrays, PXGLDrawElements};

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

@interface PXGraphics(Private)
- (BOOL) build;
@end

@implementation PXGraphics

@synthesize vertexCount;

- (id) init
{
	self = [super init];

	if (self)
	{
		vCanvas = inkCreate();

		if (vCanvas == nil)
		{
			[self release];
			return nil;
		}
	}

	wasBuilt = false;
	previousSize = CGSizeMake(1.0f, 1.0f);

	return self;
}

- (void) dealloc
{
	inkDestroy((inkCanvas*)vCanvas);

	[super dealloc];
}

#pragma mark -
#pragma mark Fill
#pragma mark -

- (void) beginFill:(unsigned int)color alpha:(float)alpha
{
	inkBeginFill((inkCanvas*)vCanvas, inkSolidFillMake(color, alpha));
}

- (void) beginFillWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)pxMatrix repeat:(BOOL)repeat smooth:(BOOL)smooth
{
	if (textureData == nil)
		return;

	inkMatrix matrix = PXGraphicsMakeMatrixFromPXMatrix(pxMatrix);
	inkBitmapFill fill = inkBitmapFillMake(matrix, inkBitmapInfoMake(textureData.glTextureName, textureData.glTextureWidth, textureData.glTextureHeight), repeat, smooth);

	inkBeginBitmapFill((inkCanvas*)vCanvas, fill);
}

- (void) beginFillWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio
{
	inkGradientFill gradientInfo = PXGraphicsGradientInfoMake(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

	inkBeginGradientFill((inkCanvas*)vCanvas, gradientInfo);
}

- (void) endFill
{
	inkEndFill((inkCanvas*)vCanvas);
}

#pragma mark -
#pragma mark Lines
#pragma mark -

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color alpha:(float)alpha pixelHinting:(BOOL)pixelHinting scaleMode:(PXLineScaleMode)scaleMode caps:(PXCapsStyle)caps joints:(PXJointStyle)joints miterLimit:(float)miterLimit
{
	inkStroke stroke = inkStrokeMake(thickness, pixelHinting, (inkLineScaleMode)scaleMode, (inkCapsStyle)caps, (inkJointStyle)joints, miterLimit);
	inkSolidFill solidFill = inkSolidFillMake(color, alpha);

	inkLineStyle((inkCanvas*)vCanvas, stroke, solidFill);
}

- (void) lineStyleWithTextureData:(PXTextureData *)textureData matrix:(PXMatrix *)pxMatrix repeat:(BOOL)repeat smooth:(BOOL)smooth
{
	if (textureData == nil)
		return;

	inkMatrix matrix = PXGraphicsMakeMatrixFromPXMatrix(pxMatrix);
	inkBitmapFill fill = inkBitmapFillMake(matrix, inkBitmapInfoMake(textureData.glTextureName, textureData.glTextureWidth, textureData.glTextureHeight), repeat, smooth);

	inkLineBitmapStyle((inkCanvas*)vCanvas, fill);
}

- (void) lineStyleWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio
{
	inkGradientFill gradientInfo = PXGraphicsGradientInfoMake(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

	inkLineGradientStyle((inkCanvas*)vCanvas, gradientInfo);
}

#pragma mark -
#pragma mark Draw
#pragma mark -

- (void) moveToX:(float)x y:(float)y
{
	inkMoveTo((inkCanvas*)vCanvas, inkPointMake(x, y));
}

- (void) lineToX:(float)x y:(float)y
{
	wasBuilt = false;
	inkLineTo((inkCanvas*)vCanvas, inkPointMake(x, y));
}

- (void) curveToControlX:(float)controlX controlY:(float)controlY anchorX:(float)anchorX anchorY:(float)anchorY
{
	wasBuilt = false;
	inkCurveTo((inkCanvas*)vCanvas, inkPointMake(controlX, controlY), inkPointMake(anchorX, anchorY));
}

// Need to be of type PXGraphicsData
- (void) drawGraphicsData:(NSArray *)graphicsData
{
	// Do not need to reset the built setting, as if anything needs to do that
	// within the list, it will by calling the correct function.

	for (NSObject *obj in graphicsData)
	{
		if ([obj conformsToProtocol:@protocol(PXGraphicsData)] == false)
			continue;

		[(id<PXGraphicsData>)obj _sendToGraphics:self];
	}
}

- (void) drawPathWithCommands:(PXPathCommand *)commands count:(unsigned int)count data:(float *)data
{
	[self drawPathWithCommands:commands count:count data:data winding:PXPathWinding_EvenOdd];
}

- (void) drawPathWithCommands:(PXPathCommand *)commands count:(unsigned int)count data:(float *)data winding:(PXPathWinding)winding
{
	PXGraphicsPath *path = [[PXGraphicsPath alloc] initWithCommands:commands commandCount:count data:data winding:winding];

	if (path == NULL)
		return;

	NSArray *array = [[NSArray alloc] initWithObjects:path, nil];
	[path release];

	[self drawGraphicsData:array];

	[array release];
}

- (void) clear
{
	wasBuilt = false;
	inkClear((inkCanvas*)vCanvas);
}

#pragma mark -
#pragma mark Utility
#pragma mark -

- (void) drawRectWithX:(float)x y:(float)y width:(float)width height:(float)height
{
	wasBuilt = false;
	inkDrawRect((inkCanvas*)vCanvas, inkRectMakef(x, y, width, height));
}

- (void) drawRoundRectWithX:(float)x y:(float)y width:(float)width height:(float)height ellipseWidth:(float)ellipseWidth
{
	return [self drawRoundRectWithX:x y:y width:width height:height ellipseWidth:ellipseWidth ellipseHeight:NAN];
}

- (void) drawRoundRectWithX:(float)x y:(float)y width:(float)width height:(float)height ellipseWidth:(float)ellipseWidth ellipseHeight:(float)ellipseHeight
{
	wasBuilt = false;
	inkDrawRoundRect((inkCanvas*)vCanvas, inkRectMakef(x, y, width, height), inkSizeMake(ellipseWidth, ellipseHeight));
}

- (void) drawCircleWithX:(float)x y:(float)y radius:(float)radius
{
	wasBuilt = false;
	inkDrawCircle((inkCanvas*)vCanvas, inkPointMake(x, y), radius);
}

- (void) drawEllipseWithX:(float)x y:(float)y width:(float)width height:(float)height
{
	wasBuilt = false;
	inkDrawEllipse((inkCanvas*)vCanvas, inkRectMakef(x, y, width, height));
}

- (void) _setWinding:(PXPathWinding)winding
{
	switch(winding)
	{
		case PXPathWinding_EvenOdd:
			inkWindingStyle((inkCanvas*)vCanvas, inkWindingRule_EvenOdd);
			break;
		case PXPathWinding_NonZero:
			inkWindingStyle((inkCanvas*)vCanvas, inkWindingRule_NonZero);
			break;
		default:
			break;
	}
}

- (BOOL) build
{
	if (wasBuilt == false)
	{
		wasBuilt = true;

		inkBuild((inkCanvas*)vCanvas);

		return true;
	}

	return false;
}

#pragma mark -
#pragma mark Override
#pragma mark -

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	return [self _measureLocalBounds:retBounds useStroke:YES];
}

- (void) _measureLocalBounds:(CGRect *)retBounds useStroke:(BOOL)useStroke
{
	if (retBounds == NULL)
		return;

	[self build];

	inkRect bounds = inkBounds((inkCanvas*)vCanvas);

	*retBounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y
{
	return [self _containsPointWithLocalX:x localY:y shapeFlag:NO];
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	return [self _containsPointWithLocalX:x localY:y shapeFlag:shapeFlag useStroke:YES];
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag useStroke:(BOOL)useStroke
{
	[self build];

	// inkContainsPoint asks if you are using the bounds, not the shape flag;
	// therefore it is the opposite of the shape flag.
	return inkContainsPoint((inkCanvas*)vCanvas, inkPointMake((x), (y)), !shapeFlag, useStroke);
}

- (void) _renderGL
{
	BOOL print = NO;

	PXGLMatrix matrix = PXGLCurrentMatrix();
	inkMatrix nMatrix = inkMatrixMake(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
	inkSize matrixSize = inkMatrixSize(nMatrix);
	CGSize size = CGSizeMake(matrixSize.width, matrixSize.height);

	if (PXMathIsEqual(size.width, previousSize.width) == false ||
		PXMathIsEqual(size.height, previousSize.height) == false)
	{
//		printf("previousSize = (%f, %f) newSize = (%f, %f)\n", previousSize.width, previousSize.height, size.width, size.height);
		previousSize = size;
		wasBuilt = NO;

		float contentScaleFactor = PXEngineGetContentScaleFactor();
		inkSetPixelsPerPoint((inkCanvas*)vCanvas, (size.width + size.height) * 0.5f * contentScaleFactor);
	}

	print = [self build];

	vertexCount = inkDrawv((inkCanvas*)vCanvas, pxGraphicsInkRenderer);

//	if (print)
//		printf("PXGraphics::_renderGL totalVertices = %u\n", vertexCount);
}

@end
