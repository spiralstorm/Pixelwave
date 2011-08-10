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

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/glext.h>

@class PXView;
@class PXStage;
@class PXDisplayObject;

@class EAGLContext;

/*@
 * Indicates the quality of the colors used when rendering to the screen.
 * This enum is used when initializing a PXView object. Internally the
 * colorQuality is used to set up the OpenGL rendering surface's pixel format
 * and whether or not dithering is used.
 * 
 * @see [PXView initWithFrame:colorQuality:]
 * @see [PXView colorQuality]
 */
typedef enum
{
	//@ The lowest-quality pixel color format (RGB565 - 16 bit) with dithering
	//@ turned off. This is the fastest but least pretty option.
	PXViewColorQuality_Low = 0,
	//@ Specifies an RGB565 pixel format (16 bit) with dithering turned on.
	//@ This option is slightly slower but generates smoother colors. Up-close
	//@ this option may yield some pixel artifacts due to the dithering process.
	PXViewColorQuality_Medium,
	//@ Specifies an RGBA8888 pixel color format (32 bit). This is the highest
	//@ color quality possible, but also uses the most GPU memory.
	PXViewColorQuality_High
} PXViewColorQuality;

@interface PXView : UIView <NSCoding>
{
	// TODO: Move the framebuffer and renderbuffer creation to PXGL ?
@public
	GLuint _pxViewFramebuffer; // the main frame buffer
@private
	EAGLContext *eaglContext;
	GLuint renderbufferName;
	CGSize size;
	
	PXViewColorQuality colorQuality;
	
	BOOL autoresize;
	BOOL hasBeenCurrent;
	BOOL contentScaleFactorSupported;
	BOOL firstOrientationChange;
}

/**
 * The root display object of the Pixelwave engine.
 */
@property (nonatomic, retain) PXDisplayObject *root;
/**
 * The global stage of the Pixelwave engine.
 */
@property (nonatomic, readonly) PXStage *stage;
/**
 * See iOS API docs for UIView.contentScaleFactor
 */
@property (nonatomic) float contentScaleFactor;
/**
 * The color quality the view was created with.
 * This is a read-only property and may only be set at initialization.
 * 
 * @see initWithFrame:contentScaleFactor:colorQuality:
 * @see PXViewColorQuality
 */
@property (nonatomic, readonly) PXViewColorQuality colorQuality;

//-- ScriptIgnore
- (id) initWithFrame:(CGRect)frame contentScaleFactor:(float)scale;
//-- ScriptIgnore
- (id) initWithFrame:(CGRect)frame colorQuality:(PXViewColorQuality)colorQuality;
//-- ScriptName: View
//-- ScriptArg[0]: required
//-- ScriptArg[1]: -1.0f
//-- ScriptArg[2]: PX_VIEW_DEFAULT_COLOR_QUALITY
- (id) initWithFrame:(CGRect)frame contentScaleFactor:(float)scale colorQuality:(PXViewColorQuality)colorQuality;
//-- ScriptName: setRoot
- (void) setRoot:(PXDisplayObject *)root;

- (UIImage *)screenshot;

@end

@interface PXView(PrivateButPublic)
- (void) _setCurrentContext;
- (BOOL) _isCurrentContext;
- (void) _clearCurrentContext;
- (void) _swapBuffers;
@end
