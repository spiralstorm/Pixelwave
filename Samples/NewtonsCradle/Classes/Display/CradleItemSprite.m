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

#import "Globals.h"
#import "CradleItemSprite.h"
#import "CradleBallSprite.h"

@implementation CradleItemSprite

- (id) initWithAtlas:(PXTextureAtlas *)atlas ropeLength:(float)ropeLength
{
    self = [super init];

    if (self)
	{
		// Create the ball sprite
		ballSprite = [[CradleBallSprite alloc] initWithAtlas:atlas];
		ballSprite.y = ropeLength;

		[self addChild:ballSprite];
		[ballSprite release];

		// Create the rod
		PXTexture *rodTexture = [atlas textureForFrame:@"Rod.png"];
		[rodTexture setAnchorWithX:0.5f y:1.0f];
		rodTexture.y = ballSprite.y - 22.0f * myContentScale;
		rodTexture.smoothing = YES;
		[self addChild:rodTexture];
    }

    return self;
}

// We override the rotation property so that
// we can rotate the shadow and glow of the ball
// in the opposite direction. This creates the effect
// that they aren't rotating.
- (void) setRotation:(float)value
{
	[super setRotation:value];

	[ballSprite setShadeRotation:-value];
}

- (void) setSelected:(BOOL)selected
{
	[ballSprite setSelected:selected];
}

@end
