//
//  FPSSprite.m
//  PXGLSpeed
//
//  Created by John Lattin on 3/24/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "FPSSprite.h"

#include "PXMathUtils.h"

@implementation FPSSprite

- (id) init
{
	self = [super init];

	if (self)
	{
		[PXDebug setCalculateFrameRate:YES];
		[PXDebug setCountGLCalls:YES];

		[PXFont registerFontWithContentsOfFile:@"defaultFont.fnt"
										  name:@"defaultFont"
									   options:nil];

		nonEssentialSprite = [[PXSprite alloc] init];
		[self addChild:nonEssentialSprite];
		essentialSprite = [[PXSprite alloc] init];
		[self addChild:essentialSprite];

#define ADD_TEXT_FIELD(_textField_,_sprite_) \
{ \
	_textField_ = [[PXTextField alloc] initWithFont:@"defaultFont"]; \
	[_sprite_ addChild:_textField_]; \
	[_textField_ release]; \
	_textField_.textColor = 0xFFFFFF;\
	_textField_.fontSize = 10.0f;\
	_textField_.smoothing = YES;\
}
#define ADD_LABEL_AND_TEXT_FIELD(_label_, _textField_, _spriteLabel_, _spriteField_) \
{ \
	ADD_TEXT_FIELD(_label_, _spriteLabel_); \
	ADD_TEXT_FIELD(_textField_, _spriteField_); \
}

		ADD_LABEL_AND_TEXT_FIELD(lblLogicTime, tfLogicTime, nonEssentialSprite, nonEssentialSprite);
		ADD_LABEL_AND_TEXT_FIELD(lblRenderTime, tfRenderTime, nonEssentialSprite, nonEssentialSprite);

		ADD_LABEL_AND_TEXT_FIELD(lblFrameTime, tfFrameTime, nonEssentialSprite, essentialSprite);

		ADD_TEXT_FIELD(lblBar, nonEssentialSprite);

		ADD_LABEL_AND_TEXT_FIELD(lblFPS, tfFPS, nonEssentialSprite, nonEssentialSprite);
		ADD_LABEL_AND_TEXT_FIELD(lblCallCount, tfCallCount, nonEssentialSprite, nonEssentialSprite);
		ADD_LABEL_AND_TEXT_FIELD(lblCustom, tfCustom, nonEssentialSprite, nonEssentialSprite);

		lblLogicTime.text  = @"Logic  Time:";
		lblRenderTime.text = @"Render Time:";
		lblFrameTime.text  = @"Frame  Time:";
		lblBar.text        = @"-------------------------";
		lblFPS.text        = @"FPS        :";
		lblCallCount.text  = @"GL Calls   :";
		lblCustom.text     = @"Custom     :";

		float x = 0.0f;
		float y = 0.0f;
		
#define SET_POSITION_FOR_TEXT_FIELD(_textField_) \
{ \
	_textField_.x = x; \
	_textField_.y = y; \
	y += _textField_.height + 2; \
}
#define SET_POSITION_FOR_LABEL_AND_TEXT_FIELD(_label, _textField_) \
{ \
	_label.x = x; \
	_label.y = y; \
	_textField_.x  = x + _label.width; \
	_textField_.y  = y; \
	y += _label.height + 2; \
}
		SET_POSITION_FOR_LABEL_AND_TEXT_FIELD(lblLogicTime, tfLogicTime);
		SET_POSITION_FOR_LABEL_AND_TEXT_FIELD(lblRenderTime, tfRenderTime);

		SET_POSITION_FOR_LABEL_AND_TEXT_FIELD(lblFrameTime, tfFrameTime);

		SET_POSITION_FOR_TEXT_FIELD(lblBar);
		SET_POSITION_FOR_LABEL_AND_TEXT_FIELD(lblFPS, tfFPS);
		SET_POSITION_FOR_LABEL_AND_TEXT_FIELD(lblCallCount, tfCallCount);
		SET_POSITION_FOR_LABEL_AND_TEXT_FIELD(lblCustom, tfCustom);

		float buffer = 5.0f;
		CGRect rect = CGRectMake(-buffer, -buffer, self.width + (buffer * 2.0f), self.height + (buffer * 2.0f));
		[nonEssentialSprite.graphics beginFill:0x000000 alpha:0.7f];
		[nonEssentialSprite.graphics drawRectWithX:rect.origin.x y:rect.origin.y width:rect.size.width height:rect.size.height];
		[nonEssentialSprite.graphics endFill];
		[nonEssentialSprite.graphics lineStyleWithThickness:buffer color:0x000000 alpha:0.9f];
		[nonEssentialSprite.graphics drawRectWithX:rect.origin.x y:rect.origin.y width:rect.size.width height:rect.size.height];

		[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame:)];
		[self addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(onTouchDown:)];

		lastTime = PXGetTimerSec();

		essentialSprite.x = tfFrameTime.x;
		essentialSprite.y = tfFrameTime.y;
		tfFrameTime.x -= essentialSprite.x;
		tfFrameTime.y -= essentialSprite.y;

		previousPosition = CGPointMake(essentialSprite.x, essentialSprite.y);
		
		[self performSelector:@selector(onTouchDown:) withObject:nil];
	}

	return self;
}

- (void) dealloc
{
	[self removeEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame:)];
	[self removeEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(onTouchDown:)];

	[nonEssentialSprite release];
	[essentialSprite release];

	[super dealloc];
}

- (void) setLabel:(NSString *)label
{
	lblCustom.text = label;
}

- (NSString *)label
{
	return lblCustom.text;
}

- (void) setText:(NSString *)text
{
	tfCustom.text = text;
}

- (NSString *)text
{
	return tfCustom.text;
}

- (float) updateTime:(float)time1 time2:(float)time2
{
	/*float fps1 = 1.0f / time1;
	float fps2 = 1.0f / time2;

	float deltaVal = 30.0f;
	if (fps1 > 30.0f || fps2 > 30.0f)
	{
		deltaVal = fmaxf(fps1, fps2) * 0.5f;
	}

	if (PXMathIsNearlyEqual(fps1, fps2, deltaVal))
	{*/
		float smooth = 0.975f;
		float oneMinusSmooth = 1.0f - smooth;
		return (time1 * smooth) + (time2 * oneMinusSmooth);
	//}

	//return time2;
}

- (void) onTouchDown:(PXTouchEvent *)event
{
	if ([self containsChild:nonEssentialSprite])
	{
		[self removeChild:nonEssentialSprite];
		previousPosition = CGPointMake(essentialSprite.x, essentialSprite.y);
		essentialSprite.x = 0.0f;
		essentialSprite.y = 0.0f;
	}
	else
	{
		[self addChild:nonEssentialSprite atIndex:0];
		essentialSprite.x = previousPosition.x;
		essentialSprite.y = previousPosition.y;
	}
}

- (void) onFrame:(PXEvent *)event
{
	double newTime = PXGetTimerSec();
	float deltaTime = newTime - lastTime;
	lastTime = newTime;

	timeBetweenLogic     = [self updateTime:timeBetweenLogic time2:[PXDebug timeBetweenLogic]];
	timeBetweenRendering = [self updateTime:timeBetweenRendering time2:[PXDebug timeBetweenRendering]];
	timeBetweenFrames    = [self updateTime:timeBetweenFrames time2:[PXDebug timeBetweenFrames]];

	lastDeltaTime = [self updateTime:lastDeltaTime time2:deltaTime];

	if ([self containsChild:nonEssentialSprite])
	{
		tfLogicTime.text  = [NSString stringWithFormat:@" %1.4f - %d", timeBetweenLogic, lroundf(1.0f / timeBetweenLogic)];
		tfRenderTime.text = [NSString stringWithFormat:@" %1.4f - %d", timeBetweenRendering, lroundf(1.0f / timeBetweenRendering)];
		tfFPS.text        = [NSString stringWithFormat:@" %d", lroundf(1.0f / lastDeltaTime)];
		tfCallCount.text  = [NSString stringWithFormat:@" %d", [PXDebug glCallCount]];
	}
	tfFrameTime.text  = [NSString stringWithFormat:@" %1.4f - %d", timeBetweenFrames, lroundf(1.0f / timeBetweenFrames)];
}

@end
