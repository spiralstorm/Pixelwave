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

#ifndef _PX_TEXTURE_PADDING_H_
#define _PX_TEXTURE_PADDING_H_

typedef struct
{
	float top;
	float right;
	float bottom;
	float left;
} _PXTexturePadding;

#ifdef __cplusplus
extern "C" {
#endif
	
	_PXTexturePadding _PXTexturePaddingMake(float top, float right, float bottom, float left);
	
#ifdef __cplusplus
}
#endif
#endif


@interface PXTexturePadding : NSObject <NSCopying>
{
@public
	_PXTexturePadding _padding;
}

/**
 * The amount of padding (in points) to be added to
 * the top side of the texture;
 */
@property (nonatomic, assign) float top;
/**
 * The amount of padding (in points) to be added to
 * the right side of the texture;
 */
@property (nonatomic, assign) float right;
/**
 * The amount of padding (in points) to be added to
 * the bottom side of the texture;
 */
@property (nonatomic, assign) float bottom;
/**
 * The amount of padding (in points) to be added to
 * the left side of the texture;
 */
@property (nonatomic, assign) float left;

- (id) initWithTop:(float)top
			 right:(float)right
			bottom:(float)bottom
			  left:(float)left;

- (id) initWithTexturePadding:(PXTexturePadding *)padding;

- (void) setTop:(float)top
		  right:(float)right
		 bottom:(float)bottom
		   left:(float)left;

+ (id)texturePaddingWithTop:(float)top
					  right:(float)right
					 bottom:(float)bottom
					   left:(float)left;
+ (id)texturePaddingWithPadding:(PXTexturePadding *)padding;

@end
