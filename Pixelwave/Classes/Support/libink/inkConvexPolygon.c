//
//  inkConvexPolygon.c
//  ink
//
//  Created by John Lattin on 12/28/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkConvexPolygon.h"

#include "inkRenderGroup.h"

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

inkConvexPolygon* inkConvexPolygonFromRenderGroup(inkRenderGroup* renderGroup)
{
	if (renderGroup == NULL)
		return NULL;

	if (renderGroup->vertices == NULL)
		return NULL;

	size_t count = inkArrayCount(renderGroup->vertices);
	if (count == 0)
		return NULL;

	inkArray* points = inkArrayCreate(sizeof(inkPoint));
	if (points == NULL)
		return NULL;

	inkConvexPolygon* convexPolygon = inkConvexPolygonCreate();
	if (convexPolygon == NULL)
	{
		inkArrayDestroy(points);
		return NULL;
	}

	inkVertex* vertex;
	inkPoint* pointPtr;
	inkPoint point;

	inkArrayForEach(renderGroup->vertices, vertex)
	{
		pointPtr = inkArrayPush(points);
		point = inkMatrixTransformPoint(renderGroup->invGLMatrix, vertex->pos);

		if (pointPtr != NULL)
		{
			*pointPtr = point;
		}

		pointPtr = inkArrayPush(convexPolygon->points);

		if (pointPtr != NULL)
		{
			*pointPtr = point;
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

	inkArrayUpdateCount(convexPolygon->points, k);

	return convexPolygon;
}

void inkConvexPolygons(inkCanvas* canvas, inkConvexPolygonGroup* polygonGroup, inkConvexPolygonMode mode)
{
	assert(canvas);

	inkArray* renderGroups = inkRenderGroups(canvas);
	inkRenderGroup* renderGroup;
	inkConvexPolygon* polygon;
	inkConvexPolygon** polygonPtr;

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

		polygon = inkConvexPolygonFromRenderGroup(renderGroup);

		if (polygon != NULL)
		{
			polygonPtr = (inkConvexPolygon**)inkArrayPush(polygonGroup->polygons);

			if (polygonPtr == NULL)
				inkConvexPolygonDestroy(polygon);
			else
				*polygonPtr = polygon;
		}
	}
}
