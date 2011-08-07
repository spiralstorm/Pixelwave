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

#import "CradleBallSprite.h"

@interface CradleBallSprite (Private)
- (void) onTouchDown;
- (void) onTouchUp;
@end

@implementation CradleBallSprite

- (id) initWithAtlas:(PXTextureAtlas *)atlas
{
    self = [super init];

    if (self)
	{
		PXTexture *baseTexture = [atlas textureForFrame:@"BallBase.png"];
		shadeTexture = [atlas textureForFrame:@"BallShade.png"];
		glowTexture = [atlas textureForFrame:@"TouchGlow.png"];

		baseTexture.smoothing = YES;

		// We don't need to smooth the shade texture because it'll never rotate

		[baseTexture setAnchorWithX:0.5f y:0.5f];
		[shadeTexture setAnchorWithX:0.5f y:0.5f];
		[glowTexture setAnchorWithX:0.5f y:0.5f];

		baseTexture.rotation = [PXMath randomFloatInRangeFrom:0.0f to:360.0f];

		[self addChild:baseTexture];
		[self addChild:shadeTexture];
		[self addChild:glowTexture];

		[self setSelected:NO];
    }

    return self;
}

// Used to make it seem like the highlights/shadows of the
// sphere are more realistic by keeping their rotation
// static.
- (void) setShadeRotation:(float)rotation
{
	shadeTexture.rotation = rotation;
	glowTexture.rotation = rotation;
}

// Used to turn the glow on/off as the user presses/releases
// the ball.
- (void) setSelected:(BOOL)selected
{
	glowTexture.visible = selected;
}

@end
