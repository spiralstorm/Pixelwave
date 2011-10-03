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

#ifndef _PARTICLE_ENGINE_H_
#define _PARTICLE_ENGINE_H_

// Core

#import "PKParticle.h"
#import "PKParticleEmitter.h"
#import "PKParticleEffect.h"

// Particles

#import "PKParticleCreator.h"

// Flows

#import "PKSteadyFlow.h"
#import "PKBlastFlow.h"
#import "PKTimePeriodFlow.h"
#import "PKPulseFlow.h"

// Initializers

#import "PKSharedGraphicInitializer.h"
#import "PKGraphicInstanceInitializer.h"
#import "PKLifetimeInitializer.h"
#import "PKPositionInitializer.h"
#import "PKVelocityInitializer.h"
#import "PKColorInitializer.h"
#import "PKAlphaInitializer.h"
#import "PKScaleInitializer.h"
#import "PKBlendInitializer.h"
#import "PKRotationInitializer.h"
#import "PKRotationalVelocityInitializer.h"

// Actions

#import "PKMoveAction.h"
#import "PKAgeAction.h"
#import "PKAccelerateAction.h"
#import "PKFadeAction.h"
#import "PKColorChangeAction.h"
#import "PKScaleAction.h"
#import "PKSpeedLimitAction.h"
#import "PKRotateToDirectionAction.h"
#import "PKRotateAction.h"
#import "PKDestroyAction.h"
#import "PKLinearDragAction.h"
#import "PKRandomDriftAction.h"

// Renderers

#import "PKDisplayObjectRenderer.h"
#import "PKPointRenderer.h"
#import "PKQuadRenderer.h"
#import "PKSharedDisplayObjectRenderer.h"
#import "PKRenderToTextureRenderer.h"
#import "PKLineRenderer.h"

// Loaders

#import "PKParticleEffectLoader.h"

// Particle designer

#import "PKDesignerParticle.h"
#import "PKDesignerFlow.h"
#import "PKDesignerInitializer.h"
#import "PKDesignerAction.h"

// Utils

#import "PKRange.h"

#import "PKMultiZone.h"
#import "PKPointZone.h"
#import "PKRectangleZone.h"
#import "PKDiscZone.h"
#import "PKDiscSectorZone.h"
#import "PKElipticalDiscZone.h"
#import "PKLineZone.h"
#import "PKDisplayObjectZone.h"

#endif
