/*
 *  _____                       ___                                            
 * /\  _ `\  __                /\_ \                                           
 * \ \ \L\ \/\_\   __  _    ___\//\ \    __  __  __    ___     __  __    ___   
 *  \ \  __/\/\ \ /\ \/ \  / __`\\ \ \  /\ \/\ \/\ \  / __`\  /\ \/\ \  / __`\ 
 *   \ \ \/  \ \ \\/>  </ /\  __/ \_\ \_\ \ \_/ \_/ \/\ \L\ \_\ \ \_/ |/\  __/ 
 *    \ \_\   \ \_\/\_/\_\\ \____\/\____\\ \___^___ /\ \__/|\_\\ \___/ \ \____\
 *     \/_/    \/_/\//\/_/ \/____/\/____/ \/__//__ /  \/__/\/_/ \/__/   \/____/
 *       
 *           www.pixelwave.org + www.spiralstormgames.com
 *                            ~;   
 *                           ,/|\.           
 *                         ,/  |\ \.                 Core Team: Oz Michaeli
 *                       ,/    | |  \                           John Lattin
 *                     ,/      | |   |
 *                   ,/        |/    |
 *                 ./__________|----'  .
 *            ,(   ___.....-,~-''-----/   ,(            ,~            ,(        
 * _.-~-.,.-'`  `_.\,.',.-'`  )_.-~-./.-'`  `_._,.',.-'`  )_.-~-.,.-'`  `_._._,.
 * 
 * Copyright (c) 2011 Spiralstorm Games http://www.spiralstormgames.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#import "PXCGTextureParser.h"

#import <UIKit/UIKit.h>
#import "PXGL.h"

#import "PXDebug.h"
#import "PXExceptionUtils.h"
#import "PXMathUtils.h"

#define pxKMaxTextureSize         1024

@interface PXCGTextureParser(Private)
- (BOOL) processCGImage:(CGImageRef)image
			orientation:(UIImageOrientation)orientation
			  sizeToFit:(BOOL)sizeToFit
			pixelFormat:(PXTextureDataPixelFormat)_pixelFormat;
@end

@implementation PXCGTextureParser

- (void) dealloc
{
	//CGContextRelease(context);
	//context = 0;
	
	cgImage = 0;

	[super dealloc];
}

- (BOOL) isModifiable
{
	return YES;
}

+ (BOOL) isApplicableForData:(NSData *)data origin:(NSString *)origin
{
	if (data)
	{
		return YES;
	}

	return NO;
}
+ (void) appendSupportedFileExtensions:(PXLinkedList *)extensions
{
	[extensions addObject:@"png"];
	[extensions addObject:@"jpg"];
	[extensions addObject:@"jpeg"];
	[extensions addObject:@"gif"];
	[extensions addObject:@"tif"];
	[extensions addObject:@"tiff"];
	[extensions addObject:@"bmp"];
	[extensions addObject:@"bmpf"];
	[extensions addObject:@"ico"];
	[extensions addObject:@"cur"];
	[extensions addObject:@"xmb"];
}

// Pass 0 if you don't know the pixel format
- (BOOL) processCGImage:(CGImageRef)image
			orientation:(UIImageOrientation)orientation
			  sizeToFit:(BOOL)sizeToFit
			pixelFormat:(PXTextureDataPixelFormat)_pixelFormat
{
	NSUInteger width;
	NSUInteger height;
	NSUInteger i;
	CGContextRef _context = nil;
	void *_data = nil;
	unsigned _byteCount = 0;
	CGColorSpaceRef colorSpace;
	void *tempData;
	unsigned char *inPixel8;
	unsigned int *inPixel32;
	unsigned char *outPixel8;
	unsigned short *outPixel16;
	BOOL hasAlpha;
	CGImageAlphaInfo info;
	CGAffineTransform transform;
	CGSize imageSize;
	
	if (image == NULL)
	{
		return NO;
	}
	
	if (_pixelFormat == 0)
	{
		info = CGImageGetAlphaInfo(image);
		
		hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
		if (CGImageGetColorSpace(image))
		{
			if (CGColorSpaceGetModel(CGImageGetColorSpace(image)) == kCGColorSpaceModelMonochrome)
			{
				if (hasAlpha)
				{
					_pixelFormat = PXTextureDataPixelFormat_LA88;
#ifdef PIXELWAVE_DEBUG
					if ((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 16))
						PXDebugLog(@"Unoptimal image pixel format for image");
					
#endif
				}
				else
				{
					_pixelFormat = PXTextureDataPixelFormat_L8;
#ifdef PIXELWAVE_DEBUG
					if ((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 8))
						PXDebugLog(@"Unoptimal image pixel format for image");
					
#endif
				}
			}
			else
			{
				if ((CGImageGetBitsPerPixel(image) == 16) && !hasAlpha)
					_pixelFormat = PXTextureDataPixelFormat_RGBA5551;
				else
				{
					if (hasAlpha)
						_pixelFormat = PXTextureDataPixelFormat_RGBA8888;
					else
					{
						_pixelFormat = PXTextureDataPixelFormat_RGB565;
#ifdef PIXELWAVE_DEBUG
						if ((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 24))
							PXDebugLog(@"Unoptimal image pixel format for image");
						
#endif
					}
				}
			}
		}
		else   //NOTE: No colorspace means a mask image
		{
			_pixelFormat = PXTextureDataPixelFormat_A8;
#ifdef PIXELWAVE_DEBUG
			if ((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 8))
				PXDebugLog(@"Unoptimal image pixel format for image");
			
#endif
		}
	}
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	switch (orientation)
	{
			
		case UIImageOrientationUp:         //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored:         //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown:         //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored:         //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored:         //EXIF = 5
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft:         //EXIF = 6
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored:         //EXIF = 7
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight:         //EXIF = 8
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	if ((orientation == UIImageOrientationLeftMirrored) || (orientation == UIImageOrientationLeft) || (orientation == UIImageOrientationRightMirrored) || (orientation == UIImageOrientationRight))
		imageSize = CGSizeMake(imageSize.height, imageSize.width);
	
	width  = PXMathNextPowerOfTwo(imageSize.width);
	height = PXMathNextPowerOfTwo(imageSize.height);
	
	while ((width > pxKMaxTextureSize) || (height > pxKMaxTextureSize))
	{
#ifdef PIXELWAVE_DEBUG
		PXDebugLog(@"Image at %ix%i pixels is too big to fit in texture", width, height);
#endif
		width *= 0.5f;
		height *= 0.5f;
		transform = CGAffineTransformScale(transform, 0.5f, 0.5f);
		imageSize.width *= 0.5f;
		imageSize.height *= 0.5f;
	}
	
	switch (_pixelFormat)
	{
			
		case PXTextureDataPixelFormat_RGBA8888:
		case PXTextureDataPixelFormat_RGBA4444:
			colorSpace = CGColorSpaceCreateDeviceRGB();

			_byteCount = height * width * 4;
			_data = malloc(_byteCount);

			_context = CGBitmapContextCreate(_data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case PXTextureDataPixelFormat_RGBA5551:
			colorSpace = CGColorSpaceCreateDeviceRGB();

			_byteCount = height * width * 2;
			_data = malloc(_byteCount);

			_context = CGBitmapContextCreate(_data, width, height, 5, 2 * width, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Little);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case PXTextureDataPixelFormat_RGB888:
		case PXTextureDataPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();

			_byteCount = height * width * 4;
			_data = malloc(_byteCount);

			_context = CGBitmapContextCreate(_data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case PXTextureDataPixelFormat_L8:
			colorSpace = CGColorSpaceCreateDeviceGray();

			_byteCount = height * width;
			_data = malloc(_byteCount);

			_context = CGBitmapContextCreate(_data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case PXTextureDataPixelFormat_A8:
			_byteCount = height * width;
			_data = malloc(_byteCount);

			_context = CGBitmapContextCreate(_data, width, height, 8, width, NULL, kCGImageAlphaOnly);
			break;
			
		case PXTextureDataPixelFormat_LA88:
			colorSpace = CGColorSpaceCreateDeviceRGB();

			_byteCount = height * width * 4;
			_data = malloc(_byteCount);

			_context = CGBitmapContextCreate(_data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
			
	}
	
	if (_context == NULL)
	{
		PXDebugLog(@"Failed creating CGBitmapContext");
		free(_data);
		return NO;
	}
	
	if (sizeToFit)
		CGContextScaleCTM(_context, (CGFloat)width / imageSize.width, (CGFloat)height / imageSize.height);
	else
	{
		CGContextClearRect(_context, CGRectMake(0, 0, width, height));
		CGContextTranslateCTM(_context, 0, height - imageSize.height);
	}
	
	if (!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(_context, transform);
	
	CGContextDrawImage(_context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	
	// TODO: Make sure this works
	CGContextRelease(_context);
	_context = 0;
	
	// Convert "-RRRRRGGGGGBBBBB" to "RRRRRGGGGGBBBBBA"
	if (_pixelFormat == PXTextureDataPixelFormat_RGBA5551)
	{
		outPixel16 = (unsigned short *)_data;
		for (i = 0; i < width * height; ++i, ++outPixel16)
		{
			*outPixel16 = *outPixel16 << 1 | 0x0001;
		}
		
#ifdef PIXELWAVE_DEBUG
		PXDebugLog(@"Falling off fast-path converting pixel data from ARGB1555 to RGBA5551");
#endif
	}
	// Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRRGGGGGGGGBBBBBBBB"
	else if (_pixelFormat == PXTextureDataPixelFormat_RGB888)
	{
		_byteCount = height * width * 3;
		tempData = malloc(_byteCount);
		//tempData = malloc(height * width * 3);

		inPixel8 = (unsigned char *)_data;
		outPixel8 = (unsigned char *)tempData;
		for (i = 0; i < width * height; ++i)
		{
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			inPixel8++;
		}
		
		free(_data);

		_data = tempData;
#ifdef PIXELWAVE_DEBUG
		PXDebugLog(@"Falling off fast-path converting pixel data from RGBA8888 to RGB888");
#endif
	}
	// Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	else if (_pixelFormat == PXTextureDataPixelFormat_RGB565)
	{
		_byteCount = height * width * 2;
		tempData = malloc(_byteCount);
		//tempData = malloc(height * width * 2);

		inPixel32 = (unsigned int *)_data;
		outPixel16 = (unsigned short *)tempData;
		for (i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		
		free(_data);

		_data = tempData;
#ifdef PIXELWAVE_DEBUG
		PXDebugLog(@"Falling off fast-path converting pixel data from RGBA8888 to RGB565");
#endif
	}
	// Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGBBBBAAAA"
	else if (_pixelFormat == PXTextureDataPixelFormat_RGBA4444)
	{
		_byteCount = height * width * 2;
		tempData = malloc(_byteCount);
		//tempData = malloc(height * width * 2);

		inPixel32 = (unsigned int *)_data;
		outPixel16 = (unsigned short *)tempData;
		for (i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);
		
		free(_data);

		_data = tempData;
#ifdef PIXELWAVE_DEBUG
		PXDebugLog(@"Falling off fast-path converting pixel data from RGBA8888 to RGBA4444");
#endif
	}
	// Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "LLLLLLLLAAAAAAAA"
	else if (_pixelFormat == PXTextureDataPixelFormat_LA88)
	{
		_byteCount = height * width * 3;
		tempData = malloc(_byteCount);
		//tempData = malloc(height * width * 3);

		inPixel8 = (unsigned char *)_data;
		outPixel8 = (unsigned char *)tempData;

		for (i = 0; i < width * height; ++i)
		{
			*outPixel8++ = *inPixel8++;
			inPixel8 += 2;
			*outPixel8++ = *inPixel8++;
		}

		free(_data);

		_data = tempData;
#ifdef PIXELWAVE_DEBUG
		PXDebugLog(@"Falling off fast-path converting pixel data from RGBA8888 to LA88");
#endif
	}
	////////////////////

	textureInfo->pixelFormat = _pixelFormat;
	textureInfo->size = CGSizeMake(width, height);
	contentSize = CGSizeMake(imageSize.width, imageSize.height);

	//context = _context;
	// Holds a strong reference. Gets free()d in [PXTextureParser dealloc]
	textureInfo->bytes = _data;
	textureInfo->byteCount = _byteCount;

	return YES;
}

#pragma mark Protected Methods

//////////////////////////////////////
// Protected method implementations //
//////////////////////////////////////

- (id) _initWithData:(NSData *)_data
			modifier:(id<PXTextureModifier>)_modifier
			  origin:(NSString *)_origin
{	
	
	UIImage *uiImage = [[UIImage alloc] initWithData:_data];
	cgImage = [uiImage CGImage];
	cgImageOrientation = [uiImage imageOrientation];
	
	self = [super _initWithData:_data modifier:_modifier origin:_origin];
	
	[uiImage release];
	
	return self;
}

/*
 * This is a special initializer that gets called directly
 * (by [PXTextureData initWithCGImage:] and doesn't get passed in by the super.
 */
- (id) initWithCGImage:(CGImageRef)image
		   scaleFactor:(float)scaleFactor
		   orientation:(UIImageOrientation)orientation
			  modifier:(id<PXTextureModifier>)_modifier
{
	cgImage = image;
	cgImageOrientation = orientation;
	
	// This will invoke [_parse]
	self = [super _initWithData:nil modifier:_modifier origin:nil];

	if (self)
	{
		contentScaleFactor = scaleFactor;
	}
	
	return self;
}

- (BOOL) _parse
{
	/*
	UIImage *uiImage = [[UIImage alloc] initWithData:data];

	BOOL s = [self processCGImage:[uiImage CGImage]
					  orientation:[uiImage imageOrientation]
						sizeToFit:NO
					  pixelFormat:0];

	[uiImage release];
	 */
	
	BOOL s = [self processCGImage:cgImage
					  orientation:cgImageOrientation
						sizeToFit:NO
					  pixelFormat:0];

	cgImage = 0;
	cgImageOrientation = 0;

	return s;
}

@end
