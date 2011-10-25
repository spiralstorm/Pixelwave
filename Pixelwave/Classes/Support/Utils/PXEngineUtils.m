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

PXDisplayObject *PXUtilsFindCommonAncestor(PXDisplayObject *obj1, PXDisplayObject *obj2)
{
	if (obj1 == nil || obj2 == nil)
		return nil;

	unsigned int index;

	PXDisplayObject *root;

	// Create an array containing obj1 and all its ancestors.
	unsigned int object1Count = 0;
	root = obj1;

	while (root != nil)
	{
		++object1Count;
		root = root->_parent;
	}

	PXDisplayObject *obj1Ancestors[object1Count];
	PXDisplayObject **curObj1Ancestor;

	for (index = 0, root = obj1, curObj1Ancestor = obj1Ancestors; index < object1Count; ++index, root = root->_parent, ++curObj1Ancestor)
	{
		*curObj1Ancestor = root;
	}

	// Do the same for obj2.
	unsigned int object2Count = 0;
	root = obj2;
	while (root != nil)
	{
		++object2Count;
		root = root->_parent;
	}

	PXDisplayObject *obj2Ancestors[object2Count];
	PXDisplayObject **curObj2Ancestor;

	for (index = 0, root = obj2, curObj2Ancestor = obj2Ancestors; index < object2Count; ++index, root = root->_parent, ++curObj2Ancestor)
	{
		*curObj2Ancestor = root;
	}

	unsigned int minCount = MIN(object1Count, object2Count);
	root = nil;

	// Compare the elements of the arrays in reverse order until one is found
	// that doesn't match. At this point, root is nil, so no need to worry about
	// disjoint sets.
	for (index = 0, curObj1Ancestor = obj1Ancestors + (object1Count - 1), curObj2Ancestor = obj2Ancestors + (object2Count - 1);
		 index < minCount;
		 ++index, --curObj1Ancestor, --curObj2Ancestor)
	{
		if (*curObj1Ancestor != *curObj2Ancestor)
			break;

		root = *curObj1Ancestor;
	}

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
