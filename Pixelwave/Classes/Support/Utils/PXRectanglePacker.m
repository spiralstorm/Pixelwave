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

#import "PXRectanglePacker.h"

#include "PXMathUtils.h"
#include "PXPrivateUtils.h"

typedef struct
{
	CGRect *rect;

	float area;

	int index;
} PXAreaRectangle;

PXInline int PXRectanglePackerComparer(const void *element1, const void *element2);

@interface PXRectanglePacker(Private)
+ (BOOL) packRectangles:(PXAreaRectangle *)rectangles
				  count:(unsigned)count
				   size:(CGSize)size
				padding:(unsigned)padding
		   minRectWidth:(unsigned)minRectWidth;
@end

@implementation PXRectanglePacker

+ (CGSize) packRectangles:(CGRect *)rects count:(unsigned)count padding:(unsigned)padding
{
	// If we have no rectangles, then no size is consumed.
	if (!count)
		return CGSizeMake(0, 0);

	// The minimum width of a rectangle
	unsigned minRectWidth = INT_MAX;

	// The rectangles we will sort.
	PXAreaRectangle rectangles[count];
	float totalArea = 0;
	unsigned index = 0;

	// Loop through the rectangles assigning their initial values and storing
	// the pointer to the rectangle the user wishes to be pact.
	PXAreaRectangle *rectangle = rectangles;
	CGRect *rect = rects;
	for (index = 0; index < count; ++index, ++rectangle, ++rect)
	{
		rectangle->rect = rect;

		// If your width is less then the minium, change the minimum to
		// represent this.
		if (minRectWidth > rectangle->rect->size.width && (int)rectangle->rect->size.width > 0)
		{
			minRectWidth = rectangle->rect->size.width;
		}

		// Initial index is -1 (not indexed yet).
		rectangle->index = -1;

		// Calculate out the area of the rectangle, and add to the total area.
		rectangle->area = (rectangle->rect->size.width + padding) * (rectangle->rect->size.height + padding);
		totalArea += rectangle->area;
	}

	// Lets sort the rectangles.
	heapsort(rectangles, count, sizeof(PXAreaRectangle), PXRectanglePackerComparer);

	// Make a guess as to how large the texture should be, right now I am going
	// to guess an equal width and height based off the total area.
	CGSize textureSize;

	unsigned short sqrtArea = ceilf(sqrtf(totalArea));

	// We need a power of two for the size, so lets calculate out the nearest
	// power of two that is equal or larger then original guess (thus allowing
	// the rectangles to fit within it).
	unsigned short powOfTwo = PXMathNextPowerOfTwo(sqrtArea);

	// The width and height are the same size, and they must be a power of two.
	textureSize.width  = powOfTwo;
	textureSize.height = textureSize.width;

	// Attempt to pact the rectangles into the given area, if we fail, try again
	// with a larger rectangle.
	while (![PXRectanglePacker packRectangles:rectangles
										count:count
										 size:textureSize
									  padding:padding
								 minRectWidth:minRectWidth])
	{
		// Because the rectangles will be in a different order, we gotta reset
		// the indices back to -1 (not indexed yet).
		for (index = 0, rectangle = rectangles; index < count; ++index, ++rectangle)
			rectangle->index = -1;

		// The width and height must always be equal, and a power of two.  So,
		// if it didn't work out, we try again at a larger (multiple of two)
		// size.
		textureSize.width *= 2.0f;
		textureSize.height = textureSize.width;
	}

	return textureSize;
}

+ (BOOL) packRectangles:(PXAreaRectangle *)rectangles
				  count:(unsigned)count
				   size:(CGSize)size
				padding:(unsigned)padding
		   minRectWidth:(unsigned)minRectWidth
{
	minRectWidth += padding;

	unsigned index = 0;
	PXAreaRectangle *rectangle = rectangles;

	// The bounding area for the rectangle.
	unsigned short xMin = padding;
	unsigned short yMin = padding;
	unsigned short xMax;
	unsigned short yMax;

	// The height of the current row
	unsigned short rowHeight = rectangle->rect->size.height;
	// If 
	BOOL found;

	// Information about more indepth packing.
	PXAreaRectangle *nextRectangle = rectangles;
	unsigned curIndex;
	unsigned nextIndex;
	unsigned nextDist;
	for (index = 0; index < count; ++index, ++rectangle)
	{
		// If the rectangle has already been indexed, then it has already been
		// placed... so we can ignore it.
		if (rectangle->index >= 0)
			continue;

		// The bounding area for the rect in question.
		xMax = xMin + rectangle->rect->size.width;
		yMax = yMin + rectangle->rect->size.height;

		// If our max position is outside the bounds, do a quick check to see if
		// anything else can fit in it's stead, if not, then increment down a
		// row and continue onward.
		if (xMax >= size.width)
		{
			// The distance from our current spot to the wall.
			nextDist = size.width - xMin;

			found = YES;
			curIndex = index;

			// If the distance from the current spot to the wall is greater then
			// the minimum rectangle width, then it is forseeable that another
			// rectangle can fit in that spot.  So, lets find it and place it
			// there.
			while ((nextDist > minRectWidth) && found)
			{
				// Set found to NO, so that if we fail finding one, we will not
				// continue trying.
				found = NO;

				// We want to check if another rectangle can fit in the open
				// spot, we know that anything past the current location is
				// either of equal height or shorter then the row, so any
				// rectangle past this point is a canadidate.
				for (nextIndex = curIndex + 1, nextRectangle = rectangle + 1; nextIndex < count; ++nextIndex, ++nextRectangle)
				{
					// If the rectangle was already placed, we aren't going to
					// move it.
					if (nextRectangle->index >= 0)
						continue;

					// If the rectangle can fit in the spot, then we have found
					// one!  Place it there, and carry on.
					if (nextRectangle->rect->size.width + padding < nextDist)
					{
						nextRectangle->rect->origin.x = xMin;
						nextRectangle->rect->origin.y = yMin;
						nextRectangle->index = nextIndex;

						xMin += nextRectangle->rect->size.width + padding;
						found = YES;
						curIndex = nextIndex;

						break;
					}
				}

				nextDist = size.width - xMin;
			}

			// Once we are done filling the gap, we increment down a row.
			yMin += rowHeight + padding;
			xMin = padding;

			// Gotta grab the new row height, this will always be correct as the
			// rectangles are sorted by height; thus nothing past this point
			// will be taller.
			rowHeight = rectangle->rect->size.height;

			// Grab the new bounds
			xMax = xMin + rectangle->rect->size.width;
			yMax = yMin + rectangle->rect->size.height;
		}

		// If the bounds still don't fit, then the current working rectangle is
		// unusable.
		if (xMax >= size.width || yMax >= size.height)
			return NO;

		// Set the location of the rectangle.
		rectangle->rect->origin.x = xMin;
		rectangle->rect->origin.y = yMin;
		rectangle->index = index;

		// Increment the position for the next rectangle.
		xMin += rectangle->rect->size.width + padding;
	}

	return YES;
}

@end

PXInline int PXRectanglePackerComparer(const void *element1, const void *element2)
{
	if (!element1 || !element2)
	{
		return 0;
	}

	PXAreaRectangle *rect1 = (PXAreaRectangle *)element1;
	PXAreaRectangle *rect2 = (PXAreaRectangle *)element2;

	bool heightGreater  = (int)rect1->rect->size.height > (int)rect2->rect->size.height;
	bool heightEqual    = (int)rect1->rect->size.height == (int)rect2->rect->size.height;
	short areaGreater   = (int)rect1->area > (int)rect2->area;

	// We want the largest to be in the front, so we are giving backwards
	// results.
	if ((heightGreater) || (heightEqual && areaGreater))
	{
		return -1;
	}

	if (heightEqual)
		return 0;

	return 1;
}
