//
//  inkPlatform.h
//  ink
//
//  Created by John Lattin on 12/13/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_PLATFORM_H_
#define _INK_PLATFORM_H_

// Apple
#if defined(__APPLE__)

#include "AvailabilityMacros.h"

#ifdef MAC_OS_X_VERSION_10_3
#include "TargetConditionals.h"
#endif // includes for apple

// ios
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#define INK_PLATFORM_IOS

// osx
#elif defined(__MACOSX__) || defined(__MACOS__)
#define INK_PLATFORM_OSX
#endif // #if apple

// windows
#elif defined(WIN32) || defined(__WIN32) || defined(__WIN32__)
#define INK_PLATFORM_WINDOWS

// linux
#elif defined(linux) || defined(__linux) || defined(__linux__)
#define INK_PLATFORM_LINUX

// unknown?!?
#else
#define INK_PLATFORM_UNKOWN
#endif // Platform search

#endif
