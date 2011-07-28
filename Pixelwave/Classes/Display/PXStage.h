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

/**
 *	@ingroup Display
 */
typedef enum
{
	PXStageOrientation_Portrait = 0,
	PXStageOrientation_PortraitUpsideDown,
	PXStageOrientation_LandscapeLeft,
	PXStageOrientation_LandscapeRight
} PXStageOrientation;

@interface PXStage : PXDisplayObjectContainer
{
/// @cond DX_IGNORE
@private
	int stageWidth;
	int stageHeight;

	// Orientation
	PXStageOrientation orientation;

	BOOL dispatchesDisplayListEvents;
	BOOL autoOrients;
/// @endcond
}

/**
 *	The width, in pixels, of the stage.
 */
@property (nonatomic, readonly) int stageWidth;
/**
 *	The height, in pixels, of the stage.
 */
@property (nonatomic, readonly) int stageHeight;

/**
 *	The orientation of the stage.
 *	This value may be changed at any time.
 *
 *	Must be one of the following:
 *	<code>PXStageOrientation_Portrait</code>@n
 *	<code>PXStageOrientation_PortraitUpsideDown</code>@n
 *	<code>PXStageOrientation_LandscapeLeft</code>@n
 *	<code>PXStageOrientation_LandscapeRight</code>
 */
@property (nonatomic, assign) PXStageOrientation orientation;

/**
 *	If <code>YES</code> then the stage automatically rotates to the orientations
 *	acceptable It will send out a <code>PXStageOrientation</code> with the type
 *	<code>PXStageOrientationEvent_OrientationChanging</code>. If that event is canceled
 *	(using <code>preventDefault</code>) then the orientation will not take
 *	affect. If the orientation is accepted then a
 *	<code>PXStageOrientationEvent_OrientationChange</code> will be sent.
 *
 *	@b Default: NO
 */
@property (nonatomic, assign) BOOL autoOrients;

/**
 *	The color with which to clear the stage every frame.
 *	This values is used if #clearsScreen is set to <code>YES</code>.
 *	
 *	Represented as a hexadecimal number with the format: RRGGBB
 *
 *	<b>Example:</b>
 *	The following examples set the stage's background color to red.
 *	@code
 *	stage.backgroundColor = 0xFF0000;
 *	@endcode
 */
@property (nonatomic, assign) unsigned backgroundColor;

/**
 *	Whether the screen will be cleared before each draw.
 *	This option is set to <code>YES</code> by default, but may be set to
 *	<code>NO</code> as an optimization.
 */
@property (nonatomic) BOOL clearScreen;

/**
 *	Describes whether display list modification events should be dispatched
 *	when a PXDisplayObject is added or removed from a display list.
 *
 *	If set to <code>YES</code>, the following display list modification events
 *	may be dispatched:
 *	- <i>added</i> - When a display object is added to a display list.
 *	- <i>addedToStage</i> - When a display object or any of its ancestors are
 *							added to the main display list.
 *	- <i>removed</i> - When a display object is removed from the display list.
 *	- <i>removedFromStage</i> - When a display object or any of its ancestors
 *								are removed from the main display list.
 *
 *	The value of this property may be changed at any time and has an immediate
 *	effect.
 *
 *	This option is set to <code>YES</code> by default, but may be set to
 *	<code>NO</code> to avoid the overhead involved with dispatching display list
 *	modification events.
 */
@property (nonatomic) BOOL dispatchesDisplayListEvents;

/**
 *	The frame rate at which enterFrame events will be dispatched.
 *	0 < <code>renderFrameRate</code> <= <code>frameRate</code> <= 60.  This is
 *	due to the iPhone's screen refresh rate being 60hz.
 */
@property (nonatomic) float frameRate;
/**
 *	The frame rate at which the contents of the stage will be rendered to the
 *	screen.
 *	0 < <code>renderFrameRate</code> <= <code>frameRate</code> <= 60.  This is
 *	due to the iPhone's screen refresh rate being 60hz.
 */
@property (nonatomic) float renderFrameRate;

/**
 *	Defines whether or not the engine is currently running. To pause the engine
 *	set this property to >code>false</code>. Set it to <code>true</code> to
 *	resume normal operations.
 *
 *	Important note: The engine will not dispatch any events when not playing.
 *	These include the ENTER_FRAME event and touch related events.
 */
@property (nonatomic) BOOL playing;

/**
 *	The pixel scale factor. 
 */
@property (nonatomic, readonly) float contentScaleFactor;

/**
 *	The PXView instance with which the stage is associated
 */
@property (nonatomic, readonly) PXView *nativeView;

/**
 *	Statically returns a reference to the main stage associated with the
 *	Pixelwave engine.
 */
+ (PXStage *)mainStage;

@end
