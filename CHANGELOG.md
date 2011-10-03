Version 0.13.2 (Oct 3, 2011)
==============

Fixed
-----
- Important issue with point rendering
- Casting issue with feature introduced in v0.13.1

Version 0.13.1 (Oct 3, 2011)
==============

New
---
- Added several utility methods to PXTextureAtlas for quickly grabbing frames.
- Small utility creation methods to PXSprite and PXSimpleSprite.

Changed
-------
- Pixelwave + templates are ARC compatible.
- More access provided to the internal gl attributes of a PXTextureData.

Fixed
-----
- Minor bug fixes.
- Minor cleanup, inconsistency fixes and improved clarity.
- Fixed Zwoptex parser to properly handle rotated images.
- Texture loader loads retina images more accurately (bug #14).
- Fixed issue #13 involving grabbing the first touch on a display object.
- Pixelwave compiles correctly with the latest compilers and Xcode version.
- Fixed PXLinkedListForEachReverse (issue #16). Credit: Bekenn.
- Issue with sprite hit test not working properly in some cases.
- Implemented the PXSimpleButton.enabled property.

Version 0.13.0 (Aug 23, 2011)
==============

New
---
- Added support for the `PXEvent_Render` event.
- Added `[PXStage invalidate]` method which lets the engine know it should invoke a `render` event.
- Added the `[PXSprite hitArea]` property, based on the same one in AS3.

Changed
-------
- Turned on the `skipInstall` property for Xcode projects. This helps when creating an ad hoc executable with Xcode 4.
- Made `tap` event dispatching slightly more efficient.

Fixed
-----
- Graphics bug involving rendering gl point sprites.

Version 0.12.0 (Aug 12, 2011)
==============

New
---
- PXSimpleButton has been improved a bit:
	- The hitTestState can now be either a PXDisplayObject _or_ a PXRectangle (was just PXDisplayObject).
	- When the hitTestState is a PXRectangle the hit area is automatically inflated when the button is pressed for a smoother user experience (similar to buttons in UIKit).
	- The amount of inflation can be controlled via a new property in PXSimpleButton named autoInflateAmount.
- General improvement of API documentation.

Changed
-------
- Moved over to using appledoc 2.x for API documentation.
- Improved the documentation generation tool.


Version 0.11.0 (Aug. 7, 2011)
==============

New
---
- PXTexture display object now supports specifying extra inner padding and a content rotation offset.
- Added an official Pixelwave texture atlas which supports some common file formats (TexturePacker and Zwoptex), and is extendable.
- Embedded the TouchJSON library in Pixelwave. Used for parsing texture atlas JSON files.
- Added some useful utility methods related to working with files to the PXLoader and PXTextureLoader classes.
- Made the texture loader a bit smarter: Now the user doesn't have to provide the extension of the image to load.
- Added the ability to convert a UIImage to PXTextureData and vice versa.
- Added ability to take a screenshot (PXView::screenshot), producing a UIImage object.
- The texture loader and sound loaders can now have default modifiers which get applied if no modifier is specified.
- Added utility method [PXFont availableSystemFonts] which returns a list of names that can be used with PXTextField::font.
- Added the drawHitAreas flag to the PXDebug class, which draws blue rectangle around object hit areas.
- When loading a texture and its size needs to be expanded, Pixelwave will now automatically extrude the edges of the image (for smoother antialiasing). This can be turned off.
- PXTextureData now has a method to draw the contents of another texture data directly.
- The main stage object can now be accessed statically with the new [PXStage mainStage] method.
- PXView can now be made translucent by setting its opaque property to NO and making sure that its color quality is 'high'.
- Added a sample project to show usage of a texture atlas.
- Re-skinned the Newton's cradle sample. It now uses a texture atlas as well.
- In PixelKit, the Box2DTouchPicker now dispatches events when a pick starts and ends, allowing the user to cancel certain ones.

Changed
-------
- Renamed the <PXEventDispatcherProtocol> to <PXEventDispatcher>. This seems to better match the way Apple does things (with the NSObject class the the <NSObject> protocol).
- Renamed the method [PXEvent initWithType:doesBubble:isCancelable:] to [PXEvent initWithType:bubbles:cancelable:] (better following naming conventions).
- The touch system has been redesigned to be more user friendly:
	- Touches can now be 'captured' by display objects, causing the touch's events to only be dispatched on the display object it first touched (this behavior can be turned off).
	- PXInteractiveObject has a new property 'captureTouches' to allow the user control how touches should be handled by individual display objects.
	- PXStage has a new property defaultCaptureTouchesValue to allow the user to control touch capturing behavior globally.
	- The events PXTouchEvent_Out and PXTouchEvent_DoubleTap have been removed. Their functionality still exists via other methods.
	- PXInteractiveObject's 'doubleTapEnabled' property has been removed.
- PXTexture's clip rect property is no longer a PXRectangle. It is now a PXClipRect object which allows to specify how the content of the texture should be rotated.
- Event constants are no longer #defines, so instead of looking like this (PX_EVENT_ENTER_FRAME) they look like this PXEvent_EnterFrame. Much easier on the eyes.
- Some method names had a lot of 'and' in them (such as initWithX:andY:andWidth:andHeight:). Following Apple's convention we removed all 'and's but the first one in method names.
- Memory warning events are no longer dispatched by Pixelwave. If needed they can be tracked using the native iOS framework.
- Enhanced the code documentation, and added a few more entries.
- Added the method PXLinkedList::setIndex:ofObject:
- Made Pixelwave more Xcode 4 friendly.
- Added some more utility creation methods.
- Re-organized the docs folder to be more user friendly (all 'dirty' scripts are now in a hidden folder).
- All public methods now use only NSArray objects for lists (as opposed to PXLinkedList).
- Removed all (of 1) deprecated methods.

Fixed
-----
- General clean up including fixing several memory leaks, reorganizing code, and doing performance enhancements.
- Now the '-all_load' linked flag (which is required by some frameworks) won't prevent Pixelwave from compiling.
- Fixed a bug with PXDebug.halveStage not being applied to touches.
- Long time bug involving adding and removing enterFrame events.
- Bitmap fonts now work as expected with the retina display (thanks sumiguchi).
- Fixed a bug where loading an incorrect texture atlas JSON file crashes the app. The error is now gracefully outputted to the console (thanks Alex).

Version 0.10.1 (Apr. 7, 2011)
==============

New
---
- Revamped the way OpenGL is wrapped by Pixelwave (This is an internal change):
	- Prior to _renderGL the 'gl state' is reset to the default - thus you do not need to enable/disable anything you aren't using prior to rendering.
	- PXDisplayObject now has _glState which is a preset to define your glEnable's and glClientStateEnable's prior to each render call.

Changed
--------
- Changed NSObject* parameters and return-types to id where ever possible. (Thanks Bekenn).
- Removed the project version from the source comment-block headers (It got a bit annoying changing them every time).

Fixed
-----
- Implemented fix for removing the 'white' flash upon load of the app (Thanks Bekenn).
- Implemented the (missing) "doubleTap" event (PX_TOUCH_EVENT_DOUBLE_TAP) (Thanks Alex).
- Fixed Box2D bug described in: http://www.box2d.org/forum/viewtopic.php?f=4&t=5269 (Thanks sumiguchi).
- Fixed the touch cancel bug (Thanks Bekenn).
- Fixed touch positions being calculated incorrectly for iOS 3.x (Thanks makzan).

Version 0.10.0 (Mar. 8, 2011)
==============

New
---
- Sounds, textures, and fonts can now be loaded from file or from a URL. Sound, TextureData, and Font objects can also be created from raw bytes (NSData).
- Added ability to modify data at load-time through PXSoundModifier and PXTextureModifier. Can be used to convert pixel formats, make a sound mono, etc. Very powerful!
- Added a regex library, based on the Java regex lib. New classes are PXRegexMatcher and PXRegexPattern. Built on top of the C based TRE library.
- Added support for loading custom fonts in the Angelcode format (.fnt). This is the new suggested way to build and load fonts in Pixelwave.
- Added the ability for a PXTextureFont to be internally composed of several textures.
- Added support for the following pixel formats when loading PNG files: L8, A8 and LA88.
- Added PXTextureModifier to allow pixel formats to be converted at load-time (5551, A8, L8 and LA88).
- Added PXSoundModifier to allow sounds to be modified at load-time (convert-to-mono).
- Added PXFontOptions and PXTextureFontOptions. These are used to pass options as an object to a loader instead of passing them directly as parameters.
- Added a nativeView property to PXStage.
- Added PXViewColorQuality flag that can be used to change the default OpenGL surface pixel format + dithering.
- Added userData property to PXDisplayObject which can be used to reference anything.
- Added support for automatic orientation detection. If you want Pixelwave to automatically rotate your app to match the device's orientation set stage.autoOrients = YES.
- Added a new sample project (CustomFont) that shows how to load custom fonts in the Angelcode format. It also shows how to use the new automatic orientation system.

Changed
-------
- The internal loading code has been overhauled and is now much more flexible. The same powerful external interface remains though some method names have been changed.
With the new system, loaders only load data, and the actual parsing is offloaded to the appropriate PXParser object.
Both parsing and loading can be done on a separate thread. 'newing' such as 'newFont', 'newSound' and 'newTextureData' has to be done on the main thread.

- Updated the existing sample projects to work with the new loading method names.
- If you want a texture font (which almost all cases you do), then you must now supply the PXFontLoader with a PXTextureFontOptions object. The size to load, and character sets are now stored there.
- Added kerning capabilities (only supported with some fonts).
- Deleted autoresizesSurface property from PXView. Default behavior is always YES.
- Renamed [PXDisplayObject getBoundsWith...] to [PXDisplayObject boundsWith...] (Objective-C-afied).
- Renamed [PXDisplayObject getRectWith...] to [PXDisplayObject rectWith] (Objective-C-afied).
- Added dates to changelog entries.

Fixed
-----
- Made PXTextField a PXInteractiveObject. It can now be touched and interacted with directly.
- Now PXTextField will tell you the correct width and height if asking for it prior to rendering.
- Typo of 'measureLocalBound' it should have been 'measureLocalBounds'.
- PXDebug.halveStage now draws the magenta border above everything (was under).
- Fixed 'multiplyUp' recognized in getBoundsWithCoordinateSpace of DisplayObject (Thanks to Bekenn!).
- Fixed internal representation of EAGL layer, to position the bottom-left hand corner of the OpenGL context as (0,0).

Version 0.9.2 (Feb. 2, 2011)
=============

New
---
- Added [warmUp] method to SoundMixer, to initialize the sound engine explicitly.
- Added [objectsUnderPoint] method to PXDisplayObjectContainer, to grab a list of objects that contain the given point.
- Added [addObjectsFromList] method to PXLinkedList, to add all elements from one list to another.

Fixed
-----
- SystemFontRenderer wasn't taking screen's scaleFactor into account (broken in 0.9.1).
- Sound system now correctly handles audio session interruptions for OpenAL + AVAudioPlayer.
- SoundEngine now pauses/resumes correctly during an audio session interruption.
- Fixed a bug in DisplayObject where ENTER_FRAME_EVENT string was being compared with == instead of [isEqualToString:]
- Fixed a memory leak when a sound channel could not be created because too many sounds were playing.  Now if you try to play a sound and it can not happen it returns nil instead.
- Fixed a bug where [TextureData drawDisplayObject:] sometimes clipped off the rendering area.
- Fixed bug where PXDisplayObject.root returned the stage instead of the root (Thanks to makzan!).
- Render to texture works with content scale factor properly. Fixed other TextureData.draw bugs.
- Renamed [PXDisplayObject _measureLocalBound] to [_measureLocalBounds] (was a typo).

Version 0.9.1 (Dec. 31, 2010)
=============

New
---
- Added PixelKit framework.
- Added PixelKit option to 'Blank Project' Xcode template.
- Added Box2D support and 'Box2D project' Xcode template.

Fixed
-----
- Fixed several template issues.
- Fixed HelloWorld sample, so it doesn't crash on iPad.

Version 0.9.0 (Dec. 25, 2010)
=============
- Initial beta release.