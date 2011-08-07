/*
 *  PXEnginePrivate.h
 *  Pixelwave
 *
 *  Created by John Lattin on 8/2/11.
 *  Copyright 2011 Spiralstorm Games. All rights reserved.
 *
 */

#ifndef PX_ENGINE_PRIVATE_H
#define PX_ENGINE_PRIVATE_H

#pragma mark -
#pragma mark Includes
#pragma mark -

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UITouch.h>

#include "PXGLPrivate.h"
#include "PXMathUtils.h"
#include "PXPrivateUtils.h"
#include "PXSettings.h"

#include "PXEngineUtils.h"

#import "PXStage.h"
#import "PXView.h"
#import "PXDisplayObject.h"
#import "PXTextureData.h"
#import "PXLinkedList.h"
#import "PXObjectPool.h"
#import "PXSoundEngine.h"
#import "PXTouchEvent.h"
#import "PXSprite.h"
#import "PXPoint.h"

#import "PXEventDispatcher.h"

#import "PXDebugUtils.h"
#import "PXExceptionUtils.h"

#include "PXHeaderUtils.h"
#include "PXColorUtils.h"

#pragma mark -
#pragma mark Macros
#pragma mark -

#define PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(_x_, _y_, _stage_) \
{ \
	PXStageOrientation _orientation_ = _stage_.orientation; \
\
	if (_orientation_ == PXStageOrientation_PortraitUpsideDown) \
	{ \
		(_x_) = _stage_.stageWidth  - (_x_); \
		(_y_) = _stage_.stageHeight - (_y_); \
	} \
	else if (_orientation_ == PXStageOrientation_LandscapeLeft) \
	{ \
		float _oldX_ = _x_; \
		(_x_) = _stage_.stageWidth - (_y_); \
		(_y_) = _oldX_; \
	} \
	else if (_orientation_ == PXStageOrientation_LandscapeRight) \
	{ \
		float _oldX_ = _x_; \
		(_x_) = (_y_); \
		(_y_) = _stage_.stageHeight - _oldX_; \
	} \
}

#define PX_ENGINE_CONVERT_POINT_FROM_STAGE_ORIENTATION(_x_, _y_, _stage_) \
{ \
	PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(_x_, _y_, _stage_); \
	PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(_x_, _y_, _stage_); \
	PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(_x_, _y_, _stage_); \
}

#define PX_ENGINE_CONVERT_AABB_TO_STAGE_ORIENTATION(_aabb_, _stage_) \
{ \
	PXStageOrientation _orientation_ = _stage_.orientation; \
	int _stageWidth_  = _stage_.stageWidth; \
	int _stageHeight_ = _stage_.stageHeight; \
\
	if (_orientation_ == PXStageOrientation_PortraitUpsideDown) \
	{ \
		float _xMin_ = (_aabb_)->xMin; \
		float _xMax_ = (_aabb_)->xMax; \
		float _yMin_ = (_aabb_)->yMin; \
		float _yMax_ = (_aabb_)->yMax; \
\
		(_aabb_)->xMin = _stageWidth_  - _xMax_; \
		(_aabb_)->xMax = _stageWidth_  - _xMin_; \
		(_aabb_)->yMin = _stageHeight_ - _yMax_; \
		(_aabb_)->yMax = _stageHeight_ - _yMin_; \
	} \
	else if (_orientation_ == PXStageOrientation_LandscapeLeft) \
	{ \
		float _xMin_ = (_aabb_)->xMin; \
		float _xMax_ = (_aabb_)->xMax; \
		float _yMin_ = (_aabb_)->yMin; \
		float _yMax_ = (_aabb_)->yMax; \
\
		(_aabb_)->xMin = _stageWidth_ - _yMax_; \
		(_aabb_)->xMax = _stageWidth_ - _yMin_; \
		(_aabb_)->yMin = _xMin_; \
		(_aabb_)->yMax = _xMax_; \
	} \
	else if (_orientation_ == PXStageOrientation_LandscapeRight) \
	{ \
		float _xMin_ = (_aabb_)->xMin; \
		float _xMax_ = (_aabb_)->xMax; \
\
		(_aabb_)->xMin = (_aabb_)->yMin; \
		(_aabb_)->xMax = (_aabb_)->yMax; \
		(_aabb_)->yMin = _stageHeight_ - _xMax_; \
		(_aabb_)->yMax = _stageHeight_ - _xMin_; \
	} \
}

#define PX_ENGINE_CONVERT_AABB_FROM_STAGE_ORIENTATION(_aabb_, _stage_) \
{ \
	PX_ENGINE_CONVERT_AABB_TO_STAGE_ORIENTATION(_aabb_, _stage_); \
	PX_ENGINE_CONVERT_AABB_TO_STAGE_ORIENTATION(_aabb_, _stage_); \
	PX_ENGINE_CONVERT_AABB_TO_STAGE_ORIENTATION(_aabb_, _stage_); \
}

#pragma mark -
#pragma mark Structs
#pragma mark -

typedef struct
{
	unsigned size;
	unsigned maxSize;
	PXDisplayObject **array;
} _PXEngineDisplayObjectBuffer;

#pragma mark -
#pragma mark Variables
#pragma mark -

PXExtern PXStage *pxEngineStage;							//Strongly referenced
PXExtern PXDisplayObject *pxEngineRoot;						//Weakly referenced
PXExtern PXView *pxEngineView;								//Weakly referenced

PXExtern _PXEngineDisplayObjectBuffer pxEngineDOBuffer;
PXExtern PXDisplayObject **pxEngineDOBufferCurrentObject;

PXExtern unsigned pxEngineDOBufferMaxSize;
PXExtern unsigned pxEngineDOBufferOldMaxSize;

PXExtern void PXTouchEngineDispatchTouchEvents();

#endif
