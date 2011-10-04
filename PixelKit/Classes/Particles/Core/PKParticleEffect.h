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

#import "Pixelwave.h"

@class PKParticleEmitter;

@protocol PKParticleInitializer;
@protocol PKParticleAction;
@protocol PKParticleRenderer;
@protocol PKParticleFactory;
@protocol PKParticleFlow;

@interface PKParticleEffect : NSObject
{
@protected
	id<PKParticleFactory> particleFactory;

	PXLinkedList *initializers;
	PXLinkedList *actions;
}

@property (nonatomic, retain) id<PKParticleFactory> particleFactory;

@property (nonatomic, readonly) PXLinkedList *initializers;
@property (nonatomic, readonly) PXLinkedList *actions;

- (id) initWithContentsOfFile:(NSString *)path;
- (id) initWithContentsOfURL:(NSURL *)url;
- (id) initWithData:(NSData *)data;

- (PKParticleEmitter *)newEmitter;
- (id<PKParticleRenderer>)newRenderer;

- (PKParticleEmitter *)emitter;
- (id<PKParticleRenderer>)renderer;

- (void) addInitializer:(id<PKParticleInitializer>)initializer;
- (void) addAction:(id<PKParticleAction>)action;

+ (PKParticleEffect *)particleEffectWithContentsOfFile:(NSString *)path;
+ (PKParticleEffect *)particleEffectWithContentsOfURL:(NSURL *)url;
+ (PKParticleEffect *)particleEffectWithData:(NSData *)data;

@end

@interface PKParticleEffect(Private)
- (PKParticleEmitter *)newEmptyEmitter;
- (id <PKParticleFlow>)newEmptyFlow;
@end
