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

@class PKParticle;
@class PKParticleEmitter;

/**
 * An action is responsible for updating a particle from right after it has been
 * created and initialized, until it is destroyed.
 *
 * A single action is supposed to encapsulate a behavior exhibited by particles
 * as they frolic around in the world. A list of actions is maintained by each
 * #PKParticleEmitter which collectively define the behavior of the emitter's
 * particles.
 *
 * For example, the #PKMoveAction takes care of moving all the particles forward
 * in time according to their velocity. The #PKAgeAction causes each particle to
 * age which means it'll be destroyed when it surpasses its `lifetime`. The fade
 * action updates the `alpha` of the particles according to their age. All of
 * these actions combined create a specific particle effect. By using the
 * available actions, and implementing the #PKParticleAction protocol to create
 * your own, you can create any effect you can think of!
 *
 * To add an action to an emitter use the [PKParticleEmitter addAction:] method.
 * Actions are performed by the emitter in the order by which they were added.
 * The same action can safely exist in multiple emitters.
 *
 * Actions can be added and removed from an emitter at any time.
 */
@protocol PKParticleAction <PKParticleBehavior>
@required
- (void) updateParticle:(PKParticle *)particle emitter:(PKParticleEmitter *)emitter deltaTime:(float)dt;
@end
