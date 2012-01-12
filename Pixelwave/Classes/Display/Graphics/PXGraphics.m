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

#define PXGraphicsNormalMatrixMult

const inkRenderer pxGraphicsInkRenderer = {PXGLEnable, PXGLDisable, PXGLEnableClientState, PXGLDisableClientState, PXGLGetBooleanv, PXGLGetFloatv, PXGLGetIntegerv, PXGLPointSize, PXGLLineWidth, PXGLBindTexture, PXGLGetTexParameteriv, PXGLTexParameteri, PXGLVertexPointer, PXGLTexCoordPointer, PXGLColorPointer, PXGLDrawArrays, PXGLDrawElements, PXGLIsEnabled};

PXInline inkMatrix PXGraphicsMakeMatrixFromPXMatrix(PXMatrix *matrix)
{
	if (matrix == nil)
		return inkMatrixIdentity;

	return inkMatrixMake(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
}

inkGradientFill PXGraphicsGradientInfoMake(inkCanvas* canvas, PXGradientType type, NSArray *colors, NSArray *alphas, NSArray *ratios, PXMatrix *matrix, PXSpreadMethod spreadMethod, PXInterpolationMethod interpolationMethod, float focalPointRatio)
{
	inkGradientFill info = inkGradientFillDefault;

	info.type = (inkGradientType)type;
	float w, h, r, tx, ty;
	[matrix _gradientBoxInfoWidth:&w height:&h rotation:&r tx:&tx ty:&ty];
	info.matrix = inkMatrixMakeGradientBoxf(w, h, r, tx, ty);
	info.spreadMethod = (inkSpreadMethod)spreadMethod;
	info.interpolationMethod = (inkInterpolationMethod)interpolationMethod;
	info.focalPointRatio = focalPointRatio;

	unsigned int colorCount = [colors count];
	unsigned int alphaCount = [alphas count];
	unsigned int ratioCount = [ratios count];

	if (colorCount != alphaCount || colorCount != ratioCount || alphaCount != ratioCount)
	{
		PXDebugLog(@"PXGraphics Error: There must be equal quantity of colors, alphas and ratios.");

		return info;
	}

	if (colorCount == 0)
	{
		PXDebugLog(@"PXGraphics Error: Gradients should have at least one color.");

		return info;
	}

	info.colors = inkArrayCreate(sizeof(inkColor));
	if (info.colors == NULL)
		return info;
	info.ratios = inkArrayCreate(sizeof(float));
	if (info.ratios == NULL)
	{
		inkArrayDestroy(info.colors);
		return info;
	}

	inkFreeUponClear(canvas, info.colors, (void(*)(void*))inkArrayDestroy);
	inkFreeUponClear(canvas, info.ratios, (void(*)(void*))inkArrayDestroy);

	unsigned int index = 0;

	for (index = 0; index < colorCount; ++index)
	{
		unsigned int color = [[colors objectAtIndex:index] unsignedIntegerValue];
		float alpha = [[alphas objectAtIndex:index] floatValue];
		float ratio = [[ratios objectAtIndex:index] floatValue];
		ratio *= M_1_255;

		unsigned int prevColorCount = inkArrayCount(info.colors);
		unsigned int prevReatioCount = inkArrayCount(info.ratios);

		inkColor* colorPtr = inkArrayPush(info.colors);
		float* ratioPtr = inkArrayPush(info.ratios);

		if (colorPtr == NULL || ratioPtr == NULL)
		{
			inkArrayUpdateCount(info.colors, prevColorCount);
			inkArrayUpdateCount(info.ratios, prevReatioCount);

			return info;
		}

		*colorPtr = inkColorMake((color >> 16) & 0xFF , (color >> 8) & 0xFF, (color) & 0xFF, (unsigned char)(alpha * 0xFF));
		*ratioPtr = ratio;
	}

	return info;
}

@interface PXGraphics(Private)
- (inkPoint) pxPointToInkPoint:(inkPoint)point displayObject:(PXDisplayObject *)displayObject;
- (inkPoint) pxPointToInkPoint:(inkPoint)point displayObject:(PXDisplayObject *)displayObject;
@end

@implementation PXGraphics

@synthesize vertexCount;
//@synthesize convertTrianglesIntoStrips;
@synthesize buildStyle;
@synthesize scaleRebuildEpsilon;
@synthesize curvePrecision;

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

		textureDataList = [[NSMutableArray alloc] init];
	}

	wasBuilt = false;
	buildStyle = PXGraphicsBuildStyle_Hybrid;
	scaleRebuildEpsilon = 0.001f;
	//scaleRebuildEpsilon = 0.05f;
	curvePrecision = inkCurveMultiplier((inkCanvas*)vCanvas);

	PXGLMatrixIdentity(&graphicsMatrix);

	return self;
}

- (void) dealloc
{
	inkDestroy((inkCanvas*)vCanvas);

	[textureDataList release];

	[super dealloc];
}

- (void) setBuildStyle:(PXGraphicsBuildStyle)_buildStyle
{
	if (buildStyle != _buildStyle)
	{
		buildStyle = _buildStyle;
		wasBuilt = false;
	}
}

- (void) setScaleRebuildEpsilon:(float)_scaleRebuildEpsilon
{
	if (scaleRebuildEpsilon != _scaleRebuildEpsilon)
	{
		scaleRebuildEpsilon = _scaleRebuildEpsilon;
		wasBuilt = false;
	}
}

- (void) setCurvePrecision:(float)_curvePrecision
{
	if (curvePrecision != _curvePrecision)
	{
		curvePrecision = _curvePrecision;
		inkSetCurveMultiplier((inkCanvas*)vCanvas, curvePrecision);
		wasBuilt = false;
	}
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

	[textureDataList addObject:textureData];

	inkMatrix matrix = PXGraphicsMakeMatrixFromPXMatrix(pxMatrix);
	inkBitmapFill fill = inkBitmapFillMake(matrix, inkBitmapInfoMake(textureData.glTextureName, textureData.glTextureWidth, textureData.glTextureHeight), repeat, smooth);

	inkBeginBitmapFill((inkCanvas*)vCanvas, fill);
}

- (void) beginFillWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio
{
	//inkBeginFill((inkCanvas*)vCanvas, inkSolidFillMake(0xFF00FF, 1.0f));
	inkGradientFill gradientInfo = PXGraphicsGradientInfoMake((inkCanvas*)vCanvas, type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

	inkBeginGradientFill((inkCanvas*)vCanvas, gradientInfo);
}

- (void) endFill
{
	inkEndFill((inkCanvas*)vCanvas);
}

// MARK: -
// MARK: Lines
// MARK: -

- (void) lineStyleWithThickness:(float)thickness color:(unsigned int)color alpha:(float)alpha
{
	[self lineStyleWithThickness:thickness color:color alpha:alpha pixelHinting:false scaleMode:PXLineScaleMode_Normal caps:PXCapsStyle_Round joints:PXJointStyle_Bevel miterLimit:3.0f];
}

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

	[textureDataList addObject:textureData];

	inkMatrix matrix = PXGraphicsMakeMatrixFromPXMatrix(pxMatrix);
	inkBitmapFill fill = inkBitmapFillMake(matrix, inkBitmapInfoMake(textureData.glTextureName, textureData.glTextureWidth, textureData.glTextureHeight), repeat, smooth);

	inkLineBitmapStyle((inkCanvas*)vCanvas, fill);
}

- (void) lineStyleWithGradientType:(PXGradientType)type colors:(NSArray *)colors alphas:(NSArray *)alphas ratios:(NSArray *)ratios matrix:(PXMatrix *)matrix spreadMethod:(PXSpreadMethod)spreadMethod interpolationMethod:(PXInterpolationMethod)interpolationMethod focalPointRatio:(float)focalPointRatio
{
	inkGradientFill gradientInfo = PXGraphicsGradientInfoMake((inkCanvas*)vCanvas, type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

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

	[textureDataList removeAllObjects];
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
	return [self drawRoundRectWithX:x y:y width:width height:height ellipseWidth:ellipseWidth ellipseHeight:ellipseWidth];
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

- (inkMatrix) inkMatrixFromDisplayObject:(PXDisplayObject *)displayObject
{
	if (displayObject == NULL)
		return inkMatrixIdentity;

	PXGLMatrix matrix;
	PXGLMatrixIdentity(&matrix);

	PXStage *stage = PXEngineGetStage();

	if (!PXUtilsDisplayObjectMultiplyDown(stage, displayObject, &matrix))
		return inkMatrixIdentity;

//	PXGLMatrixMult(&matrix, &stage->_matrix, &matrix);

	return inkMatrixMake(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
}

- (BOOL) buildWithDisplayObject:(PXDisplayObject *)displayObject
{
	PXGLMatrix matrix;
	PXGLMatrixIdentity(&matrix);

	bool cancelBuild = false;

	if (buildStyle != PXGraphicsBuildStyle_GL)
	{
		inkMatrix mat = [self inkMatrixFromDisplayObject:displayObject];
		inkSize scale = inkMatrixSize(mat);

		PXGLMatrixScale(&matrix, scale.width, scale.height);

		buildScale = CGSizeMake(scale.width, scale.height);

		if (wasBuilt == true && buildStyle != PXGraphicsBuildStyle_Hybrid)
		{
			cancelBuild = true;
		}
		else
		{
			if (buildStyle == PXGraphicsBuildStyle_Hybrid)
			{
				if (wasBuilt == false ||
					PXMathIsNearlyEqual(previousBuildScale.width,  buildScale.width,  scaleRebuildEpsilon) == false ||
					PXMathIsNearlyEqual(previousBuildScale.height, buildScale.height, scaleRebuildEpsilon) == false)
				{
					previousBuildScale = buildScale;
				}
				else
					cancelBuild = true;
			}
		}
	}

	if (cancelBuild == true)
		return false;

	return [self build:matrix];
}

- (BOOL) build:(PXGLMatrix)matrix
{
	if (wasBuilt == false || (buildStyle == PXGraphicsBuildStyle_Hybrid && PXGLMatrixIsEqual(&matrix, &graphicsMatrix) == false))
	{
		graphicsMatrix = matrix;
		wasBuilt = true;

		inkMatrix iMatrix = inkMatrixMake(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);

		inkSetPixelsPerPoint((inkCanvas*)vCanvas, PXEngineGetContentScaleFactor());
	//	inkSetPixelsPerPoint((inkCanvas*)vCanvas, 0.01f);
		inkPushMatrix((inkCanvas*)vCanvas);
		inkMultMatrix((inkCanvas*)vCanvas, iMatrix);
		inkBuild((inkCanvas*)vCanvas);
		inkPopMatrix((inkCanvas*)vCanvas);

		return true;
	}

	return false;
}

/*- (void) setConvertTrianglesIntoStrips:(bool)_convertTrianglesIntoStrips
{
	wasBuilt = false;
	convertTrianglesIntoStrips = _convertTrianglesIntoStrips;

	inkSetConvertTrianglesIntoStrips((inkCanvas*)vCanvas, convertTrianglesIntoStrips);
}*/

- (inkPoint) inkPointToPXPoint:(inkPoint)point displayObject:(PXDisplayObject *)displayObject
{
	if (buildStyle == PXGraphicsBuildStyle_GL)
		return point;

	//inkMatrix mat = [self inkMatrixFromDisplayObject:displayObject];
	inkMatrix mat = inkMatrixMake(graphicsMatrix.a, graphicsMatrix.b, graphicsMatrix.c, graphicsMatrix.d, graphicsMatrix.tx, graphicsMatrix.ty);

	inkSize scale = inkMatrixSize(mat);

	if (scale.width == 0.0f || scale.height == 0.0f)
		return inkPointZero;

	mat = inkMatrixMake(1.0f / scale.width, 0.0f, 0.0f, 1.0f / scale.height, 0.0f, 0.0f);

	point = inkMatrixTransformPoint(mat, point);

	return point;
}

- (inkPoint) pxPointToInkPoint:(inkPoint)point displayObject:(PXDisplayObject *)displayObject
{
	if (buildStyle == PXGraphicsBuildStyle_GL)
		return point;

	inkMatrix mat = inkMatrixMake(graphicsMatrix.a, graphicsMatrix.b, graphicsMatrix.c, graphicsMatrix.d, graphicsMatrix.tx, graphicsMatrix.ty);

	inkSize scale = inkMatrixSize(mat);

	if (scale.width == 0.0f || scale.height == 0.0f)
		return inkPointZero;

	mat = inkMatrixMake(scale.width, 0.0f, 0.0f, scale.height, 0.0f, 0.0f);

	point = inkMatrixTransformPoint(mat, point);

	return point;
}

// MARK: -
// MARK: Override
// MARK: -

- (CGRect) _measureLocalBoundsWithDisplayObject:(PXDisplayObject *)displayObject useStroke:(BOOL)useStroke
{
	[self buildWithDisplayObject:displayObject];

	inkRect bounds = inkBoundsv((inkCanvas*)vCanvas, useStroke);

	inkBox box = inkBoxFromRect(bounds);
	box.pointA = [self inkPointToPXPoint:box.pointA displayObject:displayObject];
	box.pointB = [self inkPointToPXPoint:box.pointB displayObject:displayObject];
	box.pointC = [self inkPointToPXPoint:box.pointC displayObject:displayObject];
	box.pointD = [self inkPointToPXPoint:box.pointD displayObject:displayObject];

	bounds = inkRectFromMinMaxBox(box);

	return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
}

- (BOOL) _containsLocalPoint:(CGPoint)point displayObject:(PXDisplayObject *)displayObject shapeFlag:(BOOL)shapeFlag useStroke:(BOOL)useStroke
{
	[self buildWithDisplayObject:displayObject];

	inkPoint iPoint = [self pxPointToInkPoint:inkPointMake(point.x, point.y) displayObject:displayObject];

	return inkContainsPoint((inkCanvas*)vCanvas, iPoint, !shapeFlag, useStroke) != NULL;
}

- (void) _postFrame:(PXDisplayObject *)displayObject
{
	[self buildWithDisplayObject:displayObject];
	justBuilt = true;
}

- (void) _renderGLWithDisplayObject:(PXDisplayObject *)displayObject
{
	// In most cases, this shouldn't do anything as the post frame will take
	// care of it during the 'frame time', however this is useful if this was
	// not on the display hierarchy and therefore did not receieve the post
	// frame.
	if (justBuilt == false)
		[self buildWithDisplayObject:displayObject];
	else
		justBuilt = false;

	if (buildStyle == PXGraphicsBuildStyle_GL)
	{
		vertexCount = inkDrawv((inkCanvas*)vCanvas, (inkRenderer*)&pxGraphicsInkRenderer);
		return;
	}

	PXGLMatrix origMatrix = PXGLCurrentMatrix();
	glMatrix = origMatrix;

	if (buildScale.width == 0.0f || buildScale.height == 0.0f)
		return;

	PXGLMatrix mat2 = PXGLMatrixMake(1.0f / buildScale.width, 0.0f, 0.0f, 1.0f / buildScale.height, 0.0f, 0.0f);

	PXGLMatrixMult(&glMatrix, &glMatrix, &mat2);

	PXGLLoadIdentity();
	PXGLMultMatrix(&glMatrix);

	vertexCount = inkDrawv((inkCanvas*)vCanvas, (inkRenderer*)&pxGraphicsInkRenderer);

	PXGLLoadIdentity();
	PXGLMultMatrix(&origMatrix);
}

@end
