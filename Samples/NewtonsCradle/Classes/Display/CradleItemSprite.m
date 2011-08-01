//
//  CradleBall.m
//  NewtonsCradle
//
//  Created by Oz Michaeli on 7/31/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "Globals.h"
#import "CradleItemSprite.h"
#import "CradleBallSprite.h"

@implementation CradleItemSprite

- (id) initWithAtlas:(PXTextureAtlas *)atlas ropeLength:(float)ropeLength
{
    self = [super init];
    if (self) {
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
