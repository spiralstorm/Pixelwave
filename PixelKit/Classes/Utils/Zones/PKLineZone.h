//
//  PKLineZone.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/13/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKZone.h"

@interface PKLineZone : NSObject <PKZone>
{
@protected
	CGPoint start;
	CGPoint end;
}

@property (nonatomic, assign) CGPoint start;
@property (nonatomic, assign) CGPoint end;

- (id) initWithStart:(CGPoint)start end:(CGPoint)end;

+ (PKLineZone *)lineZoneWithStart:(CGPoint)startPoint end:(CGPoint)end;

@end
