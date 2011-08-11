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

void PXUtilsDisplayObjectMultiplyUp(PXDisplayObject *displayObject, PXGLMatrix *matrix)
{
	PXDisplayObject *parent = displayObject->_parent;

	if (!parent)
		return;

	PXGLMatrix *doMatrix = &(displayObject->_matrix);
	PXGLMatrix matInv;
	PXGLMatrixIdentity(&matInv);
	PXGLMatrixMult(&matInv, &matInv, doMatrix);
	PXGLMatrixInvert(&matInv);
	PXGLMatrixMult(matrix, matrix, &matInv);

	while (parent && parent->_parent)
	{
		PXGLMatrixIdentity(&matInv);
		PXGLMatrixMult(&matInv, &matInv, &parent->_matrix);
		PXGLMatrixInvert(&matInv);
		PXGLMatrixMult(matrix, matrix, &matInv);

		parent = parent->_parent;
	}
}

bool PXUtilsDisplayObjectMultiplyDownContinue(PXDisplayObject *targetCoordinateSpace, PXDisplayObject *displayObject, PXGLMatrix *matrix)
{
	if (displayObject == targetCoordinateSpace)
		return true;

	if (displayObject->_parent)
	{
		if (PXUtilsDisplayObjectMultiplyDownContinue(targetCoordinateSpace, displayObject->_parent, matrix))
		{
			PXGLMatrixMult(matrix, matrix, &(displayObject->_matrix));
			return true;
		}
	}

	return false;
}
void PXUtilsDisplayObjectMultiplyDown(PXDisplayObject *displayObject, PXGLMatrix *matrix)
{
	if (!displayObject)
		return;

	PXDisplayObject *root = displayObject->_parent;

	while (root && root->_parent)
	{
		root = root->_parent;
	}

	PXUtilsDisplayObjectMultiplyDownContinue(root, displayObject, matrix);
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
	PXUtilsDisplayObjectMultiplyUp(displayObject, &matrix);

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
	PXUtilsDisplayObjectMultiplyDown(displayObject, &matrix);

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
