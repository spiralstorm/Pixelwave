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

#import "PXSoundListener.h"

#import "PXVector3D.h"
#import "PXMath.h"
#include "PXMathUtils.h"
#import "PXAL.h"
#import "PXEngine.h"
#import "PXSoundEngine.h"

#import "PXSoundTransform3D.h"

/**
 * Represents a listener in a three-dimensional
 * coordinate system.  A listener's orientation is defined by two vectors; the
 * forward-vector and the up-vector.  These vectors can quickly be set by using
 * the `setRotation:using2DPerspective:` method.
 *
 *
 *	            |
 *	            |  _ +z
 *	            |  /|
 *	            | /
 *	            |/
 *	------------*-----------> +x
 *	           /|
 *	          / |
 *	         /  |
 *	            |
 *	            V
 *	           +y
 * 
 */
@implementation PXSoundListener

// A 3D line is used because when I hand off the coordinates to openAL, it takes
// it in the form of a 6 value floating point array.  A 3D line consists of two
// three value floating points, for a total of 6.  The first of the two points
// is used for the forward-vector, and the second is for the up-vector.  These
// two vectors make up the orientation.
PXMathLine3D pxSoundListenerOrientation;

BOOL pxSoundListenerInitialized = NO;

- (id) init
{
	// Can only initialize once; it is the sound engine's job to initialize, not
	// the users.
	if (pxSoundListenerInitialized)
	{
		[self release];
		return nil;
	}

	self = [super init];

	if (self)
	{
		pxSoundListenerInitialized = YES;
		pxSoundListenerOrientation = PXMathLine3DMake(0.0f, 0.0f, -1.0f,
													  0.0f, 1.0f,  0.0f);

		// Set the listener to face into the screen
		[self setRotation:-90.0f using2DPerspective:PXSoundListener2DPerspective_SideView];

		// The listener is in 3-space, so it needs a 3-space transform.
		transform = [[PXSoundTransform3D alloc] init];

		// Initialize it's position and velocity
		[self setPositionWithX:0.0f y:0.0f z:0.0f];
		[self setVelocityWithX:0.0f y:0.0f z:0.0f];

		// Set the default distance reference 
		self.defaultReferenceDistance = 64.0f;
		self.defaultLogarithmicExponent = 2.0f;
	}

	return self;
}

- (void) dealloc
{
	[transform release];

	[super dealloc];
}

#pragma mark -
#pragma mark Properties

- (void) setTransform:(PXSoundTransform3D *)_transform
{
	if (!_transform)
		return;

	[self setPositionWithX:_transform.x y:_transform.y z:_transform.z];
	[self setVelocityWithX:_transform.velocityX y:_transform.velocityY z:_transform.velocityZ];

	self.defaultReferenceDistance = _transform.referenceDistance;
	self.defaultLogarithmicExponent = _transform.logarithmicExponent;
}

- (PXSoundTransform3D *)transform
{
	return [[transform copy] autorelease];
}

- (void) setForward:(PXVector3D *)forward
{
	// Have to negate the y and z to convert from al coordinates to pixelwave
	// coordinates.
	PXMathPoint3DSet(&(pxSoundListenerOrientation.pointA), forward.x, -forward.y, -forward.z);

//	PXDebugALBeginErrorChecks(@"setForward");

	alListenerfv(AL_ORIENTATION, &(pxSoundListenerOrientation.pointA.x));

//	PXDebugALErrorCheck(@"alListenerfv");
//	PXDebugALEndErrorChecks();
}

- (PXVector3D *)forward
{
	// Have to negate the y and z to convert from al coordinates to pixelwave
	// coordinates.
	return [PXVector3D vector3DWithX: pxSoundListenerOrientation.pointA.x
								y:-pxSoundListenerOrientation.pointA.y
								z:-pxSoundListenerOrientation.pointA.z];
}

- (void) setUp:(PXVector3D *)up
{
	// Have to negate the y and z to convert from al coordinates to pixelwave
	// coordinates.
	PXMathPoint3DSet(&(pxSoundListenerOrientation.pointB), up.x, -up.y, -up.z);

//	PXDebugALBeginErrorChecks(@"setUp");

	alListenerfv(AL_ORIENTATION, &(pxSoundListenerOrientation.pointA.x));

//	PXDebugALErrorCheck(@"alListenerfv");
//	PXDebugALEndErrorChecks();
}

- (PXVector3D *)up
{
	// Have to negate the y and z to convert from al coordinates to pixelwave
	// coordinates.
	return [PXVector3D vector3DWithX: pxSoundListenerOrientation.pointB.x
								y:-pxSoundListenerOrientation.pointB.y
								z:-pxSoundListenerOrientation.pointB.z];
}

- (void) setX:(float)val
{
	[self setPositionWithX:val y:transform.y z:transform.z];
}
- (void) setY:(float)val
{
	[self setPositionWithX:transform.x y:val z:transform.z];
}
- (void) setZ:(float)val
{
	[self setPositionWithX:transform.x y:transform.y z:val];
}

- (float) x
{
	return transform.x;
}
- (float) y
{
	return transform.y;
}
- (float) z
{
	return transform.z;
}

- (void) setVelocityX:(float)val
{
	[self setVelocityWithX:val y:transform.velocityY z:transform.velocityZ];
}
- (void) setVelocityY:(float)val
{
	[self setVelocityWithX:transform.velocityX y:val z:transform.velocityZ];
}
- (void) setVelocityZ:(float)val
{
	[self setVelocityWithX:transform.velocityX y:transform.velocityY z:val];
}

- (float) velocityX
{
	return transform.velocityX;
}
- (float) velocityY
{
	return transform.velocityY;
}
- (float) velocityZ
{
	return transform.velocityZ;
}

- (void) setDefaultReferenceDistance:(float)referenceDistance
{
	transform.referenceDistance  = referenceDistance;
}
- (float) defaultReferenceDistance
{
	return transform.referenceDistance;
}

- (void) setDefaultLogarithmicExponent:(float)logarithmicExponent
{
	transform.logarithmicExponent = logarithmicExponent;
	
}
- (float) defaultLogarithmicExponent
{
	return transform.logarithmicExponent;
}

#pragma mark -
#pragma mark Methods
/**
 * Changes the forward and up vectors to match the perspective at the given
 * angle.
 *
 * @param rotation The angle in degrees of rotation.
 * @param perspective The perspective of rotation.
 *
 * **Example:**
 *	[[PXSoundMixer soundListener] setRotation:-90.0f using2DPerspective:PXSoundListener2DPerspective_SideView];
 *	// forward[0,0,-1], up[0,1,0]
 */
- (void) setRotation:(float)rotation using2DPerspective:(PXSoundListener2DPerspective)perspective
{
	float angleInRadians = PXMathToRad(rotation);
	float cs = cosf(angleInRadians);
	float sn = sinf(angleInRadians);

	switch(perspective)
	{
		case PXSoundListener2DPerspective_TopDown:
			//  0 degrees - forward[1, 0,0], up[0,0,1]
			// 90 degrees - forward[0,-1,0], up[0,0,1]
			pxSoundListenerOrientation = PXMathLine3DMake(cs,  -sn, 0.0f,
														  0.0f, 0.0f, 1.0f);
			break;
		case PXSoundListener2DPerspective_SideView:
			//  0 degrees - forward[1,0, 0], up[0,-1,0]
			// 90 degrees - forward[0,0,-1], up[0,-1,0]
			pxSoundListenerOrientation = PXMathLine3DMake(cs,    0.0f,  -sn,
														  0.0f, -1.0f, 0.0f);
			break;
		default:
			break;
	}

//	PXDebugALBeginErrorChecks(@"setRotation");

	alListenerfv(AL_ORIENTATION, &(pxSoundListenerOrientation.pointA.x));

//	PXDebugALErrorCheck(@"alListenerfv");
//	PXDebugALEndErrorChecks();
}

/**
 * Sets the position of the listener.
 *
 * @param x The x-position in 3 space.
 * @param y The y-position in 3 space.
 * @param z The z-position in 3 space.
 *
 * **Example:**
 *	[[PXSoundMixer soundListener] setPositionWithX:240.0f y:160.0f z:0.0f];
 *	// Set's the position of the listener to [240.0f, 160.0f, 0.0f];
 */
- (void) setPositionWithX:(float)x y:(float)y z:(float)z
{
	transform.x = x;
	transform.y = y;
	transform.z = z;

//	PXDebugALBeginErrorChecks(@"setPositionWithX");

	alListener3f(AL_POSITION, x, -transform.y, -transform.z);

//	PXDebugALErrorCheck(@"alListener3f");
//	PXDebugALEndErrorChecks();
}

/**
 * Sets the velocity of the listener.
 *
 * @param x The x-velocity in 3 space.
 * @param y The y-velocity in 3 space.
 * @param z The z-velocity in 3 space.
 *
 * **Example:**
 *	[[PXSoundMixer soundListener] setVelocityWithX:10.0f y:-5.0f z:0.0f];
 *	// Set's the velocity of the listener to [10.0f, -5.0f, 0.0f];
 */
- (void) setVelocityWithX:(float)x y:(float)y z:(float)z
{
	transform.velocityX = x;
	transform.velocityY = y;
	transform.velocityZ = z;

//	PXDebugALBeginErrorChecks(@"setVelocityWithX");

	alListener3f(AL_VELOCITY, transform.velocityX, -transform.velocityY, -transform.velocityZ);

//	PXDebugALErrorCheck(@"alListener3f");
//	PXDebugALEndErrorChecks();
}

- (void) _setVolume:(float)volume
{
//	PXDebugALBeginErrorChecks(@"_setVolume");

	alListenerf(AL_GAIN, volume);

//	PXDebugALErrorCheck(@"alListenerf");
//	PXDebugALEndErrorChecks();
}

@end
