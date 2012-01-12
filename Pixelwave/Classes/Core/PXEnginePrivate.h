/*
 *  _____                       ___                                            
 * /\  _ `\  __                /\_ \                                           
 * \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
 *  \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
 *   \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
 *    \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
 *     \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
 *       
 *           www.pixelwave.org + www.spiralstormgames.com
 *                            ~;   
 *                           ,/|\.           
 *                         ,/  |\ \.                 Core Team: Oz Michaeli
 *                       ,/    | |  \                           John Lattin
 *                     ,/      | |   |
 *                   ,/        |/    |
 *                 ./__________|----'  .
 *            ,(   ___.....-,~-''-----/   ,(            ,~            ,(        
 * _.-~-.,.-'`  `_.\,.',.-'`  )_.-~-./.-'`  `_._,.',.-'`  )_.-~-.,.-'`  `_._._,.
 * 
 * Copyright (c) 2011 Spiralstorm Games http://www.spiralstormgames.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
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
