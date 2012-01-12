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

#import "PKParticleBehavior.h"

@class PKParticleEmitter;
@class PKParticle;

/**
 * A particle initializer is in charge of setting the attributes of a
 * #PXparticle when one is created by an emitter and unsetting the attributes
 * when the particle is destroyed.
 *
 * A single initializer usually encapsulates a single initialization action such
 * as setting a particle's position, or it's starting color. A list of
 * initializers is kept within each #PKParticleEmitter and collectively defines
 * the initial state of each particle.
 *
 * To add an initializer to an emitter use the [PKParticleEmitter addInitializer:]
 * method. Initializers are performed by the emitter in the order by which they
 * were added. The same initializer can safely exist in multiple emitters.
 *
 * Initializers can only be added and removed from an emitter when it contains
 * no living particles.
 */
@protocol PKParticleInitializer <PKParticleBehavior>
@required
- (void) initializeParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter;
- (void) disposeParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter;
@end
