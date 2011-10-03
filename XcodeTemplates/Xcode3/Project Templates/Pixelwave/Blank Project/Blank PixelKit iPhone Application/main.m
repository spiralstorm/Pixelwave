//
//  main.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import <UIKit/UIKit.h>

int main (int argc, char *argv[])
{
	int retVal = 0;

#if __has_feature(objc_arc)
	@autoreleasepool
	{
		retVal = UIApplicationMain(argc, argv, nil, nil);
	}
#else
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	retVal = UIApplicationMain(argc, argv, nil, nil);
	[pool release];
#endif

	return retVal;
}
