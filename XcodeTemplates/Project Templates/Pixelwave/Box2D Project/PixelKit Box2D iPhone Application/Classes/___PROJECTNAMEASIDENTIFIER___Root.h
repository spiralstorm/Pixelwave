//
//  ___PROJECTNAMEASIDENTIFIER___Root.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "Pixelwave.h"
#import "Box2D.h"

#import "Box2DListeners.h"

@interface ___PROJECTNAMEASIDENTIFIER___Root : PXSprite
{
@private
	b2World *physicsWorld;
	float timeStep;
	int velocityIterations, positionIterations;

	// Listeners
	DestructionListener *destructionListener;
	ContactListener *contactListener;
}

- (void) initializeAsRoot;

@end
