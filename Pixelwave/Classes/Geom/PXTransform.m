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

#import "PXMath.h"
#import "PXDisplayObjectContainer.h"
#import "PXMatrix.h"
#import "PXColorTransform.h"
#import "PXTransform.h"
#import "PXRectangle.h"
#include "PXMathUtils.h"

#import "PXExceptionUtils.h"

/**
 * Describes the local transformation of a #PXDisplayObject in
 * two-dimensional space and color space.
 *
 * #PXTransform also provides methods for finding the #PXDisplayObject 's
 * transformation in global (stage) coordinate space.
 *
 * The two-dimensional transformation (translation, scale, rotation and skew)
 * of the associated PXDisplayObject can be read and set via the
 * #matrix property.
 *
 * The color transformation of the associated #PXDisplayObject can be read and
 * set via the #colorTransform property.
 *
 * @see PXMatrix
 * @see PXColorTransform
 * @see PXDisplayObject
 */
@implementation PXTransform

- (id) init
{
	PXThrow(PXException, @"PXTransform shouldn't be instantiated");

	[self release];
	return nil;
}

- (id) _initWithDisplayObject:(PXDisplayObject *)dispObject
{
	self = [super init];

	if (self)
	{
		_displayObject = dispObject;
	}

	return self;
}

- (void) dealloc
{
	_displayObject = nil;

	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(matrix=%@, concatenatedMatrix=%@, colorTransform=%@, concatenatedColorTransform=%@, pixelBounds=%@)",
			self.matrix,
			self.concatenatedMatrix,
			self.colorTransform,
			self.concatenatedColorTransform,
			self.pixelBounds];
}

- (void) setMatrix:(PXMatrix *)mat
{
	if (!mat)
		return;
	
	PXGLMatrix sMat;

	sMat.a = mat.a;
	sMat.b = mat.b;
	sMat.c = mat.c;
	sMat.d = mat.d;
	sMat.tx = mat.tx;
	sMat.ty = mat.ty;

	[_displayObject _setMatrix:&sMat];
}

- (PXMatrix *)matrix
{
	PXMatrix *mat = [PXMatrix new];

	PXGLMatrix *_matrix = &_displayObject->_matrix;

	mat.a  = _matrix->a;
	mat.b  = _matrix->b;
	mat.c  = _matrix->c;
	mat.d  = _matrix->d;
	mat.tx = _matrix->tx;
	mat.ty = _matrix->ty;

	return [mat autorelease];
}

- (PXMatrix *)concatenatedMatrix
{
	PXDisplayObjectContainer *parent = _displayObject->_parent;

	if (!parent)
		return self.matrix;

	PXGLMatrix *_matrix = &_displayObject->_matrix;

	PXMatrix *mat = [PXMatrix new];

	PXMatrix *m1 = [parent.transform concatenatedMatrix];

	float a2  = _matrix->a;
	float b2  = _matrix->b;
	float c2  = _matrix->c;
	float d2  = _matrix->d;
	float tx2 = _matrix->tx;
	float ty2 = _matrix->ty;

	float a1  = m1.a;
	float b1  = m1.b;
	float c1  = m1.c;
	float d1  = m1.d;
	float tx1 = m1.tx;
	float ty1 = m1.ty;

	mat.a  =  a1 * a2 +  b1 * c2;
	mat.b  =  a1 * b2 +  b1 * d2;
	mat.c  =  c1 * a2 +  d1 * c2;
	mat.d  =  c1 * b2 +  d1 * d2;
	mat.tx = tx1 * a2 + ty1 * c2 + tx2;
	mat.ty = tx1 * b2 + ty1 * d2 + ty2;

	return [mat autorelease];
}

- (void) setColorTransform:(PXColorTransform *)ct
{
	PXGLColorTransform sCt;

	sCt.redMultiplier   = ct.redMultiplier;
	sCt.greenMultiplier = ct.greenMultiplier;
	sCt.blueMultiplier  = ct.blueMultiplier;
	sCt.alphaMultiplier = ct.alphaMultiplier;

	[_displayObject _setColorTransform:&sCt];
}

- (PXColorTransform *)colorTransform
{
	PXGLColorTransform *_colorTransform = &_displayObject->_colorTransform;

	PXColorTransform *newCT = [[PXColorTransform alloc] initWithRedMult:_colorTransform->redMultiplier
														   greenMult:_colorTransform->greenMultiplier
															blueMult:_colorTransform->blueMultiplier
														   alphaMult:_colorTransform->alphaMultiplier];

	return [newCT autorelease];
}

- (PXColorTransform *)concatenatedColorTransform
{
	PXGLColorTransform *_colorTransform = &_displayObject->_colorTransform;

	PXColorTransform *newCT = [PXColorTransform new];

	PXDisplayObjectContainer *parent = _displayObject->_parent;

	if (!parent)
	{
		[newCT setMultipliersWithRed:_colorTransform->redMultiplier
							green:_colorTransform->greenMultiplier
							 blue:_colorTransform->blueMultiplier
							alpha:_colorTransform->alphaMultiplier];

		return [newCT autorelease];
	}

	PXColorTransform *ct = [parent.transform concatenatedColorTransform];

	newCT.redMultiplier	  = ct.redMultiplier   * _colorTransform->redMultiplier;
	newCT.greenMultiplier = ct.greenMultiplier * _colorTransform->greenMultiplier;
	newCT.blueMultiplier  = ct.blueMultiplier  * _colorTransform->blueMultiplier;
	newCT.alphaMultiplier = ct.alphaMultiplier * _colorTransform->alphaMultiplier;

	return [newCT autorelease];
}

- (PXRectangle *)pixelBounds
{
	CGRect rect;
	[_displayObject _measureGlobalBounds:&rect];

	return [[[PXRectangle alloc] initWithX:rect.origin.x
									  y:rect.origin.y
								  width:rect.size.width
								 height:rect.size.height] autorelease];
}

@end
