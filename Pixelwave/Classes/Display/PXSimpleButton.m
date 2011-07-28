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

#import "PXSimpleButton.h"

#import "PXLinkedList.h"
#import "PXTouchEvent.h"

#include "PXGLPrivate.h"
#include "PXEngine.h"
#include "PXPrivateUtils.h"

/**
 *	@ingroup Display
 *
 *	A PXSimpleButton object represents a button with an up, down and hit test
 *	state.  If no hit test state is specified, then the current visible state
 *	serves as the hit area for the button.
 *
 *	The following code creates a button with an up and down texture for its
 *	states:
 *	@code
 *	PXTexture *upTex = [PXTexture textureWithTextureData:[PXTextureData textureDataWithContentsOfFile:@"upPic.png"]];
 *	PXTexture *downTex = [PXTexture textureWithTextureData:[PXTextureData textureDataWithContentsOfFile:@"downPic.png"]];
 *
 *	PXSimpleButton *button = [[PXSimpleButton alloc] initWithUpState:upTex downState:downTex hitTestState:nil];
 *	@endcode
 *
 *	@see PXTexture
 *	@see PXTextureData
 */
@implementation PXSimpleButton

@synthesize downState, upState, hitTestState, enabled;

- (id) init
{
	return [self initWithUpState:nil downState:nil hitTestState:nil];
}

/**
 *	Creates a button with specified up, down and hit test states. The states
 *	retain count also gets increased by 1, so that the button has a strong
 *	reference to it.
 *
 *	@param upState
 *		A PXDisplayObject that specifies the visual up state for the button.
 *	@param downState
 *		A PXDisplayObject that specifies the visual down state for the button.
 *	@param hitTestState
 *		A PXDisplayObject that specifies the hit area for the button.  If
 *		<code>nil</code> is specified then no interaction can exist on this
 *		button.
 *
 *	@b Example:
 *	@code
 *	PXShape *upState = [PXShape new];
 *	PXShape *downState = [PXShape new];
 *
 *	[upState.graphics beginFill:0xFF0000 alpha:1.0f];
 *	[upState.graphics drawRectWithX:100 y:100 width:20 height:15];
 *	[upState.graphics endFill];
 *	// draws a red rectangle at (100, 100) with a size of (20, 15)
 *
 *	[downState.graphics beginFill:0x0000FF alpha:1.0f];
 *	[downState.graphics drawRectWithX:105 y:105 width:15 height:10];
 *	[downState.graphics endFill];
 *	// draws a blue rectangle at (105, 105) with a size of (15, 10)
 *
 *	PXSimpleButton *button = [[PXSimpleButton alloc] initWithUpState:upState downState:downState hitTestState:nil];
 *	// Creates a button that is red with a hit-area at (100, 100) with size
 *	// (20, 15) when not pressed (up state), when it is pressed (down state) it
 *	// is blue with a hit area at (105, 105) with size (15, 10).
 *
 *	[button addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(methodForListeningToDownState:)];
 *	[button addEventListenerOfType:PXTouchEvent_TouchUp listener:PXListener(methodForListeningToUpState:)];
 *	// Adding events to the button will allow you to listen in on interaction.
 *	@endcode
 *
 *	@see PXShape
 *	@see PXGraphics
 *	@see PXTouchEvent
 */
- (id) initWithUpState:(PXDisplayObject *)_upState downState:(PXDisplayObject *)_downState hitTestState:(PXDisplayObject *)_hitTestState
{
	self = [super init];

	if (self)
	{
		PX_ENABLE_BIT(_flags, _PXDisplayObjectFlags_useCustomHitArea);

		downState = nil;
		upState = nil;
		hitTestState = nil;

		self.downState = _downState;
		self.upState = _upState;
		self.hitTestState = _hitTestState;

		enabled = YES;

		visibleState = _PXSimpleButtonVisibleState_Up;

		listOfTouches = [[PXLinkedList alloc] init];
	}

	return self;
}

- (void) dealloc
{
	[listOfTouches release];

	self.downState = nil;
	self.upState = nil;
	self.hitTestState = nil;

	[super dealloc];
}

- (void) setHitTestState:(PXDisplayObject *)newState
{
	if (hitTestState)
	{
		[self removeEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(pxSimpleButtonTouchDown:)];
		[self removeEventListenerOfType:PXTouchEvent_TouchUp listener:PXListener(pxSimpleButtonTouchUp:)];
		[self removeEventListenerOfType:PXTouchEvent_TouchOut listener:PXListener(pxSimpleButtonTouchUp:)];
		[self removeEventListenerOfType:PXTouchEvent_TouchCancel listener:PXListener(pxSimpleButtonTouchUp:)];
	}
	
	[newState retain];
	[hitTestState release];
	hitTestState = newState;

	if (hitTestState)
	{
		[self addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(pxSimpleButtonTouchDown:)];
		[self addEventListenerOfType:PXTouchEvent_TouchUp listener:PXListener(pxSimpleButtonTouchUp:)];
		[self addEventListenerOfType:PXTouchEvent_TouchOut listener:PXListener(pxSimpleButtonTouchUp:)];
		[self addEventListenerOfType:PXTouchEvent_TouchCancel listener:PXListener(pxSimpleButtonTouchUp:)];
	}
}

- (void) pxSimpleButtonTouchDown:(PXTouchEvent *)event
{
	if (event.eventPhase != PXEventPhase_Target)
		return;

	[listOfTouches addObject:event.nativeTouch];

	visibleState = _PXSimpleButtonVisibleState_Down;
}

- (void) pxSimpleButtonTouchUp:(PXTouchEvent *)event
{
	[listOfTouches removeObject:event.nativeTouch];

	if ([listOfTouches count] == 0)
	{
		visibleState = _PXSimpleButtonVisibleState_Up;
	}
}

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	*retBounds = CGRectZero;

	// If a hit test exists. . .
	if (hitTestState)
	{
		// Ask the hit test for the GLOBAL bounds, because it needs to take any
		// children it may have into affect.
		[hitTestState _measureGlobalBounds:retBounds];
	}
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	if (hitTestState)
	{
		return [hitTestState _hitTestPointWithParentX:x parentY:y shapeFlag:shapeFlag];
	}

	return NO;
}

- (void) _renderGL
{
	PXDisplayObject *visibleStateDisp = nil;
	switch (visibleState)
	{
		case _PXSimpleButtonVisibleState_Up:
			visibleStateDisp = upState;
			break;
		case _PXSimpleButtonVisibleState_Down:
			visibleStateDisp = downState;
			break;
		default:
			visibleStateDisp = nil;
			break;
	}

	if (visibleStateDisp)
	{
		PXEngineRenderDisplayObject(visibleStateDisp, YES, NO);
		//PXGLFlush();
	}
}

/**
 *	Creates a button with specified up, down and hit test states. The button
 *	holds a strong refernece to the states, so you can release them after
 *	setting them.
 *
 *	@param upState
 *		A PXDisplayObject that specifies the visual up state for the button.
 *	@param downState
 *		A PXDisplayObject that specifies the visual down state for the button.
 *	@param hitTestState
 *		A PXDisplayObject that specifies the hit area for the button.  If
 *		<code>nil</code> is specified then no interaction can exist on this
 *		button.
 *
 *	@b Example:
 *	@code
 *	PXShape *upState = [PXShape new];
 *	PXShape *downState = [PXShape new];
 *
 *	[upState.graphics beginFill:0xFF0000 alpha:1.0f];
 *	[upState.graphics drawRectWithX:100 y:100 width:20 height:15];
 *	[upState.graphics endFill];
 *	// draws a red rectangle at (100, 100) with a size of (20, 15)
 *
 *	[downState.graphics beginFill:0x0000FF alpha:1.0f];
 *	[downState.graphics drawRectWithX:105 y:105 width:15 height:10];
 *	[downState.graphics endFill];
 *	// draws a blue rectangle at (105, 105) with a size of (15, 10)
 *
 *	PXSimpleButton *button = [PXSimpleButton simpleButtonWithUpState:upState downState:downState hitTestState:nil];
 *	// Creates a button that is red with a hit-area at (100, 100) with size
 *	// (20, 15) when not pressed (up state), when it is pressed (down state) it
 *	// is blue with a hit area at (105, 105) with size (15, 10).
 *
 *	[button addEventListenerOfType:PXTouchEvent_TouchDown listener:PXListener(methodForListeningToDownState:)];
 *	[button addEventListenerOfType:PXTouchEvent_TouchUp listener:PXListener(methodForListeningToUpState:)];
 *	// Adding events to the button will allow you to listen in on interaction.
 *	@endcode
 */
+ (PXSimpleButton *)simpleButtonWithUpState:(PXDisplayObject *)upState
								  downState:(PXDisplayObject *)downState
							   hitTestState:(PXDisplayObject *)hitTestState
{
	return [[[PXSimpleButton alloc] initWithUpState:upState
										  downState:downState
									   hitTestState:hitTestState] autorelease];
}

@end
