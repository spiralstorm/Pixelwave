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

#import "PXTextureData.h"

#include "PXEngine.h"
#import "PXMatrix.h"
#import "PXColorTransform.h"
#import "PXStage.h"
#import "PXMathUtils.h"

#import "PXExceptionUtils.h"
#import "PXDebugUtils.h"

#import "PXTextureParser.h"

#import "PXTextureLoader.h"

#import "PXRectangle.h"
#include <CoreGraphics/CGGeometry.h>
#include "PXColorUtils.h"

// For drawTextureData
#import "PXTexture.h"

BOOL pxTextureDataExpandEdges = YES;

/**
 * Represents a texture in GPU memory. To draw the image represented by a
 * PXTextureData object to the screen, a PXTexture display object must be
 * linked to it and added to the main display list. One PXTextureData object
 * can be linked by many PXTexture objects, allowing for the same image to
 * be rendered multiple times per frame without taking up extra memory.
 *
 * A PXTextureData object can be created with the contents of an external image
 * file via the PXTextureLoader class. Additionaly, a PXTextureData can be
 * initialized to contain a rasterized string of text with the
 * #initWithString:font: method.
 * Additionally, a blank PXTextureData object can be created and populated by
 * the user at run-time.
 *
 * @see initWithString:font:
 * @see drawDisplayObject:
 * @see [PXTextureLoader initWithContentsOfFile:]
 * @see textureDataWithContentsOfFile:
 */
@implementation PXTextureData

@synthesize width = _contentWidth, height = _contentHeight;
@synthesize glTextureName = _glName;
@synthesize pixelFormat;
@synthesize contentScaleFactor = _contentScaleFactor;

- (id) init
{
	PXThrow(PXException, @"TextureData objects shouldn't be initialized without any parameters");
	[self release];
	return nil;
}

- (id) _initWithoutGLName
{
	self = [super init];

	if (self)
	{
		// No smoothing
		_smoothingType = GL_NEAREST;
		_contentScaleFactor = 1.0f;

		// Repeating
		_wrapType = GL_REPEAT;

		// Default fill color
		_fillColor = 0xFFFFFFFF;

		// Reset the gl texture. Populating it is done later
		_glName = 0;
	}

	return self;
}

- (id) _init
{
	self = [self _initWithoutGLName];

	if (self)
	{
		if (![self _makeGLName])
		{
			[self release];
			return nil;
		}
	}

	return self;
}

- (void) dealloc
{
	if (_glName > 0)
	{
		PXGLBindTexture(GL_TEXTURE_2D, 0);

		glDeleteTextures(1, &_glName);
	}

	[super dealloc];
}

- (BOOL) _makeGLName
{
	if (_glName > 0)
	{
		PXGLBindTexture(GL_TEXTURE_2D, 0);

		glDeleteTextures(1, &_glName);
	}

	glGenTextures(1, &_glName);

	if (_glName == 0)
	{
		return NO;
	}

	GLuint boundTex = PXGLBoundTexture();
	PXGLBindTexture(GL_TEXTURE_2D, _glName);
	{
		// Smoothing = false initially
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _smoothingType);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _smoothingType);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _wrapType);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _wrapType);
	}
	PXGLBindTexture(GL_TEXTURE_2D, boundTex);

	return YES;
}

- (id) initWithData:(NSData *)data
{
	return [self initWithData:data modifier:nil];
}

- (id) initWithData:(NSData *)data modifier:(id<PXTextureModifier>)modifier
{
	self = [super init];

	if (self)
	{
		PXTextureParser *textureParser = [[PXTextureParser alloc] initWithData:data
																	  modifier:modifier
																		origin:nil];
		PXTextureData *newTextureData = [textureParser newTextureData];

		[textureParser release];
		[self release];

		self = newTextureData;

		// If initialization code is needed, do a check if self exists prior to
		// doing any code.
	}

	return self;
}

/**
 * Initializes a TextureData object with the given width and height values in
 * pixels.
 * The returned texture data object is initially filled with white,
 * non-transparent pixels. To modify the contents of the image you can use the
 * #drawDisplayObject: method.
 * 
 * @param width The width of the new TextureData in pixels.
 * @param height The height of the new TextureData in pixels.
 *
 * @see drawDisplayObject:
 * @see drawDisplayObject:matrix:colorTransform:clipRect:smoothing:clearTexture:
 */
- (id) initWithWidth:(unsigned)width height:(unsigned)height
{
	//Create an RGBA8888 texture
	return [self initWithWidth:width height:height transparency:NO fillColor:0xFFFFFF contentScaleFactor:1.0f];
}

- (id) initWithWidth:(unsigned)width
			  height:(unsigned)height
		transparency:(BOOL)transparency
		   fillColor:(unsigned)fillColor
{
	return [self initWithWidth:width
						height:height
				  transparency:transparency
					 fillColor:fillColor
			contentScaleFactor:1.0f];
}

/**
 * Initializes a PXTextureData object with the given width and height values in
 * pixels.
 * To modify the contents of the image you can use the
 * #drawDisplayObject: method.
 *
 * **Example:**
 *	// Create two texture data objects 512 x 512 pixels in size and a blue fill.
 *	
 *	// The first one has an alpha channel
 *	PXTextureData *textureDataWithAlpha = [[PXTextureData alloc] initWithWidth:512 height:512 transparency:YES fillColor:0xFF0000FF];
 *	
 *	// The second one doesn't
 *	PXTextureData *textureDataWithoutAlpha = [[PXTextureData alloc] initWithWidth:512 height:512 transparency:NO fillColor:0x0000FF];
 * 
 * @param width The width of the new TextureData in pixels.
 * @param height The height of the new TextureData in pixels.
 * @param transparency A boolean value indicating if the PXTextureData object should have an
 * alpha channel.
 * @param fillColor A hex value indicating the default color of the texture data's pixels.
 * For texture datas with an alpha channel, use the format 0xRRGGBB. For
 * texture datas without an alpha channel use the format 0xAARRGGBB.
 *
 * @see drawDisplayObject:
 * @see drawDisplayObject:matrix:colorTransform:clipRect:smoothing:clearTexture:
 */

- (id) initWithWidth:(unsigned)width
			  height:(unsigned)height
		transparency:(BOOL)transparency
		   fillColor:(unsigned)fillColor
  contentScaleFactor:(float)contentScaleFactor
{
	// A little unconservative, but necessary
	self = [self _init];

	if (self)
	{
		_fillColor = fillColor;

		// Find the tightest fitting power-of-two box that will hold the texture
		unsigned int powerOfTwoWidth = PXMathNextPowerOfTwo(width);
		unsigned int powerOfTwoHeight = PXMathNextPowerOfTwo(height);

		GLint glFormat;
		GLubyte *data = 0;

		unsigned pixelsCount = powerOfTwoWidth * powerOfTwoHeight;
		unsigned index;
		
		if (transparency)
		{
			glFormat = GL_RGBA;

			PXColor4 col;
			PXColorHexToARGB(fillColor, &col);

			data = malloc(sizeof(PXColor4) * pixelsCount);

			if (!data)
			{
				PXThrow(PXException, @"Couldn't allocate enough cpu memory to generate pixel data for this TextureData");
				[self release];
				return nil;
			}

			PXColor4 *pixels = (PXColor4 *)data;
			PXColor4 *pixel;
			for (index = 0, pixel = pixels; index < pixelsCount; ++index, ++pixel)
			{
				*pixel = col;
			}
		}
		else
		{
			glFormat = GL_RGB;

			PXColor3 col;
			PXColorHexToRGB(fillColor, &col);

			data = malloc(sizeof(PXColor3) * pixelsCount);

			if (!data)
			{
				PXThrow(PXException, @"Couldn't allocate enough cpu memory to generate pixel data for this TextureData");
				[self release];
				return nil;
			}

			PXColor3 *pixels = (PXColor3 *)data;
			PXColor3 *pixel;
			for (index = 0, pixel = pixels; index < pixelsCount; ++index, ++pixel)
			{
				*pixel = col;
			}
		}

		GLuint boundTex = PXGLBoundTexture();
		PXGLBindTexture(GL_TEXTURE_2D, _glName);

		glTexImage2D( GL_TEXTURE_2D,
					 0,
					 glFormat,
					 powerOfTwoWidth,
					 powerOfTwoHeight,
					 0,
					 glFormat,
					 GL_UNSIGNED_BYTE,
					 data );

		free(data);
		data = 0;

		// Bring back the previously bound texture
		PXGLBindTexture(GL_TEXTURE_2D, boundTex);

		[self _setInternalPropertiesWithWidth:powerOfTwoWidth
									   height:powerOfTwoHeight
							usingContentWidth:width
								contentHeight:height
						   contentScaleFactor:contentScaleFactor
									   format:glFormat];
	}

	return self;
}

/**
 * Initializes the texture data by rasterising the given line of text onto it.
 *
 * @param string The text to render onto the texture data.
 * @param font A UIFont object representing the font to use.
 */
- (id) initWithString:(NSString *)string font:(UIFont *)font
{
	return [self initWithString:string
						   font:font
						  width:0
						 height:0
					  alignment:UITextAlignmentLeft
				  lineBreakMode:UILineBreakModeClip];
}

/**
 * Initializes the texture data by rasterising the given line of text onto it.
 *
 * @param string The text to render onto the texture data.
 * @param font A UIFont object representing the font to use.
 * @param width The maximum width, in pixels, into which the text will be fitted.
 * @param height The maximum height, in pixels, into which the text will be fitted.
 * @param alignment A value of type UITextAlignment describing the direction in which the
 * text should be aligned.
 * @param lineBreakMode A value of type UILineBreakMode describing how text should be handled
 * when it overflows the given bounds (width and height).
 */
- (id) initWithString:(NSString *)string
				 font:(UIFont *)font
				width:(int)contentWidth
			   height:(int)contentHeight
			alignment:(UITextAlignment)alignment
		lineBreakMode:(UILineBreakMode)lineBreakMode
{
	if (!string)
	{
		PXThrowNilParam(string);
	}
	if (!font)
	{
		PXThrowNilParam(font);
	}

	// Create a texture with a single channel

	if (![self _init])
		return nil;

	if (contentWidth <= 0 || contentHeight <= 0)
	{
		CGSize size = [string sizeWithFont:font];

		contentWidth  = contentWidth  < 0 ? size.width  : contentWidth;
		contentHeight = contentHeight < 0 ? size.height : contentHeight;
	}

	unsigned texWidth  = PXMathNextPowerOfTwo(contentWidth);
	unsigned texHeight = PXMathNextPowerOfTwo(contentHeight);

	NSAssert(_glName != 0, @"glName must be instantiated at this point");

	CGColorSpaceRef	colorSpace;
	void			*data;
	CGContextRef	context;

	colorSpace = CGColorSpaceCreateDeviceGray();
	int bytesPerColor = 1;
	int bytesPerRow =  texWidth * bytesPerColor;
	data = calloc(texHeight, bytesPerRow);
	context = CGBitmapContextCreate(data, texWidth, texHeight, 8, bytesPerRow, colorSpace, kCGImageAlphaNone);
	// More info about this at http://developer.apple.com/mac/library/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_images/dq_images.html#//apple_ref/doc/uid/TP30001066-CH212-CJBHEGIB
	CGColorSpaceRelease(colorSpace);
	if (context == NULL)
	{
		PXDebugLog (@"PXTextureData: Error creating a CGBitmapContext");

		free(data);
		[self release];
		return nil;
	}

	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextTranslateCTM(context, 0.0, texHeight);
	CGContextScaleCTM(context, 1.0, -1.0);

	UIGraphicsPushContext(context);
	{
		CGRect drawRect = CGRectMake(0, 0, contentWidth, contentWidth);
		[string drawInRect:drawRect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
	}
	UIGraphicsPopContext();

	GLuint boundTex = PXGLBoundTexture();
	
    PXGLBindTexture(GL_TEXTURE_2D, _glName);
	{
		GLuint internalFormat = GL_ALPHA;
		glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, texWidth, texHeight, 0, internalFormat, GL_UNSIGNED_BYTE, data);
	}
	PXGLBindTexture(GL_TEXTURE_2D, boundTex);

	CGContextRelease(context);
	free(data);

	[self _setInternalPropertiesWithWidth:texWidth
								   height:texHeight
							usingContentWidth:contentWidth
							contentHeight:contentHeight
						contentScaleFactor:1.0f
									format:PXTextureDataPixelFormat_A8];

	return self;
}

- (void) _setInternalPropertiesWithWidth:(unsigned)texWidth
								  height:(unsigned)texHeight
					   usingContentWidth:(unsigned)contWidth
						   contentHeight:(unsigned)contHeight
					  contentScaleFactor:(float)contScaleFactor
								  format:(PXTextureDataPixelFormat)pixFormat
{
	textureWidth = texWidth;
	textureHeight = texHeight;
	_contentWidth = contWidth;
	_contentHeight = contHeight;
	_contentScaleFactor = contScaleFactor;
	pixelFormat = pixFormat;

	float _maxS, _maxT;

	_maxS = _contentWidth / (float)textureWidth;
	_maxT = _contentHeight / (float)textureHeight;

	_sPerPixel = _maxS / (float)_contentWidth;
	_tPerPixel = _maxT / (float)_contentHeight;
}

/**
 * Renders the source TextureData onto this TextureData.
 * To modify the transformation with which the source is drawn onto the texture you can pass custom `matrix` and `colorTransform` objects, or `nil` for the default transformations.
 *
 * @param source A PXTextureData to draw onto this PXTextureData.
 * @param matrix A PXMatrix object representing the transformation with which
 * `source` will be rendered. Pass `nil` to use the
 * default (identity) matrix.
 * @param colorTransform A PXColorTransform object representing the color transformation with
 * which `source` will be rendered. Pass `nil` to use
 * the default transformation.
 * @param clipRect A PXRectangle object defining the area of the `source` object
 * to draw. Pass `nil` to use the entire area of
 * `source`.
 * @param smoothing A boolean value indicating if a TextureData object should be smoothed
 * when rotated or scaled. Only applies when drawing a TextureData object.
 * @param clearTexture A boolean value indicating if the TextureData should be cleared before
 * being drawn onto. Pass `NO` for this value as an optimization
 * if the entire surface of the PXTextureData will be drawn into.
 */
- (void) drawTextureData:(PXTextureData *)source
				  matrix:(PXMatrix *)matrix
		  colorTransform:(PXColorTransform *)colorTransform
				clipRect:(PXRectangle *)clipRect
			   smoothing:(BOOL)smoothing
			clearTexture:(BOOL)clearTexture
{
	PXTexture *texture = [[PXTexture alloc] initWithTextureData:source];
	
	[self drawDisplayObject:texture
					 matrix:matrix
			 colorTransform:colorTransform
				   clipRect:clipRect
				  smoothing:smoothing
			   clearTexture:clearTexture];
	
	[texture release];
}

/**
 * Renders the given display object onto the texture data with the default
 * transformation, without clearing out the texture data's previous contents.
 *
 * @param source A PXDisplayObject to draw onto this PXTextureData.
 */
- (void) drawDisplayObject:(PXDisplayObject *)source
{
	[self drawDisplayObject:source matrix:nil colorTransform:nil clipRect:nil smoothing:NO clearTexture:NO];
}

/**
 * Renders the given display object onto the TextureData.
 * The transformation of
 * the source display object is ignored during the render process. To modify
 * the transformation with which the source is drawn onto the texture you can
 * pass custom `matrix` and `colorTransform` objects, or
 * `nil` for the default transformations.
 *
 * @param source A PXDisplayObject to draw onto this PXTextureData.
 * @param matrix A PXMatrix object representing the transformation with which
 * `source` will be rendered. Pass `nil` to use the
 * default transformation.
 * @param colorTransform A PXColorTransform object representing the color transformation with
 * which `source` will be rendered. Pass `nil` to use
 * the default transformation.
 * @param clipRect A PXRectangle object defining the area of the `source` object
 * to draw. Pass `nil` to use the entire area of
 * `source`.
 * @param smoothing A boolean value indicating if a TextureData object should be smoothed
 * when rotated or scaled. Only applies when drawing a TextureData object.
 * @param clearTexture A boolean value indicating if the TextureData should be cleared before
 * being drawn onto. Pass `NO` for this value as an optimization
 * if the entire surface of the PXTextureData will be drawn into.
 */
- (void) drawDisplayObject:(PXDisplayObject *)source
					matrix:(PXMatrix *)matrix
			colorTransform:(PXColorTransform *)colorTransform
				  clipRect:(PXRectangle *)clipRect
				 smoothing:(BOOL)smoothing
			  clearTexture:(BOOL)clearTexture
{
	if (!source)
	{
		PXThrowNilParam(source);
		return;
	}

	PXGLMatrix *matPtr = 0;
	PXGLColorTransform *ctPtr = 0;

	PXGLMatrix mat;
	if (matrix)
	{
		mat.a = matrix.a;
		mat.b = matrix.b;
		mat.c = matrix.c;
		mat.d = matrix.d;
		mat.tx = matrix.tx;
		mat.ty = matrix.ty;
		matPtr = &mat;
	}

	PXGLColorTransform ct;
	if (colorTransform)
	{
		ct.redMultiplier   = colorTransform.redMultiplier;
		ct.greenMultiplier = colorTransform.greenMultiplier;
		ct.blueMultiplier  = colorTransform.blueMultiplier;
		ct.alphaMultiplier = colorTransform.alphaMultiplier;
		ctPtr = &ct;
	}

	CGRect *rectPtr = 0;
	CGRect rect;

	if (clipRect)
	{
		rect = CGRectMake(clipRect.x, clipRect.y, clipRect.width, clipRect.height);
		rectPtr = &rect;
	}

	PXEngineRenderToTexture(self, source, matPtr, ctPtr, rectPtr, smoothing, clearTexture);
}

///////

- (PXRectangle *)rect
{
	return [PXRectangle rectangleWithX:0.0f y:0.0f
							  width:self.width height:self.height];
}

- (BOOL) transparency
{	
	return pixelFormat == PXTextureDataPixelFormat_A8 ||
		   pixelFormat == PXTextureDataPixelFormat_LA88 ||
		   pixelFormat == PXTextureDataPixelFormat_RGBA4444 ||
		   pixelFormat == PXTextureDataPixelFormat_RGBA5551 ||
		   pixelFormat == PXTextureDataPixelFormat_RGBA8888 ||
		   pixelFormat == PXTextureDataPixelFormat_RGBA_PVRTC2 ||
		   pixelFormat == PXTextureDataPixelFormat_RGBA_PVRTC4;
}

+ (void) setExpandEdges:(BOOL)expandEdges
{
	pxTextureDataExpandEdges = expandEdges;
}
+ (BOOL) expandEdges
{
	return pxTextureDataExpandEdges;
}

//////

/**
 * A utility method for quickly loading an image from file and placing it into
 * a PXTextureData object.
 *
 * @param filePath The path of the image to load. The path can point to a file in the
 * application bundle or the application's sandox on the hard-drive.
 *
 * @return The resulting, `autoreleased`, PXTextureData object.
 */
+ (PXTextureData *)textureDataWithContentsOfFile:(NSString *)path
{
	return [PXTextureData textureDataWithContentsOfFile:path modifier:nil];
}

+ (PXTextureData *)textureDataWithContentsOfFile:(NSString *)path modifier:(id<PXTextureModifier>)modifier
{
	PXTextureLoader *textureLoader = [[PXTextureLoader alloc] initWithContentsOfFile:path modifier:modifier];

	if (!textureLoader)
	{
		PXDebugLog (@"PXTextureData: Couldn't resolve file at path %@", path);
		return nil;
	}

	PXTextureData *textureData = [textureLoader newTextureData];
	[textureLoader release];

	return [textureData autorelease];
}

+ (PXTextureData *)textureDataWithContentsOfURL:(NSURL *)url
{
	return [PXTextureData textureDataWithContentsOfURL:url modifier:nil];
}

+ (PXTextureData *)textureDataWithContentsOfURL:(NSURL *)url modifier:(id<PXTextureModifier>)modifier
{
	PXTextureLoader *textureLoader = [[PXTextureLoader alloc] initWithContentsOfURL:url modifier:modifier];
	PXTextureData *textureData = [textureLoader newTextureData];
	[textureLoader release];

	return [textureData autorelease];
}

+ (PXTextureData *)textureDataWithData:(NSData *)data
{
	return [[[PXTextureData alloc] initWithData:data] autorelease];
}

+ (PXTextureData *)textureDataWithData:(NSData *)data modifier:(id<PXTextureModifier>)modifier
{
	return [[[PXTextureData alloc] initWithData:data modifier:modifier] autorelease];
}

@end

#import <UIKit/UIKit.h>
#import "PXCGUtils.h"
#import "PXCGTextureParser.h"

@implementation PXTextureData (UIKit)
- (id) initWithUIImage:(UIImage *)image
{
	return [self initWithUIImage:image modifier:nil];
}

- (id) initWithUIImage:(UIImage *)image modifier:(id<PXTextureModifier>)modifier
{
	return [self initWithCGImage:[image CGImage]
					 scaleFactor:[image scale]
					 orientation:[image imageOrientation]
						modifier:modifier];
}

// This is a non-traditional init function. It replaces self with a new object.
- (id) initWithCGImage:(CGImageRef)cgImage
		   scaleFactor:(float)scaleFactor
		   orientation:(UIImageOrientation)cgImageOrientation
			  modifier:(id<PXTextureModifier>)modifier
{
	[self release];
	self = nil;
	
	PXCGTextureParser *parser = [[PXCGTextureParser alloc] initWithCGImage:cgImage
															   scaleFactor:(float)scaleFactor
															   orientation:cgImageOrientation
																  modifier:modifier];
	
	PXTextureData *newTextureData = [parser newTextureData];
	
	[parser release];

	self = newTextureData;

	if (self)
	{
		// Add init code here if needed
	}
	//}	
	return self;
}

- (UIImage *)UIImage
{
	CGImageRef imageRef = PXCGUtilsCreateCGImageFromTextureData(self);
	
	// Texture datas are always oriented up.
	UIImage *image = [UIImage imageWithCGImage:imageRef
										 scale:self.contentScaleFactor
								   orientation:UIImageOrientationUp];
	CGImageRelease(imageRef);
	
	return image;
}

- (CGImageRef) CGImage
{
	CGImageRef imageRef = PXCGUtilsCreateCGImageFromTextureData(self);
	
	// Dark voodo magic...
	[(id)imageRef autorelease];
	
	// "Any sufficiently advanced technology is indistinguishable from magic"
	//		- Arthur C. Clarke
	//
	// Discussion about autoreleasing CGImageRef:
	// http://www.cocoabuilder.com/archive/cocoa/215004-autorelease-cgimageref.html
	
	return imageRef;
}

///////////////

+ (PXTextureData *)textureDataWithUIImage:(UIImage *)image
{
	return [[[PXTextureData alloc] initWithUIImage:image] autorelease];
}

+ (PXTextureData *)textureDataWithUIImage:(UIImage *)image
								 modifier:(id<PXTextureModifier>)modifier
{
	return [[[PXTextureData alloc] initWithUIImage:image
										  modifier:modifier] autorelease];
}

+ (PXTextureData *)textureDataWithCGImage:(CGImageRef)cgImage
							  scaleFactor:(float)scaleFactor
							  orientation:(UIImageOrientation)orientation
								 modifier:(id<PXTextureModifier>)modifier
{
	return [[[PXTextureData alloc] initWithCGImage:cgImage
									   scaleFactor:scaleFactor
									   orientation:orientation
										  modifier:modifier] autorelease];
}

@end
