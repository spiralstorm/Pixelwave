//
//  PXGraphicsData.h
//  Pixelwave
//
//  Created by John Lattin on 11/8/11.
//  Copyright (c) 2011 Spiralstorm Games. All rights reserved.
//

@class PXGraphics;

@protocol PXGraphicsData <NSObject>
@required
- (void) _sendToGraphics:(PXGraphics *)graphics;
@end
