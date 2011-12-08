//
//  inkTypes.c
//  ink
//
//  Created by John Lattin on 11/17/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkTypes.h"

#include "inkGLU.h"

const inkPresetGLData inkPresetGLDataDefault = _inkPresetGLDataDefault;
const inkSpreadMethod inkSpreadMethodDefault = _inkSpreadMethodDefault;
const inkInterpolationMethod inkInterpolationMethodDefault = _inkInterpolationMethodDefault;
const inkGradientType inkGradientTypeDefault = _inkGradientTypeDefault;
const inkPathWinding inkPathWindingDefault = _inkPathWindingDefault;
const inkTriangleCulling inkTriangleCullingDefault = _inkTriangleCullingDefault;
const inkJointStyle inkJointStyleDefault = _inkJointStyleDefault;
const inkLineScaleMode inkLineScaleModeDefault = _inkLineScaleModeDefault;
const inkCapsStyle inkCapsStyleDefault = _inkCapsStyleDefault;

const inkRenderer inkRendererDefault = _inkRendererDefault;

inkRenderer inkRendererMake(inkStateFunction enableFunc, inkStateFunction disableFunc, inkStateFunction enableClientFunc, inkStateFunction disableClientFunc, inkGetBooleanFunction getBooleanFunc, inkGetFloatFunction getFloatFunc, inkGetIntegerFunction getIntegerFunc, inkPointSizeFunction pointSizeFunc, inkLineWidthFunction lineWidthFunc, inkTextureFunction textureFunc, inkGetTexParameterFunction getTexParamFunc, inkSetTexParameterFunction setTexParamFunc, inkPointerFunction vertexFunc, inkPointerFunction textureCoordinateFunc, inkPointerFunction colorFunc, inkDrawArraysFunction drawArraysFunc, inkDrawElementsFunction drawElementsFunc)
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

	return renderer;
}
