//
//  inkStroke.c
//  ink
//
//  Created by John Lattin on 11/10/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#include "inkStroke.h"

inkStroke inkStrokeMake(float thickness, bool pixelHinting, inkLineScaleMode scaleMode, inkCapsStyle caps, inkJointStyle joints, float miterLimit)
{
	inkStroke stroke;

	stroke.thickness = thickness;
	stroke.pixelHinting = pixelHinting;
	stroke.scaleMode = scaleMode;
	stroke.caps = caps;
	stroke.joints = joints;
	stroke.miterLimit = miterLimit;

	return stroke;
}
