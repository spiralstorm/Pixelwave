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

#import "ParticlesRoot.h"

#import "FPSSprite.h"
#import "NotificationBox.h"
#import "FaderOuter.h"

// Samples
#import "FountainSample.h"
#import "FireSample.h"
#import "DesignerSample.h"
#import "PointRendererSample.h"

@interface ParticlesRoot (Private)
- (void) setCurrentSample:(uint)index;
- (void) setSample:(Sample *)sample;

- (void) showButtons;

- (void) onTouchDown:(PXTouchEvent *)e;
- (void) onTouchMove:(PXTouchEvent *)e;
- (void) onTouchUp:(PXTouchEvent *)e;
- (void) onTouchCancel:(PXTouchEvent *)e;
@end

@implementation ParticlesRoot

- (void) initializeAsRoot
{
	self.stage.backgroundColor = 0x000000;

	self.stage.frameRate = 60.0f;
//	self.stage.renderFrameRate = 60.0f;

	// Events

	[self addEventListenerOfType:PXEvent_EnterFrame listener:PXListener(onFrame)];

	[self.stage addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(onTouchDown:)];
	[self.stage addEventListenerOfType:PXTouchEvent_TouchMove listener:PXListener(onTouchMove:)];
	[self.stage addEventListenerOfType:PXTouchEvent_TouchUp listener:PXListener(onTouchUp:)];
	[self.stage addEventListenerOfType:PXTouchEvent_TouchCancel listener:PXListener(onTouchCancel:)];

	// Set up the background

	PXTextureAtlas *atlas = [PXTextureAtlas textureAtlasWithContentsOfFile:@"Assets.json" modifier:nil];	
/*	PXTexture *bg = [atlas textureForFrame:@"Background.png"];
	[self addChild:bg];

	bg.width  = self.stage.stageWidth;
	bg.height = self.stage.stageHeight;*/

	sampleContainer = [[PXSimpleSprite alloc] init];
	sampleContainer.touchChildren = NO;
	sampleContainer.touchEnabled = NO;
	[self addChild:sampleContainer];

	// Arrows
	PXTexture *btnUpTexture;
	PXTexture *btnDownTexture;

	btnUpTexture = [atlas textureForFrame:@"ArrowButton.png"];
	[btnUpTexture setAnchorWithX:0.5f y:0.5f];
	btnDownTexture = [atlas textureForFrame:@"ArrowButton.png"];
	btnDownTexture.transform.colorTransform = [PXColorTransform colorTransformWithRedMult:0.5f greenMult:0.5f blueMult:0.5f alphaMult:1.0f];
	[btnDownTexture setAnchorWithX:0.5f y:0.5f];

	btnNext = [PXSimpleButton simpleButtonWithUpState:btnUpTexture downState:btnDownTexture hitRectWithPadding:10.0f];
	btnNext.x = self.stage.stageWidth - 40.0f;
	btnNext.y = self.stage.stageHeight * 0.5f;
	[btnNext addEventListenerOfType:PXTouchEvent_Tap listener:PXListener(onNextTap)];

	btnPrev = [PXSimpleButton simpleButtonWithUpState:btnUpTexture downState:btnDownTexture hitRectWithPadding:10.0f];
	btnPrev.x = 40.0f;
	btnPrev.y = self.stage.stageHeight * 0.5f;
	btnPrev.scaleX = -1.0f;
	[btnPrev addEventListenerOfType:PXTouchEvent_Tap listener:PXListener(onPrevTap)];

	buttonsContainer = [PXSimpleSprite simpleSpriteWithChildren:[NSArray arrayWithObjects:btnPrev, btnNext, nil]];
	buttonsContainer.touchEnabled = NO;
	[self addChild:buttonsContainer];

	// Notification box
	notificationBox = [[[NotificationBox alloc] init] autorelease];
	notificationBox.x = self.stage.stageWidth  * 0.5f;
	notificationBox.y = self.stage.stageHeight * 0.5f;
	notificationBox.touchEnabled = NO;
	notificationBox.touchChildren = NO;

	[self addChild:notificationBox];

	samples = [[NSArray arrayWithObjects:
				[[[FountainSample alloc] init] autorelease],
				[[[DesignerSample alloc] init] autorelease],
				[[[PointRendererSample alloc] init] autorelease],
				[[[FireSample alloc] init] autorelease],
			   nil] retain];

	[self setCurrentSample:0];
	[self showButtons];

	// FPS
	fpsSprite = [[FPSSprite alloc] init];
	[self addChild:fpsSprite];
	[fpsSprite release];
	fpsSprite.label = @"new count  :";

	fpsSprite.x = 16.0f;
	fpsSprite.y = 16.0f;
}

- (void) dealloc
{
	[self setSample:nil];

	[samples release];
	samples = nil;

	[sampleContainer release];
	sampleContainer = nil;

	[super dealloc];
}

 - (void) setCurrentSample:(uint)index
{
	currentSample = index;

	Sample *s = [samples objectAtIndex:currentSample];
	
	[self setSample:s];
}
	 
- (void) setSample:(Sample *)value
{
	[value retain];

	if (sample)
	{
		[sample teardown];
		[sampleContainer removeChild:sample];
		sample = nil;
	}

	if (value)
	{
		sample = value;
		[sampleContainer addChild:sample];
		[sample setup];
	}

	[value release];

	[notificationBox showWithTitle:[sample description]
						  subtitle:[NSString stringWithFormat:@"%i/%i", currentSample + 1, samples.count]];
	[self showButtons];
}

- (void) showButtons
{
	[[FaderOuter sharedFader] stopAnimationsForObject:buttonsContainer];
	buttonsContainer.alpha = 1.0f;
	buttonsContainer.visible = YES;
	[[FaderOuter sharedFader] fadeOutObject:buttonsContainer afterDelay:2.0f];
}

- (void) onNextTap
{
	++currentSample;

	if (currentSample >= samples.count)
	{
		currentSample = 0;
	}

	[self setCurrentSample:currentSample];
}

- (void) onPrevTap
{
	--currentSample;

	if (currentSample < 0)
	{
		currentSample = samples.count - 1;
	}

	[self setCurrentSample:currentSample];
}

- (void) onTouchDown:(PXTouchEvent *)event
{
	if (event.eventPhase != PXEventPhase_Target)
		return;

	[self showButtons];

	[sample onTouchDown:event];
}

- (void) onTouchMove:(PXTouchEvent *)event
{
	if (event.eventPhase != PXEventPhase_Target)
		return;

	[sample onTouchMove:event];
}

- (void) onTouchUp:(PXTouchEvent *)event
{
	if (event.eventPhase != PXEventPhase_Target)
		return;

	[sample onTouchUp:event];
}

- (void) onTouchCancel:(PXTouchEvent *)event
{
	if (event.eventPhase != PXEventPhase_Target)
		return;

	[sample onTouchCancel:event];
}

- (void) onFrame
{
	fpsSprite.text = [NSString stringWithFormat:@" %u", sample.particleCount];
}

@end
