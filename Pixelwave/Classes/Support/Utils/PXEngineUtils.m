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

#include "PXEngineUtils.h"
#include "PXEngine.h"

#import "PXDisplayObject.h"
#import "PXDisplayObjectContainer.h"
#import "PXStage.h"

#import "PXPoint.h"
#import "PXObjectPool.h"
#import "PXLinkedList.h"

#import "PXExceptionUtils.h"

PXDisplayObject* PXUtilsFindCommonAncestor(PXDisplayObject* obj1, PXDisplayObject* obj2)
{
	// Create an array containing obj1 and all its ancestors.
	NSUInteger objectCount = 0;
	PXDisplayObject* root = obj1;
	while (root != nil)
	{
		++objectCount;
		root = root->_parent;
	}
	NSMutableArray* obj1Ancestors = [[NSMutableArray alloc] initWithCapacity: objectCount];

	root = obj1;
	while (root != nil)
	{
		[obj1Ancestors addObject: root];
		root = root->_parent;
	}

	// Do the same for obj2.
	objectCount = 0;
	root = obj2;
	while (root != nil)
	{
		++objectCount;
		root = root->_parent;
	}
	NSMutableArray* obj2Ancestors = [[NSMutableArray alloc] initWithCapacity: objectCount];
	
	root = obj2;
	while (root != nil)
	{
		[obj2Ancestors addObject: root];
		root = root->_parent;
	}

	// Compare the elements of the arrays in reverse order until one is found that
	// doesn't match.  At this point, root is nil, so no need to worry about disjoint
	// sets.  In order to avoid fragmenting memory for callers, reverseObjectEnumerator
	// is not used.
	for (NSUInteger index1 = [obj1Ancestors count], index2 = [obj2Ancestors count]; (index1-- > 0) && (index2-- > 0); )
	{
		id test = [obj1Ancestors objectAtIndex: index1];
		if (test != [obj2Ancestors objectAtIndex: index2])
			break;

		root = test;
	}

	[obj1Ancestors release];
	[obj2Ancestors release];

	// Return the last element that matched.  
	return root;
}

bool PXUtilsDisplayObjectMultiplyUp(PXDisplayObject *rootCoordinateSpace, PXDisplayObject *displayObject, PXGLMatrix *matrix)
{
	while (displayObject != rootCoordinateSpace)
	{
		if (displayObject == nil)
			return false;

		PXGLMatrix matInv;
		PXGLMatrixIdentity(&matInv);
		PXGLMatrixMult(&matInv, &matInv, &displayObject->_matrix);
		PXGLMatrixInvert(&matInv);
		PXGLMatrixMult(matrix, matrix, &matInv);

		displayObject = displayObject->_parent;
	}

	return true;
}

bool PXUtilsDisplayObjectMultiplyDown(PXDisplayObject *rootCoordinateSpace, PXDisplayObject *displayObject, PXGLMatrix *matrix)
{
	if (displayObject == rootCoordinateSpace)
		return true;

	if (displayObject->_parent)
	{
		if (PXUtilsDisplayObjectMultiplyDown(rootCoordinateSpace, displayObject->_parent, matrix))
		{
			PXGLMatrixMult(matrix, matrix, &(displayObject->_matrix));
			return true;
		}
	}

	return false;
}

CGPoint PXUtilsGlobalToLocal(PXDisplayObject *displayObject, CGPoint point)
{
	// If this is the stage, then the global point is already in local
	// coordinates.
	if (displayObject == PXEngineGetStage())
	{
		return point;
	}

	PXGLMatrix matrix;
	PXGLMatrixIdentity(&matrix);
	if (!PXUtilsDisplayObjectMultiplyUp(PXEngineGetStage(), displayObject, &matrix))
		PXThrow(PXArgumentException, @"Parameter displayObject must be on the stage.");

	point = PXGLMatrixConvertPoint(&matrix, point);

	return point;
}
CGPoint PXUtilsLocalToGlobal(PXDisplayObject *displayObject, CGPoint point)
{
	// If this is the stage, then the local point is already in global
	// coordinates.
	if (displayObject == PXEngineGetStage())
	{
		return point;
	}

	PXGLMatrix matrix;
	PXGLMatrixIdentity(&matrix);
	if (!PXUtilsDisplayObjectMultiplyDown(PXEngineGetStage(), displayObject, &matrix))
		PXThrow(PXArgumentException, @"Parameter displayObject must be on the stage.");

	point = PXGLMatrixConvertPoint(&matrix, point);
	//PX_GL_CONVERT_POINT_TO_MATRIX(matrix, point.x, point.y);

	return point;
}

PXLinkedList *PXUtilsNewPooledList()
{
	return (PXLinkedList *)([PXEngineGetSharedObjectPool() newObjectUsingClass:[PXLinkedList class]]);
}
void PXUtilsReleasePooledList(PXLinkedList *list)
{
	[PXEngineGetSharedObjectPool() releaseObject:list];
}
PXPoint *PXUtilsNewPooledPoint()
{
	return (PXPoint *)([PXEngineGetSharedObjectPool() newObjectUsingClass:[PXPoint class]]);
}
void PXUtilsReleasePooledPoint(PXPoint *point)
{
	[PXEngineGetSharedObjectPool() releaseObject:point];
}
