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
 * The function first cycles through all the display objects on the screen in
 * reverse order, looking for the most immediate target of a touch event, and
 * then traverses up the display hierarchy until it finds an interactive object
 * for which touches are enabled.
 * - Bekenn, Pixelwave forums
 *
 * Returns the displayObject that should recieve the event (could be nil)
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
	signed int index;
	signed int startIndex = pxEngineDOBuffer.size - 1;

	// Loop through the list of possible touch targets.
	// Since items were added to the list in back-to-front order, we iterate
	// backwards to go front-to-back.
	for (index = startIndex, curDisplayObject = &(pxEngineDOBuffer.array[startIndex]);
		 index >= 0;
		 --index, --curDisplayObject)
	{
		target = *curDisplayObject;

		aabb = &(target->_aabb);

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

	// Will be nil at this point
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
	id<PXEventDispatcher> captureTarget = NULL;

	// If stage's touch children is off, then the only reciever of any touches
	// would automatically be stage.
	if (pxEngineStage->_touchChildren)
	{
		// Loop through all of the cached touch events so we can find them a
		// target and dispatch them apropriately.
		PXLinkedListForEach(pxTouchEngineTouchEvents, event)
		{
			eventType = event.type;

			didTouchUp     = false;
			didTouchCancel = false;
			didTouchDown   = false;
			didTouchUpOrCancel = false;

			// Find what type of touch even this is. Since string comparison
			// isn't cheap, we do a lazy check.
			didTouchDown = [eventType isEqualToString:PXTouchEvent_TouchDown];
			if (didTouchDown == false)
			{
				didTouchUp = [eventType isEqualToString:PXTouchEvent_TouchUp];
				if (didTouchUp == false)
				{
					didTouchCancel = [eventType isEqualToString:PXTouchEvent_TouchCancel];
				}
			}

			// Keep track of if the touch was up or canceled. This is important
			// as we will need to deassociate the touch with it's captured
			// target if it has one.
			didTouchUpOrCancel = didTouchUp || didTouchCancel;

			// Grab the 'key' for the dictionary of captures, and the target
			captureKey = event.nativeTouch;
			captureTarget = (id<PXEventDispatcher>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, captureKey);

			// If a capture target exists, then we don't need to find a new one
			if (captureTarget != nil)
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
			if (didTouchDown == false && target != nil && target != captureTarget)
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
			if (target == nil)
			{
				target = pxEngineStage;
			}

			// If a touch was lifted (up) or canceled by UIKit (cancel), it
			// needs to be deassociated from anything that captured it because
			// it's likely to not exist anymore (and even if it still exists, we
			// can't track it).
			if (didTouchUpOrCancel == true)
			{
				CFDictionaryRemoveValue(pxEngineTouchCapturingObjects, captureKey);
			}

			event->_target = target;
			[target dispatchEvent:event];
		} // PXLinkedListForEach
	}
	else
	{
		// This is an optimization. When the user sets stage.touchChildren == NO
		// it means we can skip the regular touch dispatch flow through the
		// hierarchy. Because of that, no touches can be captured again either
		// (remember that stage never captures touches) so we cancel any touches
		// that are currently captured by something.
		PXLinkedListForEach(pxTouchEngineTouchEvents, event)
		{
			captureKey = event.nativeTouch;
			captureTarget = (id<PXEventDispatcher>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, captureKey);

			if (captureTarget != nil)
			{
				PXTouchEngineCancelTouch(captureKey);
			}

			// At this point target = stage.
			event->_target = target;
			[target dispatchEvent:event];
		}
	}

	[pxTouchEngineTouchEvents removeAllObjects];
}

#pragma mark -

// Internal method for canceling a touch. It will dispatch the cancel event to a
// captured target (if one exists) and remove it from the association list.
void PXTouchEngineCancelTouch(UITouch *touch)
{
	// Get the object that is captured by the touch.
	id<PXEventDispatcher> object = (id<PXEventDispatcher>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, touch);

	// If the object is nil, then the touch does not have a capturing target,
	// thus it is not in our list, and we can just return.
	if (object == nil)
		return;

	// Remove the touch, it will soon not be capturing.
	// NOTE:	This must be done BEFORE sending the event out. This is because
	//			a cancel event could remove a child which would then send out a
	//			cancel event which would then reomve the child, etc. The child
	//			is not actually removed from the list until AFTER the cancel
	//			events are sent out. This is because the display hierarchy must
	//			remain in tact until all events are handeled.
	CFDictionaryRemoveValue(pxEngineTouchCapturingObjects, touch);

	// Find the position of the touch on the stage.
	PXPoint *pxPoint = [pxEngineStage positionOfTouch:touch];
	CGPoint point = CGPointMake(pxPoint.x, pxPoint.y);

	// Send out the cancel event.
	PXTouchEvent *event = PXTouchEngineNewTouchEventWithTouch(touch, &point, PXTouchEvent_TouchCancel, NO);
	[object dispatchEvent:event];
	[event release];
}

// A recursive method that will fill the 'addList' with any display object in
// the display hierarchy who has a touch associated with them. The list in order
// will go parent->parent's child->child's child->parent's child... etc.
// Will return false if there is nothing left to add.
// Note:	The return value is ONLY for the inner recursive method. You do not
//			need to care about it. Instead, only care about the list you are
//			sending it. It must be a VALID list (as in, one that is empty and
//			allocated).
bool PXTouchEngineGetTouchDisplayHierarchy(PXDisplayObject *object, PXLinkedList *addList)
{
	CFIndex count = CFDictionaryGetCount(pxEngineTouchCapturingObjects);

	// If we have found all targets, or there were none for us to find, then we
	// can just say we are done.
	if (count <= 0 || [addList count] == count)
		return false;

	// If this object is within the capturing list, add it to the list the user
	// wants.
	if (CFDictionaryContainsValue(pxEngineTouchCapturingObjects, object) == true)
	{
		[addList addObject:object];
	}

	// If it is a display object container, we need to go through it's children
	// and add them to the list as well.
	if (PX_IS_BIT_ENABLED(object->_flags, _PXDisplayObjectFlags_isContainer) == true)
	{
		PXDisplayObjectContainer *container = (PXDisplayObjectContainer *)object;

		unsigned index;
		PXDisplayObject *child;

		// Loop through each of the children and add them to the list if needed.
		for (index = 0, child = container->_childrenHead; index < container->_numChildren; ++index, child = child->_next)
		{
			// If we returned false, then it means we are done looking and can
			// just return. This will trickle up through the call stack
			// returning false and thus completing the search.
			if (PXTouchEngineGetTouchDisplayHierarchy(child, addList) == false)
				return false;
		}
	}

	// We may not be done yet.
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

	// Gives us a parallel array structure so that you can iterate through the
	// posabilities.
	CFDictionaryGetKeysAndValues(pxEngineTouchCapturingObjects, (const void **)(keys), NULL);

	CFIndex index;
	CFTypeRef *key;

	id<PXEventDispatcher> target;

	// Loop through the dictionary and see if the object has any association
	// with a touch; if it does, we need to cancel it.
	for (index = 0, key = keys; index < count; ++index, ++key)
	{
		// Grab the target EVERY TIME this way even if the dictionary changes
		// during this loop, we are only doing the most up to date interactions.
		target = (id<PXEventDispatcher>)(CFDictionaryGetValue(pxEngineTouchCapturingObjects, *key));

		// If no target exists, continue.
		if (target == nil)
			continue;

		if ([objects containsObject:target] == true)
		{
			PXTouchEngineCancelTouch((UITouch *)(*key));

			// You can not remove the current target from the list. It may have
			// more then one association that needs to get taken care of, and
			// the object will only appear once in the list.
		}
	}
}

// talk about the rules we set.
void PXTouchEngineRemoveAllTouchCapturesFromObject(id<PXEventDispatcher> capturingObject)
{
	// Cheap function to ensure that we actually need to do something.
	CFIndex count = CFDictionaryGetCount(pxEngineTouchCapturingObjects);

	// If no touch events are captured, then there is nothing to do, so just
	// return.
	if (count <= 0)
		return;

	PXObjectPool *pool = PXEngineGetSharedObjectPool();

	// Grab a pooled list to add stuff to.
	// NOTE:	After this point, you can not quick return unless you release
	//			this pool!
	PXLinkedList *hierarchy = [pool newObjectUsingClass:[PXLinkedList class]];

	// RULE:	If the capturing object is a display object, then we must
	//			dispatch a cancel event to all of it's children when we are
	//			removing the display object from the hierarchy.
	// RULE:	The capturing object does not need to be a display object, it
	//			just needs to enforce the event dispatcher protocol.
	if ([capturingObject isKindOfClass:[PXDisplayObject class]])
	{
		PXTouchEngineGetTouchDisplayHierarchy((PXDisplayObject *)capturingObject, hierarchy);
	}
	else if (CFDictionaryContainsValue(pxEngineTouchCapturingObjects, capturingObject) == true)
	{
		[hierarchy addObject:capturingObject];
	}

	// Ensure that the hierarchy actually contains something prior to calling
	// the method that says do all checks prior to calling it. Also, there would
	// be no need to remove all capture objects from the list that contains
	// nothing.
	if ([hierarchy count] > 0)
	{
		_PXTouchEngineRemoveAllTouchCapturesFromObjects(hierarchy);
	}

	// Release the list back to the pool
	[pool releaseObject:hierarchy];
}

// Only used by the user
// NOTE:	It is impossible for us to ensure that the touch is 'real'. Meaning,
//			if you kept a touch around (long after it died), or created one and
//			sent it to this method to associated it with you, then we have no
//			way of ensuring that the touch is real. So, please don't do that. It
//			won't break anything, but could yield strange results.
void PXTouchEngineSetTouchCapturingObject(UITouch *nativeTouch, id<PXEventDispatcher> capturingObject)
{
	// If you send us a nil touch, then there is nothing for us to do.
	if (nativeTouch == nil)
		return;

	id<PXEventDispatcher> originalObject = (id<PXEventDispatcher>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, nativeTouch);

	// Only do work if the object is actually changing
	if (originalObject != capturingObject)
	{
		if ([capturingObject isKindOfClass:[PXDisplayObject class]])
		{
			// RULE:	Display objects can't have touch events disptached on
			//			them by the system if they are not on the display list.
			if (((PXDisplayObject *)(capturingObject)).stage == nil)
				return;
		}

		// Send out a cancel event on the OLD object, if one exists.
		if (originalObject != nil)
		{
			PXTouchEngineCancelTouch(nativeTouch);
		}

		// Change the target
		if (capturingObject != nil)
		{
			CFDictionarySetValue(pxEngineTouchCapturingObjects, nativeTouch, capturingObject);
		}
	}
}

// Returns the capturing target if one exists.
id<PXEventDispatcher> PXTouchEngineGetTouchCapturingObject(UITouch *nativeTouch)
{
	if (nativeTouch == nil)
		return nil;
	
	return (id<PXEventDispatcher>)CFDictionaryGetValue(pxEngineTouchCapturingObjects, nativeTouch);
}

// Returns the first NATIVE touch found in the list.
UITouch *PXTouchEngineGetFirstTouch()
{
	// No touches could exist.
	if (pxTouchEngineTouchEvents == nil || [pxTouchEngineTouchEvents count] <= 0)
		return nil;

	// Find the event
	PXTouchEvent *event = (PXTouchEvent *)[pxTouchEngineTouchEvents objectAtIndex:0];

	// Return to them the native touch
	return event.nativeTouch;
}

// Returns all NATIVE touches in our list
PXLinkedList *PXTouchEngineGetAllTouches()
{
	if (pxTouchEngineTouchEvents == nil || [pxTouchEngineTouchEvents count] <= 0)
		return nil;

	PXLinkedList *list = [[PXLinkedList alloc] init];
	PXTouchEvent *event;

	// Loop through the events and add them if the native touch exists.
	for (event in pxTouchEngineTouchEvents)
	{
		if (event.nativeTouch != nil)
			[list addObject:event.nativeTouch];
	}

	return [list autorelease];
}

CGPoint PXTouchEngineTouchToScreenCoordinates(UITouch *touch)
{
	// If the view doesn't exist, then we can not convert the touch, so give up.
	if (touch == nil || pxEngineView == nil)
		return CGPointZero;

	// Grab the location of the touch in the view
	CGPoint point = [touch locationInView:pxEngineView];

	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)[pxEngineView layer];
	CGPoint pos = eaglLayer.position;

	// Add the layer's position, this way we are always in the correct spot.
	point.x += pos.x;
	point.y += pos.y;

	// Convert it to stage coordinates.
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

	// If orientTouch == NO then this has already been done.
	if (orientTouch == YES)
	{
		// Convert the touch to stage coordinates.
		PX_ENGINE_CONVERT_POINT_TO_STAGE_ORIENTATION(location.x, location.y, pxEngineStage);

		// Do half screen magic...
#ifdef PX_DEBUG_MODE
		if (PXDebugIsEnabled(PXDebugSetting_HalveStage) && pos != NULL)
		{
			CGSize stageSize = CGSizeMake(pxEngineStage.stageWidth, pxEngineStage.stageHeight);

			// Conversion magic
			location.x = 2.0f * ((stageSize.width  * 0.75f) + ((location.x) - (stageSize.width)));
			location.y = 2.0f * ((stageSize.height * 0.75f) + ((location.y) - (stageSize.height)));
		}
#endif
	}

	return [[PXTouchEvent alloc] initWithType:type nativeTouch:touch stageX:location.x stageY:location.y tapCount:touch.tapCount];
}

void PXTouchEngineInvokeTouch(UITouch *touch, CGPoint *pos, NSString *type)
{
	// Add the event to the queue.
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
