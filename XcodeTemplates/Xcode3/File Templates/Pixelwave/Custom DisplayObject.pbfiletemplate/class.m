//
//  «FILENAME»
//  «PROJECTNAME»
//
//  Created by «FULLUSERNAME» on «DATE».
//  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.
//

«OPTIONALHEADERIMPORTLINE»
@implementation «FILEBASENAMEASIDENTIFIER»

- (id) init
{
	self = [super init];

	if (self)
	{
		_renderMode = PXRenderMode_BatchAndManageStates;
		
		// Available render modes:
		// ----------------------
		//
		// PXRenderMode_BatchAndManageStates (recommended)
		//		Pixelwave will manage all gl draw calls. Redundant state changes
		//		will be ignored, and drawing vertices will batched. When this
		//		option is on you should never call gl*() methods. Instead use
		//		the PXGL*()	alternatives.
		//
		// PXRenderMode_ManageStates
		//		Similar to 'BatchAndManageStates' except that vertices will not
		//		be batched.
		//		When this option is on you should never call gl*() methods.
		//		Instead use	the PXGL*()	alternatives.
		//
		// PXRenderMode_Custom
		//		Pixelwave won't manage any of your gl draw calls. Use the gl*()
		//		functions directly.
		//
		// PXRenderMode_Off
		//		This display object won't be rendered at all. This option is
		//		used primarily with display object containers. When this option
		//		is used, the _renderGL method will never be invoked.
	}

	return self;
}

- (void) _measureLocalBounds:(CGRect *)retBounds
{
	// Set the bounds to your local bounds, ex:
	//retBounds->origin.x = x;
	//retBounds->origin.y = y;
	//retBounds->size.width  = width;
	//retBounds->size.height = height;
}

- (BOOL) _containsPointWithLocalX:(float)x
						   localY:(float)y
						shapeFlag:(BOOL)shapeFlag
{
	// Return YES if the point lies within your local area.  If shape flag is
	// 'NO', then a simple bounding box check is sufficient.

	// This is an example of how to do a simple rectangle test:
	//if (!shapeFlag)
	//{
	//	CGRect rect;
	//	[self _localBounds:&rect];
	//
	//	return CGRectContainsPoint(rect, CGPointMake(x, y));
	//}

	return NO;
}

- (void) _renderGL
{
	// Custom OpenGL calls go here.
	
	// If the current render mode supports managed states, don't use any method
	// beginning with gl*(). Instead use the PXGL*() set of methods.
}

@end
