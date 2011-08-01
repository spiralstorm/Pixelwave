//
//  CradleBallSprite.m
//  NewtonsCradle
//
//  Created by Oz Michaeli on 7/31/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CradleBallSprite.h"

@interface CradleBallSprite (Private)
- (void) onTouchDown;
- (void) onTouchUp;
@end

@implementation CradleBallSprite

- (id) initWithAtlas:(PXTextureAtlas *)atlas
{
    self = [super init];
    if (self) {
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
// sphere are more realistic, by keeping their rotation
// static.
- (void) setShadeRotation:(float)rotation{
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
