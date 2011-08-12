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

#import "PXSoundTransform3D.h"
#import "PXSoundEngine.h"

/**
 * Represents the volume, pitch, position, velocity
 * and distance formula for a 3D-ready #PXSoundChannel.
 *
 * The following code creates a sound transform with 120% volume and 80%
 * pitch:
 *	PXSoundTransform3D *transform = [[PXSoundTransform3D alloc] initWithVolume:1.2f pitch:0.8f];
 *	// Volume will be 120% and pitch will be 80%, position[0,0,0] and
 *	// velocity[0,0,0], reference distance and logarithmic exponent is set to
 *	// the defaults described in sound listener.  To access the sound listener
 *	// use [PXSoundMixer soundListener].
 *
 * @see PXSoundChannel, PXSoundMixer, PXSoundListener
 */
@implementation PXSoundTransform3D

@synthesize x, y, z;

@synthesize velocityX, velocityY, velocityZ;

@synthesize referenceDistance;
@synthesize logarithmicExponent;

- (id) init
{
	return [self initWithVolume:1.0f pitch:1.0f];
}

/**
 * Creates a new 3D sound transform with the given `volume` and
 * `pitch`.
 *
 * @param volume The amplitude of the sound.
 * @param pitch The frequency of the sound.
 *
 * **Example:**
 *	PXSoundTransform3D *transform = [[PXSoundTransform3D alloc] initWithVolume:1.2f pitch:0.8f];
 *	// Volume will be 120% and pitch will be 80%, position[0,0,0] and
 *	// velocity[0,0,0], reference distance and logarithmic exponent is set to
 *	// the defaults described in sound listener. To access the sound listener
 *	// use [PXSoundMixer soundListener].
 *
 * @see PXSoundChannel, PXSoundMixer, PXSoundListener
 */
- (id) initWithVolume:(float)_volume pitch:(float)_pitch
{
	self = [super initWithVolume:_volume pitch:_pitch];

	if (self)
	{
		[self setX:0.0f y:0.0f z:0.0f];
		[self setVelocityX:0.0f y:0.0f z:0.0f];

		self.referenceDistance = PXSoundEngineGetDefaultReferenceDistance();
		self.logarithmicExponent = PXSoundEngineGetDefaultLogarithmicExponent();
	}

	return self;
}

#pragma mark NSObject overrides

- (id) copyWithZone:(NSZone *)zone
{
	PXSoundTransform3D *copy = [[[self class] allocWithZone:zone] initWithVolume:volume pitch:pitch];

	copy.x = x;
	copy.y = y;
	copy.z = z;

	copy.velocityX = velocityX;
	copy.velocityY = velocityY;
	copy.velocityZ = velocityZ;

	copy.referenceDistance  = referenceDistance;
	copy.logarithmicExponent = logarithmicExponent;

	return copy;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(volume=%f, pitch=%f, x=%f, y=%f, z=%f, vx=%f, vy=%f, vz=%f, referenceDistance=%f, logarithmicExponent=%f)",
			volume,
			pitch,
			x, y, z,
			velocityX, velocityY, velocityZ,
			referenceDistance,
			logarithmicExponent];
}

#pragma mark Pooled Reset

- (void) reset
{
	[super reset];

	[self setX:0.0f y:0.0f z:0.0f];
	[self setVelocityX:0.0f y:0.0f z:0.0f];

	self.referenceDistance = PXSoundEngineGetDefaultReferenceDistance();
	self.logarithmicExponent = PXSoundEngineGetDefaultLogarithmicExponent();
}

#pragma mark -
#pragma mark Properties

- (void) setReferenceDistance:(float)_referenceDistance
{
	referenceDistance = fabsf(_referenceDistance);
}

- (void) setLogarithmicExponent:(float)_logarithmicExponent
{
	logarithmicExponent = fabsf(_logarithmicExponent);
}

#pragma mark -
#pragma mark Methods

/**
 * Sets the position to (x, y, z).
 *
 * @param x The horizontal coordinate.
 * @param y The vertical coordinate.
 * @param z The depth coordinate.
 *
 * **Example:**
 *	PXSoundTransform3D *transform = [PXSoundTransform3D new];
 *	// transform will have a volume of 1.0f and pitch of 1.0f
 *	[transform setX:5.0f y:7.0f z:0.0f];
 *	// transform's position will now be (5.0f, 7.0f, 0.0f)
 */
- (void) setX:(float)_x y:(float)_y z:(float)_z
{
	x = _x;
	y = _y;
	z = _z;
}
/**
 * Sets the velocity to (x, y, z).
 *
 * @param x The horizontal coordinate change per second.
 * @param y The vertical coordinate change per second.
 * @param z The depth coordinate change per second.
 *
 * **Example:**
 *	PXSoundTransform3D *transform = [PXSoundTransform3D new];
 *	// transform will have a volume of 1.0f and pitch of 1.0f
 *	[transform setVelocityX:-10.0f y:4.1f z:0.0f];
 *	// transform's velocity will now be (-10.0f, 4.1f, 0.0f)
 */
- (void) setVelocityX:(float)_x y:(float)_y z:(float)_z
{
	velocityX = _x;
	velocityY = _y;
	velocityZ = _z;
}

#pragma mark -
#pragma mark Static Methods

/**
 * Creates a 3D sound transform with the given `volume` and
 * `pitch`.
 *
 * @param volume The amplitude of the sound.
 * @param pitch The frequency of the sound.
 *
 * @return The created sound transform.
 *
 * **Example:**
 *	PXSoundTransform3D *transform = [PXSoundTransform3D soundTransformWithVolume:1.2f pitch:0.8f];
 *	// Volume will be 120% and pitch will be 80%, position[0,0,0] and
 *	// velocity[0,0,0], reference distance and logarithmic exponent is set to
 *	// the defaults described in sound listener.  To access the sound listener
 *	// use [PXSoundMixer soundListener].
 *
 * @see PXSoundChannel, PXSoundMixer, PXSoundListener
 */
+ (PXSoundTransform3D *)soundTransform3DWithVolume:(float)volume pitch:(float)pitch
{
	return [[[PXSoundTransform3D alloc] initWithVolume:volume pitch:pitch] autorelease];
}

@end
