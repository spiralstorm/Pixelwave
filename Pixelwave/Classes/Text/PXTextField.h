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

#import "PXInteractiveObject.h"

@class PXFontRenderer;

typedef enum
{
	PXTextFieldAlign_Left = 0,
	PXTextFieldAlign_Center,
	PXTextFieldAlign_Right,
	PXTextFieldAlign_TopLeft,
	PXTextFieldAlign_Top,
	PXTextFieldAlign_TopRight,
	PXTextFieldAlign_BottomLeft,
	PXTextFieldAlign_Bottom,
	PXTextFieldAlign_BottomRight,
	PXTextFieldAlign_Custom
} PXTextFieldAlign;

@interface PXTextField : PXInteractiveObject
{
/// @cond DX_IGNORE
@public
	NSString *_text;

	float _alignHorizontal;
	float _alignVertical;

	float _fontSize;
	float _letterSpacing;
	BOOL _kerning;
@private
	BOOL pxTextFieldPadding1;
	short pxTextFieldPadding2;
@protected
	PXGLColorVertices border;
	PXGLColorVertices background;

	NSString *fontName;
	PXFontRenderer *renderer;

	PXTextFieldAlign align;

	unsigned char textRed;
	unsigned char textGreen;
	unsigned char textBlue;
	unsigned char textAlpha;

	BOOL isValid;
	BOOL useBorder;
	BOOL useBackground;
	BOOL smoothing;
/// @endcond
}

/**
 *	The text of the text field.
 *
 *	@b Default: <code>nil</code>
 */
@property (nonatomic, copy) NSString *text;
/**
 *	The registered name of the font.
 *
 *	@b Default: <code>PX_TEXT_FIELD_DEFAULT_FONT</code>
 */
@property (nonatomic, copy) NSString *font;
/**
 *	The size of the text.
 *
 *	@b Default: 12.0f
 */
@property (nonatomic) float fontSize;
/**
 *	The alignment of the text.
 *
 *	@b Default: <code>PXTextFieldAlign_TopLeft</code>
 */
@property (nonatomic) PXTextFieldAlign align;
/**
 *	The horizontal alignment of the text.  Ranges between 0.0f and 1.0f.
 *
 *	@b Default: 0.0f
 */
@property (nonatomic) float alignHorizontal;
/**
 *	The vertical alignment of the text.  Ranges between 0.0f and 1.0f.
 *
 *	@b Default: 0.0f
 */
@property (nonatomic) float alignVertical;

/**
 *	The extra space between each letter.
 *
 *	@b Default: 0.0f
 */
@property (nonatomic) float letterSpacing;

/**
 *	The color of the text.
 *
 *	@b Default: 0x000000 - black
 */
@property (nonatomic) unsigned textColor;
/**
 *	The background color of the text field.
 *
 *	@b Default: 0xFFFFFF - white
 */
@property (nonatomic) unsigned backgroundColor;
/**
 *	The background alpha of the text field.
 *
 *	@b Default: 1.0f
 */
@property (nonatomic) float backgroundAlpha;
/**
 *	If <code>YES</code> it displays the background of the text field.
 *
 *	@b Default: <code>NO</code>
 */
@property (nonatomic) BOOL background;

/**
 *	The border color of the text field.
 *
 *	@b Default: 0x000000 - black
 */
@property (nonatomic) unsigned borderColor;
/**
 *	The border alpha of the text field.
 *
 *	@b Default: 1.0f
 */
@property (nonatomic) float borderAlpha;
/**
 *	If <code>YES</code> it displays the border of the text field.
 *
 *	@b Default: <code>NO</code>
 */
@property (nonatomic) BOOL border;

/**
 *	If the text should be smoothed when transformed. This property is set to
 *	<code>NO</code> be default and should only be set to <code>YES</code> when
 *	the text field is being transformed (such as during an animation)
 *
 *	@b Default: <code>NO</code>
 */
@property (nonatomic) BOOL smoothing;

/**
 *	If <code>YES</code> and the font has kerning values stored, then your text
 *	will be kerned.
 *
 *	@b Default: <code>YES</code>
 */
@property (nonatomic) BOOL kerning;

//-- ScriptName: TextField
- (id) initWithFont:(NSString *)fontName;

//-- ScriptIgnore
+ (PXTextField *)textField;
//-- ScriptIgnore
+ (PXTextField *)textFieldWithFont:(NSString *)fontName;
//-- ScriptName: make
//-- ScriptArg[0]: nil
//-- ScriptArg[1]: nil
+ (PXTextField *)textFieldWithFont:(NSString *)fontName text:(NSString *)text;

@end
