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

#import "PXDebug.h"
#import "PXDebugUtils.h"
#import "PXEngine.h"

#include "PXPrivateUtils.h"
#include "PXSettings.h"

PXInline_c void PXDebugLog(NSString *format, ...)
{
#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_LogErrors))
	{
		va_list args;
		va_start(args, format);
		
		NSLogv(format, args);
		
		va_end(args);
	}
#else
	PX_NOT_USED(format);
#endif
}

/**
 * Provides tweaks and toggles for displaying debugging information about
 * the engine.
 *
 * This class exposes only static methods.
 *
 * @warning The tweaks in this class are designed for use in a testing
 * environment and shouldn't be used in production code.
 */
@implementation PXDebug

+ (void) setDrawBoundingBoxes:(BOOL)val
{
	if (val)
	{
		PXDebugEnableSetting(PXDebugSetting_DrawBoundingBoxes);
	}
	else
	{
		PXDebugDisableSetting(PXDebugSetting_DrawBoundingBoxes);
	}
}

/**
 * When set to YES, red axis-aligned boxes are drawn around
 * each display object.
 */
+ (BOOL) drawBoundingBoxes
{
	return (BOOL)(PXDebugIsEnabled(PXDebugSetting_DrawBoundingBoxes));
}

+ (void) setDrawHitAreas:(BOOL)val
{
	PXDebugEnableSetting(PXDebugSetting_DrawHitAreas);
}

/**
 * When set to `YES` blue axis-aligned boxes
 * are drawn around each display object's hit area (the
 * within which touches must land to register).
 */
+ (BOOL) drawHitAreas
{
	return (BOOL)(PXDebugIsEnabled(PXDebugSetting_DrawHitAreas));
}

+ (void) setHalveStage:(BOOL)val
{
	if (val)
	{
		PXDebugEnableSetting(PXDebugSetting_HalveStage);
	}
	else
	{
		PXDebugDisableSetting(PXDebugSetting_HalveStage);
	}
}

/**
 * Renders the entire stage at half scale. This is particularly useful
 * when you need to see what's going on outside of the stage's bounds.
 */
+ (BOOL) halveStage
{
	return (BOOL)(PXDebugIsEnabled(PXDebugSetting_HalveStage));
}

+ (void) setCalculateFrameRate:(BOOL)val
{
	if (val)
	{
		PXDebugEnableSetting(PXDebugSetting_CalculateFrameRate);
	}
	else
	{
		PXDebugDisableSetting(PXDebugSetting_CalculateFrameRate);
	}
}
/**
 * When turned on, the engine's frame rate is calculated and can be
 * queried via these methods:
 * 
 * - #timeBetweenFrames
 * - #timeBetweenLogic
 * - #timeBetweenRendering
 * - #timeWaiting
 */
+ (BOOL) calculateFrameRate
{
	return (BOOL)(PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate));
}

+ (void) setCountGLCalls:(BOOL)val
{
	if (val)
	{
		PXDebugEnableSetting(PXDebugSetting_CountGLCalls);
	}
	else
	{
		PXDebugDisableSetting(PXDebugSetting_CountGLCalls);
	}
}

/**
 * When turned on, the amount of OpenGl calls performed each frame
 * can be queried with the #glCallCount method
 */
+ (BOOL) countGLCalls
{
	return (BOOL)(PXDebugIsEnabled(PXDebugSetting_CountGLCalls));
}

/**
 * The amount of OpenGL calls performed in the previous frame.
 * This method returns 0 if #countGLCalls is set to `NO`.
 */
+ (unsigned) glCallCount
{
	return PXGLDBGGetRenderCallCount();
}

+ (void) setLogErrors:(BOOL)val
{
	if (val)
	{
		PXDebugEnableSetting(PXDebugSetting_LogErrors);
	}
	else
	{
		PXDebugDisableSetting(PXDebugSetting_LogErrors);
	}
}
/**
 * When turned on, Pixelwave errors are logged to the console.
 */
+ (BOOL) logErrors
{
	return (BOOL)(PXDebugIsEnabled(PXDebugSetting_LogErrors));
}

/**
 * The amount of time in seconds that passed between the last two frames.
 * This value can be used to calculate the framerate of the
 * application.
 *
 * @warning Returns 0 unless #calculateFrameRate is set to `YES`.
 */
+ (float) timeBetweenFrames
{
	PXDebugInformIfCalculateFrameRateOn(@"timeBetweenFrames");

	return _PXEngineDBGGetTimeBetweenFrames();
}

/**
 * The duration, in seconds, of the last logic phase.
 *
 * The logic phase involves all user code invoked via
 * `PXEvent_EnterFrame` events.
 *
 * @warning Returns 0 unless #calculateFrameRate is set to `YES`.
 */
+ (float) timeBetweenLogic
{
	PXDebugInformIfCalculateFrameRateOn(@"timeBetweenLogic");

	return _PXEngineDBGGetTimeBetweenLogic();
}
/**
 * The duration, in seconds, of the last rendering phase.
 *
 * @warning Returns 0 unless #calculateFrameRate is set to `YES`.
 */
+ (float) timeBetweenRendering
{
	PXDebugInformIfCalculateFrameRateOn(@"timeBetweenRendering");

	return _PXEngineDBGGetTimeBetweenRendering();
}
/**
 * The amount of delay, in seconds, between the
 * last two frames.
 *
 * Frames are delayed if a frame finishes before the
 * next frame is scheduled to run. The amount of time
 * allotted to each frame is set through the [PXStage frameRate]
 * property.
 *
 * @warning Returns 0 unless #calculateFrameRate is set to `YES`.
 */
+ (float) timeWaiting
{
	PXDebugInformIfCalculateFrameRateOn(@"timeWaiting");

	return _PXEngineDBGGetTimeWaiting();
}

@end
