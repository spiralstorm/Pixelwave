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

#import "PXTextField.h"

#import "PXFont.h"
#import "PXTextureFont.h"
#import "PXSystemFontRenderer.h"
#import "PXTextureFontRenderer.h"

#import "PXMathUtils.h"
#import "PXGLRenderer.h"

#import "PXPrivateUtils.h"
#import "PXExceptionUtils.h"

#import "PXSettings.h"

@interface PXTextField(Private)
- (void) validate;
- (void) updateBackgroundCoordinates;
- (void) updateBorderCoordinates;
@end

/**
 * A display object which represents a line of text.
 *
 * _Example:_
 * The following code creates a text field with the Helvetica font, that can
 * only accept letters ',' and '!' with size of 30.0f.
 *
 *	[PXTextureFont registerSystemFontWithFont:@"Helvetica"
 *	                                     name:@"fontName"
 *	                              fontOptions:[PXFontOptions fontOptionsWithSize:30.0f
 *	                                                               characterSets:PXFontCharacterSet_AllLetters
 *	                                                           specialCharacters:@",!"]];
 *
 *	PXTextField *textField = [[PXTextField alloc] initWithFont:@"fontName"];
 *
 *	textField.text = @"Hi!";
 *
 * @see PXTextureFont, PXFont
 */
@implementation PXTextField

@synthesize text = _text;
@synthesize font = fontName;
@synthesize kerning = _kerning;
@synthesize align;
@synthesize alignHorizontal = _alignHorizontal;
@synthesize alignVertical   = _alignVertical;
@synthesize letterSpacing = _letterSpacing;
@synthesize smoothing = smoothing;

@synthesize border = useBorder;
@synthesize background = useBackground;

- (id) init
{
	self = [super init];

	if (self)
	{
		isValid = NO;

		_text = nil;

		fontName = nil;
		renderer = nil;

		// Default...
		_letterSpacing = 0.0f;
		_fontSize = 12.0f;
		_kerning = YES;

		// Starting color is black
		textRed   = 0x00;
		textGreen = 0x00;
		textBlue  = 0x00;
		textAlpha = 0xFF;

		border		= PXGLColorVerticesMake(0, 0x00, 0x00, 0x00, 0xFF);
		background	= PXGLColorVerticesMake(0, 0xFF, 0xFF, 0xFF, 0xFF);

		useBorder = NO;
		useBackground = NO;

		// Default is left aligned.
		self.align = PXTextFieldAlign_TopLeft;
	}

	return self;
}

/**
 * Creates a new PXTextField with a registered font.
 *
 * @param fontName The name of the registered font.  If the font does not exist or was not
 * registered then the default (`PXTextFieldDefaultFont`) is
 * used instead.
 *
 * **Example:**
 *	[PXTextureFont registerSystemFontWithFont:@"Helvetica"
 *	                                     name:@"fontName"
 *	                              fontOptions:[PXFontOptions fontOptionsWithSize:30.0f
 *	                                                               characterSets:PXFontCharacterSet_AllLetters
 *	                                                           specialCharacters:@",!"]];
 *
 *	PXTextField *textField = [[PXTextField alloc] initWithFont:@"fontName"];
 *
 *	textField.text = @"Hi!";
 *
 * @see PXTextureFont, PXFont
 */
- (id) initWithFont:(NSString *)_fontName
{
	self = [self init];

	if (self)
	{
		if (_fontName)
		{
			self.font = _fontName;

			// If it's a texture font, use the font's native size as the default
			PXFont *font = [PXFont fontWithName:_fontName];

			if (font)
			{
				if ([font isKindOfClass:[PXTextureFont class]])
				{
					self.fontSize = ((PXTextureFont *)font)->_fontSize;
				}
			}
		}
	}

	return self;
}

- (void) dealloc
{
	PXGLColorVerticesFree(&border);
	PXGLColorVerticesFree(&background);

	// Release the text and font.
	self.text = nil;

	[fontName release];
	fontName = nil;

	// Release the renderer.
	[renderer release];
	renderer = nil;

	[super dealloc];
}

- (void) setFont:(NSString *)_fontName
{
	// If the font is nil, then there is no point in proceeding.
	if (!_fontName)
	{
		PXThrowNilParam(_fontName);
		return;
	}
	
	// Release our old fontName
	[fontName release];
	// Copy the new one.
	fontName = [_fontName copy];

	// Release the renderer.
	[renderer release];
	renderer = nil;

	// The text field is no longer valid.
	isValid = NO;

	// Grab the font.
	PXFont *pxFont = [PXFont fontWithName:fontName];
	if (pxFont)
	{
		// If it exists then grab the renderer and set our font size.
		renderer = [pxFont _newFontRenderer];
	}
	else
	{
		// If it didn't exist in our library, perhaps it is a system font?  Set
		// our font size, and check if it is a system font.
		UIFont *uiFont = [UIFont fontWithName:fontName size:_fontSize];
		
		// If the font exists in the system, use it
		if (uiFont)
		{
			// Make a new renderer for the system font.
			renderer = [[PXSystemFontRenderer alloc] initWithUIFont:uiFont];
		}
		// If it isn't, the renderer will be nil, and such be set to the system
		// font when the text field is validated
	}

	if (renderer)
	{
		// Give the renderer this class so that it can access the desired files.
		renderer->_textField = self;
	}
}

- (void) setText:(NSString *)text
{
	[_text release];
	_text = [text copy];

	// Changing the text invalidates it.
	isValid = NO;
}

- (void) setKerning:(BOOL)kerning
{
	if (_kerning == kerning)
		return;

	_kerning = kerning;

	// Changing the kerning invalidates it.
	isValid = NO;
}

- (float) fontSize
{
	return _fontSize;
}
- (void) setFontSize:(float)fontSize
{
	_fontSize = fontSize;

	// Changing the font size invalidates it.
	isValid = NO;
}

- (void) setTextColor:(unsigned)color
{
	// Grab the corresponding red, green and blue values from the hex color.
	textRed   = 0xFF & (color >> 16);
	textGreen = 0xFF & (color >> 8);
	textBlue  = 0xFF & (color);
}

- (unsigned) textColor
{
	// Turn our color from bytes to hex.
	return ((textRed << 16) | (textGreen << 8) | (textBlue));
}

/*
- (void) setTextAlpha:(float)alpha
{
	PXMathClamp(alpha, 0.0f, 1.0f);
	textAlpha = PX_COLOR_FLOAT_TO_BYTE(alpha);
}

- (float) textAlpha
{
	// Turn our color from bytes to hex.
	return PX_COLOR_BYTE_TO_FLOAT(textAlpha);
}
*/

- (void) setBackgroundColor:(unsigned)color
{
	// Grab the corresponding red, green and blue values from the hex color.
	background.r = 0xFF & (color >> 16);
	background.g = 0xFF & (color >> 8);
	background.b = 0xFF & (color);
}
- (unsigned) backgroundColor
{
	// Turn our color from bytes to hex.
	return ((background.r << 16) | (background.g << 8) | (background.b));
}
- (void) setBackgroundAlpha:(float)alpha
{
	PXMathClamp(alpha, 0.0f, 1.0f);
	background.a = PX_COLOR_FLOAT_TO_BYTE(alpha);
}

- (float) backgroundAlpha
{
	return PX_COLOR_BYTE_TO_FLOAT(background.a);
}

- (void) setBorderColor:(unsigned)color
{
	// Grab the corresponding red, green and blue values from the hex color.
	border.r = 0xFF & (color >> 16);
	border.g = 0xFF & (color >> 8);
	border.b = 0xFF & (color);
}

- (unsigned) borderColor
{
	return ((border.r << 16) | (border.g << 8) | (border.b));
}
- (void) setBorderAlpha:(float)alpha
{
	PXMathClamp(alpha, 0.0f, 1.0f);
	border.a = PX_COLOR_FLOAT_TO_BYTE(alpha);
}

- (float) borderAlpha
{
	return PX_COLOR_BYTE_TO_FLOAT(border.a);
}

- (void) setBackground:(BOOL)use
{
	if (useBackground != use)
	{
		useBackground = use;

		if (useBackground)
		{
			background = PXGLColorVerticesMake(4, background.r, background.g, background.b, background.a);

			[self updateBackgroundCoordinates];
		}
		else
		{
			PXGLColorVerticesFree(&background);
		}
	}
}

- (void) setBorder:(BOOL)use
{
	if (useBorder != use)
	{
		useBorder = use;

		if (useBorder)
		{
			border = PXGLColorVerticesMake(4, border.r, border.g, border.b, border.a);

			[self updateBorderCoordinates];
		}
		else
		{
			PXGLColorVerticesFree(&border);
		}
	}
}

- (void) setAlign:(PXTextFieldAlign)_align
{
	align = _align;

	switch (align)
	{
		case PXTextFieldAlign_Left:
			_alignHorizontal = 0.0f;
			_alignVertical   = 0.5f;
			break;
		case PXTextFieldAlign_Center:
			_alignHorizontal = 0.5f;
			_alignVertical   = 0.5f;
			break;
		case PXTextFieldAlign_Right:
			_alignHorizontal = 1.0f;
			_alignVertical   = 0.5f;
			break;
		case PXTextFieldAlign_TopLeft:
			_alignHorizontal = 0.0f;
			_alignVertical   = 0.0f;
			break;
		case PXTextFieldAlign_Top:
			_alignHorizontal = 0.5f;
			_alignVertical   = 0.0f;
			break;
		case PXTextFieldAlign_TopRight:
			_alignHorizontal = 1.0f;
			_alignVertical   = 0.0f;
			break;
		case PXTextFieldAlign_BottomLeft:
			_alignHorizontal = 0.0f;
			_alignVertical   = 1.0f;
			break;
		case PXTextFieldAlign_Bottom:
			_alignHorizontal = 0.5f;
			_alignVertical   = 1.0f;
			break;
		case PXTextFieldAlign_BottomRight:
			_alignHorizontal = 1.0f;
			_alignVertical   = 1.0f;
			break;
		default:
			return;
	}

	[renderer _updateAlignment];

	[self updateBackgroundCoordinates];
	[self updateBorderCoordinates];
}

- (void) setAlignHorizontal:(float)_align
{
	align = PXTextFieldAlign_Custom;
	_alignHorizontal = PXMathClamp(_align, 0.0f, 1.0f);

	[renderer _updateAlignment];

	[self updateBackgroundCoordinates];
	[self updateBorderCoordinates];
}

- (void) setAlignVertical:(float)_align
{
	align = PXTextFieldAlign_Custom;
	_alignVertical = PXMathClamp(_align, 0.0f, 1.0f);

	[renderer _updateAlignment];

	[self updateBackgroundCoordinates];
	[self updateBorderCoordinates];
}

- (void) setSmoothing:(BOOL)val
{
	smoothing = val;
	renderer.smoothing = val;
}

- (void) updateBackgroundCoordinates
{
	if (!useBackground)
		return;

	CGRect bounds;
	if (renderer)
		bounds = renderer->_bounds;

	if (!background.vertices)
		return;

	PXGLVertex *vertex = background.vertices;

	vertex->x = roundf(bounds.origin.x);
	vertex->y = roundf(bounds.origin.y);
	++vertex;
	vertex->x = roundf(bounds.origin.x);
	vertex->y = roundf(bounds.origin.y + bounds.size.height);
	++vertex;
	vertex->x = roundf(bounds.origin.x + bounds.size.width);
	vertex->y = roundf(bounds.origin.y);
	++vertex;
	vertex->x = roundf(bounds.origin.x + bounds.size.width);
	vertex->y = roundf(bounds.origin.y + bounds.size.height);
}
- (void) updateBorderCoordinates
{
	if (!useBorder)
		return;

	CGRect bounds = CGRectMake(0, 0, 0, 0);
	if (renderer)
		bounds = renderer->_bounds;

	if (!border.vertices)
		return;

	PXGLVertex *vertex = border.vertices;

	vertex->x = roundf(bounds.origin.x);
	vertex->y = roundf(bounds.origin.y);
	++vertex;
	vertex->x = roundf(bounds.origin.x);
	vertex->y = roundf(bounds.origin.y + bounds.size.height);
	++vertex;
	vertex->x = roundf(bounds.origin.x + bounds.size.width);
	vertex->y = roundf(bounds.origin.y + bounds.size.height);
	++vertex;
	vertex->x = roundf(bounds.origin.x + bounds.size.width);
	vertex->y = roundf(bounds.origin.y);
}

- (float) height
{
	[self validate];

	return [super height];
}
- (float) width
{
	[self validate];

	return [super width];
}
- (void) _measureLocalBounds:(CGRect *)retBounds
{
	// Validate to get the correcdt bounds.
	[self validate];

	if (renderer)
		*retBounds = renderer->_bounds;
}

- (BOOL) _containsPointWithLocalX:(float)x localY:(float)y shapeFlag:(BOOL)shapeFlag
{
	CGRect bounds = CGRectZero;
	[self _measureLocalBounds:&bounds];

	return CGRectContainsPoint(bounds, CGPointMake(x, y));
}

- (void) validate
{
	// If the renderer has already been validated, then we don't need to do it
	// again.
	if (isValid)
		return;

	if (!renderer)
	{
		self.font = PXTextFieldDefaultFont;
	}

	isValid = YES;

	[renderer _validate];
	renderer.smoothing = smoothing;

	[self updateBackgroundCoordinates];
	[self updateBorderCoordinates];
}

- (void) _renderGL
{
	// Validate before drawing.
	[self validate];

	if (useBackground | useBorder)
	{
//		PXGLShadeModel(GL_SMOOTH);

//		PXGLDisable(GL_TEXTURE_2D);
//		PXGLDisable(GL_POINT_SPRITE_OES);

//		PXGLDisableClientState(GL_TEXTURE_COORD_ARRAY);
//		PXGLDisableClientState(GL_POINT_SIZE_ARRAY_OES);
//		PXGLDisableClientState(GL_COLOR_ARRAY);

		if (useBackground)
		{
			PXGLColor4ub(background.r, background.g, background.b, background.a);

			// Set the vertices, then draw!
			PXGLVertexPointer(2, GL_FLOAT, sizeof(PXGLVertex), &(background.vertices->x));
			PXGLDrawArrays(GL_TRIANGLE_STRIP, 0, background.vertexCount);
		}

		if (useBorder)
		{
			PXGLColor4ub(border.r, border.g, border.b, border.a);
			PXGLLineWidth(1.0f);

			// Set the vertices, then draw!
			PXGLVertexPointer(2, GL_FLOAT, sizeof(PXGLVertex), &(border.vertices->x));
			PXGLDrawArrays(GL_LINE_LOOP, 0, border.vertexCount);
		}
	}

	PXGLColor4ub(textRed, textGreen, textBlue, textAlpha);
	[renderer _renderGL];
}

/**
 * Creates a PXTextField using the default font
 * (`PXTextFieldDefaultFont`). No text will be displayed until you
 * set the text property of the PXTextField just created. If no texts exists,
 * then the this object will appear to have 0 size.
 *
 * **Example:**
 *	PXTextField *textField = [PXTextField textField];
 *
 * @see PXTextureFont, PXFont
 */
+ (PXTextField *)textField
{
	return [[PXTextField new] autorelease];
}

/**
 * Creates a PXTextField using the registered font if it exists, or the default
 * font (`PXTextFieldDefaultFont`). No text will be displayed until
 * you set the text property of the PXTextField just created. If no texts
 * exists, then the this object will appear to have 0 size.
 *
 * @param fontName The name of the registered font.  If the font does not exist or was not
 * registered then the default (`PXTextFieldDefaultFont`) is
 * used instead.
 *
 * **Example:**
 *	PXTextField *textField = [PXTextField textField];
 *
 * @see PXTextureFont, PXFont
 */
+ (PXTextField *)textFieldWithFont:(NSString *)_fontName
{
	return [[[PXTextField alloc] initWithFont:_fontName] autorelease];
}

/**
 * Creates a PXTextField with a registered font.
 *
 * @param fontName The name of the registered font.  If the font does not exist or was not
 * registered then the default (`PXTextFieldDefaultFont`) is
 * used instead.
 * @param text The text for the text field.
 *
 * **Example:**
 *	[PXTextureFont registerSystemFontWithFont:@"Helvetica"
 *	                                     name:@"fontName"
 *	                              fontOptions:[PXFontOptions fontOptionsWithSize:30.0f
 *	                                                               characterSets:PXFontCharacterSet_AllLetters
 *	                                                           specialCharacters:@",!"]];
 *
 *	PXTextField *textField = [PXTextField textFieldWithFont:@"fontName" text:@"Hi"];
 *
 * @see PXTextureFont, PXFont
 */
+ (PXTextField *)textFieldWithFont:(NSString *)_fontName text:(NSString *)_text
{
	PXTextField *textField = [[PXTextField alloc] initWithFont:_fontName];
	textField.text = _text;

	return [textField autorelease];
}

@end
