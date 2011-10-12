//
//  FPSSprite.m
//  PXGLSpeed
//
//  Created by John Lattin on 3/24/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "FPSSprite.h"

#include "PXPrivateUtils.h"
#include "PXMathUtils.h"

static const unsigned int fpsSpriteTextFieldLength = 6;

@interface FPSSprite(Private)
- (void) onTouchDown:(PXTouchEvent *)event;

- (NSString *)formatString:(NSString *)string desiredLength:(NSUInteger)desiredLength shiftLeft:(BOOL)shiftLeft;
- (NSString *)formatString:(NSString *)string desiredLength:(NSUInteger)desiredLength shiftLeft:(BOOL)shiftLeft appendCharacter:(NSString *)singleCharacter;
@end

@implementation FPSSprite

@synthesize displayMode;

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

		nonEssentialSprite.touchEnabled = NO;
		nonEssentialSprite.touchChildren = NO;
		essentialSprite.touchEnabled = NO;
		essentialSprite.touchChildren = NO;

#define ADD_TEXT_FIELD(_textField_,_sprite_) \
{ \
	_textField_ = [[PXTextField alloc] initWithFont:@"defaultFont"]; \
	[_sprite_ addChild:_textField_]; \
	[_textField_ release]; \
	_textField_.textColor = 0xFFFFFF; \
	_textField_.fontSize = 10.0f; \
	_textField_.smoothing = YES; \
	_textField_.touchEnabled = NO; \
}
#define ADD_LABEL_AND_TEXT_FIELD(_label_, _textField_, _spriteLabel_, _spriteField_) \
{ \
	ADD_TEXT_FIELD(_label_, _spriteLabel_); \
	ADD_TEXT_FIELD(_textField_, _spriteField_); \
}

		ADD_LABEL_AND_TEXT_FIELD(lblLogicTime, tfLogicTime, nonEssentialSprite, nonEssentialSprite);
		ADD_LABEL_AND_TEXT_FIELD(lblRenderTime, tfRenderTime, nonEssentialSprite, nonEssentialSprite);

		ADD_TEXT_FIELD(lblBar, nonEssentialSprite);

		ADD_LABEL_AND_TEXT_FIELD(lblFPS, tfFPS, nonEssentialSprite, essentialSprite);
		ADD_LABEL_AND_TEXT_FIELD(lblCallCount, tfCallCount, nonEssentialSprite, nonEssentialSprite);
		ADD_LABEL_AND_TEXT_FIELD(lblCustom, tfCustom, nonEssentialSprite, nonEssentialSprite);

		lblLogicTime.text  = @"Logic    :";
		lblRenderTime.text = @"Render   :";
		lblBar.text        = @"----------";
		lblFPS.text        = @"FPS      :";
		lblCallCount.text  = @"GL Calls :";
		lblCustom.text     = @"Custom   :";

		lblBar.text = [self formatString:lblBar.text desiredLength:(fpsSpriteTextFieldLength + [lblLogicTime.text length]) shiftLeft:NO appendCharacter:@"-"];

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

		SET_POSITION_FOR_TEXT_FIELD(lblBar);
		SET_POSITION_FOR_LABEL_AND_TEXT_FIELD(lblFPS, tfFPS);
		SET_POSITION_FOR_LABEL_AND_TEXT_FIELD(lblCallCount, tfCallCount);
		SET_POSITION_FOR_LABEL_AND_TEXT_FIELD(lblCustom, tfCustom);

		const float buffer = 5.0f;
		CGRect rect = CGRectMake(-buffer, -buffer, self.width + (buffer * 2.0f), self.height + (buffer * 2.0f));
		[nonEssentialSprite.graphics beginFill:0x000000 alpha:0.7f];
		[nonEssentialSprite.graphics drawRectWithX:rect.origin.x y:rect.origin.y width:rect.size.width height:rect.size.height];
		[nonEssentialSprite.graphics endFill];
		[nonEssentialSprite.graphics lineStyleWithThickness:buffer color:0x000000 alpha:0.9f];
		[nonEssentialSprite.graphics drawRectWithX:rect.origin.x y:rect.origin.y width:rect.size.width height:rect.size.height];

		[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame:)];
		[self addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(onTouchDown:)];

		lastTime = PXGetTimerSec();

		essentialSprite.x = tfFPS.x;
		essentialSprite.y = tfFPS.y;
		tfFPS.x -= essentialSprite.x;
		tfFPS.y -= essentialSprite.y;

		previousPosition = CGPointMake(essentialSprite.x, essentialSprite.y);

		PXRectangle *bounds = [self boundsWithCoordinateSpace:self];
		self.hitArea = bounds;

		lastDeltaTime = 1.0f / [PXStage mainStage].frameRate;
	//	[self onTouchDown:nil];

		self.displayMode = FPSSpriteDisplayMode_Render;
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

- (void) setDisplayMode:(FPSSpriteDisplayMode)value
{
	displayMode = value;

	if (PX_IS_BIT_ENABLED(displayMode, FPSSpriteDisplayMode_Render) == YES)
	{
		self.visible = YES;
	}
	else
	{
		self.visible = NO;
	}
}

- (NSString *)formatString:(NSString *)string desiredLength:(NSUInteger)desiredLength shiftLeft:(BOOL)shiftLeft
{
	return [self formatString:string desiredLength:desiredLength shiftLeft:shiftLeft appendCharacter:nil];
}

- (NSString *)formatString:(NSString *)string desiredLength:(NSUInteger)desiredLength shiftLeft:(BOOL)shiftLeft appendCharacter:(NSString *)singleCharacter
{
	if (singleCharacter == nil || [singleCharacter length] == 0)
	{
		singleCharacter = @" ";
	}
	else if ([singleCharacter length] > 1)
	{
		singleCharacter = [string substringWithRange:NSMakeRange(0, 1)];
	}

	NSUInteger recievedLength = [string length];

	if (recievedLength < desiredLength)
	{
		NSUInteger delta = desiredLength - recievedLength;
		NSUInteger index;

		// This is really silly, fix it when there is time.
		for (index = 0; index < delta; ++index)
		{
			if (shiftLeft == YES)
			{
				string = [NSString stringWithFormat:@"%@%@", string, singleCharacter];
			}
			else
			{
				string = [NSString stringWithFormat:@"%@%@", singleCharacter, string];
			}
		}
	}
	else if (recievedLength > desiredLength)
	{
		string = [string substringWithRange:NSMakeRange(0, desiredLength)];
	}

	return string;
}

- (void) setLabel:(NSString *)label
{
	NSUInteger desiredLength = [lblLogicTime.text length] - 1;

	label = [self formatString:label desiredLength:desiredLength shiftLeft:YES];

	lblCustom.text = [NSString stringWithFormat:@"%@:", label];
}

- (NSString *)label
{
	return lblCustom.text;
}

- (void) setText:(NSString *)text
{
	tfCustom.text = [self formatString:text desiredLength:fpsSpriteTextFieldLength shiftLeft:NO];
}

- (NSString *)text
{
	return tfCustom.text;
}

- (float) updateTime:(float)time1 time2:(float)time2
{
	const float smooth = 0.975f;
	float oneMinusSmooth = 1.0f - smooth;

	return (time1 * smooth) + (time2 * oneMinusSmooth);
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

- (NSString *)percentString:(float)percent
{
	if (percent > 99.9f)
		percent = 99.9f;

	NSString *string = [NSString stringWithFormat:@"%2.1f%%", percent];

	string = [self formatString:string desiredLength:fpsSpriteTextFieldLength shiftLeft:NO];

	return string;
}

- (void) onFrame:(PXEvent *)event
{
	double newTime = PXGetTimerSec();
	float deltaTime = newTime - lastTime;
	lastTime = newTime;

	timeBetweenLogic = [self updateTime:timeBetweenLogic time2:[PXDebug timeBetweenLogic]];

	lastDeltaTime = [self updateTime:lastDeltaTime time2:deltaTime];

	float fps = 1.0f / lastDeltaTime;

	if (fps > 99.99f)
		fps = 99.99f;

	if (PX_IS_BIT_ENABLED(displayMode, FPSSpriteDisplayMode_Render) == YES)
	{
		if ([self containsChild:nonEssentialSprite])
		{
			int logicPercent = lroundf((timeBetweenLogic / lastDeltaTime) * 1000.0f);
			int renderPercent = 1000 - logicPercent;
			NSString *fpsString = [NSString stringWithFormat:@"%2.2f", fps];
			NSString *callCountString = [NSString stringWithFormat:@"%d", [PXDebug glCallCount]];

			tfLogicTime.text  = [self percentString:logicPercent / 10.0f];
			tfRenderTime.text = [self percentString:renderPercent / 10.0f];
			tfFPS.text        = [self formatString:fpsString desiredLength:fpsSpriteTextFieldLength shiftLeft:NO];
			tfCallCount.text  = [self formatString:callCountString desiredLength:fpsSpriteTextFieldLength shiftLeft:NO];
		}
		else
			tfFPS.text        = [NSString stringWithFormat:@"%d", lroundf(fps)];
	}

	if (PX_IS_BIT_ENABLED(displayMode, FPSSpriteDisplayMode_Print) == YES)
	{
		if (++frameCount == 15)
		{
			frameCount = 0;

			PXDebugLog(@"fps = %2.2f\n", fps);
		}
	}
}

@end
