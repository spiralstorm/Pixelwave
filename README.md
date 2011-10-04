What exactly is Pixelwave?
=========================
Pixelwave is a framework for iOS that makes developing 2D games and other interactive applications simple. It provides an intuitive Objective-C API which is greatly inspired by the ActionScript 3.0 API. It lets you avoid writing low-level code without giving up the power of using OpenGL and OpenAL. Under the hood Pixelwave packs a punch when it comes to rendering performance and optimizations. The framework also includes PixelKit, a collection of useful utilities for game developers.

Pixelwave works on every iOS device ever made: iPhone, iPod Touch, and iPad.

Official site: http://www.pixelwave.org


      _____                       ___                                            
     /\  _ `\  __                /\_ \                                           
     \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
      \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
       \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
        \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
         \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
           
            v0.13.2   www.pixelwave.org + www.spiralstormgames.com
                                ~;   
                               ,/|\.           
                             ,/  |\ \.                 Core Team: Oz Michaeli
                           ,/    | |  \                           John Lattin
                         ,/      | |   |
                       ,/        |/    |
                     ./__________|----'  .
                ,(   ___.....-,~-''-----/   ,(            ,~            ,(        
     _.-~-.,.-'`  `_.\,.',.-'`  )_.-~-./.-'`  `_._,.',.-'`  )_.-~-.,.-'`  `_._._,.
     
     Copyright (c) 2011 Spiralstorm Games http://www.spiralstormgames.com


Design goals
============

### A Simple Interface
Pixelwave's API is very simple to use. It's built with Objective-C to be completely object oriented. To get a better feel for what working with Pixelwave looks like, take a look at some [code samples](http://www.pixelwave.org/docs/Quick_Code_Samples).

### Performance
Pixelwave is built to be fast. The core of the engine is built with C, and relies on OpenGL for hardware-accelerated rendering and OpenAL for high performance sounds. Pixelwave also performs many 'invisible' optimizations (such as batching draw calls) for you. Pixelwave likes to work hard, so you don't have to.

### Powerful Features
What makes Pixelwave's features powerful is how easy they are to use. Need to draw Images? Vector shapes? Text? No problem. Playing sounds is also a breeze.
Pixelwave's features include:

* Support for many different image formats
* Powerful text rendering
* GPU accelerated vector shape rendering
* Support for many sound formats
* Easy 3D and 2D sound playback
* Physics engine integration
* Simple performance monitoring
* Particle simulation engine (alpha version, see particles-alpha branch)
* Flexible tweening engine (in the works)
* Resource manager (in the works)

Read more on the [features page](http://www.pixelwave.org/features).

### Extendability
Extending the capabilities of the engine doesn't require digging through thousands of lines of code (like most open-source projects). To extend the graphics engine for example, Pixelwave exposes simple C API for interacting with the GPU, allowing you to create your own visual elements or integrate existing OpenGL code into Pixelwave.
To read more about Pixelwave's extendability features check out the [manual](http://www.pixelwave.org/docs/Manual#Extending).

### Documentation
We believe that without proper documentation, even the best written framework in existence would be unusable by most. Aside from performance and ease of use, one of Pixelwave's main goals is to provide you with a lot of documentation.

What do I need to know?
=======================
You'll need to be familiar with Objective-C. If you'd like to extend Pixelwave, or create super-efficient chunks of code you can drop down to using C as well. Developers with knowledge of AS3 will surely feel at home quickly as Pixelwave's class structure is derived from it. If you're not familiar with AS3 there's no need to panic. We think you'll quickly come to appreciate the clean and intuitive API.

Getting Started
================

The first place you should visit is the [Getting Started Guide](http://www.pixelwave.org/docs/Getting_Started_Guide).

Everything you need to know about using Pixelwave is over at the [Documentation Center](http://www.pixelwave.org/docs).