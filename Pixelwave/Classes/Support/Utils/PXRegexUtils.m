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

#import "PXRegexUtils.h"

#import "PXDebug.h"

#include "regex.h"

PXInline_c BOOL PXRegexError(int error)
{
	switch(error)
	{
		case REG_OK:
			// No error = no message
			return NO; // DON'T STOP!
			break;
		case REG_NOMATCH:
			// No match = no message
			// no return, because we want it to stop.
			break;
		case REG_BADPAT:
			// Invalid regexp.
			PXDebugLog(@"Invalid regular expression.");
			break;
		case REG_ECOLLATE:
			// Unknown collating element.
			PXDebugLog(@"Unknown collating element.");
			break;
		case REG_ECTYPE:
			// Unknown character class name.
			PXDebugLog(@"Unknown character class name.");
			break;
		case REG_EESCAPE:
			// Trailing backslash.
			PXDebugLog(@"Trailing backslash.");
			break;
		case REG_ESUBREG:
			// Invalid back reference.
			PXDebugLog(@"Invalid back reference.");
			break;
		case REG_EBRACK:
			// "[]" imbalance.
			PXDebugLog(@"\"[]\" imbalance.");
			break;
		case REG_EPAREN:
			// "\(\)" or "()" imbalance.
			PXDebugLog(@"\"\\(\\)\" or \"()\" imbalance.");
			break;
		case REG_EBRACE:
			// "\{\}" or "{}" imbalance.
			PXDebugLog(@"\"\\{\\}\" or \"{}\" imbalance.");
			break;
		case REG_BADBR:
			// Invalid content of {}.
			PXDebugLog(@"Invalid content of {}.");
			break;
		case REG_ERANGE:
			// Invalid use of range operator
			PXDebugLog(@"Invalid use of range operator");
			break;
		case REG_ESPACE:
			// Out of memory.
			PXDebugLog(@"Out of memory.");
			break;
		case REG_BADRPT:
			// Invalid use of repetition operators.
			PXDebugLog(@"Invalid use of repetition operators.");
			break;
	}

	return YES;
}
