//
//  inkTessellator.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkTessellator.h"

#include "glu.h"

// TODO: Remove
#include "PXGLUtils.h"

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
	if (tessellator)
	{
		if (tessellator->gluTessellator != NULL)
			gluDeleteTess(tessellator->gluTessellator);

		inkRenderGroupDestroy(tessellator->currentRenderGroup);
		inkArrayClear(tessellator->combineVertices);

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

	//inkRenderGroupDestroy(tessellator->currentRenderGroup);
	inkRenderGroup** renderGroupPtr = (inkRenderGroup**)inkArrayPush(tessellator->renderGroups);
	*renderGroupPtr = inkRenderGroupCreate(sizeof(INKvertex), type);
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

	if (v0 == NULL && v1 == NULL && v2 == NULL && v3 == NULL)
		return;

	INKvertex* vertex = inkArrayPush(tessellator->combineVertices);

	if (vertex == NULL)
		return;

	vertex->x = coords[0];
	vertex->y = coords[1];

	GLfloat w0 = weight[0];
	GLfloat w1 = weight[1];
	GLfloat w2 = weight[2];
	GLfloat w3 = weight[3];

#define inkTessellatorCombineVertexColor(_out_, _in_, _w_)\
{ \
	if (_in_ != NULL) \
	{ \
		_out_->r += _in_->r * _w_; \
		_out_->g += _in_->g * _w_; \
		_out_->b += _in_->b * _w_; \
		_out_->a += _in_->a * _w_; \
	} \
}

	// Color will be 0 by default as inkArrayPush will memset's to 0.
	inkTessellatorCombineVertexColor(vertex, v0, w0);
	inkTessellatorCombineVertexColor(vertex, v1, w1);
	inkTessellatorCombineVertexColor(vertex, v2, w2);
	inkTessellatorCombineVertexColor(vertex, v3, w3);

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

void inkTessellatorExpandRenderGroup(inkTessellator* tessellator, inkRenderGroup* renderGroup)
{
	if (tessellator == NULL || tessellator->gluTessellator == NULL || renderGroup == NULL)
		return;

	inkTessellatorBeginContour(tessellator);

	inkArray* vertexArray = renderGroup->vertices;
	INKvertex* inkVertex = NULL;
	GLUtesselator* gluTessellator = tessellator->gluTessellator;
	inkTessellatorGLUVertex gluVertex;

	inkArrayForEach(vertexArray, inkVertex)
	{
		gluVertex = inkTessellatorGLUVertexMake(inkVertex->x, inkVertex->y);

		gluTessVertex(gluTessellator, (double*)(&gluVertex), inkVertex);
	}

	inkTessellatorEndContour(tessellator);

	/*inkRenderGroup* tessellatedGroup = tessellator->currentRenderGroup;

	if (tessellatedGroup == NULL)
		return;

	INKvertex* loopVertex;

	renderGroup->glDrawMode = tessellatedGroup->glDrawMode;

	inkArrayClear(renderGroup->vertices);

	inkArrayForEach(tessellatedGroup->vertices, loopVertex)
	{
		inkVertex = (INKvertex*)inkArrayPush(renderGroup->vertices);
		*inkVertex = *loopVertex;
	}*/
}
