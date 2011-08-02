//
//  PXTouchEngine.m
//  Pixelwave
//
//  Created by John Lattin on 8/2/11.
//  Copyright 2011 Spiralstorm Games. All rights reserved.
//

#include "PXTouchEngine.h"

#include "PXEngine.h"
#include "PXEnginePrivate.h"

#pragma mark -
#pragma mark Variables
#pragma mark -

PXLinkedList *pxTouchEngineTouchEvents = nil;					//Strongly referenced
PXLinkedList *pxTouchEngineRemoveFromSavedTouchEvents = nil;	//Strongly referenced
PXLinkedList *pxTouchEngineRemoveFromCaptureTouchEvents = nil;	//Strongly referenced

// A dictionary which holds the associations between a UITouch and the object
// which captured it.
CFMutableDictionaryRef pxEngineTouchCapturingObjects = NULL;

#pragma mark -
#pragma mark Functions
#pragma mark -

PXTouchEvent *PXTouchEngineNewTouchEventWithTouch(UITouch *touch, CGPoint *pos, NSString *type, BOOL orientTouch);
void PXTouchEngineCancelTouch(UITouch *touch);
bool PXTouchEngineGetTouchDisplayHierarchy(PXDisplayObject *object, PXLinkedList *addList);

void _PXTouchEngineRemoveAllTouchCapturesFromObjects(PXLinkedList *objects);

void PXTouchEngineAddEvent(UITouch *touch, CGPoint *pos, NSString *type);

#pragma mark -
#pragma mark Implementations
#pragma mark -

void PXTouchEngineInit()
{
	pxEngineTouchCapturingObjects = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

	pxTouchEngineTouchEvents = [[PXLinkedList alloc] init];
	pxTouchEngineRemoveFromSavedTouchEvents = [[PXLinkedList alloc] init];
	pxTouchEngineRemoveFromCaptureTouchEvents = [[PXLinkedList alloc] init];
}

void PXTouchEngineDealloc()
{
	[pxTouchEngineRemoveFromSavedTouchEvents release];
	pxTouchEngineRemoveFromSavedTouchEvents = nil;
	[pxTouchEngineRemoveFromCaptureTouchEvents release];
	pxTouchEngineRemoveFromCaptureTouchEvents = nil;

	[pxTouchEngineTouchEvents release];
	pxTouchEngineTouchEvents = nil;

	CFRelease(pxEngineTouchCapturingObjects);
	pxEngineTouchCapturingObjects = NULL;
}

/**
 *	The function first cycles through all the display objects on the screen in
 *	reverse order, looking for the most immediate target of a touch event, and
 *	then traverses up the display hierarchy until it finds an interactive object
 *	for which touches are enabled.
 *		- Beken, Pixelwave forums
 *
 *	Returns the displayObject that should recieve the event (could be nil)
 */
PXDisplayObject *PXTouchEngineFindTouchTarget(float x, float y)
{
	PXDisplayObject *target;
	PXDisplayObjectContainer *parent;
	PXDisplayObject *possibleParentTarget = nil;
	PXGLAABB *aabb;

	bool touchEnabled = false;
	// Keeps track of if the current target can recieve touch events
	bool origTouchEnabled = false;
	bool parentTouchEnabled = false;
	bool onceHadTarget = false;

	bool usesCustomHitArea;

	PXDisplayObject **curDisplayObject;

	// Signed due to reverse traversal
	int index;
	int startIndex = pxEngineDOBuffer.size - 1;

	// Loop through the list of possible touch targets.
	// Since items were added to the list in back-to-front order, we iterate
	// backwards to go front-to-back.
	for (index = startIndex, curDisplayObject = &(pxEngineDOBuffer.array[startIndex]);
		 index >= 0;
		 --index, --curDisplayObject)
	{
		target = *curDisplayObject;

		aabb = &target->_aabb;

		usesCustomHitArea = PX_IS_BIT_ENABLED(target->_flags, _PXDisplayObjectFlags_useCustomHitArea);

		// Broad phase hit-test (AABB)
		// We only check for AABB containment if the disp doesn't have a custom
		// hit area. If there is a custom hit area, we can't rely only on the 
		// visual bounds for a hit test.
		if (!usesCustomHitArea && !PXGLAABBContainsPointv(aabb, x, y))
		{
			continue;
		}

		// Only touch objects that are still on the stage
		if (target.stage == nil)
		{
			continue;
		}

		// Narrow phase - This is the expensive one.
		if (!([target _hitTestPointWithoutRecursionWithGlobalX:x globalY:y shapeFlag:YES]))
		{
			continue;
		}

		origTouchEnabled = PX_IS_BIT_ENABLED(target->_flags, _PXDisplayObjectFlags_isInteractive) ? ((PXInteractiveObject *)(target))->_touchEnabled : NO;
		touchEnabled = origTouchEnabled;

		parent = (PXDisplayObjectContainer *)(target->_parent);
		onceHadTarget = NO;

		// This checks if the parent is root, and it has touches enabled, but
		// not touch children. If true, then
		if (parent)
		{
			parentTouchEnabled = parent->_touchEnabled;

			if (!(parent->_touchChildren) && parent == pxEngineRoot && parentTouchEnabled)
			{
				onceHadTarget = YES;
				possibleParentTarget = parent;
			}
		}

		// Now we loop up through the target's ancestors, stoping right before
		// the root. We do this so that the ancestor closest to target which can
		// recieve touch events gets to handle the touch.
		//
		// We stop short before root because....
		while (parent && parent != pxEngineRoot)
		{
			if (parent == possibleParentTarget)
			{
				onceHadTarget = YES;
			}

			parentTouchEnabled = parent->_touchEnabled;

			// If the parent allows its chidren to recieve touch events
			if (parent->_touchChildren)
			{
				// If the target can't recieve touch events, but the parent can,
				// the parent becomes the current valid target, and we keep
				// going up the chain
				if (!touchEnabled && parentTouchEnabled)
				{
					possibleParentTarget = parent;
					onceHadTarget = YES;
					touchEnabled = parentTouchEnabled;
				}
			}
			else
			{
				// The target's parent doesn't allow touch events, which means
				// the target cannot be asociated with that event at all, make
				// the parent the new target
				target = parent;
				possibleParentTarget = nil;
				onceHadTarget = NO;

				// Update these value to reflect the new target
				touchEnabled = parentTouchEnabled;
				origTouchEnabled = parentTouchEnabled;
			}

			parent = parent->_parent;
		}

		// If along the traversal we found a target willing to accept the event
		// but the parent should recieve it, give it to the parent
		if (onceHadTarget && possibleParentTarget)
		{
			return possibleParentTarget;
		}

		// If there's no ancesstor of target stopping it from recieving the
		// event, let target have it.
		if (origTouchEnabled)
		{
			return target;
		}
	}

	if (possibleParentTarget != nil)
		PXDebugLog (@"PXEngineFindTouchTarget WARNING: possibleParentTarget != nil as expected\n");

	// TODO: John, check to see if this line can just return nil.
	// Look through the code and try to proove it won't fail
	return possibleParentTarget;
}

void PXTouchEngineDispatchTouchEvents()
{
	if (pxTouchEngineTouchEvents.count == 0)
	{
		return;
	}

	PXTouchEvent *event = nil;
	PXDisplayObject *target = pxEngineStage;

	NSString *eventType = nil;

	bool didTouchUp     = false;
	bool didTouchCancel = false;
	bool didTouchDown   = false;
	bool didTouchUpOrCancel = false;

	id<NSObject> captureKey = NULL;
	id<PXEventDispatcherProtocol> captureTarget = NULL;

	if (pxEngineStage->_touchChildren)
	{
		PXLinkedListForEach(pxTouchEngineTouchEvents, event)
		{
			eventType = event.type;

			// Find what type of touch even this is
			didTouchDown = [eventType isEqualToString:PXTouchEvent_TouchDown];
			if (!didTouchDown)
			{
				didTouchUp = [eventType isEqualToString:PXTouchEvent_TouchUp];
				if (!didTouchUp)
				{
					didTouchCancel = [eventType isEqualToString:PXTouchEvent_TouchCancel];
				}
			}

			didTouchUpOrCancel = didTouchUp || didTouchCancel;

			// Grab the 'key' for the dictionary of captures, and the target
			captureKey = event.nativeTouch;
			captureTarget = (id<PXEventDispatcherProtocol>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, captureKey);

			// If a capture target exists, then we don't need to find a new one
			if (captureTarget)
			{
				target = (PXDisplayObject *)captureTarget;
			}
			else
			{
				// Find the target at the position
				target = PXTouchEngineFindTouchTarget(event->_stageX, event->_stageY);

				// If it is a down event, then we can set the capture
				if (didTouchDown && target && PX_IS_BIT_ENABLED(target->_flags, _PXDisplayObjectFlags_isInteractive))
				{
					// Only set the capture, if this target allows it.
					if (((PXInteractiveObject *)(target))->_captureTouches)
					{
						CFDictionarySetValue(pxEngineTouchCapturingObjects, captureKey, target);
					}
				}
			}

			// If the target exists and is not equal to the captured target,
			// then we need to check if it is a target that cares about captures
			// and it failed the on touch down, it means that the target was not
			// captured in touch down, thus it should not recieve these events.
			if (!didTouchDown && target && target != captureTarget)
			{
				if (PX_IS_BIT_ENABLED(target->_flags, _PXDisplayObjectFlags_isInteractive))
				{
					if (((PXInteractiveObject *)(target)).captureTouches)
					{
						target = NULL;
					}
				}
			}

			// If no target exists, send it to the stage!
			if (!target)
				target = pxEngineStage;

			if (didTouchUpOrCancel)
				CFDictionaryRemoveValue(pxEngineTouchCapturingObjects, captureKey);

			event->_target = target;
			[target dispatchEvent:event];
		} // PXLinkedListForEach
	}
	else
	{
		PXLinkedListForEach(pxTouchEngineTouchEvents, event)
		{
			captureKey = event.nativeTouch;
			captureTarget = (id<PXEventDispatcherProtocol>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, captureKey);

			if (captureTarget)
			{
				PXTouchEngineCancelTouch(captureKey);
			}

			event->_target = target;
			[target dispatchEvent:event];
		}
	}

	[pxTouchEngineTouchEvents removeAllObjects];
}

#pragma mark -

void PXTouchEngineCancelTouch(UITouch *touch)
{
	id<PXEventDispatcherProtocol> object = (id<PXEventDispatcherProtocol>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, touch);

	if (!object)
		return;

	CFDictionaryRemoveValue(pxEngineTouchCapturingObjects, touch);

	// Find the position of the touch on the stage.
	PXPoint *pxPoint = [pxEngineStage positionOfTouch:touch];
	CGPoint point = CGPointMake(pxPoint.x, pxPoint.y);

	PXTouchEvent *event = PXTouchEngineNewTouchEventWithTouch(touch, &point, PXTouchEvent_TouchCancel, NO);
	[object dispatchEvent:event];
	[event release];
}

bool PXTouchEngineGetTouchDisplayHierarchy(PXDisplayObject *object, PXLinkedList *addList)
{
	CFIndex count = CFDictionaryGetCount(pxEngineTouchCapturingObjects);

	if (count <= 0 || [addList count] == count)
		return false;

	if (CFDictionaryContainsValue(pxEngineTouchCapturingObjects, object))
	{
		[addList addObject:object];
	}

	if (PX_IS_BIT_ENABLED(object->_flags, _PXDisplayObjectFlags_isContainer))
	{
		PXDisplayObjectContainer *container = (PXDisplayObjectContainer *)object;

		unsigned index;
		PXDisplayObject *child;

		for (index = 0, child = container->_childrenHead; index < container->_numChildren; ++index, child = child->_next)
		{
			if (!PXTouchEngineGetTouchDisplayHierarchy(child, addList))
				return false;
		}
	}

	return true;
}

#pragma mark -

void _PXTouchEngineRemoveAllTouchCapturesFromObjects(PXLinkedList *objects)
{
	// DO NOT CALL THIS FUNCTION IF THE CAPTURING OBJECT DOES NOT EXIST IN THE
	// LIST! This method is internal because it should only be used in that
	// fashion, it has no checks.

	CFIndex count = CFDictionaryGetCount(pxEngineTouchCapturingObjects);

	CFTypeRef keys[count];

	// Gives us a parallel array structure so that you can iterate through
	// the posabilities.
	CFDictionaryGetKeysAndValues(pxEngineTouchCapturingObjects, (const void **)(keys), NULL);

	CFIndex index;
	CFTypeRef *key;

	id<PXEventDispatcherProtocol> target;
	UITouch *touch;

	id<PXEventDispatcherProtocol> currentTarget;

	// Loop through the dictionary and see if the object has any association
	// with a touch; if it does, we need to cancel it.
	for (index = 0, key = keys; index < count; ++index, ++key)
	{
		// Grab the target EVERY TIME this way even if the dictionary changes
		// during this loop, we are only doing the most up to date interactions.
		target = (id<PXEventDispatcherProtocol>)(CFDictionaryGetValue(pxEngineTouchCapturingObjects, *key));

		// If no target exists, continue.
		if (!target)
			continue;

		touch = (UITouch *)(*key);

		for (currentTarget in objects)
		{
			if (currentTarget == target)
			{
				PXTouchEngineCancelTouch(touch);

				// You can not remove the current target from the list. It may
				// have more then one association that needs to get taken care
				// of, and the object will only appear once in the list.
				break;
			}
		}
	}
}

void PXTouchEngineRemoveAllTouchCapturesFromObject(id<PXEventDispatcherProtocol> capturingObject)
{
	CFIndex count = CFDictionaryGetCount(pxEngineTouchCapturingObjects);

	if (count <= 0)
		return;

	if ([capturingObject isKindOfClass:PXDisplayObject.class])
	{
		PXDisplayObject *displayObject = (PXDisplayObject *)capturingObject;

		PXLinkedList *displayHierarchy = [[PXLinkedList alloc] init];
		PXTouchEngineGetTouchDisplayHierarchy(displayObject, displayHierarchy);

		if ([displayHierarchy count] > 0)
		{
			_PXTouchEngineRemoveAllTouchCapturesFromObjects(displayHierarchy);
		}

		[displayHierarchy release];
	}
	else
	{
		if (!CFDictionaryContainsValue(pxEngineTouchCapturingObjects, capturingObject))
			return;

		PXLinkedList *list = [[PXLinkedList alloc] init];
		[list addObject:capturingObject];
		_PXTouchEngineRemoveAllTouchCapturesFromObjects(list);
		[list release];
	}
}

void PXTouchEngineSetTouchCapturingObject(UITouch *nativeTouch, id<PXEventDispatcherProtocol> capturingObject)
{
	if (!nativeTouch)
		return;

	id<PXEventDispatcherProtocol> originalObject = (id<PXEventDispatcherProtocol>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, nativeTouch);

	// Only do work if the object is actually changing
	if (originalObject != capturingObject)
	{
		// Send out a cancel event on the OLD object.
		PXTouchEngineCancelTouch(nativeTouch);

		// Change or remove the target
		if (capturingObject)
		{
			CFDictionarySetValue(pxEngineTouchCapturingObjects, nativeTouch, capturingObject);
		}
	}
}

id<PXEventDispatcherProtocol> PXTouchEngineGetTouchCapturingObject(UITouch *nativeTouch)
{
	if (!nativeTouch)
		return nil;
	
	return (id<PXEventDispatcherProtocol>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, nativeTouch);
}

UITouch *PXTouchEngineGetFirstTouch()
{
	if (!pxTouchEngineTouchEvents)
		return nil;

	if ([pxTouchEngineTouchEvents count] <= 0)
		return nil;

	PXTouchEvent *event = (PXTouchEvent *)[pxTouchEngineTouchEvents objectAtIndex:0];

	return event.nativeTouch;
}
PXLinkedList *PXTouchEngineGetAllTouches()
{
	if (!pxTouchEngineTouchEvents)
		return nil;

	PXLinkedList *list = [[PXLinkedList alloc] init];
	PXTouchEvent *event;

	for (event in pxTouchEngineTouchEvents)
	{
		if (event.nativeTouch)
			[list addObject:event.nativeTouch];
	}

	return [list autorelease];
}

CGPoint PXTouchEngineTouchToScreenCoordinates(UITouch *touch)
{
	if (!touch || !pxEngineView)
		return CGPointMake(0.0f, 0.0f);
	
	CGPoint point = [touch locationInView:pxEngineView];
	
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)[pxEngineView layer];
	CGPoint pos = eaglLayer.position;
	
	point.x += pos.x;
	point.y += pos.y;
	
	PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(point.x, point.y, pxEngineStage);
	
	return point;
}

PXTouchEvent *PXTouchEngineNewTouchEventWithTouch(UITouch *touch, CGPoint *pos, NSString *type, BOOL orientTouch)
{
	CGPoint location = CGPointZero;

	if (pos != NULL)
	{
		location = *pos;
	}

	if (orientTouch)
	{
		PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(location.x, location.y, pxEngineStage);

#ifdef PX_DEBUG_MODE
		if (PXDebugIsEnabled(PXDebugSetting_HalveStage) && pos != NULL)
		{
			CGSize stageSize = CGSizeMake(pxEngineStage.stageWidth, pxEngineStage.stageHeight);

			location.x = 2.0f * ((stageSize.width  * 0.75f) + ((location.x) - (stageSize.width)));
			location.y = 2.0f * ((stageSize.height * 0.75f) + ((location.y) - (stageSize.height)));
		}
#endif
	}

	return [[PXTouchEvent alloc] initWithType:type nativeTouch:touch stageX:location.x stageY:location.y tapCount:touch.tapCount];
}

void PXTouchEngineInvokeTouch(UITouch *touch, CGPoint *pos, NSString *type)
{
	PXTouchEvent *event = PXTouchEngineNewTouchEventWithTouch(touch, pos, type, YES);
	[pxTouchEngineTouchEvents addObject:event];
	[event release];
}

void PXTouchEngineInvokeTouchDown(UITouch *touch, CGPoint *pos)
{
	PXTouchEngineInvokeTouch(touch, pos, PXTouchEvent_TouchDown);
}
void PXTouchEngineInvokeTouchMove(UITouch *touch, CGPoint *pos)
{
	PXTouchEngineInvokeTouch(touch, pos, PXTouchEvent_TouchMove);
}
void PXTouchEngineInvokeTouchUp(UITouch *touch, CGPoint *pos)
{
	PXTouchEngineInvokeTouch(touch, pos, PXTouchEvent_TouchUp);
}
void PXTouchEngineInvokeTouchCancel(UITouch *touch, CGPoint *pos)
{
	PXTouchEngineInvokeTouch(touch, pos, PXTouchEvent_TouchCancel);
}
