//
//  inkConvexPolygon.c
//  ink
//
//  Created by John Lattin on 12/28/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkConvexPolygon.h"

#include "inkRenderGroup.h"
#include "inkGL.h"

bool inkConvexPolygonIsConvex(inkArray* points, bool clockwise);

void inkConvexPolygons(inkCanvas* canvas, inkConvexPolygonGroup* polygonGroup, inkConvexPolygonMode mode);

inkConvexPolygon* inkConvexPolygonCreate()
{
	inkConvexPolygon* polygon = malloc(sizeof(inkConvexPolygon));

	if (polygon != NULL)
	{
		polygon->points = inkArrayCreate(sizeof(inkPoint));

		if (polygon->points == NULL)
		{
			inkConvexPolygonDestroy(polygon);
			return NULL;
		}
	}

	return polygon;
}

void inkConvexPolygonDestroy(inkConvexPolygon* polygon)
{
	if (polygon == NULL)
		return;

	inkArrayDestroy(polygon->points);

	free(polygon);
}

inkConvexPolygonGroup* inkConvexPolygonGroupCreate(inkCanvas* canvas, inkConvexPolygonMode mode)
{
	inkConvexPolygonGroup* polygonGroup = malloc(sizeof(inkConvexPolygonGroup));

	if (polygonGroup != NULL)
	{
		polygonGroup->polygons = inkArrayCreate(sizeof(inkConvexPolygon*));

		if (polygonGroup->polygons == NULL)
		{
			inkConvexPolygonGroupDestroy(polygonGroup);
			return NULL;
		}

		inkConvexPolygons(canvas, polygonGroup, mode);

		if (inkArrayCount(polygonGroup->polygons) == 0)
		{
			inkConvexPolygonGroupDestroy(polygonGroup);
			return NULL;
		}
	}

	return polygonGroup;
}

void inkConvexPolygonGroupDestroy(inkConvexPolygonGroup* polygonGroup)
{
	if (polygonGroup == NULL)
		return;

	if (polygonGroup->polygons != NULL)
	{
		inkConvexPolygon* polygon;

		inkArrayPtrForEach(polygonGroup->polygons, polygon)
		{
			inkConvexPolygonDestroy(polygon);
		}

		inkArrayDestroy(polygonGroup->polygons);
	}

	free(polygonGroup);
}

inkConvexPolygon* inkConvexPolygonFromPoints(inkArray* points)
{
	if (points == NULL)
		return NULL;

	size_t count = inkArrayCount(points);
	if (count == 0)
		return NULL;

	inkConvexPolygon* convexPolygon = inkConvexPolygonCreate();
	if (convexPolygon == NULL)
	{
		inkArrayDestroy(points);
		return NULL;
	}

	inkPoint* pointPtr;
	inkPoint* point;

	inkArrayForEach(points, point)
	{
		pointPtr = inkArrayPush(convexPolygon->points);

		if (pointPtr != NULL)
		{
			*pointPtr = *point;
		}
	}

	count = inkArrayCount(points);
	if (count == 0)
	{
		inkConvexPolygonDestroy(convexPolygon);
		inkArrayDestroy(points);
		return NULL;
	}

	qsort(points->elements, count, sizeof(inkPoint), (int (*)(const void *, const void *))(inkPointCompareX));

	inkPoint* hull = convexPolygon->points->elements;
	inkPoint* inPoints = points->elements;

	ssize_t i, t, k = 0;

	// lower hull
	for (i = 0; i < count; ++i)
	{
	//	while (k >= 2 && ccw(hull[k-2], hull[k-1], &points[i]) <= 0)
		while (k >= 2 && inkTriangleCCW(inkTriangleMake(hull[k-2], hull[k-1], inPoints[i])) <= 0)
			--k;

		hull[k++] = inPoints[i];
	}

	// upper hull
	for (i = count - 2, t = k + 1; i >= 0; --i)
	{
		//while (k >= t && ccw(hull[k - 2], hull[k - 1], &points[i]) <= 0)
		while (k >= t && inkTriangleCCW(inkTriangleMake(hull[k - 2], hull[k - 1], inPoints[i])) <= 0)
			--k;

		hull[k++] = inPoints[i];
	}

	--k;

	inkArrayUpdateCount(convexPolygon->points, k);

	return convexPolygon;
}

bool inkConvexPolygonsAddPoint(inkArray* points, inkPoint point)
{
	inkPoint* pointPtr = inkArrayPush(points);
	if (pointPtr != NULL)
	{
		*pointPtr = point;
		return true;
	}

	return false;
}

/*bool inkConvexPolygonsAddPointFromVertex(inkRenderGroup* renderGroup, inkVertex* vertex, inkArray** pointGroupList, inkArray** points, inkArray*** pointsPtr)
{
	bool regroup = false;
	switch(renderGroup->glDrawMod)
	{
		case GL_TRIANGLES:
			break;
		case GL_TRIANGLE_STRIP;
			break;
		case GL_
	}

	inkPoint point = inkMatrixTransformPoint(renderGroup->invGLMatrix, vertex->pos);

	inkConvexPolygonsAddPoint(*points, point);

	if (inkConvexPolygonIsConvex(*points) == false)
	{
		inkArrayPop(*points);

		inkArray* previousPoints = *points;

		*points = (inkArray*)inkArrayPush(*pointGroupList);
		if (points == NULL)
			return false;

		*pointsPtr = (inkArray**)inkArrayPush(*pointGroupList);
		if (pointsPtr == NULL)
			return false;

		*points = inkArrayCreate(sizeof(inkPoint));
		**pointsPtr = *points;

		unsigned int previousCount = inkArrayCount(previousPoints);

		inkConvexPolygonsAddPoint(*points, *((inkPoint*)inkArrayElementAt(previousPoints, previousCount - 2)));
		inkConvexPolygonsAddPoint(*points, *((inkPoint*)inkArrayElementAt(previousPoints, previousCount - 1)));
		inkConvexPolygonsAddPoint(*points, point);
	}

	return true;
}*/

void inkConvexPolygonAddPolygonFromPoint(inkArray* points, inkConvexPolygonGroup* polygonGroup)
{
	inkConvexPolygon* polygon = inkConvexPolygonFromPoints(points);
	inkConvexPolygon** polygonPtr;

	if (polygon != NULL)
	{
		polygonPtr = (inkConvexPolygon**)inkArrayPush(polygonGroup->polygons);

		if (polygonPtr == NULL)
			inkConvexPolygonDestroy(polygon);
		else
			*polygonPtr = polygon;
	}
}

void inkConvexPolygons(inkCanvas* canvas, inkConvexPolygonGroup* polygonGroup, inkConvexPolygonMode mode)
{
	assert(canvas);

	inkArray* renderGroups = inkRenderGroups(canvas);
	inkRenderGroup* renderGroup;

//	inkArray* copyRenderGroups = inkArrayCreate(sizeof(inkRenderGroup*));
//	inkRenderGroup** copyRenderGroupPtr;

//	inkConvexPolygon* polygon = NULL;
//	inkConvexPolygon** polygonPtr = NULL;

//	inkArray* pointGroupList = NULL;
//	inkVertex* vertex = NULL;
//	inkArray* points = NULL;
	//inkPoint point;

//	if (copyRenderGroups == NULL)
//		goto freeMemory;

	inkArray* points = inkArrayCreate(sizeof(inkPoint));
	inkVertex* vertex = NULL;

	if (points == NULL)
		return;

	inkTriangle triangle;
	unsigned int index;
	unsigned int vertexCount;
	inkPoint firstPoint;

	bool clockwise;

	/*unsigned int startIndex = 1;
	bool dontIncreaseStartIndex = false;
	
	inkArrayForEachv(vertices, vertex, index = 0, ++index)
	{
		//if (index++ == 0)
		if (index == 0)
		{
			continue;
		}
		
		if (dontIncreaseStartIndex == false && previousVertex.pos.x == vertex->pos.x && previousVertex.pos.y == vertex->pos.y)
		{
			++startIndex;
			continue;
		}
		else
		{
			dontIncreaseStartIndex = true;
		}
		
		sum += (vertex->pos.x - previousVertex.pos.x) * (vertex->pos.y + previousVertex.pos.y);
		previousVertex = *vertex;
	}*/

	float sum = 0.0f;
	inkVertex previousVertex;

	inkArrayPtrForEach(renderGroups, renderGroup)
	{
		switch(mode)
		{
			case inkConvexPolygonMode_Polygon:
				if (renderGroup->isStroke == true)
					continue;
				break;
			case inkConvexPolygonMode_Stroke:
				if (renderGroup->isStroke == false)
					continue;
				break;
			case inkConvexPolygonMode_StrokeAndPolygon:
			default:
				break;
		}

		inkArrayClear(points);

		inkArrayForEachv(renderGroup->vertices, vertex, index = 0, ++index)
		{
			inkConvexPolygonsAddPoint(points, vertex->pos);

			if (index != 0)
			{
				sum += (vertex->pos.x - previousVertex.pos.x) * (vertex->pos.y + previousVertex.pos.y);
			}

			previousVertex = *vertex;
		}

		clockwise = !(sum >= 0.0f);

		if (inkConvexPolygonIsConvex(points, clockwise))
		{
			inkConvexPolygonAddPolygonFromPoint(points, polygonGroup);
			continue;
		}

		vertexCount = inkArrayCount(renderGroup->vertices);

		firstPoint = *((inkPoint*)inkArrayElementAt(renderGroup->vertices, 0));
		triangle.pointC = *((inkPoint*)inkArrayElementAt(renderGroup->vertices, vertexCount - 1));

		inkArrayForEachv(renderGroup->vertices, vertex, index = 0, ++index)
		{
			triangle.pointA = triangle.pointB;
			triangle.pointB = triangle.pointC;
			triangle.pointC = inkPointMake(vertex->pos.x, vertex->pos.y);

			switch(renderGroup->glDrawMode)
			{
					// TRIANGLES
				case GL_TRIANGLES:
					if (index % 3 != 0)
						break;
				case GL_TRIANGLE_FAN:
					if (renderGroup->glDrawMode == GL_TRIANGLE_FAN)
						triangle.pointA = firstPoint;
				case GL_TRIANGLE_STRIP:
					if (index < 2)
						break; // must break so index iterates

					inkArrayClear(points);
					inkConvexPolygonsAddPoint(points, triangle.pointA);
					inkConvexPolygonsAddPoint(points, triangle.pointB);
					inkConvexPolygonsAddPoint(points, triangle.pointC);
	
					inkConvexPolygonAddPolygonFromPoint(points, polygonGroup);
					break;
				default:
					break;
			}
		}
	}

	inkArrayDestroy(points);

	/*inkArrayPtrForEach(renderGroups, renderGroup)
	{
		switch(mode)
		{
			case inkConvexPolygonMode_Polygon:
				if (renderGroup->isStroke == true)
					continue;
				break;
			case inkConvexPolygonMode_Stroke:
				if (renderGroup->isStroke == false)
					continue;
				break;
			case inkConvexPolygonMode_StrokeAndPolygon:
			default:
				break;
		}

		copyRenderGroupPtr = inkArrayPush(copyRenderGroups);
		if (copyRenderGroupPtr != NULL)
		{
			*copyRenderGroupPtr = inkRenderGroupCopy(renderGroup);
		}
	}

	pointGroupList = inkArrayCreate(sizeof(inkArray*));

	if (pointGroupList == NULL)
		goto freeMemory;

	inkArray** pointsPtr;
	// Break up into point groups
	inkArrayPtrForEach(copyRenderGroups, renderGroup)
	{
	//	inkRenderGroupConvertToStrips(renderGroup);

		pointsPtr = (inkArray**)inkArrayPush(pointGroupList);
		if (pointsPtr == NULL)
			continue;
		points = inkArrayCreate(sizeof(inkPoint));
		*pointsPtr = points;

		switch(renderGroup->glDrawType)
		{
			case inkDrawType_Arrays:
			{
				inkArrayForEach(renderGroup->vertices, vertex)
				{
					inkConvexPolygonsAddPointFromVertex(renderGroup, vertex, &pointGroupList, &points, &pointsPtr);
				}
			}
				break;
			case inkDrawType_Elements:
			{
				unsigned short* indexPtr;
				unsigned short lastIndex = 0;
				unsigned int index;
				inkArrayForEachv(renderGroup->indices, indexPtr, index = 0, ++index)
				{
					if (index != 0)
					{
						if (lastIndex == *indexPtr)
							continue;
					}

					lastIndex = *indexPtr;

					vertex = (inkVertex*)(inkArrayElementAt(renderGroup->vertices, *indexPtr));
					inkConvexPolygonsAddPointFromVertex(renderGroup, vertex, &pointGroupList, &points, &pointsPtr);
				}
			}
				break;
				
			default:
				break;
		}*/
		/*inkArrayForEach(renderGroup->vertices, vertex)
		{
			point = inkMatrixTransformPoint(renderGroup->invGLMatrix, vertex->pos);

			inkConvexPolygonsAddPoint(points, point);

			if (inkConvexPolygonIsConvex(points) == false)
			{
				inkArrayPop(points);

				inkArray* previousPoints = points;

				points = (inkArray*)inkArrayPush(pointGroupList);
				if (points == NULL)
					goto freeMemory;

				pointsPtr = (inkArray**)inkArrayPush(pointGroupList);
				if (pointsPtr == NULL)
					continue;
				points = inkArrayCreate(sizeof(inkPoint));
				*pointsPtr = points;

				unsigned int previousCount = inkArrayCount(previousPoints);

				inkConvexPolygonsAddPoint(points, *((inkPoint*)inkArrayElementAt(previousPoints, previousCount - 2)));
				inkConvexPolygonsAddPoint(points, *((inkPoint*)inkArrayElementAt(previousPoints, previousCount - 1)));
				inkConvexPolygonsAddPoint(points, point);
			}
		}*/
	//}

	// Add 
	/*inkArrayPtrForEach(pointGroupList, points)
	{
		polygon = inkConvexPolygonFromPoints(points);

		if (polygon != NULL)
		{
			polygonPtr = (inkConvexPolygon**)inkArrayPush(polygonGroup->polygons);

			if (polygonPtr == NULL)
				inkConvexPolygonDestroy(polygon);
			else
				*polygonPtr = polygon;
		}
	}

freeMemory:
	if (copyRenderGroups != NULL)
	{
		inkArrayPtrForEach(copyRenderGroups, renderGroup)
		{
			inkRenderGroupDestroy(renderGroup);
		}

		inkArrayDestroy(copyRenderGroups);
	}
	if (pointGroupList != NULL)
	{
		inkArrayPtrForEach(pointGroupList, points)
		{
			inkArrayDestroy(points);
		}

		inkArrayDestroy(pointGroupList);
	}*/
}

bool inkConvexPolygonIsConvex(inkArray* points, bool clockwise)
{
	if (inkArrayCount(points) <= 3)
		return true;

	inkTriangle triangle;

	inkPoint* point;
	unsigned int index;

	//bool reverse = false;
	float val;

	inkArrayForEachv(points, point, index = 0, ++index)
	{
		if (index == 0)
		{
			triangle.pointA = *point;
			continue;
		}

		if (index == 1)
		{
			triangle.pointB = *point;
			continue;
		}
		triangle.pointC = *point;

	//	if (index == 2)
	//	{
	//		reverse = inkPointPerp(inkPointSubtract(triangle.pointB, triangle.pointA), inkPointSubtract(triangle.pointC, triangle.pointB)) > 0.0f;
	//	}

		//if (clockwise == true)
		//{
		val = inkPointPerp(inkPointSubtract(triangle.pointB, triangle.pointA), inkPointSubtract(triangle.pointC, triangle.pointB));
		if (val > 0.0f && clockwise == true)
			return false;
		else if (val <= 0.0f && clockwise == false)
			return false;
		/*	{
				return false;
			}
		}
		else
		{
			if (inkPointPerp(inkPointSubtract(triangle.pointB, triangle.pointA), inkPointSubtract(triangle.pointC, triangle.pointB)) < 0.0f)
			{
				return false;
			}
		}*/

		triangle.pointA = triangle.pointB;
		triangle.pointB = triangle.pointC;
	}

    return true;
}
