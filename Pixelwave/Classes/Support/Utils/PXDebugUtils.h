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

#ifndef _PX_DEBUG_UTILS_H_
#define _PX_DEBUG_UTILS_H_

#import "PXDebug.h"
#include "PXHeaderUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef enum
{
	PXDebugSetting_None							= 0x00000000,
	PXDebugSetting_DrawBoundingBoxes			= 0x00000001,
	PXDebugSetting_HalveStage					= 0x00000002,
	PXDebugSetting_CalculateFrameRate			= 0x00000004,
	PXDebugSetting_CountGLCalls					= 0x00000008,
	PXDebugSetting_LogErrors					= 0x00000010,
	PXDebugSetting_DrawHitAreas					= 0x00000020,
	PXDebugSetting_All							= 0xFFFFFFFF
} PXDebugSetting;
	
PXInline_h void PXDebugEnableSetting(PXDebugSetting flag);
PXInline_h void PXDebugDisableSetting(PXDebugSetting flag);
PXInline_h BOOL PXDebugIsEnabled(PXDebugSetting flag);

PXInline_h void PXDebugInformIfCalculateFrameRateOn(NSString *methodName);
PXInline_h NSString *PXDebugALErrorInfo(int error);
	
#ifdef __cplusplus
}
#endif

#endif
