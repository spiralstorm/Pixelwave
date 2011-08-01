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

#include "PXEngine.h"

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

#define PX_ENGINE_MIN_BUFFER_SIZE 4
#define PX_ENGINE_MIN_FRAME_RATE 30

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

/**
 *	@internal
 */
@interface PXEngine : NSObject
{
@private
	id displayLink;
	short displayLinkInterval;
	BOOL displayLinkSupported;
	
	NSTimer *animationTimer;
}

- (void) updateMainLoopInterval;
@end

void PXEngineUpdateMainLoopInterval();

void PXEngineOnFrame( );
void PXEngineRenderStage( );

PXTouchEvent *pxEngineNewTouchEventWithTouch(UITouch *touch, CGPoint *pos, NSString *type, BOOL orientTouch);

// A dictionary which holds the associations between a UITouch and the object
// which captured it.
CFMutableDictionaryRef pxEngineTouchCapturingObjects = NULL;

PXObjectPool *pxEngineSharedObjectPool = nil;

PXLinkedList *pxEngineCachedListeners = nil;			//Strongly referenced
PXLinkedList *pxEngineFrameListeners = nil;				//Strongly referenced
PXLinkedList *pxEngineTouchEvents = nil;				//Strongly referenced
PXLinkedList *pxEngineSavedTouchEvents = nil;			//Strongly referenced
PXLinkedList *pxEngineRemoveFromSavedTouchEvents = nil;	//Strongly referenced
PXLinkedList *pxEngineRemoveFromCaptureTouchEvents = nil;//Strongly referenced

PXEvent *pxEngineEnterFrameEvent = nil;					//Strongly referenced
PXStage *pxEngineStage = nil;							//Strongly referenced
PXEngine *pxEngine = nil;								//Strongly referenced
PXDisplayObject *pxEngineRoot = nil;					//Weakly referenced
PXView *pxEngineView = nil;								//Weakly referenced

bool pxEngineInitialized = false;
bool pxEngineShouldClear = false;
bool pxEngineIsRunning = false;

// Render to texture frame buffer object
GLuint pxEngineRTTFBO = 0;

// This value may change later on. Currently 60HZ is the max screen refresh
// rate for any iDevice
float pxEngineMaxFrameRate = 60.0f;
const float pxEngineMaxDT = 1.0f / PX_ENGINE_MIN_FRAME_RATE;
float pxEngineMaxFrameRateSeconds = 1.0f; // Defined in PXEngineInit
float pxEngineMinFrameRateSeconds = 0.01;

float pxEngineMainDT = 0.0f;
float pxEngineRenderDT = 0.0f;
float pxEngineRenderTimeAccum = 0.0f;
float pxEngineLogicDT = 0.0f;
float pxEngineLogicTimeAccum = 0.0f;

// The size of the view in POINTS. Always in PORTRAIT
CGSize pxEngineViewSize;
PXColor4f pxEngineClearColor = {1.0f, 1.0f, 1.0f, 1.0f}; // Initialize to white

#ifdef PX_DEBUG_MODE
float pxEngineTimeBetweenFrames = 0.0f;
float pxEngineTimeBetweenLogic = 0.0f;
float pxEngineTimeBetweenRendering = 0.0f;
float pxEngineTimeWaiting = 0.0f;
#endif

#if (PX_ENGINE_IDLE_TIME_INCLUDES_BETWEEN_SYSTEM_CALLS)
NSTimeInterval pxEngineInterval = 0.0f;
#endif

typedef struct
{
	unsigned size;
	unsigned maxSize;
	PXDisplayObject **array;
} _PXEngineDisplayObjectBuffer;

_PXEngineDisplayObjectBuffer pxEngineDOBuffer;
PXDisplayObject **pxEngineDOBufferCurrentObject = NULL;


unsigned pxEngineDOBufferMaxSize = 0;
unsigned pxEngineDOBufferOldMaxSize = 0;

void PXEngineInit(PXView *view)
{
	if (pxEngine)
		return;

#ifdef PIXELWAVE_DEBUG
	PXDebug.logErrors = YES;
#endif

	///////////////
	// Top Level //
	///////////////

	_PXTopLevelInitialize();

	////////
	// ?? //
	////////

	pxEngineDOBuffer.size = 0;
	pxEngineDOBuffer.maxSize = PX_ENGINE_MIN_BUFFER_SIZE;
	pxEngineDOBuffer.array = malloc(sizeof(PXDisplayObject *) * pxEngineDOBuffer.maxSize);
	pxEngineDOBufferCurrentObject = pxEngineDOBuffer.array;

	///////////
	// Timer //
	///////////

	pxEngine = [PXEngine new];
	pxEngineView = view;
	
	// view.bounds are measured in PIXELS by Cocoa
	pxEngineViewSize = view.bounds.size;
	
	// pxEngineViewSize should be in POINTS, convert:
	float contentScaleFactor = pxEngineView.contentScaleFactor;
	float one_contentScaleFactor = 1.0f / contentScaleFactor;
	pxEngineViewSize.width  *= one_contentScaleFactor;
	pxEngineViewSize.height *= one_contentScaleFactor;

	//////////////////////
	// Rendering System //
	//////////////////////

	PXGLInit(pxEngineViewSize.width, pxEngineViewSize.height, contentScaleFactor);

	// Create a frame buffer to use for renderToTexture
	glGenFramebuffersOES(1, &pxEngineRTTFBO);

	////////////
	// Events //
	////////////

	pxEngineTouchCapturingObjects = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

	// Initialized with weak references so that DisplayObjects with an
	// ENTER_FRAME listener can get deallocated when they leave the Display
	// list. It's the object's responsibility to remove all of the event
	// listeners it added once it gets deallocated.
	pxEngineFrameListeners = [[PXLinkedList alloc] initWithWeakReferences:YES];

	pxEngineCachedListeners = [[PXLinkedList alloc] init];
	pxEngineTouchEvents = [[PXLinkedList alloc] init];
	pxEngineSavedTouchEvents = [[PXLinkedList alloc] init];
	pxEngineRemoveFromSavedTouchEvents = [[PXLinkedList alloc] init];
	pxEngineRemoveFromCaptureTouchEvents = [[PXLinkedList alloc] init];

	// Create a reusable enter frame event instead of creating one every frame.
	pxEngineEnterFrameEvent = [[PXEvent alloc] initWithType:PXEvent_EnterFrame
												 doesBubble:NO
											   isCancelable:NO];

	//////////
	// Misc //
	//////////

	// Seed the random number generator
#if (PX_SEED_RAND_WITH_TIME_ON_INIT)
	PXMathSeedRandomWithTime();
#endif

	//////////////////
	// Display List //
	//////////////////

	// Create the stage
	pxEngineStage = [[PXStage alloc] init];
	pxEngineIsRunning = true;
	PXEngineSetRenderFrameRate(30.0f);
	PXEngineSetLogicFrameRate(30.0f);
	PXEngineSetClearScreen(YES);

	////////////////
	// The Toggle //
	////////////////

	pxEngineInitialized = true;

	// Create the root
	PXSprite *defaultRoot = [PXSprite new];
	PXEngineSetRoot(defaultRoot);
	[defaultRoot release];

	//PXSoundEngineInit();
}

void PXEngineDealloc( )
{
	PXSoundEngineDealloc();

	// Backwards of init()
	if (pxEngineSharedObjectPool)
	{
		[pxEngineSharedObjectPool release];
		pxEngineSharedObjectPool = nil;
	}

	pxEngineRoot = nil;
	[pxEngineStage release];
	pxEngineStage = nil;

	[pxEngineEnterFrameEvent release];
	pxEngineEnterFrameEvent = nil;

	[pxEngineRemoveFromSavedTouchEvents release];
	pxEngineRemoveFromSavedTouchEvents = nil;
	[pxEngineRemoveFromCaptureTouchEvents release];
	pxEngineRemoveFromCaptureTouchEvents = nil;

	// Loops through each of the saved touches, and releases their hold on the
	// target.  This is used in checking if the finger was released inside or
	// outside of the bounding area of the first target.

	PXTouchEvent *savedTouch;
	PXLinkedListForEach(pxEngineSavedTouchEvents, savedTouch)
	{
		[savedTouch->_target release];
	}

	[pxEngineSavedTouchEvents release];
	pxEngineSavedTouchEvents = nil;

	[pxEngineTouchEvents release];
	pxEngineTouchEvents = nil;
	[pxEngineCachedListeners release];
	pxEngineCachedListeners = nil;
	[pxEngineFrameListeners release];
	pxEngineFrameListeners = nil;

	// Get rid of the render-to-texture buffer
	if (pxEngineRTTFBO != 0)
		glDeleteFramebuffersOES(1, &pxEngineRTTFBO);
	pxEngineRTTFBO = 0;

	PXGLDealloc( );

	CFRelease(pxEngineTouchCapturingObjects);
	pxEngineTouchCapturingObjects = NULL;

	[pxEngine dealloc];
	pxEngine = nil;

	pxEngineView = nil;

	if (pxEngineDOBuffer.array)
	{
		PXDisplayObject **curDisplayObject;
		unsigned index;
		for (index = 0, curDisplayObject = pxEngineDOBuffer.array; index < pxEngineDOBuffer.size; ++index, ++curDisplayObject)
		{
			[(*curDisplayObject) release];
		}

		free(pxEngineDOBuffer.array);
		pxEngineDOBuffer.array = 0;
		pxEngineDOBufferCurrentObject = 0;
	}

	_PXTopLevelDealloc();

	pxEngineInitialized = false;
}

PXDisplayObject **PXEngineNextBufferObject( )
{
	// Check to see if our size (you could also think of this as the current
	// index for our purposes) is at the end of the array.  If so, then we need
	// to increase the size of the array.
	if (pxEngineDOBuffer.size == pxEngineDOBuffer.maxSize)
	{
		//Lets double the size of the array
		pxEngineDOBuffer.maxSize <<= 1;
		pxEngineDOBuffer.array = realloc(pxEngineDOBuffer.array, sizeof(PXDisplayObject *) * pxEngineDOBuffer.maxSize);
		pxEngineDOBufferCurrentObject = pxEngineDOBuffer.array + pxEngineDOBuffer.size;
	}

	PXDisplayObject **cur = pxEngineDOBufferCurrentObject;
	++pxEngineDOBufferCurrentObject;
	++(pxEngineDOBuffer.size);
	//Lets return the next available vertex for use.
	return cur;
}

PXView *PXEngineGetView( )
{
	return pxEngineView;
}
float PXEngineGetViewWidth( )
{
	return pxEngineViewSize.width;
}

float PXEngineGetViewHeight( )
{
	return pxEngineViewSize.height;
}

// TODO Later: This does not work properly, it may not be needed.
void PXEngineUpdateViewSize()
{
	return;

	//pxEngineViewSize = pxEngineView.bounds.size;

	//float contentScaleFactor = pxEngineView.contentScaleFactor;
	//float one_contentScaleFactor = 1.0f / contentScaleFactor;

	//pxEngineViewSize.width  *= one_contentScaleFactor;
	//pxEngineViewSize.height *= one_contentScaleFactor;

	//PXGLSetViewSize(pxEngineViewSize.width, pxEngineViewSize.height, contentScaleFactor);
}

void PXEngineConvertPointToStageOrientation(float *x, float *y)
{
	if (x && y)
	{
		PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(*x, *y, pxEngineStage);
	}
}

PXStage *PXEngineGetStage( )
{
	return pxEngineStage;
}

void PXEngineSetContentScaleFactor(float scale)
{
	PXGLSetViewSize(pxEngineViewSize.width, pxEngineViewSize.height, scale, true);
}
/// The content scale factor of the main view
float PXEngineGetContentScaleFactor()
{
	return PXGLGetContentScaleFactor();
}
float PXEngineGetOneOverContentScaleFactor()
{
	return PXGLGetOneOverContentScaleFactor();
}
/// The content scale factor of the device
float PXEngineGetMainScreenScale()
{
	float screenScaleFactor = 1.0f;
#ifdef __IPHONE_4_0
	NSString *reqSysVer = @"4.0";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
		screenScaleFactor = [UIScreen mainScreen].scale;
#endif
	return screenScaleFactor;
}

void PXEngineSetMultiTouchEnabled(BOOL enabled)
{
	pxEngineView.multipleTouchEnabled = enabled;
}

void PXEngineSetRoot(PXDisplayObject *root)
{
	if (!root)
		return;

	if (root == pxEngineRoot)
		return;

	[root retain];
	if (pxEngineRoot)
		[pxEngineStage removeChild:pxEngineRoot];

	pxEngineRoot = root;
	[pxEngineStage addChild:pxEngineRoot];
	[pxEngineRoot setName:@"root1"];
	[root release];
}

PXDisplayObject *PXEngineGetRoot( )
{
	return pxEngineRoot;
}

BOOL PXEngineIsInitialized( )
{
	return pxEngineInitialized;
}

#pragma mark Clearing the screen

void PXEngineSetClearScreen(BOOL clear)
{
	pxEngineShouldClear = clear;
}

BOOL PXEngineShouldClearScreen( )
{
	return pxEngineShouldClear;
}

void PXEngineSetClearColor(PXColor4f color)
{
	pxEngineClearColor = color;
}
PXColor4f PXEngineGetClearColor()
{
	return pxEngineClearColor;
}

/*
void PXEngineSetTimerInterval(float seconds)
{
	[pxEngine startAnimationWithInterval:1.0f / seconds];
}

void PXEngineSetTimerStep(float dt)
{
	pxEngineRenderDT = dt;
	pxEngineRenderDTAccum = 0.0f;
}
*/

#pragma mark Setting the Frame Rate

void PXEngineUpdateMainLoopInterval()
{
	pxEngineMainDT = PXMathMin(pxEngineLogicDT, pxEngineRenderDT);

	float minDT = 1.0f / pxEngineMaxFrameRate;
	float index = 2.0f;
	float startDT = minDT;
	float lastDT = startDT;

	while (startDT < pxEngineMainDT)
	{
		lastDT = startDT;
		startDT = 1.0f / (pxEngineMaxFrameRate / index);

		index += 1.0f;
	}
	startDT = lastDT;
	pxEngineMainDT = startDT;

	// Make sure the real timer interval never goes under the minimum frame rate
	// @see PX_ENGINE_MIN_FRAME_RATE
	if (pxEngineMainDT > pxEngineMaxDT)
		pxEngineMainDT = pxEngineMaxDT;
	else if (pxEngineMainDT < minDT)
		pxEngineMainDT = minDT;	

	[pxEngine updateMainLoopInterval];
}

void PXEngineSetLogicFrameRate(float fps)
{
	fps = roundf(fps);

	if (PXMathIsZero(fps))
	{
		pxEngineLogicDT = 0.0f;
	}
	else
	{
		if (fps < pxEngineMinFrameRateSeconds)
			fps = pxEngineMinFrameRateSeconds;
		else if (fps > pxEngineMaxFrameRate)
			fps = pxEngineMaxFrameRate;

		pxEngineLogicDT = 1.0f / fps;
	}

	PXEngineUpdateMainLoopInterval();
}
float PXEngineGetLogicFrameRate()
{
	if (PXMathIsZero(pxEngineLogicDT))
		return 0.0f;

	return 1.0f / pxEngineLogicDT;
}

void PXEngineSetRenderFrameRate(float fps)
{
	fps = roundf(fps);

	if (PXMathIsZero(fps))
	{
		pxEngineRenderDT = 0.0f;
	}
	else
	{
		if (fps < pxEngineMinFrameRateSeconds)
			fps = pxEngineMinFrameRateSeconds;
		else if (fps > pxEngineMaxFrameRate)
			fps = pxEngineMaxFrameRate;

		pxEngineRenderDT = 1.0f / fps;
	}

	PXEngineUpdateMainLoopInterval();
}
float PXEngineGetRenderFrameRate()
{
	if (PXMathIsZero(pxEngineRenderDT))
		return 0.0f;

	return 1.0f / pxEngineRenderDT;
}

/**
 *	Plays and pauses the engine
 */
void PXEngineSetRunning(bool val)
{
	pxEngineIsRunning = val;
	PXEngineUpdateMainLoopInterval();
}
bool PXEngineGetRunning()
{
	return pxEngineIsRunning;
}

#pragma mark Registering Frame Event Listeners

void PXEngineAddFrameListener(PXDisplayObject *displayObject)
{
	if (!pxEngineFrameListeners)
		return;

	[pxEngineFrameListeners addObject:displayObject];
}

void PXEngineRemoveFrameListener(PXDisplayObject *displayObject)
{
	if (!pxEngineFrameListeners)
		return;

	[pxEngineFrameListeners removeObject:displayObject];
}

#pragma mark -
#pragma mark TOUCHES
#pragma mark -

/**
 *	The function first cycles through all the display objects on the screen in
 *	reverse order, looking for the most immediate target of a touch event, and
 *	then traverses up the display hierarchy until it finds an interactive object
 *	for which touches are enabled.
 *		- Beken, Pixelwave forums
 *
 *	Returns the displayObject that should recieve the event (could be nil)
 */
PXDisplayObject *PXEngineFindTouchTarget(float x, float y)
{
	PXDisplayObject *target;
	PXDisplayObjectContainer *parent;
	PXDisplayObject *possibleParentTarget = nil;
	PXGLAABB *aabb;

	BOOL touchEnabled = NO;
	// Keeps track of if the current target can recieve touch events
	BOOL origTouchEnabled = NO;
	BOOL parentTouchEnabled = NO;
	BOOL onceHadTarget = NO;

	bool usesCustomHitArea;

	PXDisplayObject **curDisplayObject;
	int index;
	int startIndex = pxEngineDOBuffer.size - 1;

	// Loop through the list of possible touch targets.
	// Since items were added to the list in back-to-front order, we iterate
	// backwards to go front-to-back.
	for (index = startIndex, curDisplayObject = &(pxEngineDOBuffer.array[startIndex]);
		 index >= 0;
		 --index, --curDisplayObject)
	{
		target = *curDisplayObject;

		aabb = &target->_aabb;

		usesCustomHitArea = PX_IS_BIT_ENABLED(target->_flags, _PXDisplayObjectFlags_useCustomHitArea);

		// Broad phase hit-test (AABB)
		// We only check for AABB containment if the disp doesn't have a custom
		// hit area. If there is a custom hit area, we can't rely only on the 
		// visual bounds for a hit test.
		if (!usesCustomHitArea && !PXGLAABBContainsPointv(aabb, x, y))
		{
			continue;
		}

		// Narrow phase - This is the expensive one.
		if (!([target _hitTestPointWithoutRecursionWithGlobalX:x globalY:y shapeFlag:YES]))
		{
			continue;
		}

		origTouchEnabled = PX_IS_BIT_ENABLED(target->_flags, _PXDisplayObjectFlags_isInteractive) ? ((PXInteractiveObject *)(target))->_touchEnabled : NO;
		touchEnabled = origTouchEnabled;

		parent = (PXDisplayObjectContainer *)(target->_parent);
		onceHadTarget = NO;

		// This checks if the parent is root, and it has touches enabled, but
		// not touch children. If true, then
		if (parent)
		{
			//parentTouchEnabled = PX_IS_BIT_ENABLED(parent->_flags, _PXDisplayObjectFlags_isInteractive) ? ((PXInteractiveObject *)(parent))->_touchEnabled : NO;
			parentTouchEnabled = parent->_touchEnabled;

			if (!(parent->_touchChildren) && parent == pxEngineRoot && parentTouchEnabled)
			{
				onceHadTarget = YES;
				possibleParentTarget = parent;
			}
		}

		// Now we loop up through the target's ancestors, stoping right before
		// the root. We do this so that the ancestor closest to target which can
		// recieve touch events gets to handle the touch.
		//
		// We stop short before root because....
		while (parent && parent != pxEngineRoot)
		{
			if (parent == possibleParentTarget)
			{
				onceHadTarget = YES;
			}

			//parentTouchEnabled = PX_IS_BIT_ENABLED(parent->_flags, _PXDisplayObjectFlags_isInteractive) ? ((PXInteractiveObject *)(parent))->_touchEnabled : NO;
			parentTouchEnabled = parent->_touchEnabled;

			// If the parent allows its chidren to recieve touch events
			if (parent->_touchChildren)
			{
				// If the target can't recieve touch events, but the parent can,
				// the parent becomes the current valid target, and we keep
				// going up the chain
				if (!touchEnabled && parentTouchEnabled)
				{
					possibleParentTarget = parent;
					onceHadTarget = YES;
					touchEnabled = parentTouchEnabled;
				}
			}
			else
			{
				// The target's parent doesn't allow touch events, which means
				// the target cannot be asociated with that event at all, make
				// the parent the new target
				target = parent;
				possibleParentTarget = nil;
				onceHadTarget = NO;
				// Update these value to reflect the new target
				touchEnabled = parentTouchEnabled;
				origTouchEnabled = parentTouchEnabled;
			}

			parent = parent->_parent;
		}

		// If along the traversal we found a target willing to accept the event
		// but the parent should recieve it, give it to the parent
		if (onceHadTarget && possibleParentTarget)
		{
			return possibleParentTarget;
		}

		// If there's no ancesstor of target stopping it from recieving the
		// event, let target have it.
		if (origTouchEnabled)
		{
			return target;
		}
	}

	if (possibleParentTarget != nil)
		PXDebugLog (@"PXEngineFindTouchTarget WARNING: possibleParentTarget != nil as expected\n");

	// TODO: John, check to see if this line can just return nil.
	// Look through the code and try to proove it won't fail
	return possibleParentTarget;
}

void PXEngineDispatchTouchEvents()
{
	if (pxEngineTouchEvents.count == 0)
	{
		return;
	}

	PXTouchEvent *originalEvent = nil;
	PXTouchEvent *savedEvent = nil;
	PXDisplayObject *target = pxEngineStage;
	PXDisplayObject *savedTarget = nil;
	PXTouchEvent *outOrCancelEvent;
	PXTouchEvent *doubleTapEvent;
	PXInteractiveObject *interactiveTarget;
	CGPoint pos;
	NSString *eventType = nil;

	bool didTouchUp     = false;
	bool didTouchCancel = false;
	bool didTouchDown   = false;
	bool didTouchUpOrCancel = false;

	id<NSObject> captureKey = NULL;
	id<PXEventDispatcherProtocol> captureTarget = NULL;

	CFDictionaryRef copiedDictionary = CFDictionaryCreateCopy(NULL, pxEngineTouchCapturingObjects);

	// This dictionary tracks who actually got the touch. In the case where the
	// same touch happens more then once a frame, we will automatically
	// associate it with the previous owner for this frame.
	CFMutableDictionaryRef localizedTouchSearchDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

	if (pxEngineStage->_touchChildren)
	{
		PXLinkedListForEach(pxEngineTouchEvents, originalEvent)
		{
			eventType = originalEvent.type;

			// Find what type of touch even this is
			didTouchDown = [eventType isEqualToString:PXTouchEvent_TouchDown];
			if (!didTouchDown)
			{
				didTouchUp = [eventType isEqualToString:PXTouchEvent_TouchUp];
				if (!didTouchUp)
					didTouchCancel = [eventType isEqualToString:PXTouchEvent_TouchCancel];
			}
			didTouchUpOrCancel = didTouchUp || didTouchCancel;

			// Grab the 'key' for the dictionary of captures, and the target
			captureKey = originalEvent.nativeTouch;
			captureTarget = (id<PXEventDispatcherProtocol>)CFDictionaryGetValue(localizedTouchSearchDictionary, captureKey);
			if (!captureTarget)
				captureTarget = (id<PXEventDispatcherProtocol>)CFDictionaryGetValue(copiedDictionary, captureKey);

			[captureKey retain];

			// If a capture target exists, then we don't need to find a new one
			if (captureTarget)
			{
				target = (PXDisplayObject *)captureTarget;
			}
			else
			{
				// Find the target at the position
				target = PXEngineFindTouchTarget(originalEvent.stageX, originalEvent.stageY);

				// If it is a down event, then we can set the capture
				if (didTouchDown && target && PX_IS_BIT_ENABLED(target->_flags, _PXDisplayObjectFlags_isInteractive))
				{
					// Only set the capture, if this target allows it.
					if (((PXInteractiveObject *)(target))->_captureTouches)
					{
						CFDictionarySetValue(pxEngineTouchCapturingObjects, captureKey, target);
					}
				}
			}

			// If the target exists and is not equal to the captured target,
			// then we need to check if it is a target that cares about captures
			// and it failed the on touch down, it means that the target was not
			// captured in touch down, thus it should not recieve these events.
			if (!didTouchDown && target && target != captureTarget)
			{
				if (PX_IS_BIT_ENABLED(target->_flags, _PXDisplayObjectFlags_isInteractive))
				{
					if (((PXInteractiveObject *)(target)).captureTouches)
					{
						target = NULL;
					}
				}
			}

			// If no target exists, send it to the stage!
			if (!target)
				target = pxEngineStage;

			// If the same touch has happened more than once this frame, we are
			// just going to automatically associate it with the previous owner.
			CFDictionarySetValue(localizedTouchSearchDictionary, captureKey, target);

			// Ok, this is pretty complicated.  If either the user touched up,
			// or down, we need to make this check.  If they touched down, then
			// we need to retain the target they were going for, if they are
			// touching up, we need to release it.  This is because we need to
			// ensure the object doesn't disappear prior to sending out the
			// event.
			if (didTouchUpOrCancel || didTouchDown)
			{
				// We remove BEFORE sending out any events so that if they
				// remove themselves from their parent, they will not then also
				// spawn a cancel event upwards which could cause an infinate
				// loop of cancel events.
				if (didTouchUpOrCancel)
					CFDictionaryRemoveValue(pxEngineTouchCapturingObjects, captureKey);

				// Go through each of the saved touch events, and check to see
				// if our native touch... meaning the touch given to us by the
				// UI device, is the same as the touch we are checking against.
				PXLinkedListForEach(pxEngineSavedTouchEvents, savedEvent)
				{
					if (savedEvent.nativeTouch == originalEvent.nativeTouch)
					{
						savedTarget = savedEvent->_target;

						// If our saved target isn't the same as our current
						// target, then we need to update the previous target.
						// Otherwise we need to release the event we are holding
						// so that we do not hold it into memory forever.
						if (savedTarget != target)
						{
							if (didTouchUpOrCancel && savedTarget)
							{
								// Make a cgpoint out of the position.
								pos = CGPointMake(savedEvent->_stageX, savedEvent->_stageY);
								// Make an event to dispatch upon releasing the
								// button outside of it's place.
								outOrCancelEvent = pxEngineNewTouchEventWithTouch(savedEvent->_nativeTouch,
																				  &pos,
																				  (didTouchUp ? PXTouchEvent_TouchOut : PXTouchEvent_TouchCancel),
																				  NO);

								[savedTarget dispatchEvent:outOrCancelEvent];
								[outOrCancelEvent release];

								// Make sure we release the target we kept a
								// retain on.
								[savedTarget release];
								savedEvent->_target = nil;
							}
							else
							{
								// If we had a previous saved target, we should
								// release it before swapping the pointer.
								if (savedTarget)
									[savedTarget release];

								// Lets retain it, so it can't die while we are
								// using it; then we should set the pointer.
								[target retain];
								savedEvent->_target = target;
							}
						}
						else if (didTouchUpOrCancel)
						{
							// We touched up in the same area we touched down
							// on, so we just need to release the target as no
							// out event will be sent.. the up event was already
							// sent also.
							[savedEvent->_target release];
							savedEvent->_target = nil;
							savedTarget = nil;
						}

						break;
					} // if (savedEvent.nativeTouch == event.nativeTouch)
				} // PXLinkedListForEach
			} // if (didTouchUpOrCancel || didTouchDown)

			if ([target isKindOfClass:[PXInteractiveObject class]])
				interactiveTarget = (PXInteractiveObject *)target;
			else
				interactiveTarget = nil;

			if ([eventType isEqualToString:PXTouchEvent_Tap] &&
				(interactiveTarget.doubleTapEnabled && savedEvent.tapCount == 2))
			{
				CGPointMake(savedEvent->_stageX, savedEvent->_stageY);
				// Make an event to dispatch upon releasing the
				// button outside of it's place.
				doubleTapEvent = pxEngineNewTouchEventWithTouch(savedEvent->_nativeTouch,
																&pos,
																PXTouchEvent_DoubleTap,
																NO);

				[target dispatchEvent:doubleTapEvent];
				[doubleTapEvent release];
			}
			else
			{
				originalEvent->_target = target;
				[target dispatchEvent:originalEvent];
			}

			[captureKey release];
		} // PXLinkedListForEach
	}
	else
	{
		PXLinkedListForEach(pxEngineTouchEvents, originalEvent)
		{
			originalEvent->_target = target;
			[target dispatchEvent:originalEvent];
		}
	}

	[pxEngineTouchEvents removeAllObjects];

	// Remove all saved touches
	PXLinkedListForEach(pxEngineRemoveFromSavedTouchEvents, originalEvent)
	{
		[pxEngineSavedTouchEvents removeObject:originalEvent];
	}
	[pxEngineRemoveFromSavedTouchEvents removeAllObjects];

	CFRelease(copiedDictionary);
	CFRelease(localizedTouchSearchDictionary);
}

void PXEngineDispatchFrameEvents()
{
	if (pxEngineFrameListeners.count == 0)
		return;

	PXDisplayObject *child = nil;

	// Dispatch it on all listeners (listeners must be PXDisplayObject's, but
	// aren't necessarily on the display list, don't have to have a non-nil
	// 'parent')
	PXLinkedListForEach(pxEngineFrameListeners, child)
	{
		[pxEngineCachedListeners addObject:child];
	}

	// From Flash API:
	// Note:	This event has neither a "capture phase" nor a "bubble phase",
	//			which means that event listeners must be added directly to any
	//			potential targets, whether the target is on the display list or
	//			not.
	PXLinkedListForEach(pxEngineCachedListeners, child)
	{
		// The enterFrame event doesn't follow the event flow, even though it's
		// dispatched into the display list in some cases
		[child _dispatchEventNoFlow:pxEngineEnterFrameEvent];
	}

	[pxEngineCachedListeners removeAllObjects];
}

/**
 *	The main rendering function. This renders the entire display list, starting
 *	at the stage, to the screen.
 */
void PXEngineRender()
{
	assert(pxEngineDOBuffer.array);
	unsigned index;
	PXDisplayObject **curDisplayObject;
	for (index = 0, curDisplayObject = pxEngineDOBuffer.array; index < pxEngineDOBuffer.size; ++index, ++curDisplayObject)
	{
		[*curDisplayObject release];
	}

	pxEngineDOBuffer.size = 0;

	if (pxEngineDOBufferMaxSize < (pxEngineDOBufferOldMaxSize >> 2))
	{
		int newMaxSize = pxEngineDOBuffer.maxSize >> 1;
		if (newMaxSize > PX_ENGINE_MIN_BUFFER_SIZE)
		{
			pxEngineDOBuffer.maxSize = newMaxSize;
			pxEngineDOBuffer.array = realloc(pxEngineDOBuffer.array, sizeof(PXDisplayObject *) * pxEngineDOBuffer.maxSize);
		}
	}

	pxEngineDOBufferOldMaxSize = pxEngineDOBufferMaxSize;
	pxEngineDOBufferMaxSize = 0;
	pxEngineDOBufferCurrentObject = pxEngineDOBuffer.array;

	if (pxEngineShouldClear)
	{
		glClearColor(pxEngineClearColor.r, pxEngineClearColor.g, pxEngineClearColor.b, pxEngineClearColor.a);
		glClear(GL_COLOR_BUFFER_BIT);
	}

	PXGLPreRender();
	//glPushMatrix();

#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_HalveStage))
	{
		/*
		glPushMatrix();
		glScalef(0.5f, 0.5f, 1.0f);
		glTranslatef(pxEngineViewSize.width * 0.5f, pxEngineViewSize.height * 0.5f, 0.0f);
		 */
		PXGLPushMatrix();
		PXGLTranslate(pxEngineViewSize.width * 0.5f, pxEngineViewSize.height * 0.5f);
		PXGLScale(0.5f, 0.5f);
	}
#endif

	PXEngineRenderDisplayObject(pxEngineStage, true, true);

#ifdef PX_DEBUG_MODE
	// Draw a magenta border around the smaller stage
	if (PXDebugIsEnabled(PXDebugSetting_HalveStage))
	{
		PXGLVertex vertices[4];

		float viewWidth  = pxEngineViewSize.width;
		float viewHeight = pxEngineViewSize.height;

		vertices[0] = PXGLVertexMake(0.0f, 0.0f);
		vertices[1] = PXGLVertexMake(0.0f, viewHeight);
		vertices[2] = PXGLVertexMake(viewWidth, viewHeight);
		vertices[3] = PXGLVertexMake(viewWidth, 0.0f);

		PXGLLineWidth(1.0f);
		PXGLShadeModel(GL_SMOOTH);
		PXGLDisable(GL_TEXTURE_2D);
		PXGLDisable(GL_POINT_SPRITE_OES);
		PXGLColor4ub(0xFF, 0x00, 0xFF, 0xFF);
		PXGLVertexPointer(2, GL_FLOAT, 0, vertices);
		PXGLDrawArrays(GL_LINE_LOOP, 0, 4);
		//PXGLFlush();

		PXGLPopMatrix();
	}

	if (PXDebugIsEnabled(PXDebugSetting_DrawBoundingBoxes))
	{
		PXGLVertex vertices[4];

		PXGLAABB aabb;
		PXGLAABB *aabbPtr;
		PXDisplayObject *doAABB;
		PXDisplayObject **curDisplayObject;

		for (index = 0, curDisplayObject = pxEngineDOBuffer.array; index < pxEngineDOBuffer.size; ++index, ++curDisplayObject)
		{
			doAABB = *curDisplayObject;

			if (!PX_IS_BIT_ENABLED(doAABB->_flags, _PXDisplayObjectFlags_shouldRenderAABB))
				continue;

			aabbPtr = &doAABB->_aabb;

			aabb.xMin = aabbPtr->xMin;
			aabb.xMax = aabbPtr->xMax;
			aabb.yMin = aabbPtr->yMin;
			aabb.yMax = aabbPtr->yMax;

			PX_ENGINE_CONVERT_AABB_FROM_STAGE_ORIENTATION(&aabb, pxEngineStage);

			vertices[0] = PXGLVertexMake(aabb.xMin, aabb.yMin);
			vertices[1] = PXGLVertexMake(aabb.xMin, aabb.yMax);
			vertices[2] = PXGLVertexMake(aabb.xMax, aabb.yMax);
			vertices[3] = PXGLVertexMake(aabb.xMax, aabb.yMin);

			PXGLShadeModel(GL_SMOOTH);
			PXGLDisable(GL_TEXTURE_2D);
			PXGLColor4ub(0xFF, 0, 0, 0xFF);
			PXGLVertexPointer(2, GL_FLOAT, 0, vertices);
			PXGLDrawArrays(GL_LINE_LOOP, 0, 4);
		}
	}

	if (PXDebugIsEnabled(PXDebugSetting_DrawHitAreas))
	{
		PXGLVertex vertices[4];

		PXDisplayObject *doAABB;
		PXDisplayObject **curDisplayObject;
		//PXRectangle *pBounds;
		CGRect bounds;

		CGPoint topLeft;
		CGPoint topRight;
		CGPoint bottomLeft;
		CGPoint bottomRight;

		for (index = 0, curDisplayObject = pxEngineDOBuffer.array; index < pxEngineDOBuffer.size; ++index, ++curDisplayObject)
		{
			doAABB = *curDisplayObject;

			bounds = CGRectZero;
			[doAABB _measureLocalBounds:&bounds];

			if (CGRectIsEmpty(bounds))
				continue;

			topLeft     = PXUtilsLocalToGlobal(doAABB, CGPointMake(bounds.origin.x, bounds.origin.y));
			bottomLeft  = PXUtilsLocalToGlobal(doAABB, CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height));
			topRight    = PXUtilsLocalToGlobal(doAABB, CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y));
			bottomRight = PXUtilsLocalToGlobal(doAABB, CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height));

			PX_ENGINE_CONVERT_POINT_FROM_STAGE_ORIENTATION(topLeft.x, topLeft.y, pxEngineStage);
			PX_ENGINE_CONVERT_POINT_FROM_STAGE_ORIENTATION(bottomLeft.x, bottomLeft.y, pxEngineStage);
			PX_ENGINE_CONVERT_POINT_FROM_STAGE_ORIENTATION(topRight.x, topRight.y, pxEngineStage);
			PX_ENGINE_CONVERT_POINT_FROM_STAGE_ORIENTATION(bottomRight.x, bottomRight.y, pxEngineStage);

			vertices[0] = PXGLVertexMake(topLeft.x, topLeft.y);
			vertices[1] = PXGLVertexMake(bottomLeft.x, bottomLeft.y);
			vertices[2] = PXGLVertexMake(bottomRight.x, bottomRight.y);
			vertices[3] = PXGLVertexMake(topRight.x, topRight.y);

			PXGLShadeModel(GL_SMOOTH);
			PXGLDisable(GL_TEXTURE_2D);
			PXGLColor4ub(0, 0, 0xFF, 0xFF);
			PXGLVertexPointer(2, GL_FLOAT, 0, vertices);
			PXGLDrawArrays(GL_LINE_LOOP, 0, 4);
		}
	}
#endif

	PXGLPostRender();
	PXGLConsolidateBuffers();

	/*
#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_HalveStage))
	{
		glPopMatrix();
	}
#endif
	 */

	[pxEngineView _swapBuffers];
}

/*
 if (pxEngineRenderDT <= 0)
 return;
 
 pxEngineRenderDTAccum += pxEngineMainDT;
 if (pxEngineRenderDTAccum < pxEngineRenderDT)
 return;
 
 pxEngineRenderDTAccum = 0.0f;
 */

void PXEngineLogicPhase()
{
	PXEngineDispatchTouchEvents(); //Touch

	pxEngineLogicTimeAccum += pxEngineMainDT;

	if (pxEngineLogicTimeAccum >= pxEngineLogicDT)
	{
#ifdef PX_DEBUG_MODE
		NSTimeInterval start = 0;

		if (PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
		{
			start = [NSDate timeIntervalSinceReferenceDate];
		}
#endif

		PXEngineDispatchFrameEvents(); //Frame
		pxEngineLogicTimeAccum -= pxEngineLogicDT;

#ifdef PX_DEBUG_MODE
		if (PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
		{
			NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
			pxEngineTimeBetweenLogic = end - start;
		}
#endif
	}
}

void PXEngineRenderPhase()
{
	// If we don't have a render change in time, and 
	if (!PXMathIsZero(pxEngineRenderDT))
	{
		pxEngineRenderTimeAccum += pxEngineMainDT;
		if (pxEngineRenderTimeAccum >= pxEngineRenderDT)
		{
#ifdef PX_DEBUG_MODE
			NSTimeInterval start = 0;

			if (PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
			{
				start = [NSDate timeIntervalSinceReferenceDate];
			}
#endif

			PXEngineRender(); //Render
			pxEngineRenderTimeAccum -= pxEngineRenderDT;

#ifdef PX_DEBUG_MODE
			if (PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
			{
				NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
				pxEngineTimeBetweenRendering = end - start;
			}
#endif
		}
	}
}

void PXEngineOnFrame()
{
	PXSoundEngineUpdate();

	PXEngineLogicPhase();
	PXEngineRenderPhase();

#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
	{
		pxEngineTimeBetweenFrames = pxEngineTimeBetweenLogic + pxEngineTimeBetweenRendering;
	}
#endif
}

#pragma mark -
#pragma mark RENDER
#pragma mark -
void PXEngineRenderDisplayObject(PXDisplayObject *displayObject, bool transformationsEnabled, bool canBeUsedForTouches)
{
	//////////////////////
	// Quick exit tests //
	//////////////////////
	
	float doScaleX = 1.0f;
	float doScaleY = 1.0f;
	float doAlpha = 1.0f;
	
	if (transformationsEnabled)
	{
		doScaleX = displayObject->_scaleX;
		doScaleY = displayObject->_scaleY;
		doAlpha = displayObject->_colorTransform.alphaMultiplier;

		if (!PX_IS_BIT_ENABLED(displayObject->_flags, _PXDisplayObjectFlags_visible))
			return;

		if (PXMathIsZero(doScaleX))
			return;

		if (PXMathIsZero(doScaleY))
			return;

		// This has been commented out so that display objects with
		// an alpha of 0.0 can get clicked

		//if (doAlpha < 0.0001f)
		//	return;
	}

	bool matrixPushed = false;
	bool transformPushed = false;
	bool crippleAABB = false;
	bool useCustomHitArea = PX_IS_BIT_ENABLED(displayObject->_flags, _PXDisplayObjectFlags_useCustomHitArea);

	bool isCustom = displayObject->_renderMode == PXRenderMode_Custom;
	bool isCustomOrManaged = (displayObject->_renderMode == PXRenderMode_ManageStates) || isCustom;
	bool isRenderOn = !(displayObject->_renderMode == PXRenderMode_Off);

	if (isCustomOrManaged)
	{
		PXGLFlush( );
	}

	if (transformationsEnabled)
	{
		float doX = displayObject->_matrix.tx;
		float doY = displayObject->_matrix.ty;
		float doRotation = displayObject->_rotation;

		// Color Transform
		PXGLColorTransform *doColorTransform = &displayObject->_colorTransform;

		// Matrix Transform
		// Should translate, scale or rotate
		if (!PXMathIsZero(doX) ||
			!PXMathIsZero(doY) ||
		    !PXMathIsOne(doScaleX) ||
			!PXMathIsOne(doScaleY) ||
		    !PXMathIsZero(doRotation))
		{
			PXGLPushMatrix( );
			PXGLMultMatrix(&displayObject->_matrix);

			matrixPushed = true;
		}

		if (!PXMathIsOne(doColorTransform->redMultiplier  ) ||
			!PXMathIsOne(doColorTransform->greenMultiplier) ||
			!PXMathIsOne(doColorTransform->blueMultiplier ) ||
			!PXMathIsOne(doAlpha))
		{
			PXGLColorTransform colorTransform;

			colorTransform.redMultiplier   = doColorTransform->redMultiplier;
			colorTransform.greenMultiplier = doColorTransform->greenMultiplier;
			colorTransform.blueMultiplier  = doColorTransform->blueMultiplier;
			colorTransform.alphaMultiplier = doAlpha;

			PXGLPushColorTransform( );
			PXGLSetColorTransform(&colorTransform);

			transformPushed = true;
		}
	}

	PXGLAABB *doAABB = &displayObject->_aabb;

	// Used for debugging - will only have an aabb if it can be used for
	// touching.
	if (canBeUsedForTouches)
	{
		PX_ENABLE_BIT(displayObject->_flags, _PXDisplayObjectFlags_shouldRenderAABB);
	}
	else
	{
		PX_DISABLE_BIT(displayObject->_flags, _PXDisplayObjectFlags_shouldRenderAABB);
	}
	//displayObject->_shouldRenderAABB = canBeUsedForTouches;

	if (isRenderOn)
	{
		// Reset the bounding box in gl so that when we draw it, it updates the
		// bounding box to the drawn area. If custom or managed, then it resets
		// the aabb to the clip rect defined in gl; this is done because it will
		// always fire for the touch events, as long as the clip rect is within
		// a touchable area.
		PXGLResetAABB(isCustomOrManaged);

		// If it is custom or managed, then we need the real matrix to be inside
		// gl, so when they use the gl draw commands, they draw in the correct
		// spot. Note, this will push the ENTIRE matrix thus far, so we need to
		// pop it immediately after incase a child of this custom or managed is
		// also custom or managed.
		if (isCustomOrManaged)
		{
			PXGLSyncTransforms();
		}

		PXGLResetStates(displayObject->_glState);
		displayObject->_impRenderGL(displayObject, nil);

		// Popping the matrix, please see the above comment.
		if (isCustomOrManaged)
		{
			PXGLUnSyncTransforms();
		}

		// This is like popping the color transform of the display object. It
		// resets the color to the previous color on the stack (that was set
		// before they called 'color4f, or color4ub').
		PXGLColor4ub(0xFF, 0xFF, 0xFF, 0xFF);

		// Grab the current AABB of the drawn display object (only itself, not
		// it's children).
		PXGLAABB *aabb = PXGLGetCurrentAABB( );

		/*
		if (useCustomHitArea)
		{
			CGRect aabbRect;
			[displayObject _measureGlobalBounds:&aabbRect];

			aabb->xMin = floorf(aabbRect.origin.x);
			aabb->yMin = floorf(aabbRect.origin.y);
			aabb->xMax = ceilf(aabb->xMin + aabbRect.size.width);
			aabb->yMax = ceilf(aabb->yMin + aabbRect.size.height);

			PXGLAABBMult(aabb);
		}
		 */
		
		// Is usable refers to if the display object even drew anything, which
		// will change the AABB from max/min ints (the reset state) to what was
		// drawn. IsAABBVisable is true when the aabb is within the current
		// clipping rectangle.
		if (canBeUsedForTouches && (useCustomHitArea || (!PXGLAABBIsReset(aabb) && PXGLIsAABBVisible(aabb))))
		{
			// List is to contain a display object pointer, and an aabb. We
			// retain it here, as it is released when the list is emptied
			// (which is done after drawing).
			[displayObject retain];

			// We get the next object on the 'drawn list' and set this display
			// object and aabb to that object. This is done to retain a list of
			// drawn display objects for looping on when asking for touch
			// events.
			PXDisplayObject **objPtr = PXEngineNextBufferObject();

		//	if (orientationEnabled)
		//	{
				PX_ENGINE_CONVERT_AABB_TO_STAGE_ORIENTATION(aabb, pxEngineStage);
		//	}

			// Set the AABB of the display object to the one found by rendering.
			doAABB->xMin = aabb->xMin;
			doAABB->yMin = aabb->yMin;
			doAABB->xMax = aabb->xMax;
			doAABB->yMax = aabb->yMax;

			*objPtr = displayObject;
			++pxEngineDOBufferMaxSize;
		}
		else
		{
			// The aabb was not acceptable, cripple the renderer's version
			crippleAABB = true;
		}
	}
	else
	{
		// The display object was not drawn, cripple the renderer's aabb so that
		// it can not be checked for touchs.
		crippleAABB = true;
	}

	if (crippleAABB)
	{
		// Setting the aabb to a bounds that makes no sense, and can not be both
		// below and above.
		doAABB->xMin =  1;
		doAABB->xMax = -1;
		doAABB->yMin =  1;
		doAABB->yMax = -1;
	}

	// If it is a custom drawing, then we need to set GL back to what Pixelwave
	// is, thus we need to upload every value of pixelwave back into gl.
	if (isCustom)
	{
		PXGLSyncGLToPX( );
	}

	// If you have children, draw them too!
	if (PX_IS_BIT_ENABLED(displayObject->_flags, _PXDisplayObjectFlags_isContainer))
	{
		PXDisplayObjectContainer *container = (PXDisplayObjectContainer *)displayObject;
		PXDisplayObject *child = container->_childrenHead;

		container->_impPreChildRenderGL(container, nil);

		unsigned index;

		for (index = 0; index < container->_numChildren; ++index)
		{
			PXEngineRenderDisplayObject(child, true, canBeUsedForTouches);

			child = child->_next;
		}

		container->_impPostChildRenderGL(container, nil);
	}

	// If we pushed a color transform, we need to pop it.
	if (transformPushed)
	{
		PXGLPopColorTransform( );
	}

	// If we pushed a matrix transform, we need to pop it.
	if (matrixPushed)
	{
		PXGLPopMatrix( );
	}
}

// clipRect is defined in POINTS
void PXEngineRenderToTexture(PXTextureData *textureData, PXDisplayObject *source, PXGLMatrix *matrix, PXGLColorTransform *colorTransform, CGRect *clipRect, BOOL smoothing, BOOL clearTexture)
{
	if (!textureData)
	{
		return;
	}
	if (!source)
	{
		return;
	}
	
	// Finish any rendering queued up to the main buffer
	PXGLFlush( );

	////////////////////////////////////////
	// Set up the texture rendering state //
	////////////////////////////////////////

	// Bind the renderToTexture buffer
	PXGLBindFramebuffer(GL_FRAMEBUFFER_OES, pxEngineRTTFBO);

	// Bind the texture to the buffer
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, textureData->_glName, 0);

#ifdef PX_DEBUG_MODE
	// Make sure the buffer is bound properly
	GLenum status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);

	if (status != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		PXDebugLog(@"Framebuffer object is not complete, error: %x", status);

		switch (status)
		{
			case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_OES:
				PXDebugLog(@"GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
				break;
			case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_OES:
				PXDebugLog(@"GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_OES");
				break;
			case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_OES:
				PXDebugLog(@"GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT");
				break;
			case GL_FRAMEBUFFER_INCOMPLETE_FORMATS_OES:
				PXDebugLog(@"GL_FRAMEBUFFER_INCOMPLETE_FORMATS_OES");
				break;
			default:
				break;
		}

		PXThrow(PXGLException, @"Framebuffer object is not complete. renderToTexture could not be completed");

		return;
	}
#endif

	// Decide if the render should be clipped
	BOOL bShouldClip = NO;
	BOOL bAlterViewport = NO;

	// Clip rect is in POINTS
	if (clipRect)
	{
		bShouldClip = YES;
	}

	// pxEngineViewSize is ALWAYS PORTRAIT. That's fine though because
	// renderToTexture doesn't take screen orientation into account, it's always
	// done in portrait as well. That's fine because we're not dealing with a 
	// screen we're rendering directly to texture

	// Now, since pxEngineViewSize is in POINTS, and TextureData in based on
	// PIXELS, we need to convert

	float textureDataScaleFactor = textureData.contentScaleFactor;
	CGSize textureDataSizeInPoints;
	textureDataSizeInPoints.width  = textureData.width  / textureDataScaleFactor;
	textureDataSizeInPoints.height = textureData.height / textureDataScaleFactor;

	if (textureDataSizeInPoints.width > pxEngineViewSize.width ||
		textureDataSizeInPoints.height > pxEngineViewSize.height)
	{
		bAlterViewport = YES;
	}

	// Set up the surfaces
	if (bAlterViewport)
	{
		// in POINTS
		PXGLSetViewSize(textureDataSizeInPoints.width, textureDataSizeInPoints.height, textureDataScaleFactor, false);//PXGLGetContentScaleFactor());

		// in POINTS
		PXGLClipRect(0, 0, textureDataSizeInPoints.width, textureDataSizeInPoints.height);
	}
	
	if (bShouldClip)
	{
		glEnable(GL_SCISSOR_TEST);
		// Takes in coordinates in PIXELS
		glScissor(clipRect->origin.x	* textureDataScaleFactor,	// in PIXELS
				  clipRect->origin.y	* textureDataScaleFactor,	// in PIXELS
				  clipRect->size.width	* textureDataScaleFactor,	// in PIXELS
				  clipRect->size.height	* textureDataScaleFactor);	// in PIXELS
	}

	// Set up the rendering (reset the matrix/stacks/ect)
	
	PXGLPreRender( );

	if (matrix)
	{
		PXGLMultMatrix(matrix);
	}

	if (colorTransform)
	{
		PXGLSetColorTransform(colorTransform);
	}

	assert(pxEngineDOBuffer.array);

	// Clear the TextureData if the user asked
	if (clearTexture)
	{
		uint fillColor = textureData->_fillColor;
		float div = 1/255.0f;

		float a = (float)((fillColor >> 24) & 0xFF) * div;
		float r = (float)((fillColor >> 16) & 0xFF) * div;
		float g = (float)((fillColor >> 8) & 0xFF) * div;
		float b = (float)((fillColor) & 0xFF) * div;

		glClearColor(r, g, b, a);
		glClear(GL_COLOR_BUFFER_BIT);
	}

	// Offset in POINTS
	PXGLScale(1.0f, -1.0f);

	if (bAlterViewport)
	{
		PXGLTranslate(0, textureDataSizeInPoints.height);
	}
	else
	{
		PXGLTranslate(0, pxEngineViewSize.height);
	}

	////////////
	// RENDER //
	////////////
	
	PXEngineRenderDisplayObject(source, false, false);
	
	// Flush anything, render any queued up commands
	PXGLPostRender( );
	
	////////////////////////////////////
	// Restore screen rendering state //
	////////////////////////////////////

	// Put the viewport / clip rect back to screen rendering settings
	if (bAlterViewport)
	{
		// in POINTS
		PXGLSetViewSize(pxEngineViewSize.width, pxEngineViewSize.height, pxEngineView.contentScaleFactor, true);
	}

	// in POINTS
	PXGLClipRect(0, 0, pxEngineViewSize.width, pxEngineViewSize.height);

	if (bShouldClip)
	{
		glDisable(GL_SCISSOR_TEST);
	}

	// Switch back to main buffer
	PXGLBindFramebuffer(GL_FRAMEBUFFER_OES, pxEngineView->_pxViewFramebuffer);
}

#pragma mark Extracting Pixel Data

// Delared in: PXTextureData.h

/**
 * Reads the data from the texture and always returns it in RGBA8888 format.
 * the length of the array must be '4 bytes * number of pixels'
 * Specified coordinates are in PIXELS
 */
// TODO Later: Allow to return pixel data in other formats (RGB, LA88, A8, etc).
// TODO: Look into if this could be done by switching the GLContext instead
// of changing the view size...
void PXTextureDataReadPixels(PXTextureData *textureData, int x, int y, int width, int height, void *pixels)
{
	if (!textureData)
		return;
	
	// Change the state

	// Bind the Texture FBO
	PXGLBindFramebuffer(GL_FRAMEBUFFER_OES, pxEngineRTTFBO);
	// Connect the texture data to it
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES,
							  GL_COLOR_ATTACHMENT0_OES,
							  GL_TEXTURE_2D, textureData->_glName,
							  0);

	float textureDataScaleFactor = textureData.contentScaleFactor;
	float one_textureDataScaleFactor = 1.0f / textureDataScaleFactor;
	
	float widthInPoints = width * one_textureDataScaleFactor;
	float heightInPoints = height * one_textureDataScaleFactor;
	
	// Update the view size to match the texture's
	PXGLSetViewSize(widthInPoints, heightInPoints, textureDataScaleFactor, false);

	// Read
	glReadPixels(x, y,
				 width, height,
				 GL_RGBA, GL_UNSIGNED_BYTE,
				 pixels);

	// Revert the state
	// Set the viewport back to match the screen's
	PXGLSetViewSize(pxEngineViewSize.width, pxEngineViewSize.height, pxEngineView.contentScaleFactor, true);

	// Bind the screen buffer back
	PXGLBindFramebuffer(GL_FRAMEBUFFER_OES, pxEngineView->_pxViewFramebuffer);
}

/**
 *	The size of the view in PIXELS
 */
CGSize PXEngineGetScreenBufferSize()
{
	float scaleFactor = PXEngineGetContentScaleFactor();
	
	CGSize pixelSize = pxEngineViewSize;
	pixelSize.width *= scaleFactor;
	pixelSize.height *= scaleFactor;
	
	return pixelSize;
}

/**
 *	@param w The width of the area to grab, in pixels
 *	@param h The height of the area to grab, in pixels
 *	@param pixels An array of size w * h * 4.
 */
void PXEngineGetScreenBufferPixels(int x, int y, int width, int height, void *pixels)
{
	/*
	PXGLReadPixelsInverted(0, 0,
						   width, height,
						   pixelData);
	 */
	
	// Bind the screen buffer back
	//PXGLBindFramebuffer(GL_FRAMEBUFFER_OES, pxEngineView->_framebuffer);
	glReadPixels(x, y,
				 width, height,
				 GL_RGBA, GL_UNSIGNED_BYTE,
				 pixels);	
}

#pragma mark Misc

PXObjectPool *PXEngineGetSharedObjectPool()
{
	if (!pxEngineSharedObjectPool)
	{
		pxEngineSharedObjectPool = [[PXObjectPool alloc] init];
	}
	
	return pxEngineSharedObjectPool;
}

#pragma mark Touches

void PXEngineRemoveAllTouchCapturesFromObject(id<PXEventDispatcherProtocol> capturingObject)
{
	if (!capturingObject)
		return;

	// If the dictionary does not contain the object, just return.
	if (CFDictionaryGetCountOfValue(pxEngineTouchCapturingObjects, capturingObject) <= 0)
		return;

	CFIndex count = CFDictionaryGetCount(pxEngineTouchCapturingObjects);

	if (count > 0)
	{
		// Make temporary parallel arrays to store the keys and the values.
		CFTypeRef keys[count];
		CFTypeRef values[count];

		// Gives us a parallel array structure so that you can iterate through
		// the posabilities.
		CFDictionaryGetKeysAndValues(pxEngineTouchCapturingObjects, (const void **)(keys), (const void **)(values));

		PXPoint *pxPoint;
		CGPoint point;
		PXTouchEvent *event;

		CFIndex index;
		CFTypeRef *key;
		CFTypeRef *value;

		id<PXEventDispatcherProtocol> target;
		UITouch *touch;

		// Loop through the dictionary and see if the object has any association
		// with a touch; if it does, we need to cancel it.
		for (index = 0, key = keys, value = values; index < count; ++index, ++key, ++value)
		{
			// Convert the value and key into a usable form
			target = (id<PXEventDispatcherProtocol>)(*value);
			touch = (UITouch *)(*key);

			// Compare the target, if it is the capturing object, then we know
			// that it is a touch we need to cancel.
			if (target == capturingObject)
			{
				// Remove the key from the dictionary. THIS IS ALRIGHT and
				// should be done BEFORE sending the event. Why before the
				// event? Well, if someone 'removesAllChildren' or something
				// silly like that during the event, then this will enter again,
				// and become an infinate loop... which is bad.
				CFDictionaryRemoveValue(pxEngineTouchCapturingObjects, touch);

				// Get the position of the touch
				pxPoint = [pxEngineStage positionOfTouch:touch];
				point = CGPointMake(pxPoint.x, pxPoint.y);

				// Send out the cancel event
				event = pxEngineNewTouchEventWithTouch(touch, &point, PXTouchEvent_TouchCancel, NO);
				[target dispatchEvent:event];
				[event release];
			}
		}
	}
}

void PXEngineSetTouchCapturingObject(UITouch *nativeTouch, id<PXEventDispatcherProtocol> capturingObject)
{
	if (!nativeTouch)
		return;

	id<PXEventDispatcherProtocol> originalObject = (id<PXEventDispatcherProtocol>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, nativeTouch);

	// Only do work if the object is actually changing
	if (originalObject != capturingObject)
	{
		// Send out a cancel event on the OLD object.
		PXPoint *pxPoint = [pxEngineStage positionOfTouch:nativeTouch];
		CGPoint point = CGPointMake(pxPoint.x, pxPoint.y);
		PXTouchEvent *event = pxEngineNewTouchEventWithTouch(nativeTouch, &point, PXTouchEvent_TouchCancel, NO);
		[originalObject dispatchEvent:event];
		[event release];

		// Change or remove the target
		if (!capturingObject)
		{
			CFDictionaryRemoveValue(pxEngineTouchCapturingObjects, nativeTouch);
		}
		else
		{
			CFDictionarySetValue(pxEngineTouchCapturingObjects, nativeTouch, capturingObject);
		}
	}
}

id<PXEventDispatcherProtocol> PXEngineGetTouchCapturingObject(UITouch *nativeTouch)
{
	if(!nativeTouch)
		return nil;

	return (id<PXEventDispatcherProtocol>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, nativeTouch);
}

UITouch *PXEngineGetFirstTouch()
{
	if (!pxEngineSavedTouchEvents)
		return nil;

	if ([pxEngineSavedTouchEvents count] <= 0)
		return nil;

	PXTouchEvent *event = (PXTouchEvent *)[pxEngineSavedTouchEvents objectAtIndex:0];

	return event.nativeTouch;
}
PXLinkedList *PXEngineGetAllTouches()
{
	if (!pxEngineSavedTouchEvents)
		return nil;

	PXLinkedList *list = [[PXLinkedList alloc] init];
	PXTouchEvent *event;
	for (event in pxEngineSavedTouchEvents)
	{
		if (event.nativeTouch)
			[list addObject:event.nativeTouch];
	}

	return [list autorelease];
}

CGPoint PXEngineTouchToScreenCoordinates(UITouch *touch)
{
	if (!touch || !pxEngineView)
		return CGPointMake(0.0f, 0.0f);

	CGPoint point = [touch locationInView:pxEngineView];

	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)[pxEngineView layer];
	CGPoint pos = eaglLayer.position;

	point.x += pos.x;
	point.y += pos.y;

	PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(point.x, point.y, pxEngineStage);

	return point;
}

PXTouchEvent *pxEngineNewTouchEventWithTouch(UITouch *touch, CGPoint *pos, NSString *type, BOOL orientTouch)
{
	//PXTouchEvent *event;

	CGPoint location = CGPointMake(0.0f, 0.0f);

	if (pos)
	{
		location = *pos;
	}

	if (orientTouch)
	{
		PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(location.x, location.y, pxEngineStage);
#ifdef PX_DEBUG_MODE
		if (PXDebugIsEnabled(PXDebugSetting_HalveStage) && pos)
		{
			location.x = 2.0f * ((pxEngineStage.stageWidth  * 0.75f) + ((location.x) - (pxEngineStage.stageWidth)));
			location.y = 2.0f * ((pxEngineStage.stageHeight * 0.75f) + ((location.y) - (pxEngineStage.stageHeight)));
		}
#endif
	}

	//event = [[PXTouchEvent alloc] initWithType:type nativeTouch:touch stageX:location.x stageY:location.y tapCount:touch.tapCount];

	return [[PXTouchEvent alloc] initWithType:type nativeTouch:touch stageX:location.x stageY:location.y tapCount:touch.tapCount];
}

void PXEngineInvokeTouchBegan(UITouch *touch, CGPoint *pos)
{
	PXTouchEvent *event = pxEngineNewTouchEventWithTouch(touch, pos, PXTouchEvent_TouchDown, YES);
	[pxEngineTouchEvents addObject:event];
	[event release];

	event = pxEngineNewTouchEventWithTouch(touch, pos, PXTouchEvent_Tap, YES);
	[pxEngineSavedTouchEvents addObject:event];
	[event release];
}
void PXEngineInvokeTouchMoved(UITouch *touch, CGPoint *pos)
{
	PXTouchEvent *event = pxEngineNewTouchEventWithTouch(touch, pos, PXTouchEvent_TouchMove, YES);
	[pxEngineTouchEvents addObject:event];
	[event release];
}

void PXEngineInvokeTouchEnded(UITouch *touch, CGPoint *pos)
{
	PXTouchEvent *event = pxEngineNewTouchEventWithTouch(touch, pos, PXTouchEvent_TouchUp, YES);
	[pxEngineTouchEvents addObject:event];
	[event release];

	PXTouchEvent *savedTouch;
	//PXGenericObject object;

	int x = pos->x;
	int y = pos->y;

	PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(x, y, pxEngineStage);

	float distX;
	float distY;
	float touchDistanceSq;
	// 30 point radius

	PXLinkedListForEach(pxEngineSavedTouchEvents, savedTouch)
	{
		if (savedTouch.nativeTouch == touch)
		{
			distX = savedTouch->_stageX - x;
			distX *= distX;
			distY = savedTouch->_stageY - y;
			distY *= distY;
			touchDistanceSq = distX + distY;
			//PX_ENGINE_IS_TOUCH_SAME_PLACE((int)savedTouch->_stageX, (int)savedTouch->_stageY, x, y)
			//if ((int)savedTouch->_stageX == x
			//&& (int)savedTouch->_stageY == y)
			if (touchDistanceSq < PXEngineTouchRadiusSquared)
			{
				[pxEngineTouchEvents addObject:savedTouch];
			}

			[pxEngineRemoveFromSavedTouchEvents addObject:savedTouch];
			break;
		}
	}
}
void PXEngineInvokeTouchCanceled(UITouch *touch)
{
	PXTouchEvent *event = pxEngineNewTouchEventWithTouch(touch, nil, PXTouchEvent_TouchCancel, YES);
	[pxEngineTouchEvents addObject:event];
	[event release];

	PXTouchEvent *savedTouch;

	PXLinkedListForEach(pxEngineSavedTouchEvents, savedTouch)
	{
		if (savedTouch.nativeTouch == touch)
		{
			[pxEngineRemoveFromSavedTouchEvents addObject:savedTouch];
			break;
		}
	}
}

float _PXEngineDBGGetTimeBetweenFrames()
{
#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
	{
		return pxEngineTimeBetweenFrames;
	}

#endif
	return 0.0f;
}
float _PXEngineDBGGetTimeBetweenLogic()
{
#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
	{
		return pxEngineTimeBetweenLogic;
	}
#endif

	return 0.0f;
}
float _PXEngineDBGGetTimeBetweenRendering()
{
#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
	{
		return pxEngineTimeBetweenRendering;
	}
#endif

	return 0.0f;
}
float _PXEngineDBGGetTimeWaiting()
{
#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
	{
		return pxEngineTimeWaiting;
	}
#endif

	return 0.0f;
}

////////////////////////////
// PXEngine Private Class //
////////////////////////////

@implementation PXEngine

- (id) init
{
	self = [super init];

	if (self)
	{
		displayLinkSupported = NO;

#ifdef __IPHONE_3_1
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
			displayLinkSupported = YES;
#endif

		animationTimer = nil;

		displayLink = nil;
	}

	return self;
}

- (void) dealloc
{
	if (pxEngineSharedObjectPool)
	{
		[pxEngineSharedObjectPool release];
		pxEngineSharedObjectPool = nil;
	}
		
	if (displayLinkSupported && displayLink)
	{
		[displayLink invalidate];
		displayLink = nil;
	}
	
	if (animationTimer)
	{
		[animationTimer invalidate];
		animationTimer = nil;
	}

	[super dealloc];
}

- (void) onTimerTick
{
#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
	{
	#if (PX_ENGINE_IDLE_TIME_INCLUDES_BETWEEN_SYSTEM_CALLS)
		NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
		float delta = end - pxEngineInterval;

		if (PXMathIsZero(pxEngineInterval) || PXMathIsZero(delta) || delta < 0.0f || delta > 2700.0f)
		{
			pxEngineTimeWaiting = 0.0f;
		}
		else
		{
			pxEngineTimeWaiting = delta - pxEngineTimeBetweenFrames;
		}
		pxEngineInterval = end;
	#else
		pxEngineTimeWaiting = pxEngineLogicDT - pxEngineTimeBetweenFrames;
		if (pxEngineTimeWaiting < 0.0f)
		{
			pxEngineTimeWaiting = 0.0f;
		}
	#endif
	}
#endif

//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		PXEngineOnFrame( );
//	[pool release];
}

//- (void) startAnimationWithInterval:(float)interval
- (void) updateMainLoopInterval
{
	/*
	if (PXMathIsZero(interval))
		return;

	pxEngineMainDT = interval;
*/

	if (displayLink)
	{
		[displayLink invalidate];
		displayLink = nil;
	}

	if (animationTimer)
	{
		[animationTimer invalidate];
		animationTimer = nil;
	}

	if (!pxEngineIsRunning)
	{
		return;
	}

#ifdef __IPHONE_3_1
	if (displayLinkSupported)
	{
		displayLinkInterval = (int)(pxEngineMaxFrameRate * pxEngineMainDT);
		if (displayLinkInterval < 1)
			displayLinkInterval = 1;

		displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(onTimerTick)];

		[displayLink setFrameInterval:displayLinkInterval];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
	else
#endif
	{
		animationTimer = [NSTimer scheduledTimerWithTimeInterval:pxEngineMainDT target:self selector:@selector(onTimerTick) userInfo:nil repeats:YES];
	}
}

@end
