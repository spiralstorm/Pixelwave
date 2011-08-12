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

#include "PXTextureDataPixelFormat.h"

@class PXDisplayObject;
@class PXMatrix;
@class PXColorTransform;
@class PXRectangle;
@protocol PXTextureModifier;

@interface PXTextureData : NSObject
{
@public
	// gl handle
	GLuint _glName;
	
	// Content Size
	float _contentWidth;
	float _contentHeight;
	float _contentScaleFactor;

	// uv coords to pixels conversion
	float _sPerPixel;
	float _tPerPixel;
	
	// Fill color
	unsigned _fillColor;

	// Either GL_LINEAR or GL_NEAREST
	unsigned short _smoothingType;
	// Either GLL_REPEAT or GL_CLAMP_TO_EDGE
	unsigned short _wrapType;
@private
	// åPixel format in memory
	PXTextureDataPixelFormat pixelFormat;
	// Actual texture size (Must be a power of 2)
	unsigned textureWidth;
	unsigned textureHeight;
}

/**
 * The width of the texture data in pixels.
 */
@property (nonatomic, readonly) float width;
/**
 * The height of the texture data in pixels.
 */
@property (nonatomic, readonly) float height;

/**
 * A rectangle representing the TextureData. The x and y values are always 0.0f, while #width and #height are the width and height of the TextureData in pixels.
 */
@property (nonatomic, readonly) PXRectangle *rect;

/**
 * The scaling factor used when creating the PXTextureData object. This value
 * is usually one, except when working with retina display graphics, in which
 * case the `contentScaleFactor` would be higher than one.
 *
 * **Example:**
 *	// Lets assume that this code is running on a device with a retina display,
 *	// and the file "ball@2x.png" is available along side "ball.png" in the
 *	// application bundle.
 *	PXTextureData *textureData = [PXTextureData textureDataWithContentOfFile:@"ball.png"];
 *
 *	NSLog(@"%f", textureData.contentScaleFactor); // output: 2.0
 *
 *	// The output would be 1.0 on a non-retina display device.
 */
@property (nonatomic, readonly) float contentScaleFactor;

/**
 * A boolean value indicating if the pixel format of this PXTextureData
 * supports an alpha channel.
 */
@property (nonatomic, readonly) BOOL transparency;

/**
 * The OpenGL handle used to reference this texture data object in GPU memory.
 * This value is available as a convenience and should not be used by the user
 * to modify properties of the texture data object in OpenGL.
 */
@property (nonatomic, readonly) GLuint glTextureName;

/**
 * The pixel format of the data.
 *
 * @see PXTextureDataPixelFormat
 */
@property (nonatomic, readonly) PXTextureDataPixelFormat pixelFormat;

//-- ScriptIgnore
- (id) initWithData:(NSData *)data;
//-- ScriptName: TextureData
//-- ScriptArg[0]: required
//-- ScriptArg[1]: nil
- (id) initWithData:(NSData *)data modifier:(id<PXTextureModifier>)modifier;

//-- ScriptIgnore
- (id) initWithWidth:(unsigned)width height:(unsigned)height;
//-- ScriptIgnore
- (id) initWithWidth:(unsigned)width
			  height:(unsigned)height
		transparency:(BOOL)transparency
		   fillColor:(unsigned)fillColor;

//-- ScriptName: TextureDataWithSize
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: NO
//-- ScriptArg[3]: 0xFFFFFF
//-- ScriptArg[4]: 1.0f
- (id) initWithWidth:(unsigned)width
			  height:(unsigned)height
		transparency:(BOOL)transparency
		   fillColor:(unsigned)fillColor
  contentScaleFactor:(float)contentScaleFactor;

//-- ScriptIgnore
- (id) initWithString:(NSString *)string font:(UIFont *)font;

//-- ScriptName: TextureDataWithString
//-- ScriptArg[0]: required
//-- ScriptArg[1]: required
//-- ScriptArg[2]: 0
//-- ScriptArg[3]: 0
//-- ScriptArg[4]: UITextAlignmentLeft
//-- ScriptArg[5]: UILineBreakModeClip
- (id) initWithString:(NSString *)string
				 font:(UIFont *)font
				width:(int)width
			   height:(int)height
			alignment:(UITextAlignment)alignment
		lineBreakMode:(UILineBreakMode)lineBreakMode;

//-- ScriptIgnore
- (void) drawDisplayObject:(PXDisplayObject *)source;
//-- ScriptName: drawDisplayObject
//-- ScriptArg[0]: required
//-- ScriptArg[1]: nil
//-- ScriptArg[2]: nil
//-- ScriptArg[3]: nil
//-- ScriptArg[4]: NO
//-- ScriptArg[5]: NO
- (void) drawDisplayObject:(PXDisplayObject *)source
					matrix:(PXMatrix *)matrix
			colorTransform:(PXColorTransform *)colorTransform
				  clipRect:(PXRectangle *)clipRect
				 smoothing:(BOOL)smoothing
			  clearTexture:(BOOL)clearTexture;

- (void) drawTextureData:(PXTextureData *)source
				  matrix:(PXMatrix *)matrix
		  colorTransform:(PXColorTransform *)colorTransform
				clipRect:(PXRectangle *)clipRect
			   smoothing:(BOOL)smoothing
			clearTexture:(BOOL)clearTexture;

//-- ScriptName: setExpandEdges
//-- ScriptArg[0]: required
+ (void) setExpandEdges:(BOOL)expandEdges;
//-- ScriptName: expandEdges
+ (BOOL) expandEdges;

//-- ScriptIgnore
+ (PXTextureData *)textureDataWithContentsOfFile:(NSString *)path;
//-- ScriptName: makeWithContentsOfFile
//-- ScriptArg[0]: required
//-- ScriptArg[1]: nil
+ (PXTextureData *)textureDataWithContentsOfFile:(NSString *)path modifier:(id<PXTextureModifier>)modifier;
//-- ScriptIgnore
+ (PXTextureData *)textureDataWithContentsOfURL:(NSURL *)url;
//-- ScriptName: makeWithContentsOfURL
//-- ScriptArg[0]: required
//-- ScriptArg[1]: nil
+ (PXTextureData *)textureDataWithContentsOfURL:(NSURL *)url modifier:(id<PXTextureModifier>)modifier;
//-- ScriptIgnore
+ (PXTextureData *)textureDataWithData:(NSData *)data;
//-- ScriptName: makeWithData
//-- ScriptArg[0]: required
//-- ScriptArg[1]: nil
+ (PXTextureData *)textureDataWithData:(NSData *)data modifier:(id<PXTextureModifier>)modifier;
@end

@interface PXTextureData (UIKit)
- (id) initWithUIImage:(UIImage *)image;
- (id) initWithUIImage:(UIImage *)image modifier:(id<PXTextureModifier>)modifier;

- (id) initWithCGImage:(CGImageRef)cgImage
		   scaleFactor:(float)scaleFactor
		   orientation:(UIImageOrientation)cgImageOrientation
			  modifier:(id<PXTextureModifier>)modifier;

- (UIImage *)UIImage;
- (CGImageRef) CGImage;

+ (PXTextureData *)textureDataWithUIImage:(UIImage *)image;
+ (PXTextureData *)textureDataWithUIImage:(UIImage *)image
								 modifier:(id<PXTextureModifier>)modifier;
+ (PXTextureData *)textureDataWithCGImage:(CGImageRef)cgImage
							  scaleFactor:(float)scaleFactor
							  orientation:(UIImageOrientation)orientation
								 modifier:(id<PXTextureModifier>)modifier;
@end

@interface PXTextureData(PrivateButPublic)
- (id) _init;
- (id) _initWithoutGLName;
- (BOOL) _makeGLName;
- (void) _setInternalPropertiesWithWidth:(unsigned)textureWidth
								  height:(unsigned)textureHeight
					   usingContentWidth:(unsigned)contentWidth
						   contentHeight:(unsigned)contentHeight
					  contentScaleFactor:(float)contentScaleFactor
								  format:(PXTextureDataPixelFormat)pixelFormat;
@end

/**
 * Populates a C array with the pixels of a PXTextureData within the specified
 * rectangle area.
 * 
 * The data returned is in the format RGBA8, where each component is
 * represented by an unsigned byte.
 *
 * Please note, this is not a fast method. Refrain from using it in real-time
 * code.
 *
 * @param textureData The PXTextureData object to read the pixels from.
 * @param x The left coordinate of the clipping rectangle.
 * @param y The top coordinate of the clipping rectangle.
 * @param width The width of the clipping rectangle.
 * @param height The height of the clipping rectangle
 * @param pixels An unsigned byte array with a length of `width * height * 4`
 * 
 */
void PXTextureDataReadPixels(PXTextureData *textureData, int x, int y, int width, int height, void *pixels);
