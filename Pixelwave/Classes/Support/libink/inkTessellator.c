//
//  inkTessellator.c
//  ink
//
//  Created by John Lattin on 11/9/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkTessellator.h"

#include "inkGLU.h"

typedef struct
{
	GLdouble x;
	GLdouble y;
	GLdouble z;
} inkTessellatorGLUVertex;

inkInline inkTessellatorGLUVertex inkTessellatorGLUVertexMake(float x, float y)
{
	inkTessellatorGLUVertex vertex;

	vertex.x = (GLdouble)x;
	vertex.y = (GLdouble)y;
	vertex.z = 0.0;

	return vertex;
}

inkInline void inkTessellatorInitialize(inkTessellator* tessellator);

inkInline void inkTessellatorClearTemporaryVertices(inkTessellator* tessellator);
inkInline INKvertex* inkTessellatorAddTemporaryVertex(inkTessellator* tessellator);

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

		tessellator->vertexPtrs = inkArrayCreate(sizeof(INKvertex*));

		if (tessellator->vertexPtrs == NULL)
		{
			inkTessellatorDestroy(tessellator);
			return NULL;
		}

		tessellator->glData = inkPresetGLDataDefault;
		tessellator->currentRenderGroup = NULL;
		tessellator->polygonBegan = false;
		tessellator->contourBegan = false;
		tessellator->isStroke = false;
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

		inkTessellatorClearTemporaryVertices(tessellator);
		inkArrayDestroy(tessellator->vertexPtrs);

		free(tessellator);
	}
}

inkInline void inkTessellatorClearTemporaryVertices(inkTessellator* tessellator)
{
	if (tessellator->vertexPtrs)
	{
		INKvertex* vertex;

		inkArrayPtrForEach(tessellator->vertexPtrs, vertex)
		{
			free(vertex);
		}

		inkArrayClear(tessellator->vertexPtrs);
	}
}

inkInline INKvertex* inkTessellatorAddTemporaryVertex(inkTessellator* tessellator)
{
	INKvertex* vertex = calloc(1, sizeof(INKvertex));

	if (vertex == NULL)
		return NULL;

	INKvertex** vertexPtr = (INKvertex**)inkArrayPush(tessellator->vertexPtrs);

	if (vertexPtr == NULL)
	{
		free(vertex);
		return NULL;
	}

	*vertexPtr = vertex;

	return vertex;
}

inkInline void inkTessellatorInitialize(inkTessellator* tessellator)
{
	if (tessellator == NULL || tessellator->gluTessellator == NULL)
		return;

	GLUtesselator* gluTessellator = tessellator->gluTessellator;

	gluTessProperty(gluTessellator, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_ODD);

	gluTessCallback(gluTessellator, GLU_TESS_BEGIN_DATA, inkTessellatorBeginCallback);
	gluTessCallback(gluTessellator, GLU_TESS_END_DATA, inkTessellatorEndCallback);
	gluTessCallback(gluTessellator, GLU_TESS_VERTEX_DATA, inkTessellatorVertexCallback);
	gluTessCallback(gluTessellator, GLU_TESS_ERROR_DATA, inkTessellatorErrorCallback);
	gluTessCallback(gluTessellator, GLU_TESS_COMBINE_DATA, inkTessellatorCombineCallback);
}

void inkTessellatorSetWindingRule(inkTessellator* tessellator, inkWindingRule windingRule)
{
	if (tessellator == NULL)
		return;

	GLUtesselator* gluTessellator = tessellator->gluTessellator;

	switch(windingRule)
	{
		case inkWindingRule_EvenOdd:
			gluTessProperty(gluTessellator, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_ODD);
			break;
		case inkWindingRule_NonZero:
			gluTessProperty(gluTessellator, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_NONZERO);
			break;
		case inkWindingRule_Positive:
			gluTessProperty(gluTessellator, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_POSITIVE);
			break;
		case inkWindingRule_Negative:
			gluTessProperty(gluTessellator, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_NEGATIVE);
			break;
		case inkWindingRule_AbsGeqTwo:
			gluTessProperty(gluTessellator, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_ABS_GEQ_TWO);
			break;
		default:
			break;
	}
}

inkPresetGLData inkTessellatorGetGLData(inkTessellator* tessellator)
{
	if (tessellator == NULL)
		return inkPresetGLDataDefault;

	return tessellator->glData;
}

void inkTessellatorSetGLData(inkTessellator* tessellator, inkPresetGLData glData)
{
	if (tessellator == NULL)
		return;

	tessellator->glData = glData;
}

void inkTessellatorSetIsStroke(inkTessellator* tessellator, bool isStroke)
{
	if (tessellator == NULL)
		return;

	tessellator->isStroke = isStroke;
}

void inkTessellatorBegin(INKenum type, inkTessellator* tessellator)
{
	inkTessellatorBeginCallback(type, tessellator);
}

void inkTessellatorEnd(inkTessellator* tessellator)
{
	inkTessellatorEndCallback(tessellator);
}

void inkTessellatorVertex(void* vertex, inkTessellator* tessellator)
{
	inkTessellatorVertexCallback(vertex, tessellator);
}

void inkTessellatorError(INKenum error, inkTessellator*tessellator)
{
	inkTessellatorErrorCallback(error, tessellator);
}

void inkTessellatorCombine(double coords[3], INKvertex* vertexData[4], float weight[4], INKvertex** outData, inkTessellator* tessellator)
{
	inkTessellatorCombineCallback(coords, vertexData, weight, outData, tessellator);
}

void inkTessellatorBeginCallback(GLenum type, inkTessellator* tessellator)
{
	if (tessellator == NULL || tessellator->renderGroups == NULL)
		return;

	inkRenderGroup** renderGroupPtr = (inkRenderGroup**)inkArrayPush(tessellator->renderGroups);
	if (renderGroupPtr == NULL)
		return;

	*renderGroupPtr = inkRenderGroupCreate(type, tessellator->glData, tessellator->isStroke);
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

	INKvertex* currentVertex = inkRenderGroupNextVertex(tessellator->currentRenderGroup);

	if (currentVertex != NULL)
	{
		*currentVertex = *((INKvertex *)(vertex));
	}
}

void inkTessellatorErrorCallback(GLenum error, inkTessellator* tessellator)
{
	if (tessellator == NULL)
		return;

	printf("inkTessellatorErrorCallback:: error = %s\n", gluErrorString(error));
}

void inkTessellatorCombineCallback(GLdouble coords[3], INKvertex* vertexData[4], GLfloat weight[4], INKvertex** outData, inkTessellator* tessellator)
{
	if (tessellator == NULL || tessellator->vertexPtrs == NULL || outData == NULL)
		return;

	INKvertex* v0 = vertexData[0];
	INKvertex* v1 = vertexData[1];
	INKvertex* v2 = vertexData[2];
	INKvertex* v3 = vertexData[3];

	// Can't merge if all points given are null.
	if (v0 == NULL && v1 == NULL && v2 == NULL && v3 == NULL)
		return;

	// This will not have an array issue as inside it will make a pointer to
	// pointer array, thus saving the original pointer.
	INKvertex* vertex = inkTessellatorAddTemporaryVertex(tessellator);

	if (vertex == NULL)
		return;

	// Need to temporarly store in floats so that way when you have part of a
	// color, such as 255 * 0.33 and you add that to 255 * 0.67 it will still
	// come out to 255
	GLfloat r = 0.0f;
	GLfloat g = 0.0f;
	GLfloat b = 0.0f;
	GLfloat a = 0.0f;

	GLfloat s = 0.0f;
	GLfloat t = 0.0f;

	GLfloat w0 = weight[0];
	GLfloat w1 = weight[1];
	GLfloat w2 = weight[2];
	GLfloat w3 = weight[3];

	// This macro will guarantee only adding vertex values that exist. It is
	// faster to do this as a macro then in a loop, aka. this is the loop
	// unrolled.
#define inkTessellatorCombineVertex(_r_, _g_, _b_, _a_, _s_, _t_, _in_, _w_)\
{ \
	if (_in_ != NULL) \
	{ \
		_r_ += (_in_)->r * _w_; \
		_g_ += (_in_)->g * _w_; \
		_b_ += (_in_)->b * _w_; \
		_a_ += (_in_)->a * _w_; \
\
		_s_ += (_in_)->s * _w_; \
		_t_ += (_in_)->t * _w_; \
	} \
}

	// Color will be 0 by default as inkArrayPush will memset's to 0.
	inkTessellatorCombineVertex(r, g, b, a, s, t, v0, w0);
	inkTessellatorCombineVertex(r, g, b, a, s, t, v1, w1);
	inkTessellatorCombineVertex(r, g, b, a, s, t, v2, w2);
	inkTessellatorCombineVertex(r, g, b, a, s, t, v3, w3);

	vertex->x = coords[0];
	vertex->y = coords[1];

	// Rounding really shouldn't be needed as it should never exceed 255,
	// however with floating point rounding errors it is possible to get
	// slightly above 255 which would roll back around to 0 and thus fail.

	vertex->r = lroundf(r);
	vertex->g = lroundf(g);
	vertex->b = lroundf(b);
	vertex->a = lroundf(a);

	vertex->s = s;
	vertex->t = t;

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
	else
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

	inkTessellatorClearTemporaryVertices(tessellator);
}

void inkTessellatorBeginContour(inkTessellator* tessellator)
{
	if (tessellator == NULL || tessellator->gluTessellator == NULL)
		return;

	if (tessellator->contourBegan == true)
		inkTessellatorEndContour(tessellator);
	else
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

	//GLdouble v[] = {gluVertex.x, gluVertex.y, 0.0};
	//gluTessVertex(tessellator->gluTessellator, v, vertex);
	gluTessVertex(tessellator->gluTessellator, (GLdouble*)(&gluVertex), vertex);
}
