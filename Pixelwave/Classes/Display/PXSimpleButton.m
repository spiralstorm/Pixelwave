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
#import "PXRectangle.h"

#include "PXGLPrivate.h"
#include "PXEngine.h"
#include "PXPrivateUtils.h"
#include "PXDebug.h"

#include "PXTouchEngine.h"

@interface PXSimpleButton(Private)
- (CGRect) currentHitAreaRect;
@end

/**
 * A button with 3 possible states. Two states (up, down) are visual and one state (hitTest)
 * determines the touchable area of the button. The up and down states are simply references
 * to #PXDisplayObject objects. Each state can have a different display object, or they
 * can share the same one.
 * 
 * The hitTest state is a slightly special case as it can be either a #PXDisplayObject
 * _or_ a #PXRectangle object. If the #hitTest state is set to `nil`
 * the button will have no touch interactions.
 * 
 * The hitTest state
 * ---
 * When a button is touched down by the user, there's a chance that the user's finger
 * will move slightly and leave the button's 'hit' bounds. If the user releases
 * his/her finger at that point, it will seem like their touch was ignored, when
 * in fact it was simply lifted out of bounds, an action which doesn't register
 * a 'tap' event.
 *
 * To alleviate this issue, Pixelwave attempts to inflate a button's
 * hit area automatically when it is touched down and deflate it back
 * to its original size when the touch is released. This helps solve
 * the issue mentioned above and also allows the user to validate
 * that he/she is pressing the correct button by slightly moving
 * his/her finger to see if the button has changed to its #downState.
 *
 * **But** there's one thing to note. Pixelwave will only perform this
 * behavior if the #hitTestState of the button is an object of type #PXRectangle.
 * 
 * To use a #PXRectangle as the #hitTestState of the
 * button you may:
 * 
 * 1. _(Recommended_) Use the #initWithUpState:downState:hitRectPadding: method.
 * 
 * > This  method will automatically create and use a #PXRectangle (with the same size as the button) for
 * > the hitTestState.<br/>
 * > This lets you avoid manually figuring out the size of the button and creating a
 * > rectangle of the correct size.<br/>
 * > It also lets you make the default hit area slightly larger
 * > than the visual size of the button with the `hitRectPadding` parameter.
 * 
 * 2. Set #hitTestState property to any #PXRectangle object.
 * 3. Pass a #PXRectangle object as the hitTestState of the
 * #initWithUpState:downState:hitTestState: method.
 *
 * The following code creates a button with an up and down texture for its
 * states:
 *	PXTexture *upTex = [PXTexture textureWithTextureData:[PXTextureData textureDataWithContentsOfFile:@"upPic.png"]];
 *	PXTexture *downTex = [PXTexture textureWithTextureData:[PXTextureData textureDataWithContentsOfFile:@"downPic.png"]];
 *
 *	PXSimpleButton *button = [[PXSimpleButton alloc] initWithUpState:upTex downState:downTex hitTestState:nil];
 *
 * Listening to touch events
 * ---
 * In order to properly handle the event of the user tapping a #PXSimpleButton
 * it's best to listen to the `PXTouchEvent_Tap` event.
 *
 * The advantages of listening to a `tap` event as opposed to a `down` or
 * `up` event are that a `tap` event is only fired in the
 * case that the user released his/her touch within the bounds of the button.
 * 
 * Using the `tap` event may sound obvious, but not using it may have life altering effects.
 * For example, after pressing down on the "delete all my files" button the user decides that she made a
 * grave mistake and drags her finger away from the button before releasing it in the hope that it would cancel the operation.
 * 
 * A plain `up` event would fire no matter where the touch is released, making the user very upset/sad/possibly suicidal.
 * A `tap` event on the other hand wouldn't be fired if the user decides to abort, thus helping us avoid app-related casualties.
 * Thank you `tap` event!
 *
 * @see PXRectangle
 */
@implementation PXSimpleButton

@synthesize downState;
@synthesize upState;
@synthesize enabled;
@synthesize autoInflateAmount;

- (id) init
{
	return [self initWithUpState:nil downState:nil hitTestState:nil];
}

- (id) initWithUpState:(PXDisplayObject *)_upState downState:(PXDisplayObject *)_downState
{
	return [self initWithUpState:_upState downState:_downState hitRectWithPadding:0.0f];
}

/**
 * Initializes a button with specified `up` state and
 * `down` state, and a #PXRectangle for the `hitTest` state.
 *
 * The #PXRectangle object created for the #hitTestState is sized to match the #upState
 * display object if one is provided, or the size of the #downState display object otherswise.
 *
 * Because the #hitTestState will be a #PXRectangle object it will be
 * automatically expanded when the button is pressed as specified by #autoInflateAmount.
 *
 * @param upState A PXDisplayObject that specifies the visual up state for the button.
 * @param downState A PXDisplayObject that specifies the visual down state for the button.
 *
 * @see PXRectangle;
 */
- (id) initWithUpState:(PXDisplayObject *)_upState downState:(PXDisplayObject *)_downState hitRectWithPadding:(float)hitRectPadding
{	
	// Create a rectangle of the size of the 'upState' or the 'downState' if the
	// 'upState' is not provided.

	PXRectangle *bounds = nil;
	PXDisplayObject *checkState = (_upState == nil) ? _downState : _upState;

	if (checkState != nil)
	{
		bounds = [checkState boundsWithCoordinateSpace:checkState];
		[bounds inflateWithX:hitRectPadding y:hitRectPadding];
	}

	return [self initWithUpState:_upState downState:_downState hitTestState:bounds];
}

/**
 * Initializes a button with specified up, down and hit test states.
 *
 * The hitTest state may be either a #PXDisplayObject _or_ a #PXRectangle. See the
 * #hitTestState property for more info.
 *
 * **Example:**
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
 *	PXSimpleButton *button = [[PXSimpleButton alloc] initWithUpState:upState downState:downState hitTestState:upState];
 *	// Creates a button that is red with a hit-area at (100, 100) with size
 *	// (20, 15) when not pressed (up state), when it is pressed (down state) it
 *	// is blue with a hit area at (105, 105) with size (15, 10).
 *
 *	[button addEventListenerOfType:PXTouchEvent_Tap listener:PXListener(onTap:)];
 *	// Adding events to the button will allow you to listen in on interaction.
 *
 * @param upState Displayed when the button is in its normal state (not pressed down).
 * @param downState Displayed when the user presses down on the button.
 * @param hitTestState a #PXDisplayObject or #PXRectangle that specifies the hit shape
 * of the button. If `nil` is specified then no interaction can exist
 * on this button. An object that is neither a #PXDisplayObject nor a #PXRectangle
 * will be regarded as `nil`.
 * 
 * @see PXShape
 * @see PXGraphics
 * @see PXTouchEvent
 */
- (id) initWithUpState:(PXDisplayObject *)_upState downState:(PXDisplayObject *)_downState hitTestState:(id<NSObject>)_hitTestState
{
	self = [super init];

	if (self)
	{
		PX_ENABLE_BIT(self->_flags, _PXDisplayObjectFlags_useCustomHitArea);

		autoInflateAmount = 60.0f;

		downState = nil;
		upState = nil;
		hitTestState = nil;

		enabled = YES;

		visibleState = _PXSimpleButtonVisibleState_Up;

		pxSimpleButtonTouchList = [[PXLinkedList alloc] init];

		// Don't set any states until after the listeners are made.
		self.downState = _downState;
		self.upState = _upState;
		self.hitTestState = _hitTestState;
	}

	return self;
}

- (void) dealloc
{
	[pxSimpleButtonTouchList release];

	self.downState = nil;
	self.upState = nil;
	self.hitTestState = nil;

	[super dealloc];
}

- (void) setHitTestState:(id<NSObject>)newState
{	
	[newState retain];
	[hitTestState release];
	hitTestState = nil;

	hitAreaIsRect = NO;

	if ([newState isKindOfClass:[PXDisplayObject class]] == YES)
	{
		hitTestState = [(PXDisplayObject *)newState retain];
	}
	else if ([newState isKindOfClass:[PXRectangle class]] == YES)
	{
		hitAreaIsRect = YES;
		hitAreaRect = PXRectangleToCGRect((PXRectangle *)newState);
	}
	else if (newState != nil)
	{
		PXDebugLog(@"PXSimpleButton ERROR: hitTestState MUST be either a PXRectangle or PXDisplayObject\n");
	}

	[newState release];
}

- (id<NSObject>) hitTestState
{
	if (hitAreaIsRect)
		return PXRectangleFromCGRect(hitAreaRect);

	return hitTestState;
}

- (BOOL) dispatchEvent:(PXEvent *)event
{
	[self retain];
	
	BOOL wasEnabled = enabled;

	BOOL didDispatch = [super dispatchEvent:event];

	if (didDispatch == YES)
	{
		// It's important to do this logic afterwards so that we're not changing
		// this hit area BEFORE a touch up event, which will cause tap to not fire
		// if the touch was in the buffer zone.
		if ([event isKindOfClass:[PXTouchEvent class]])
		{
			if (wasEnabled)
			{
				PXTouchEvent *touchEvent = (PXTouchEvent *)event;
				NSString *eventType = touchEvent.type;

				if ([eventType isEqualToString:PXTouchEvent_TouchDown])
				{
					[pxSimpleButtonTouchList addObject:touchEvent.nativeTouch];

					visibleState = _PXSimpleButtonVisibleState_Down;

					isPressed = YES;
				}
				else if ([eventType isEqualToString:PXTouchEvent_TouchMove])
				{
					// Checking the auto expand rect is automatically done
					if (touchEvent.insideTarget == YES)
					{
						visibleState = _PXSimpleButtonVisibleState_Down;
					}
					else
					{
						visibleState = _PXSimpleButtonVisibleState_Up;
					}
				}
				else if ([eventType isEqualToString:PXTouchEvent_TouchUp] ||
						 [eventType isEqualToString:PXTouchEvent_TouchCancel])
				{
					[pxSimpleButtonTouchList removeObject:touchEvent.nativeTouch];

					if ([pxSimpleButtonTouchList count] == 0)
					{
						visibleState = _PXSimpleButtonVisibleState_Up;
					}

					isPressed = NO;
				}
			}
			else
			{
				visibleState = _PXSimpleButtonVisibleState_Up;
			}
		}
	}

	[self release];

	return didDispatch;
}

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	return [self _measureLocalBounds:retBounds useStroke:YES];
}

- (void) _measureLocalBounds:(CGRect *)retBounds useStroke:(BOOL)useStroke
{
	*retBounds = CGRectZero;

	if (hitAreaIsRect == YES)
	{
		*retBounds = [self currentHitAreaRect];
	}
	else if (hitTestState != nil)
	{
		// Ask the hit test for the GLOBAL bounds, because it needs to take
		// any children it may have into affect.
		if (useStroke == YES) // For backwards compatability
			[hitTestState _measureGlobalBounds:retBounds];
		else
			[hitTestState _measureGlobalBounds:retBounds useStroke:useStroke];
	}
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	if (hitAreaIsRect == YES)
	{
		return CGRectContainsPoint([self currentHitAreaRect], CGPointMake(x, y));
	}
	else if (hitTestState != nil)
	{
		return [hitTestState _hitTestPointWithParentX:x parentY:y shapeFlag:shapeFlag];
	}

	return NO;
}

- (CGRect) currentHitAreaRect
{
	if (isPressed == YES)
	{
		float amount = -autoInflateAmount;

		return CGRectInset(hitAreaRect, amount, amount);
	}
	else
	{
		return hitAreaRect;
	}
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

	if (visibleStateDisp != nil)
	{
		PXEngineRenderDisplayObject(visibleStateDisp, YES, NO);
	}
}

/**
 * A utility method for creating a button quickly.
 *
 * @see initWithUpState:downState:hitAreaPadding:
 */
+ (PXSimpleButton *)simpleButtonWithUpState:(PXDisplayObject *)upState
								  downState:(PXDisplayObject *)downState
						 hitRectWithPadding:(float)hitAreaPadding
{
	return [[[PXSimpleButton alloc] initWithUpState:upState
										  downState:downState
								 hitRectWithPadding:hitAreaPadding] autorelease];
}

/**
 * A utility method for creating a button quickly.
 *
 * @see initWithUpState:downState:hitTestState:
 */
+ (PXSimpleButton *)simpleButtonWithUpState:(PXDisplayObject *)upState
								  downState:(PXDisplayObject *)downState
							   hitTestState:(id<NSObject>)hitTestState
{
	return [[[PXSimpleButton alloc] initWithUpState:upState
										  downState:downState
									   hitTestState:hitTestState] autorelease];
}

@end
