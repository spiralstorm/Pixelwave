//
//  inkPlatform.h
//  ink
//
//  Created by John Lattin on 12/13/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_PLATFORM_H_
#define _INK_PLATFORM_H_

#if !defined(INK_PLATFORM_IOS) && !defined(INK_PLATFORM_OSX) && !defined(INK_PLATFORM_WINDOWS) && !defined(INK_PLATFORM_LINUX) && !defined(INK_PLATFORM_ANDROID)

// Apple
#if defined(__APPLE__) || defined(__MACH__)

#include "AvailabilityMacros.h"

#ifdef MAC_OS_X_VERSION_10_3
#include "TargetConditionals.h"
#endif // includes for apple

#endif // #if apple

// NOTE:	Any TARGET_ is ALWAYS defined for apple, thus it is checked with
//			regular if, not ifdef

// ios
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#define INK_PLATFORM_IOS

// osx
#elif TARGET_OS_MAC || defined(__MACOSX__) || defined(__MACOS__)
#define INK_PLATFORM_OSX

// windows
#elif defined(WIN32) || defined(__WIN32) || defined(__WIN32__)
#define INK_PLATFORM_WINDOWS

// linux
#elif defined(__LINUX__) || defined(__linux__) || defined(linux) || defined(__linux)
#define INK_PLATFORM_LINUX

// unknown?!?
#else
#define INK_PLATFORM_UNKOWN
#endif // Platform search

#endif

#endif
