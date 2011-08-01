//
//  CradleBallSprite.h
//  NewtonsCradle
//
//  Created by Oz Michaeli on 7/31/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "Pixelwave.h"

@interface CradleBallSprite : PXSimpleSprite
{
@private
	PXTexture *shadeTexture;
	PXTexture *glowTexture;
}
- (id) initWithAtlas:(PXTextureAtlas *)atlas;
- (void) setShadeRotation:(float)rotation;

- (void) setSelected:(BOOL)selected;

@end
