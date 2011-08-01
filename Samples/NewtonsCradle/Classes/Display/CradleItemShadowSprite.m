//
//  CradleBall.m
//  NewtonsCradle
//
//  Created by Oz Michaeli on 7/31/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "Globals.h"
#import "CradleItemShadowSprite.h"

@implementation CradleItemShadowSprite

- (id) initWithAtlas:(PXTextureAtlas *)atlas ropeLength:(float)ropeLength
{
    self = [super init];
    if (self) {
		// Create the ball shadow
		PXTexture *ballShadow = [atlas textureForFrame:@"BallWallShadow.png"];
		ballShadow.smoothing = YES;
		[ballShadow setAnchorWithX:0.5f y:0.5f];
		ballShadow.y = ropeLength;
		[self addChild:ballShadow];
		
		// Create the rod shadow
		PXTexture *rodShadow = [atlas textureForFrame:@"RodWallShadow.png"];
		rodShadow.smoothing = YES;
		[rodShadow setAnchorWithX:0.5f y:1.0f];
		rodShadow.y = ballShadow.y - 22.0f * myContentScale;
		[self addChild:rodShadow];
    }
    
    return self;
}

@end
