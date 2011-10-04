//
//  FPSSprite.h
//  PXGLSpeed
//
//  Created by John Lattin on 3/24/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "Pixelwave.h"

@interface FPSSprite : PXSprite
{
@protected
	PXSprite *essentialSprite;
	PXSprite *nonEssentialSprite;

	PXTextField *lblBar;

	PXTextField *lblLogicTime;
	PXTextField *lblRenderTime;
	PXTextField *lblFrameTime;
	PXTextField *lblFPS;
	PXTextField *lblCallCount;
	PXTextField *lblCustom;

	PXTextField *tfLogicTime;
	PXTextField *tfRenderTime;
	PXTextField *tfFrameTime;
	PXTextField *tfFPS;
	PXTextField *tfCallCount;
	PXTextField *tfCustom;

	float timeBetweenLogic;
	float timeBetweenRendering;
	float timeBetweenFrames;

	float lastDeltaTime;
	double lastTime;

	CGPoint previousPosition;
}

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *text;

@end
