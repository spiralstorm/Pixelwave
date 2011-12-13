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
#import "PXEngineUtils.h"
#import "PXEnginePrivate.h"

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
- (BOOL) buildWithDisplayObject:(PXDisplayObject *)obj;
- (BOOL) build:(PXGLMatrix)matrix;
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
	//previousSize = CGSizeMake(1.0f, 1.0f);
	PXGLMatrixIdentity(&previousMatrix);

	return self;
}

- (void) dealloc
{
	inkDestroy((inkCanvas*)vCanvas);

	[super dealloc];
}

// MARK: -
// MARK: Fill
// MARK: -

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

// MARK: -
// MARK: Lines
// MARK: -

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

// MARK: -
// MARK: Draw
// MARK: -

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

// MARK: -
// MARK: Utility
// MARK: -

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

- (BOOL) buildWithDisplayObject:(PXDisplayObject *)obj
{
	PXStage *stage = PXEngineGetStage();

	if (stage == NULL || obj == NULL)
		return NO;

	PXGLMatrix matrix;
	PXGLMatrixIdentity(&matrix);
	PXGLMatrixMult(&matrix, &matrix, &stage->_matrix);
	PXUtilsDisplayObjectMultiplyDown(stage, obj, &matrix);
	return [self build:matrix];
}

- (BOOL) build:(PXGLMatrix)matrix
{
	if (wasBuilt == false || PXGLMatrixIsEqual(&matrix, &previousMatrix) == false)
	{
		previousMatrix = matrix;
		wasBuilt = true;

		inkMatrix iMatrix = inkMatrixMake(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);

		float contentScaleFactor = PXEngineGetContentScaleFactor();
		inkSetPixelsPerPoint((inkCanvas*)vCanvas, contentScaleFactor);
		inkPushMatrix((inkCanvas*)vCanvas);
		inkMultMatrix((inkCanvas*)vCanvas, iMatrix);
		inkBuild((inkCanvas*)vCanvas);
		inkPopMatrix((inkCanvas*)vCanvas);

		return true;
	}

	return false;
}

// MARK: -
// MARK: Override
// MARK: -

- (void) _measureGlobalBounds:(CGRect *)retBounds useStroke:(BOOL)useStroke
{
	if (retBounds == NULL)
		return;

	inkRect bounds = inkBounds((inkCanvas*)vCanvas);
	*retBounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
}

- (void) _measureLocalBounds:(CGRect *)retBounds displayObject:(PXDisplayObject *)displayObject useStroke:(BOOL)useStroke
{
	PXGLMatrix matrix;
	PXGLMatrixIdentity(&matrix);
	PXStage *stage = PXEngineGetStage();

	if (!PXUtilsDisplayObjectMultiplyUp((PXDisplayObject*)stage, displayObject, &matrix))
		return;

	[self buildWithDisplayObject:displayObject];

	[self _measureGlobalBounds:retBounds useStroke:useStroke];

	PXGLAABBf aabb = PXGLAABBfMake(retBounds->origin.x, retBounds->origin.y, retBounds->origin.x + retBounds->size.width, retBounds->origin.y + retBounds->size.height);
	PX_ENGINE_CONVERT_AABB_TO_STAGE_ORIENTATION(&aabb, stage);
	aabb = PXGLMatrixConvertAABBf(&matrix, aabb);
	*retBounds = CGRectMake(aabb.xMin, aabb.yMin, aabb.xMax - aabb.xMin, aabb.yMax - aabb.yMin);
}

- (BOOL) _containsGlobalPoint:(CGPoint)point shapeFlag:(BOOL)shapeFlag useStroke:(BOOL)useStroke
{
	PXStage *stage = PXEngineGetStage();
	PX_ENGINE_CONVERT_POINT_FROM_STAGE_ORIENTATION(point.x, point.y, stage);

	// inkContainsPoint asks if you are using the bounds, not the shape flag;
	// therefore it is the opposite of the shape flag.
	return inkContainsPoint((inkCanvas*)vCanvas, inkPointMake(point.x, point.y), !shapeFlag, useStroke) != NULL;
}

- (BOOL) _containsLocalPoint:(CGPoint)point displayObject:(PXDisplayObject *)displayObject shapeFlag:(BOOL)shapeFlag useStroke:(BOOL)useStroke
{
	[self buildWithDisplayObject:displayObject];

	return [self _containsGlobalPoint:PXUtilsLocalToGlobal(displayObject, point) shapeFlag:shapeFlag useStroke:YES];
}

- (void) _renderGL
{
	BOOL print = NO;

	PXGLMatrix matrix = PXGLCurrentMatrix();

	print = [self build:matrix];

	PXGLLoadIdentity();
	vertexCount = inkDrawv((inkCanvas*)vCanvas, (inkRenderer*)&pxGraphicsInkRenderer);
	PXGLMultMatrix(&matrix);

	if (print)
		printf("PXGraphics::_renderGL totalVertices = %u\n", vertexCount);
}

@end
