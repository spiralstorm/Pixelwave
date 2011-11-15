//
//  inkTessellator.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkTessellator.h"

#include "glu.h"

typedef struct
{
	double x;
	double y;
	double z;
} inkTessellatorGLUVertex;

inkInline inkTessellatorGLUVertex inkTessellatorGLUVertexMake(float x, float y)
{
	inkTessellatorGLUVertex vertex;

	vertex.x = (double)x;
	vertex.y = (double)y;
	vertex.z = 0.0;

	return vertex;
}

inkInline void inkTessellatorInitialize(inkTessellator* tessellator);

void inkTessellatorBeginCallback(GLenum type, inkTessellator* tessellator);
void inkTessellatorEndCallback(inkTessellator* tessellator);
void inkTessellatorVertexCallback(GLvoid* vertex, inkTessellator* tessellator);
void inkTessellatorErrorCallback(GLenum error, inkTessellator*tessellator);
void inkTessellatorCombineCallback(GLdouble coords[3], INKvertex* vertexData[4], GLfloat weight[4], INKvertex** outData, inkTessellator* tessellator);

inkTessellator *inkTessellatorCreate()
{
	inkTessellator *tessellator = malloc(sizeof(inkTessellator));

	if (tessellator != NULL)
	{
		tessellator->gluTessellator = gluNewTess();

		if (tessellator->gluTessellator == NULL)
		{
			inkTessellatorDestroy(tessellator);
			return NULL;
		}

		tessellator->combineVertices = inkArrayCreate(sizeof(INKvertex));

		if (tessellator->combineVertices == NULL)
		{
			inkTessellatorDestroy(tessellator);
			return NULL;
		}

		tessellator->currentRenderGroup = NULL;
		tessellator->polygonBegan = false;
		tessellator->contourBegan = false;
		inkTessellatorInitialize(tessellator);
	}

	return tessellator;
}

void inkTessellatorDestroy(inkTessellator* tessellator)
{
	if (tessellator != NULL)
	{
		if (tessellator->gluTessellator != NULL)
			gluDeleteTess(tessellator->gluTessellator);

		inkArrayDestroy(tessellator->combineVertices);

		free(tessellator);
	}
}

inkInline void inkTessellatorInitialize(inkTessellator* tessellator)
{
	if (tessellator == NULL || tessellator->gluTessellator == NULL)
		return;

	GLUtesselator* gluTessellator = tessellator->gluTessellator;

	gluTessProperty(gluTessellator, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_ODD);
	//gluTessProperty(gluTessellator, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_NONZERO);

	gluTessCallback(gluTessellator, GLU_TESS_BEGIN_DATA, inkTessellatorBeginCallback);
	gluTessCallback(gluTessellator, GLU_TESS_END_DATA, inkTessellatorEndCallback);
	gluTessCallback(gluTessellator, GLU_TESS_VERTEX_DATA, inkTessellatorVertexCallback);
	gluTessCallback(gluTessellator, GLU_TESS_ERROR_DATA, inkTessellatorErrorCallback);
	gluTessCallback(gluTessellator, GLU_TESS_COMBINE_DATA, inkTessellatorCombineCallback);
}

void inkTessellatorBeginCallback(GLenum type, inkTessellator* tessellator)
{
	if (tessellator == NULL || tessellator->renderGroups == NULL)
		return;

	inkRenderGroup** renderGroupPtr = (inkRenderGroup**)inkArrayPush(tessellator->renderGroups);
	*renderGroupPtr = inkRenderGroupCreate(type);
	tessellator->currentRenderGroup = *renderGroupPtr;
}

void inkTessellatorEndCallback(inkTessellator* tessellator)
{
	if (tessellator == NULL)
		return;

	// TODO: Implement? Not sure that we need to do anything here
}

void inkTessellatorVertexCallback(GLvoid* vertex, inkTessellator* tessellator)
{
	if (vertex == NULL || tessellator == NULL || tessellator->currentRenderGroup == NULL)
		return;

	INKvertex* currentVertex = (INKvertex *)inkArrayPush(tessellator->currentRenderGroup->vertices);
	*currentVertex = *((INKvertex *)(vertex));
}

void inkTessellatorErrorCallback(GLenum error, inkTessellator* tessellator)
{
	if (tessellator == NULL)
		return;

	printf("inkTessellatorErrorCallback:: error = %s\n", gluErrorString(error));
}

void inkTessellatorCombineCallback(GLdouble coords[3], INKvertex* vertexData[4], GLfloat weight[4], INKvertex** outData, inkTessellator* tessellator)
{
	if (tessellator == NULL || tessellator->combineVertices == NULL || outData == NULL)
		return;

	INKvertex* v0 = vertexData[0];
	INKvertex* v1 = vertexData[1];
	INKvertex* v2 = vertexData[2];
	INKvertex* v3 = vertexData[3];

	// Can't merge if all points given are null.
	if (v0 == NULL && v1 == NULL && v2 == NULL && v3 == NULL)
		return;

	INKvertex* vertex = inkArrayPush(tessellator->combineVertices);

	if (vertex == NULL)
		return;

	// Need to temporarly store in floats so that way when you have part of a
	// color, such as 255 * 0.33 and you add that to 255 * 0.67 it will still
	// come out to 255
	GLfloat r = 0.0f;
	GLfloat g = 0.0f;
	GLfloat b = 0.0f;
	GLfloat a = 0.0f;

	vertex->x = coords[0];
	vertex->y = coords[1];

	printf("combining, making (%f, %f)\n", vertex->x, vertex->y);

	GLfloat w0 = weight[0];
	GLfloat w1 = weight[1];
	GLfloat w2 = weight[2];
	GLfloat w3 = weight[3];

	// This macro will guarantee only adding vertex values that exist. It is
	// faster to do this as a macro then in a loop, aka. this is the loop
	// unrolled.
#define inkTessellatorCombineVertexColor(_r_, _g_, _b_, _a_, _in_, _w_)\
{ \
	if (_in_ != NULL) \
	{ \
		_r_ += _in_->r * _w_; \
		_g_ += _in_->g * _w_; \
		_b_ += _in_->b * _w_; \
		_a_ += _in_->a * _w_; \
	} \
}

	// Color will be 0 by default as inkArrayPush will memset's to 0.
	inkTessellatorCombineVertexColor(r, g, b, a, v0, w0);
	inkTessellatorCombineVertexColor(r, g, b, a, v1, w1);
	inkTessellatorCombineVertexColor(r, g, b, a, v2, w2);
	inkTessellatorCombineVertexColor(r, g, b, a, v3, w3);

	// Rounding really shouldn't be needed as it should never exceed 255,
	// however with floating point rounding errors it is possible to get
	// slightly above 255 which would roll back around to 0 and thus fail.

	vertex->r = lroundf(r);
	vertex->g = lroundf(g);
	vertex->b = lroundf(b);
	vertex->a = lroundf(a);

	// This would be ideal, however there are too many fail points for this to
	// work correctly.
	//vertex->r = (w0 * v0->r) + (w1 * v1->r) + (w2 * v2->r) + (w3 * v3->r);
	//vertex->g = (w0 * v0->g) + (w1 * v1->g) + (w2 * v2->g) + (w3 * v3->g);
	//vertex->b = (w0 * v0->b) + (w1 * v1->b) + (w2 * v2->b) + (w3 * v3->b);
	//vertex->a = (w0 * v0->a) + (w1 * v1->a) + (w2 * v2->a) + (w3 * v3->a);

	*outData = vertex;
}

void inkTessellatorBeginPolygon(inkTessellator* tessellator, inkArray *renderGroups)
{
	if (tessellator == NULL || tessellator->gluTessellator == NULL || renderGroups == NULL)
		return;

	if (tessellator->contourBegan == true)
		inkTessellatorEndContour(tessellator);

	if (tessellator->polygonBegan == true)
		inkTessellatorEndPolygon(tessellator);
	tessellator->polygonBegan = true;

	tessellator->renderGroups = renderGroups;

	gluTessBeginPolygon(tessellator->gluTessellator, tessellator);
}

void inkTessellatorEndPolygon(inkTessellator* tessellator)
{
	if (tessellator == NULL || tessellator->gluTessellator == NULL)
		return;

	if (tessellator->contourBegan == true)
		inkTessellatorEndContour(tessellator);

	if (tessellator->polygonBegan == false)
		return;
	tessellator->polygonBegan = false;

	gluTessEndPolygon(tessellator->gluTessellator);

	inkArrayClear(tessellator->combineVertices);
}

void inkTessellatorBeginContour(inkTessellator* tessellator)
{
	if (tessellator == NULL || tessellator->gluTessellator == NULL)
		return;

	if (tessellator->contourBegan == true)
		inkTessellatorEndContour(tessellator);
	tessellator->contourBegan = true;

	gluTessBeginContour(tessellator->gluTessellator);
} 

void inkTessellatorEndContour(inkTessellator* tessellator)
{
	if (tessellator == NULL || tessellator->gluTessellator == NULL)
		return;

	if (tessellator->contourBegan == false)
		return;
	tessellator->contourBegan = false;

	gluTessEndContour(tessellator->gluTessellator);
}

void inkTessellatorAddPoint(inkTessellator* tessellator, INKvertex* vertex)
{
	if (tessellator == NULL || tessellator->gluTessellator == NULL || vertex == NULL)
		return;

	inkTessellatorGLUVertex gluVertex = inkTessellatorGLUVertexMake(vertex->x, vertex->y);

	printf("gluVertex(%f, %f)\n", vertex->x, vertex->y);
	gluTessVertex(tessellator->gluTessellator, (double*)(&gluVertex), vertex);
}

/*void inkTessellatorExpandRenderGroup(inkTessellator* tessellator, inkRenderGroup* renderGroup)
{
	if (tessellator == NULL || tessellator->gluTessellator == NULL || renderGroup == NULL)
		return;

	inkArray* vertexArray = renderGroup->vertices;
	INKvertex* inkVertex = NULL;
	GLUtesselator* gluTessellator = tessellator->gluTessellator;
	inkTessellatorGLUVertex gluVertex;

	inkArrayForEach(vertexArray, inkVertex)
	{
		gluVertex = inkTessellatorGLUVertexMake(inkVertex->x, inkVertex->y);

		printf("gluVertex(%f, %f)\n", inkVertex->x, inkVertex->y);
		gluTessVertex(gluTessellator, (double*)(&gluVertex), inkVertex);
	}
}*/
