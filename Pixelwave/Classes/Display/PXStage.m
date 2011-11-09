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

#import "PXView.h"
#import "PXStage.h"

#import "PXColorTransform.h"

#import "PXExceptionUtils.h"

#include "PXColorUtils.h"
#include "PXEngine.h"
#include "PXMathUtils.h"

@interface PXStage (Private)
- (void) onUnsettablePropertyAccess;
@end

/**
 * A special display object that represents the entire drawing surface of the Pixelwave engine
 * and contains several global properties such as the screen size and
 * orientation.
 * 
 * Display objects should never be added directly to the stage. instead they
 * should be added to the root display object.
 *
 * An instace of the PXStage class is automatically created when the display
 * list is created by a PXView object.
 *
 * @warning The PXStage class should never be instantiated by the user.
 * To access the global stage object, the [PXDisplayObject stage] property may be
 * read on any display object one the main display list. Alternatively you can use
 * the [PXStage mainStage] method.
 *
 * @see [PXDisplayObject stage]
 * @see [PXDisplayObject root]
 */
@implementation PXStage

//@synthesize x = _x;
@synthesize stageWidth;
@synthesize stageHeight;
@synthesize orientation;
@synthesize dispatchesDisplayListEvents;
@synthesize autoOrients;
@synthesize defaultCaptureTouchesValue;

- (id) init
{
	if (PXEngineGetStage())
	{
		PXThrow(PXArgumentException, @"PXStage class shouldn't be instantiated");
		[self release];
		return nil;
	}

	self = [super init];

	if (self)
	{
		// Ha ha, laugh it up...
		_touchChildren = YES;

		autoOrients = NO;
		defaultCaptureTouchesValue = YES;

		dispatchesDisplayListEvents = YES;

		[_name release];
		_name = nil;

		_captureTouches = NO;

	//	self.orientation = PXStageOrientation_Portrait;
	}

	return self;
}

/**
 * Signals Pixelwave to dispatch a `render` event to alert display objects
 * the next time a frame is about to be rendered. After the #invalidate method
 * is called, before the rendering phase is about to start, but after all
 * `enterFrame` events have been fired, a `render` event is dispatched.
 *
 * this method must be called every time you need a `render` event to be
 * dispatched.
 *
 * The `render` event lets you make changes to the display list right before
 * the rendering phase. This allows to write more optimized code which
 * only updates the display list when it is absolutely necessary.
 */
- (void) invalidate
{
	PXEngineInvalidateStage();
}

#pragma Properties

- (PXStage *)stage
{
	return self;
}

- (PXDisplayObject *)root
{
	return self;
}

- (void) setBackgroundColor:(uint)color
{
	PXColor3f c;
	PXColorHexToRGBf(color, &c);
	
	PXColor4f realColor = PXEngineGetClearColor();
	realColor.r = c.r;
	realColor.g = c.g;
	realColor.b = c.b;
	
	PXEngineSetClearColor(realColor);
}

- (unsigned int) backgroundColor
{
	PXColor4f c = PXEngineGetClearColor();
	int hex = 0;
	PXColorRGBToHex(c.r * 0xFF, c.g * 0xFF, c.b * 0xFF, &hex);
	
	return hex;
}

- (void) setClearScreen:(BOOL)val
{
	PXEngineSetClearScreen(val);
}

- (BOOL) clearScreen
{
	return PXEngineShouldClearScreen();
}

- (void) setPlaying:(BOOL)val
{
	PXEngineSetRunning(val);
}

- (BOOL) playing
{
	return PXEngineGetRunning();
}

- (void) setFrameRate:(float)fps
{
	PXEngineSetLogicFrameRate(fps);
}

- (float) frameRate
{
	return PXEngineGetLogicFrameRate();
}

- (void) setRenderFrameRate:(float)fps
{
	PXEngineSetRenderFrameRate(fps);
}

- (float) renderFrameRate
{
	return PXEngineGetRenderFrameRate();
}

- (float) contentScaleFactor
{
	return PXEngineGetContentScaleFactor();
}

- (void) setOrientation:(PXStageOrientation)orient
{
	UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationPortrait;

	switch (orient)
	{
		case PXStageOrientation_Portrait:
			interfaceOrientation = UIInterfaceOrientationPortrait;
			break;
		case PXStageOrientation_PortraitUpsideDown:
			interfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
			break;
		case PXStageOrientation_LandscapeLeft:
			interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
			break;
		case PXStageOrientation_LandscapeRight:
			interfaceOrientation = UIInterfaceOrientationLandscapeRight;
			break;
	}

	[UIApplication sharedApplication].statusBarOrientation = interfaceOrientation;

	//if (orient == orientation) return;

	float viewWidth = PXEngineGetViewWidth();
	float viewHeight = PXEngineGetViewHeight();

	orientation = orient;

	if (orientation == PXStageOrientation_Portrait)
	{
		_rotation = 0.0f;
		_matrix.tx = 0.0f;
		_matrix.ty = 0.0f;

		stageWidth = viewWidth;
		stageHeight = viewHeight;
	}
	else if (orientation == PXStageOrientation_PortraitUpsideDown)
	{
		_rotation = 180.0f;
		_matrix.tx = viewWidth;
		_matrix.ty = viewHeight;

		stageWidth = viewWidth;
		stageHeight = viewHeight;
	}
	else if (orientation == PXStageOrientation_LandscapeLeft)
	{
		_rotation = -90.0f;
		_matrix.tx = 0.0f;
		_matrix.ty = viewHeight;

		stageWidth = viewHeight;
		stageHeight = viewWidth;
	}
	else if (orientation == PXStageOrientation_LandscapeRight)
	{
		_rotation = 90.0f;

		_matrix.tx = viewWidth;
		_matrix.ty = 0.0f;

		stageWidth = viewHeight;
		stageHeight = viewWidth;
	}
	else
		return;

	float radians = PXMathToRad(_rotation);
	float sinVal = sinf(radians);
	float cosVal = cosf(radians);

	_matrix.a =  cosVal;
	_matrix.b =  sinVal;
	_matrix.c = -sinVal;
	_matrix.d =  cosVal;
}

- (PXView *)nativeView
{
	return PXEngineGetView();
}

#pragma mark Unsettable Properties

- (void) onUnsettablePropertyAccess
{
	PXThrow(PXException, @"The PXStage class does not implement this property or method.");
}

- (void) setAlpha:(float)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setTouchEnabled:(BOOL)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setCaptureTouches:(BOOL)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setName:(NSString *)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setRotation:(float)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setScaleX:(float)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setScaleY:(float)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setColorTransform:(PXColorTransform *)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setVisible:(BOOL)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setX:(float)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setY:(float)val
{
	[self onUnsettablePropertyAccess];
}

- (void) setWidth:(float)width
{
	[self onUnsettablePropertyAccess];
}

- (void) setHeight:(float)width
{
	[self onUnsettablePropertyAccess];
}

+ (PXStage *)mainStage
{
	return PXEngineGetStage();
}

@end
