//
//  FPSSprite.h
//  PXGLSpeed
//
//  Created by John Lattin on 3/24/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "Pixelwave.h"

typedef enum
{
	FPSSpriteDisplayMode_Print  = 0x01,
	FPSSpriteDisplayMode_Render = 0x02,
	FPSSpriteDisplayMode_PrintAndRender = 0x03
} FPSSpriteDisplayMode;

@interface FPSSprite : PXSprite
{
@protected
	FPSSpriteDisplayMode displayMode;

	PXSprite *essentialSprite;
	PXSprite *nonEssentialSprite;

	PXTextField *lblBar;

	PXTextField *lblLogicTime;
	PXTextField *lblRenderTime;
	PXTextField *lblFPS;
	PXTextField *lblCallCount;
	PXTextField *lblCustom;

	PXTextField *tfLogicTime;
	PXTextField *tfRenderTime;
	PXTextField *tfFPS;
	PXTextField *tfCallCount;
	PXTextField *tfCustom;

	float timeBetweenLogic;

	float lastDeltaTime;
	double lastTime;

	CGPoint previousPosition;

	unsigned int frameCount;
}

@property (nonatomic, assign) FPSSpriteDisplayMode displayMode;

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *text;

@end
