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

#import "PXDebugUtils.h"

#include "PXPrivateUtils.h"
#include "PXAL.h"

#include "PXSettings.h"

#ifdef PX_DEBUG_MODE
uint32_t pxDebugSettings = 0;
//NSString *pxDebugALErrorPrefix = nil;
#endif

void PXDebugEnableSetting(PXDebugSetting flag)
{
#ifdef PX_DEBUG_MODE
	PX_ENABLE_BIT(pxDebugSettings, flag);
#else
	PX_NOT_USED(flag);
#endif
}

void PXDebugDisableSetting(PXDebugSetting flag)
{
#ifdef PX_DEBUG_MODE
	PX_DISABLE_BIT(pxDebugSettings, flag);
#else
	PX_NOT_USED(flag);
#endif
}

bool PXDebugIsEnabled(PXDebugSetting flag)
{
#ifdef PX_DEBUG_MODE
	return PX_IS_BIT_ENABLED(pxDebugSettings, flag);
#else
	PX_NOT_USED(flag);
	
	return NO;
#endif
}

/*void PXDebugALBeginErrorChecks(NSString *prefix)
{
#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_ThoroughALErrorChecks))
	{
		[pxDebugALErrorPrefix release];
		pxDebugALErrorPrefix = [prefix copy];

		ALenum error = alGetError();
		if (error != AL_NO_ERROR)
		{
			PXDebugLog(@"%@.  Lingering error - ErrorID:0x%X, info:%@",
					   pxDebugALErrorPrefix,
					   error,
					   PXDebugALErrorInfo(error));
		}
	}
#else
	PX_NOT_USED(prefix);
#endif
}

bool PXDebugALErrorCheck(NSString *functionName)
{
#ifdef PX_DEBUG_MODE
	if (PXDebugIsEnabled(PXDebugSetting_ThoroughALErrorChecks))
	{
		ALenum error = alGetError();
		if (error != AL_NO_ERROR)
		{
			PXDebugLog(@"%@.  Error %@ - ErrorID:0x%X, info:%@",
					   pxDebugALErrorPrefix,
					   functionName,
					   error,
					   PXDebugALErrorInfo(error));
			
			return YES;
		}

		return NO;
	}
#else
	PX_NOT_USED(functionName);
#endif
	
	return NO;
}

PXInline_c void PXDebugALEndErrorChecks()
{
#ifdef PX_DEBUG_MODE
	[pxDebugALErrorPrefix release];
	pxDebugALErrorPrefix = nil;
#endif
}*/

PXInline_c void PXDebugInformIfCalculateFrameRateOn(const char* methodName)
{
#ifdef PX_DEBUG_MODE
	if (!PXDebugIsEnabled(PXDebugSetting_CalculateFrameRate))
	{
		printf("[PXDebug %s] can not be calculated unless PXDebugSetting_CalculateFrameRate is turned on\n", methodName);
	}
#else
	PX_NOT_USED(methodName);
#endif
}

PXInline_c const char* PXDebugALErrorInfo(int error)
{
#ifdef PX_DEBUG_MODE
	//	if (PXDebugIsEnabled(PXDebugSetting_ThoroughALErrorChecks))
	//	{
	if (error == AL_NO_ERROR)
	{
		return "no error";
	}
	
	switch (error)
	{
		case AL_INVALID_NAME:
			return "invalid name";
		case AL_INVALID_ENUM:
			return "invalid enum";
		case AL_INVALID_VALUE:
			return "invalid value";
		case AL_INVALID_OPERATION:
			return "invalid operation";
		case AL_OUT_OF_MEMORY:
			return "out of memory";
		case 0xFFFFFFFF:
			return "too many sounds playing";
		default:
			return "unknown error";
	}
	//	}
#else
	PX_NOT_USED(error);
#endif
	
	return nil;
}
