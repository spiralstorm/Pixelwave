//
//  Globals.h
//  NewtonsCradle
//
//  Created by Oz Michaeli on 7/31/11.
//  Copyright 2011 NA. All rights reserved.
//

#ifndef _GLOBALS_H_
#define _GLOBALS_H_

// This extern decleration is important so that
// out cpp code (NewtonsCradleRoot.mm) can use
// this header file.
#ifdef __cplusplus
extern "C" {
#endif

extern BOOL isIPad;
extern float myContentScale;

void initGlobals();

#ifdef __cplusplus
}
#endif
	
#endif