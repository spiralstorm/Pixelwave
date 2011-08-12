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

@class PXGraphicsGroup;
@class PXLinkedList;

// TODO Later: Redo graphics class to use triangulation.

/**
 * A PXGraphics object represents a way of defining and drawing vector shapes.
 * Both #PXSprite and #PXShape have #PXGraphics objects that can be
 * used for drawing.
 *
 * **IMPORTANT NOTE**: This is not the final version of the Graphics class,
 * much more functionality will be added in a later version.
 *
 * @see PXSprite
 * @see PXShape
 */
@interface PXGraphics : NSObject
{
@protected
	PXLinkedList *groups;

	PXGraphicsGroup *cGroup;

	float currentX;
	float currentY;
@private
	int currentGroupType;
}

//-- ScriptName: beginFill
- (void) beginFill:(unsigned)color alpha:(float)alpha;
//-- ScriptName: endFill
- (void) endFill;

//-- ScriptName: lineStyle
- (void) lineStyleWithThickness:(float)thickness color:(unsigned)color alpha:(float)alpha;
//-- ScriptName: moveTo
- (void) moveToX:(float)x y:(float)y;
//-- ScriptName: lineTo
- (void) lineToX:(float)x y:(float)y;
//-- ScriptName: clear
- (void) clear;

#pragma mark -
#pragma mark Utility
#pragma mark -

//-- ScriptName: drawRect
- (void) drawRectWithX:(float)x y:(float)y width:(float)width height:(float)height;
//-- ScriptIgnore
- (void) drawCircleWithX:(float)x y:(float)y radius:(float)radius;
//-- ScriptName: drawCircle
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: required
//-- ScriptArg[3]: 0.25f
- (void) drawCircleWithX:(float)x y:(float)y radius:(float)radius precision:(float)precision;
//-- ScriptIgnore
- (void) drawEllipseWithX:(float)x y:(float)y width:(float)width height:(float)height;
//-- ScriptName: drawEllipse
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: required
//-- ScriptArg[3]: required
//-- ScriptArg[4]: 0.25f
- (void) drawEllipseWithX:(float)x y:(float)y width:(float)width height:(float)height precision:(float)precision;

@end

@interface PXGraphics(PrivateButPublic)
- (void) _lineToX:(float)x y:(float)y;
- (void) _renderGL;
- (void) _measureLocalBounds:(CGRect *)retBounds;
- (BOOL) _containsPointWithLocalX:(float)x localY:(float) y;
- (BOOL) _containsPointWithLocalX:(float)x localY:(float) y shapeFlag:(BOOL) shapeFlag;
@end
