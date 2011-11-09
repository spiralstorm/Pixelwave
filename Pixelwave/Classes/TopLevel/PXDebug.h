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

#pragma mark Header

@interface PXDebug : NSObject
{
}

//-- ScriptName: setDrawBoundingBoxes
+ (void) setDrawBoundingBoxes:(BOOL)val;
//-- ScriptName: drawBoundingBoxes
+ (BOOL) drawBoundingBoxes;

//-- ScriptName: setDrawHitAreas
+ (void) setDrawHitAreas:(BOOL)val;
//-- ScriptName: drawBoundingBoxes
+ (BOOL) drawHitAreas;

//-- ScriptName: setHalveStage
+ (void) setHalveStage:(BOOL)val;
//-- ScriptName: halveStage
+ (BOOL) halveStage;

//-- ScriptName: setCalculateFrameRate
+ (void) setCalculateFrameRate:(BOOL)val;
//-- ScriptName: calculateFrameRate
+ (BOOL) calculateFrameRate;

//-- ScriptName: setCountGLCalls
+ (void) setCountGLCalls:(BOOL)val;
//-- ScriptName: countGLCalls
+ (BOOL) countGLCalls;
//-- ScriptName: glCallCount
+ (unsigned) glCallCount;

//-- ScriptName: setLogErrors
+ (void) setLogErrors:(BOOL)val;
//-- ScriptName: logErrors
+ (BOOL) logErrors;

//-- ScriptName: getTimeBetweenFrames
+ (float) timeBetweenFrames;
//-- ScriptName: getTimeBetweenLogic
+ (float) timeBetweenLogic;
//-- ScriptName: getTimeBetweenRendering
+ (float) timeBetweenRendering;
//-- ScriptName: getTimeWaiting
+ (float) timeWaiting;

@end

#ifndef _PX_DEBUG_H_
#define _PX_DEBUG_H_

#include "PXHeaderUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

PXInline_h void PXDebugLog(NSString *format, ...);

#ifdef __cplusplus
}
#endif

#endif
