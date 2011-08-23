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

#ifndef PX_ENGINE_H
#define PX_ENGINE_H

#ifdef __cplusplus
extern "C" {
#endif

#include "PXGL.h"
#include "PXColorUtils.h"

@class UITouch;

@class PXObjectPool;
@class PXView;
@class PXStage;
@class PXDisplayObject;
@class PXTextureData;

//////////////
// Creation //
//////////////

void PXEngineInit(PXView *view);
void PXEngineDealloc( );
BOOL PXEngineIsInitialized( );

///////////////
// Main loop //
///////////////

// IN ORDER
void PXEngineDispatchTouchEvents( );
void PXEngineDispatchFrameEvents( );
void PXEngineDispatchRenderEvents( );
void PXEngineRender( );

//////////////////////////////////
// Dealing with the native view //
//////////////////////////////////

PXView *PXEngineGetView( );
float PXEngineGetViewWidth( );
float PXEngineGetViewHeight( );
void PXEngineUpdateViewSize();

void PXEngineSetMultiTouchEnabled(BOOL enabled);
	
//////////////////////////
// Content scale factor //
//////////////////////////
	
void PXEngineSetContentScaleFactor(float scale);
float PXEngineGetContentScaleFactor();
float PXEngineGetOneOverContentScaleFactor();
// TODO: Rename this to something like deviceScaleFactor
float PXEngineGetMainScreenScale();

////////
// GL //
////////

CGSize PXEngineGetScreenBufferSize();
void PXEngineGetScreenBufferPixels(int x, int y, int width, int height, void *pixels);

///////////////////////////////////
// Working with the stage / root //
///////////////////////////////////
	
void PXEngineConvertPointToStageOrientation(float *x, float *y);
PXStage *PXEngineGetStage( );

void PXEngineSetClearScreen(BOOL clear);
BOOL PXEngineShouldClearScreen();
void PXEngineSetClearColor(PXColor4f color);
PXColor4f PXEngineGetClearColor();

void PXEngineSetRoot(PXDisplayObject *root);
PXDisplayObject *PXEngineGetRoot( );

void PXEngineInvalidateStage();

/////////////////////////////
// Control the engine loop //
/////////////////////////////
	
void PXEngineSetRunning(bool val);
bool PXEngineGetRunning();

void PXEngineSetLogicFrameRate(float fps);
float PXEngineGetLogicFrameRate();
void PXEngineSetRenderFrameRate(float fps);
float PXEngineGetRenderFrameRate();

///////////////////////////////
// Broadcast event listeners //
///////////////////////////////
	
void PXEngineAddFrameListener(PXDisplayObject *displayObject);
void PXEngineRemoveFrameListener(PXDisplayObject *displayObject);
void PXEngineAddRenderListener(PXDisplayObject *displayObject);
void PXEngineRemoveRenderListener(PXDisplayObject *displayObject);

///////////////
// Rendering //
///////////////

void PXEngineRenderDisplayObject(PXDisplayObject *displayObject, bool transformationsEnabled, bool canBeUsedForTouches);

void PXEngineRenderToTexture(PXTextureData *textureData, PXDisplayObject *source, PXGLMatrix *matrix, PXGLColorTransform *colorTransform, CGRect *clipRect, BOOL smoothing, BOOL clearTexture);

///////////
// Utils //
///////////

PXObjectPool *PXEngineGetSharedObjectPool();

///////////
// Debug //
///////////

float _PXEngineDBGGetTimeBetweenFrames();
float _PXEngineDBGGetTimeBetweenLogic();
float _PXEngineDBGGetTimeBetweenRendering();
float _PXEngineDBGGetTimeWaiting();

#ifdef __cplusplus
}
#endif

#endif
