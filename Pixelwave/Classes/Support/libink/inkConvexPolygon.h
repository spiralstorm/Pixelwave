//
//  inkConvexPolygon.h
//  ink
//
//  Created by John Lattin on 12/28/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_CONVEX_POLYGON_H_
#define _INK_CONVEX_POLYGON_H_

#include "inkHeader.h"

#include "inkArray.h"
#include "inkGeometry.h"

#include "inkCanvas.h"

typedef struct
{
	inkArray* points;
} inkConvexPolygon;

typedef struct
{
	inkArray* polygons;
} inkConvexPolygonGroup;

inkExtern inkConvexPolygon* inkConvexPolygonCreate();
inkExtern void inkConvexPolygonDestroy(inkConvexPolygon* polygon);

inkExtern void inkConvexPolygonGroupDestroy(inkConvexPolygonGroup* polygon);

#endif
