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

#import "PXMath.h"
#import "PXMathUtils.h"

/**
 * Contains static methods for computing random values.
 * The PXMath class does not implement methods for general mathematical
 * operations such as `sin, cos, abs, sqrt, etc.`, but
 * instead is concentrated on dealing with random number generation.
 *
 * It is recommended to use the native C methods and Macros for common math
 * operations such as `sqrtf(), sinf(), atan2f(), etc.`.
 */

@implementation PXMath

/**
 * Returns a pseudo-random number, where 0.0f <= number < 1.0f.
 *
 * @return A pseudo-random number.
 *
 * **Example:**
 *	float randomValue = [PXMath random];
 *	//0.0f <= randomValue < 1.0f
 */
+ (float) random
{
	return PXMathRandom();
}

/**
 * Returns a pseudo-random number, where min <= number < max.  Due to the way
 * floating points work, the max value is possible under certain circumstances;
 * such as the min being 0.00001f and the max being 0.00002f.  However this is
 * still unlikely, and in the general use case it will never be equal to the
 * max.
 *
 * @return A pseudo-random number.
 *
 * **Example:**
 *	float randomValue = [PXMath randomFloatInRangeWithMin:3.0f max:4.5f];
 *	//3.0f <= randomValue < 4.5f
 */
+ (float) randomFloatInRangeFrom:(float)min to:(float)max
{
	return PXMathFloatInRange(min, max);
}

/**
 * Returns a pseudo-random number, where min <= number <= max.
 *
 * @return A pseudo-random number.
 *
 * **Example:**
 *	int randomValue = [PXMath randomIntInRangeWithMin:3 max:5];
 *	//3 <= randomValue <= 5, randomValue will be either 3, 4 or 5.
 */
+ (int) randomIntInRangeFrom:(int)min to:(int)max
{
	return PXMathIntInRange(min, max);
}

/**
 * Sets the seed for random number generation based on the current time.
 * This method gets called automatically when the Pixelwave engine is
 * initialized.
 */
+ (void) seedRandomWithTime
{
	PXMathSeedRandomWithTime();
}

/**
 * Sets the seed for random number generation with the specified value.
 * Useful in cases where a reproducible set of psuedo-random numbers is
 * required.
 *
 * @param value The new seed value.
 */
+ (void) seedRandomWithValue:(unsigned)value
{
	PXMathSeedRandomWithValue(value);
}

@end
