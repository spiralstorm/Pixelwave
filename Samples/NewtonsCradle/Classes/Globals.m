//
//  Globals.m
//  NewtonsCradle
//
//  Created by Oz Michaeli on 7/31/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "Globals.h"

BOOL isIPad = NO;
float myContentScale = 1.0f;

void initGlobals()
{
	// Check if we're on an iPad.
	// This variable is used later to see which images we need to load
	// and how we should scale our movemement values
	
#ifdef UI_USER_INTERFACE_IDIOM
	isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif

	if(isIPad){
		myContentScale = 2.0f;
	}else{
		myContentScale = 1.0f;
	}
}