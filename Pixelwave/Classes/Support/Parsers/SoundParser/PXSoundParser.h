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

#import "PXParser.h"

#import "PXParsedSoundData.h"

@class PXSound;
@protocol PXSoundModifier;

@interface PXSoundParser : PXParser
{
@protected
	id<PXSoundModifier> modifier;

	PXParsedSoundData *soundInfo;
	PXParsedSoundData *modifiedSoundInfo;
}

/**
 * A modifier is used to modify the loaded bytes, a backup is kept so can set
 * this to `nil` after getting a new sound, and still have your
 * previously loaded data.
 *
 * **Default:** `nil`
 */
@property (nonatomic, retain) id<PXSoundModifier> modifier;
/**
 * Returns `YES` if the sound data is modifiable, otherwise
 * `NO` is returned.
 */
@property (nonatomic, readonly) BOOL isModifiable;

//-- ScriptName: SoundParser
//-- ScriptArg[0]: required
//-- ScriptArg[1]: nil
//-- ScriptArg[2]: nil
- (id) initWithData:(NSData *)data modifier:(id<PXSoundModifier>)modifier origin:(NSString *)origin;

//-- ScriptName: newSound
- (PXSound *)newSound;

@end

@interface PXSoundParser (PrivateButPublic)
- (id) _initWithData:(NSData *)data
		   modifier:(id<PXSoundModifier>)modifier
			  origin:(NSString *)origin;
@end
