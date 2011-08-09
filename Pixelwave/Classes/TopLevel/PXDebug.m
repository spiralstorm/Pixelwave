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
 * the engine. This class exposes only static methods.
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
+ (BOOL) drawBoundingBoxes
{
	return (BOOL)(PXDebugIsEnabled(PXDebugSetting_DrawBoundingBoxes));
}

+ (void) setDrawHitAreas:(BOOL)val
{
	PXDebugEnableSetting(PXDebugSetting_DrawHitAreas);
}
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
+ (BOOL) countGLCalls
{
	return (BOOL)(PXDebugIsEnabled(PXDebugSetting_CountGLCalls));
}

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
+ (BOOL) logErrors
{
	return (BOOL)(PXDebugIsEnabled(PXDebugSetting_LogErrors));
}

+ (float) timeBetweenFrames
{
	PXDebugInformIfCalculateFrameRateOn(@"timeBetweenFrames");

	return _PXEngineDBGGetTimeBetweenFrames();
}
+ (float) timeBetweenLogic
{
	PXDebugInformIfCalculateFrameRateOn(@"timeBetweenLogic");

	return _PXEngineDBGGetTimeBetweenLogic();
}
+ (float) timeBetweenRendering
{
	PXDebugInformIfCalculateFrameRateOn(@"timeBetweenRendering");

	return _PXEngineDBGGetTimeBetweenRendering();
}
+ (float) timeWaiting
{
	PXDebugInformIfCalculateFrameRateOn(@"timeWaiting");

	return _PXEngineDBGGetTimeWaiting();
}

@end
