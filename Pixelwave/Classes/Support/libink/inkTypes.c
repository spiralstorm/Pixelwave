//
//  inkTypes.c
//  ink
//
//  Created by John Lattin on 11/17/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkTypes.h"

#include "inkGLU.h"

#define _inkRendererDefault {inkglEnable, inkglDisable, inkglEnableClientState, inkglDisableClientState, inkglGetBooleanv, inkglGetFloatv, inkglGetIntegerv, inkglPointSize, inkglLineWidth, inkglBindTexture, inkglGetTexParameteriv, inkglTexParameteri, inkglVertexPointer, inkglTexCoordPointer, inkglColorPointer, inkglDrawArrays, inkglDrawElements, inkglIsEnabled}

const inkPresetGLData inkPresetGLDataDefault = _inkPresetGLDataDefault;
const inkSpreadMethod inkSpreadMethodDefault = _inkSpreadMethodDefault;
const inkInterpolationMethod inkInterpolationMethodDefault = _inkInterpolationMethodDefault;
const inkGradientType inkGradientTypeDefault = _inkGradientTypeDefault;
const inkPathWinding inkPathWindingDefault = _inkPathWindingDefault;
const inkTriangleCulling inkTriangleCullingDefault = _inkTriangleCullingDefault;
const inkJointStyle inkJointStyleDefault = _inkJointStyleDefault;
const inkLineScaleMode inkLineScaleModeDefault = _inkLineScaleModeDefault;
const inkCapsStyle inkCapsStyleDefault = _inkCapsStyleDefault;

void inkglEnable(unsigned int cap) {glEnable(cap);}
void inkglDisable(unsigned int cap) {glDisable(cap);}
void inkglEnableClientState(unsigned int array) {glEnableClientState(array);}
void inkglDisableClientState(unsigned int array) {glDisableClientState(array);}
void inkglGetBooleanv(unsigned int pname, unsigned char *params) {glGetBooleanv(pname, params);}
void inkglGetFloatv(unsigned int pname, float *params) {glGetFloatv(pname, params);}
void inkglGetIntegerv(unsigned int pname, int *params) {glGetIntegerv(pname, params);}
void inkglPointSize(float size) {glPointSize(size);}
void inkglLineWidth(float width) {glLineWidth(width);}
void inkglBindTexture(unsigned int target, unsigned int texture) {glBindTexture(target, texture);}
void inkglGetTexParameteriv(unsigned int target, unsigned int pname, int *params) {glGetTexParameteriv(target, pname, params);}
void inkglTexParameteri(unsigned int target, unsigned int pname, int param) {glTexParameteri(target, pname, param);}
void inkglVertexPointer(int size, unsigned int type, int stride, const void *pointer) {glVertexPointer(size, type, stride, pointer);}
void inkglTexCoordPointer(int size, unsigned int type, int stride, const void *pointer) {glTexCoordPointer(size, type, stride, pointer);}
void inkglColorPointer(int size, unsigned int type, int stride, const void *pointer) {glColorPointer(size, type, stride, pointer);}
void inkglDrawArrays(unsigned int mode, int first, int count) {glDrawArrays(mode, first, count);}
void inkglDrawElements(unsigned int mode, int count, unsigned int type, const void *indices) {glDrawElements(mode, count, type, indices);}
bool inkglIsEnabled(unsigned int cap) {return glIsEnabled(cap);}

const inkRenderer inkRendererDefault = _inkRendererDefault;

inkRenderer inkRendererMake(inkStateFunction enableFunc, inkStateFunction disableFunc, inkStateFunction enableClientFunc, inkStateFunction disableClientFunc, inkGetBooleanFunction getBooleanFunc, inkGetFloatFunction getFloatFunc, inkGetIntegerFunction getIntegerFunc, inkPointSizeFunction pointSizeFunc, inkLineWidthFunction lineWidthFunc, inkTextureFunction textureFunc, inkGetTexParameterFunction getTexParamFunc, inkSetTexParameterFunction setTexParamFunc, inkPointerFunction vertexFunc, inkPointerFunction textureCoordinateFunc, inkPointerFunction colorFunc, inkDrawArraysFunction drawArraysFunc, inkDrawElementsFunction drawElementsFunc, inkIsEnabledFunction isEnabledFunc)
{
	inkRenderer renderer;

	renderer.enableFunc = enableFunc;
	renderer.disableFunc = disableFunc;
	renderer.enableClientFunc = enableClientFunc;
	renderer.disableClientFunc = disableClientFunc;
	renderer.getBooleanFunc = getBooleanFunc;
	renderer.getFloatFunc = getFloatFunc;
	renderer.getIntegerFunc = getIntegerFunc;
	renderer.pointSizeFunc = pointSizeFunc;
	renderer.lineWidthFunc = lineWidthFunc;
	renderer.textureFunc = textureFunc;
	renderer.getTexParamFunc = getTexParamFunc;
	renderer.setTexParamFunc = setTexParamFunc;
	renderer.vertexFunc = vertexFunc;
	renderer.textureCoordinateFunc = textureCoordinateFunc;
	renderer.colorFunc = colorFunc;
	renderer.drawArraysFunc = drawArraysFunc;
	renderer.drawElementsFunc = drawElementsFunc;
	renderer.isEnabledFunc = isEnabledFunc;

	return renderer;
}
