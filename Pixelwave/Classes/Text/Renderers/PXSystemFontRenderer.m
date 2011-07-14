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

#import "PXSystemFontRenderer.h"

#import "PXEngine.h"
#import "PXTextField.h"

#import "PXMathUtils.h"

#import "PXExceptionUtils.h"
#import "PXDebugUtils.h"

#import "PXTextureData.h"
#import "PXTextureGlyphBatch.h"

@implementation PXSystemFontRenderer

- (id) init
{
	// Need to use the initWithUIFont method.
	assert(0);
	[self release];

	return nil;
}

- (id) initWithUIFont:(UIFont *)_font
{
	self = [super init];

	if (self)
	{
		uiFont = [_font retain];

		textureData = [[PXTextureData alloc] _init];

		if (!textureData)
		{
			[self release];
			return nil;
		}
		
		textureData->_smoothingType = GL_NEAREST;

		textureGlyphBatch = [[PXTextureGlyphBatch alloc] initWithVertexCount:4];
		textureGlyphBatch->_textureData = textureData;
	}

	return self;
}

- (void) dealloc
{
	// Release the font we retained.
	[uiFont release];
	[textureData release];

	[textureGlyphBatch release];

	[super dealloc];
}

- (void) _validate
{
	textureGlyphBatch->_textureData = nil;

	// If there is no text field, then we can not grab the vital validation
	// information, thus we just return.
	if (!_textField)
		return;

	// Set the font size to the desired amount multiplied by the scaling factor.
	float fontSize = _textField->_fontSize * PXEngineGetContentScaleFactor();
	float multAmount = 1.0f / PXEngineGetContentScaleFactor();

	UIFont *newFont = [[uiFont fontWithSize:fontSize] retain];
	[uiFont release];
	uiFont = newFont;

	// What size is the font texture we are going to make?
	CGSize size = [_textField->_text sizeWithFont:uiFont];

	// Our bounds are equal to that size (divided by the scale factor of course)
	_bounds.size.width  = size.width  * multAmount;
	_bounds.size.height = size.height * multAmount;

	if (PXMathIsZero(_bounds.size.width) ||
	    PXMathIsZero(_bounds.size.height))
	{
		return;
	}
	
	// We need the next power of two for our texture, so lets find it!
	unsigned texWidth = size.width > size.height ? size.width : size.height;
	unsigned texHeight;

	texWidth = PXMathNextPowerOfTwo(texWidth);

	texHeight = texWidth;

	PXGLColoredTextureVertex *vertex = textureGlyphBatch->_vertices;

	float scaledTexWidth  = texWidth;
	float scaledTexHeight = texHeight;

	float xScale = ((float)(size.width))  / ((float)(scaledTexWidth));
	float yScale = ((float)(size.height)) / ((float)(scaledTexHeight));

	scaledTexWidth  *= (xScale * multAmount);
	scaledTexHeight *= (yScale * multAmount);

	// Setup the vertices and texture locations (it's just a rectangle).
	vertex->x = 0.0f;					vertex->y = 0.0f;
	vertex->s = 0.0f;					vertex->t = 0.0f;
	++vertex;
	vertex->x = 0.0f;					vertex->y = scaledTexHeight;
	vertex->s = 0.0f;					vertex->t = yScale;
	++vertex;
	vertex->x = scaledTexWidth;			vertex->y = 0.0f;
	vertex->s = xScale;					vertex->t = 0.0f;
	++vertex;
	vertex->x = scaledTexWidth;			vertex->y = scaledTexHeight;
	vertex->s = xScale;					vertex->t = yScale;

	// Oz's font drawer from apple...
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
		PXDebugLog (@"PXSystemFontRenderer: Error creating a CGBitmapContext");

		if (data)
			free(data);

		return;
	}

	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextTranslateCTM(context, 0.0, texHeight);
	CGContextScaleCTM(context, 1.0, -1.0);

	UIGraphicsPushContext(context);
	{
		CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
		UITextAlignment alignment = UITextAlignmentLeft;
		[_textField->_text drawInRect:drawRect
							 withFont:uiFont
						lineBreakMode:UILineBreakModeClip
							alignment:alignment];
	}
	UIGraphicsPopContext();

	// Upload the data to the texture
	GLuint boundTex = PXGLBoundTexture();
	PXGLBindTexture(GL_TEXTURE_2D, textureData->_glName);
	{
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, textureData->_smoothingType);
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, textureData->_smoothingType);
		
		GLuint internalFormat = GL_ALPHA;
		glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, texWidth, texHeight, 0, internalFormat, GL_UNSIGNED_BYTE, data);
	}
	PXGLBindTexture(GL_TEXTURE_2D, boundTex);

	CGContextRelease(context);
	free(data);

	//textureFontInfo->_glName = textureData->_glName;
	textureGlyphBatch->_textureData = textureData;

	[super _validate];
}

- (BOOL) smoothing
{
	return smoothingType == GL_LINEAR;
}
- (void) setSmoothing:(BOOL)val
{
	smoothingType = val ? GL_LINEAR : GL_NEAREST;
}

- (void) _updateAlignment
{
	[super _updateAlignment];

	// We need to update the vertices to correspond with the new bounds.
	unsigned index;
	PXGLColoredTextureVertex *vertex;

	if (!textureGlyphBatch)
		return;
	if (!textureGlyphBatch->_vertices || textureGlyphBatch->_vertexCount == 0)
		return;

	for (index = 0, vertex = textureGlyphBatch->_vertices;
		 index < textureGlyphBatch->_vertexCount;
		 ++index, ++vertex)
	{
		vertex->x += shiftX;
		vertex->y += shiftY;
	}
}

- (void) _renderGL
{
	if (!_textField)
	{
		return;
	}

	if (textureGlyphBatch->_vertices == NULL ||
		textureGlyphBatch->_vertexCount == 0 ||
		textureGlyphBatch->_textureData == nil)
	{
		return;
	}

	// Enable the texture, and draw the vertices with the correct color.
//	PXGLShadeModel(GL_SMOOTH);
	PXGLEnable(GL_TEXTURE_2D);
	PXGLEnableClientState(GL_TEXTURE_COORD_ARRAY);
//	PXGLDisableClientState(GL_POINT_SIZE_ARRAY_OES);
//	PXGLDisableClientState(GL_COLOR_ARRAY);

	PXGLBindTexture(GL_TEXTURE_2D, textureData->_glName);

	if (smoothingType != textureData->_smoothingType)
	{
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, smoothingType);
		PXGLTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, smoothingType);
		textureData->_smoothingType = smoothingType;
	}

	PXGLVertexPointer(2, GL_FLOAT, sizeof(PXGLColoredTextureVertex), &(textureGlyphBatch->_vertices->x));
	PXGLTexCoordPointer(2, GL_FLOAT, sizeof(PXGLColoredTextureVertex), &(textureGlyphBatch->_vertices->s));

	PXGLDrawArrays(GL_TRIANGLE_STRIP, 0, textureGlyphBatch->_vertexCount);
}

@end
