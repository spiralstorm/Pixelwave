//
//  inkGL.h
//  ink
//
//  Created by John Lattin on 12/13/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

#ifndef _INK_GL_H_
#define _INK_GL_H_

#include "inkPlatform.h"

#if defined(INK_PLATFORM_IOS)
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#define INK_GL_ES

#elif defined(INK_PLATFORM_OSX)
#include <GL/gl.h>
#include <GL/glext.h>

#elif defined(INK_PLATFORM_WINDOWS)
#include <OpenGL/gl.h>
#include <OpenGL/glext.h>

#elif defined(INK_PLATFORM_ANDROID)
#include <GLES/gl.h>
#include <GLES/glext.h>
#define INK_GL_ES
#else
#error "GL is not defined."
#endif

#endif
