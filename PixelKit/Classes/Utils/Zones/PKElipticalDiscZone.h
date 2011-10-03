//
//  PKDiscZone.h
//  PXParticles
//
//  Created by Spiralstorm Games on 9/12/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#import "PKZone.h"

@interface PKElipticalDiscZone : NSObject <PKZone>
{
@protected
	float x;
	float y;

	float innerWidth;
	float innerHeight;

	float outerWidth;
	float outerHeight;
}

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;

@property (nonatomic, assign) float innerWidth;
@property (nonatomic, assign) float innerHeight;

@property (nonatomic, assign) float outerWidth;
@property (nonatomic, assign) float outerHeight;

- (id) initWithX:(float)x y:(float)y innerWidth:(float)innerWidth innerHeight:(float)innerHeight outerWidth:(float)outerWidth outerHeight:(float)outerHeight;

+ (PKElipticalDiscZone *)ellipticalDiscZoneWithX:(float)x y:(float)y innerWidth:(float)innerWidth innerHeight:(float)innerHeight outerWidth:(float)outerWidth outerHeight:(float)outerHeight;

@end
