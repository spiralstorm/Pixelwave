//
//  PXTouchEngine.h
//  Pixelwave
//
//  Created by John Lattin on 8/2/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#ifndef PX_TOUCH_ENGINE_H
#define PX_TOUCH_ENGINE_H

#ifdef __cplusplus
extern "C" {
#endif

#include <CoreGraphics/CGGeometry.h>

@class PXLinkedList;
@class UITouch;
@protocol PXEventDispatcherProtocol;
	
void PXTouchEngineInit();
void PXTouchEngineDealloc();

void PXTouchEngineRemoveAllTouchCapturesFromObject(id<PXEventDispatcherProtocol> capturingObject);
void PXTouchEngineSetTouchCapturingObject(UITouch *nativeTouch, id<PXEventDispatcherProtocol> capturingObject);	
id<PXEventDispatcherProtocol> PXTouchEngineGetTouchCapturingObject(UITouch *nativeTouch);

UITouch *PXTouchEngineGetFirstTouch();
PXLinkedList *PXTouchEngineGetAllTouches();
CGPoint PXTouchEngineTouchToScreenCoordinates(UITouch *touch);

void PXTouchEngineInvokeTouch(UITouch *touch, CGPoint *pos, NSString *type);

void PXTouchEngineInvokeTouchDown(UITouch *touch, CGPoint *pos);
void PXTouchEngineInvokeTouchMove(UITouch *touch, CGPoint *pos);
void PXTouchEngineInvokeTouchUp(UITouch *touch, CGPoint *pos);
void PXTouchEngineInvokeTouchCancel(UITouch *touch, CGPoint *pos);

#ifdef __cplusplus
}
#endif

#endif
