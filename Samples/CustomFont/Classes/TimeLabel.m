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

#import "TimeLabel.h"
#import "ColorUtil.h"

#define MARK_SHOW_ALPHA 0.9f
#define MARK_HIDE_ALPHA 0.3f

/*
 *	This is a simple container that holds several TextField objects used to
 *	emulate the look of a digital clock.
 *
 *	The setTime method contains some utility code
 *	to quickly turn an NSDate object (representing the current time) into a
 *	formatted string.
 *
 *	The setHue method allows the user to pass in a value between 0 - 360 as
 *	the hue to use when coloring the text.
 */
@implementation TimeLabel

@synthesize militaryTime;

/*
 *	Sets up the display list and a reusable NSDateFormatter object
 */
- (id) init
{
	self = [super init];

	if (self)
	{
		txtTimeBack = [PXTextField textFieldWithFont:@"myFont"];
		txtTimeBack.textColor = 0xFFFFFF;
		txtTimeBack.text = @"88:88:88";
		txtTimeBack.alpha = 0.25f;
		[self addChild:txtTimeBack];
		
		txtTime = [PXTextField textFieldWithFont:@"myFont"];
		txtTime.textColor = 0xFFFFFF;
		txtTime.text = @"10:01:00";
		[self addChild:txtTime];
		
		txtAM = [PXTextField textFieldWithFont:@"myFont"];
		txtAM.textColor = 0xFFFFFF;
		txtAM.fontSize = 70;
		txtAM.smoothing = YES;
		txtAM.text = @"AM";
		txtAM.x = txtTime.width + 20;
		txtAM.y = 14;
		[self addChild:txtAM];
		
		txtPM = [PXTextField textFieldWithFont:@"myFont"];
		txtPM.textColor = txtAM.textColor;
		txtPM.fontSize = txtAM.fontSize;
		txtPM.smoothing = YES;
		txtPM.text = @"PM";
		txtPM.x = txtAM.x;
		txtPM.y = txtAM.y + txtAM.height + 16;
		[self addChild:txtPM];
		
		dateFormatter = [NSDateFormatter new];
		self.militaryTime = NO;
	}

	return self;
}

- (void) dealloc
{
	[dateFormatter release];
	dateFormatter = nil;
	
	[super dealloc];
}

/*
 *	Changes the behavior of the NSDateFormatter object to output military or
 *	non-military time.
 */
- (void) setMilitaryTime:(BOOL)val
{
	militaryTime = val;
	
	if (militaryTime)
	{
		dateFormatter.dateFormat = @"HH:mm:ss";
	}
	else
	{
		dateFormatter.dateFormat = @"hh:mm:ss";
	}

}

/*
 *	Uses the NSDateFormatter class to convert the given NSDate object into
 *	a formatted string. Also figures out if the am/pm symbol should be shown
 *	given the hour and if military time is used.
 */
- (void) setTimeWithDate:(NSDate *)date
{
	txtTime.text = [dateFormatter stringFromDate:date];

	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:date];

	BOOL isPM = components.hour >= 12;

	txtAM.alpha = MARK_HIDE_ALPHA;
	txtPM.alpha = MARK_HIDE_ALPHA;

	if (militaryTime == NO)
	{
		(isPM ? txtPM : txtAM).alpha = MARK_SHOW_ALPHA;
	}
}

/*
 *	Constructs a color in the HSV color space with the given hue value and the
 *	default saturation and value components. The HSV value is then converted to
 *	the RGB color space and is passed to Pixelwave. Pixelwave only understands
 *	and operates in the RGB color space.
 */
- (void) setHue:(float)hue
{
	float color[3];
	HSVToRGB(hue, 1.0f, 1.0f, color);

	PXColorTransform *ct = self.transform.colorTransform;

	ct.redMultiplier   = color[0];
	ct.greenMultiplier = color[1];
	ct.blueMultiplier  = color[2];

	self.transform.colorTransform = ct;
}

@end
