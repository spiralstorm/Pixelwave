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

#import "PXPooledObject.h"

@interface PXColorTransform : NSObject <NSCopying, PXPooledObject>
{
/// @cond DX_IGNORE
@private
	float redMultiplier;
	float greenMultiplier;
	float blueMultiplier;
	float alphaMultiplier;
/// @endcond
}

/**
 *	The red multiplier value ranging between 0.0f and 1.0f.
 */
@property (nonatomic, assign) float redMultiplier;
/**
 *	The green multiplier value ranging between 0.0f and 1.0f.
 */
@property (nonatomic, assign) float greenMultiplier;
/**
 *	The blue multiplier value ranging between 0.0f and 1.0f.
 */
@property (nonatomic, assign) float blueMultiplier;
/**
 *	The alpha multiplier value ranging between 0.0f and 1.0f.
 */
@property (nonatomic, assign) float alphaMultiplier;

//-- ScriptName: ColorTransform
//-- ScriptArg[0]: 1.0f
//-- ScriptArg[1]: 1.0f
//-- ScriptArg[2]: 1.0f
//-- ScriptArg[3]: 1.0f
- (id) initWithRedMult:(float)redMultiplier
			 greenMult:(float)greenMultiplier
			  blueMult:(float)blueMultiplier
			 alphaMult:(float)alphaMultiplier;

//-- ScriptName: setf
- (void) setMultipliersWithRed:(float)red
						 green:(float)green
						  blue:(float)blue
						 alpha:(float)alpha;

//-- ScriptName: set
- (void) setMultipliersWithRedValue:(unsigned char)red
						 greenValue:(unsigned char)green
						  blueValue:(unsigned char)blue
						 alphaValue:(unsigned char)alpha;

//-- ScriptName: make
//-- ScriptArg[0]: 1.0f
//-- ScriptArg[1]: 1.0f
//-- ScriptArg[2]: 1.0f
//-- ScriptArg[3]: 1.0f
+ (PXColorTransform *)colorTransformWithRedMult:(float)redMultiplier
									  greenMult:(float)greenMultiplier
									   blueMult:(float)blueMultiplier
									  alphaMult:(float)alphaMultiplier;

@end
