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

@class PXMatrix;
@class PXColorTransform;
@class PXDisplayObject;
@class PXRectangle;

@interface PXTransform : NSObject
{
/// @cond DX_IGNORE
@public
	PXDisplayObject *_displayObject;
/// @endcond
}
/**
 *	A matrix containing the local transformation of the PXDisplayObject
 *	associated with the given PXTransform.
 *	<br>
 *	Note that the <code>matrix</code> property returns a copy of itself and
 *	creates a copy of values assigned to it. That means that transformation of
 *	a PXDisplayObject can't be set by dereferencing
 *	<code>transform.matrix</code>.  Instead a PXMatrix object containing the new
 *	values and must be re-assigned to the <code>matrix</code> property.
 *	<br><br>
 *	Wrong:
 *	@code
 *	// This would have no effect.
 *	displayObject.transform.matrix.a = 5;
 *	@endcode
 *
 *	Right:
 *	@code
 *	PXMatrix *mat = displayObject.transform.matrix;
 *	mat.a = 5;
 *	// This would work.
 *	displayObject.transform.matrix = mat;
 *	@endcode
 */
@property (nonatomic, copy) PXMatrix *matrix;
/**
 *	The matrix values combined with all of the PXDisplayObject 's parents.
 *	Describes the transformation of the PXDisplayObject in global (stage)
 *	coordinates.
 */
@property (nonatomic, readonly) PXMatrix *concatenatedMatrix;
/**
 *	The transformation of the PXDisplayObject 's color in local color space.
 *	<br>
 *	Note that the <code>colorTransform</code> property returns a copy of itself
 *	and creates a copy of values assigned to it. That means that color
 *	transformation of a PXDisplayObject can't be set by dereferencing
 *	<code>transform.colorTransform</code>.  Instead a PXColorTransform object
 *	containing the new values and must be re-assigned to the
 *	<code>colorTransform</code> property.
 *	<br><br>
 *
 *	Wrong:
 *	@code
 *	// This would have no effect on the display object.
 *	displayObject.transform.colorTransform.redMultiplier = 0.5f;
 *	@endcode
 *
 *	Right:
 *	@code
 *	PXColorTransform *trans = displayObject.transform.colorTransform;
 *	trans.redMultiplier = 0.5f;
 *	// This would work.
 *	displayObject.transform.colorTransform = trans;
 *	@endcode
 */
@property (nonatomic, copy) PXColorTransform *colorTransform;
/**
 *	The color transform combined with all of the PXDisplayObject 's parents.
 *	Describes the color transformation of the PXDisplayObject in global
 *	(stage) color space.
 */
@property (nonatomic, readonly) PXColorTransform *concatenatedColorTransform;
/**
 *	A rectangle that defines the bounding area of this PXDisplayObject on the
 *	stage, in pixels.
 */
@property (nonatomic, readonly) PXRectangle *pixelBounds;

@end

/// @cond DX_IGNORE
@interface PXTransform (PrivateButPublic)
- (id) _initWithDisplayObject:(PXDisplayObject *)dispObject;
@end
/// @endcond
