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

#import "PXGL.h"

/**
 * Describes the clip area within a TextureData object. The coordinates are
 * in points as opposed to pixels.
 */
@interface PXClipRect : NSObject <NSCopying>
{
@private
	float x;
	float y;
	float width;
	float height;

	BOOL invalidated;
@public
	// Raw data
	int _numVertices;
	PXGLTextureVertex *_vertices;

	// The size of the frame within the texture atlas
	float _contentWidth, _contentHeight;
	float _contentRotation;
}

////////////////
// Properties //
////////////////

// General clip shape

/**
 * Specifies the rotation offset to be applied to the area of the texture
 * covered by this clip rect when applied to a #PXTexture.
 *
 * Rotation value is in degrees.
 *
 * @warning Avoid using values that aren't multiples of 90.0
 * (it makes the hit-test act unintuitively, albeit correctly). For regular rotation changes
 * just use the [PXTexture rotation] property.
 */
@property (nonatomic) float rotation;

// Rect specific

/**
 * The horizontal position of the top-left corner of the
 * clip rectangle, in points.
 */
@property (nonatomic) float x;
/**
 * The vertical position of the top-left corner of the
 * clip rectangle, in points.
 */
@property (nonatomic) float y;
/**
 * The width of the rectangle in points.
 */
@property (nonatomic) float width;
/**
 * The height of the rectangle in points.
 */
@property (nonatomic) float height;

/////////////
// Methods //
/////////////

// When making a version of this method without rotation, the compiler freaks
// out because it can't tell the difference between it and the similarly named
// method in PXRectangle.
- (id) initWithX:(float)x y:(float)y width:(float)width height:(float)height rotation:(float)rotation;

- (void) setX:(float)x
			y:(float)y
		width:(float)width
	   height:(float)height
	 rotation:(float)rotation;

// Utility
+ (PXClipRect *)clipRectWithX:(float)x y:(float)y width:(float)width height:(float)height;
+ (PXClipRect *)clipRectWithX:(float)x y:(float)y width:(float)width height:(float)height rotation:(float)rotation;

@end

@interface PXClipRect(PrivateButPublic)
- (void) _validate;
@end
