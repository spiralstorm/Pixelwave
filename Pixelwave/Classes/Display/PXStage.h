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

#import "PXDisplayObjectContainer.h"

@class PXView;

/*@
 * Defines constants describing the orientation of the stage.
 */
typedef enum
{
	//@ Portrait mode is when the device is upright with the home button closest
	//@ to the ground
	PXStageOrientation_Portrait = 0,
	//@ PortraitUpsideDown mode is when the device is upside down, as in, the
	//@ home button is closest to the sky.
	PXStageOrientation_PortraitUpsideDown,
	//@ LandscapeLeft is when the device is sideways with the home button on the
	//@ left hand side.
	PXStageOrientation_LandscapeLeft,
	//@ LandscapeRight is when the device is sideways with the home button on
	//@	the right hand side.
	PXStageOrientation_LandscapeRight
} PXStageOrientation;

@interface PXStage : PXDisplayObjectContainer
{
@private
	int stageWidth;
	int stageHeight;

	// Orientation
	PXStageOrientation orientation;

	BOOL dispatchesDisplayListEvents;
	BOOL autoOrients;
	BOOL defaultCaptureTouchesValue;
}

/**
 * The width, in points, of the stage.
 */
@property (nonatomic, readonly) int stageWidth;
/**
 * The height, in points, of the stage.
 */
@property (nonatomic, readonly) int stageHeight;

/**
 * The orientation of the stage.
 * This value may be changed at any time.
 *
 * Must be one of the following:
 *
 * -`PXStageOrientation_Portrait`
 * -`PXStageOrientation_PortraitUpsideDown`
 * -`PXStageOrientation_LandscapeLeft`
 * -`PXStageOrientation_LandscapeRight`
 *
 */
@property (nonatomic, assign) PXStageOrientation orientation;

/**
 * If `YES` then the stage automatically rotates to the orientations
 * acceptable It will send out a #PXStageOrientation with the type
 * `PXStageOrientationEvent_OrientationChanging`. If that event is
 * canceled (using `preventDefault`) then the orientation will not
 * take affect. If the orientation is accepted then a
 * `PXStageOrientationEvent_OrientationChange` will be sent.
 *
 * **Default:** NO
 */
@property (nonatomic, assign) BOOL autoOrients;

/**
 * The value the `captureTouches` property of a #PXInteractiveObject
 * instance should be set to when initialized.
 *
 * **Default:** YES
 */
@property (nonatomic, assign) BOOL defaultCaptureTouchesValue;

/**
 * The color with which to clear the stage every frame. This values is used if
 * #clearScreen is set to `YES`.
 * 
 * Represented as a hexadecimal number with the format: RRGGBB
 *
 * **Example:**
 * The following examples set the stage's background color to red.
 *	stage.backgroundColor = 0xFF0000;
 */
@property (nonatomic, assign) unsigned backgroundColor;

/**
 * Whether the screen will be cleared before each draw.
 * This option is set to `YES` by default, but may be set to
 * `NO` as an optimization.
 *
 * **Default:** YES
 */
@property (nonatomic) BOOL clearScreen;

/**
 * Describes whether display list modification events should be dispatched
 * when a PXDisplayObject is added or removed from a display list.
 *
 * If set to `YES`, the following display list modification events
 * may be dispatched:
 * 
 * - _added_ - When a display object is added to a display list.
 * - _addedToStage_ - When a display object or any of its ancestors are
 * added to the main display list.
 * - _removed_ - When a display object is removed from the display list.
 * - _removedFromStage_ - When a display object or any of its ancestors
 * are removed from the main display list.
 *
 * The value of this property may be changed at any time and has an immediate
 * effect.
 *
 * This option is set to `YES` by default, but may be set to
 * `NO` to avoid the overhead involved with dispatching display list
 * modification events.
 */
@property (nonatomic) BOOL dispatchesDisplayListEvents;

/**
 * The frame rate at which enterFrame events will be dispatched.
 * 0 < #renderFrameRate <= #frameRate <= 60.  This is
 * due to the iPhone's screen refresh rate being 60hz.
 */
@property (nonatomic) float frameRate;
/**
 * The frame rate at which the contents of the stage will be rendered to the
 * screen.
 * 0 < #renderFrameRate <= #frameRate <= 60. This is
 * due to the iPhone's screen refresh rate being 60hz.
 */
@property (nonatomic) float renderFrameRate;

/**
 * Defines whether or not the engine is currently running. To pause the engine
 * set this property to code>false</code>. Set it to `true` to
 * resume normal operations.
 *
 * Important note: The engine will not dispatch any events when not playing.
 * These include the ENTER_FRAME event and touch related events.
 */
@property (nonatomic) BOOL playing;

/**
 * The pixel scale factor. 
 */
@property (nonatomic, readonly) float contentScaleFactor;

/**
 * The PXView instance with which the stage is associated
 */
@property (nonatomic, readonly) PXView *nativeView;

- (void) invalidate;

/**
 * A reference to the main stage associated with the
 * Pixelwave engine.
 */
+ (PXStage *)mainStage;

@end
