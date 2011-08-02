//
//  PXEnginePrivate.m
//  Pixelwave
//
//  Created by John Lattin on 8/2/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#include "PXEnginePrivate.h"

PXStage *pxEngineStage = nil;							//Strongly referenced
PXDisplayObject *pxEngineRoot = nil;					//Weakly referenced
PXView *pxEngineView = nil;								//Weakly referenced

_PXEngineDisplayObjectBuffer pxEngineDOBuffer;
PXDisplayObject **pxEngineDOBufferCurrentObject = NULL;

unsigned pxEngineDOBufferMaxSize = 0;
unsigned pxEngineDOBufferOldMaxSize = 0;
