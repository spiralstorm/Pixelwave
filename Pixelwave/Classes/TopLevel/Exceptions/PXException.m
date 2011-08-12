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

#import "PXException.h"

#import "PXTypeException.h"

/**
 * The base class of all exceptions in the Pixelwave framework. To catch
 * exceptions associated only with the Pixelwave engine, one would do the
 * following:
 *
 *	@try
 *	{
 *		// ... Execute Pixelwave code
 *	}
 *	@catch (PXException *e)
 *	{
 *		// ... Handle Pixelwave exception
 *	}
 *	@finally
 *	{
 *		// ... Perform cleanup
 *	}
 *
 * @warning Exception handling isn't the standard way of handling run-time
 * errors in Objective-C. In Pixelwave exceptions are only thrown to let the
 * user know when a hard error occured (such as accessing an out-of-bounds
 * child in a container). For expected run-time errors (such as an incorrect
 * file path) `nil` is returned. If Pixelwave is running in debug mode
 * an error message is usually logged as well.
 */
@implementation PXException

/**
 * Creates a Pixelwave based exception.
 *
 * @param reason A human-readable message string summarizing the reason for the exception
 */
- (id) initWithReason:(NSString *)_reason
{
	return [self initWithReason:_reason userInfo:nil];
}

/**
 * Creates a Pixelwave based exception.
 *
 * @param reason A human-readable message string summarizing the reason for the exception
 * @param userInfo A dictionary containing user-defined information relating to the
 * exception
 */
- (id) initWithReason:(NSString *)_reason userInfo:(NSDictionary *)_userInfo
{
	return [super initWithName:@"PXException" reason:_reason userInfo:_userInfo];
}

@end
