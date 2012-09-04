//
//  VideoLayer.h
//  Cyclorama
//
//  Created by Iain Holmes on 29/09/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class CycArrayController;

@interface VideoLayer : AVPlayerLayer

@property (readwrite, strong) NSArrayController *videoController;

- (void)addFilter:(CIFilter *)filter atIndex:(NSUInteger)index;
- (void)removeFilterAtIndex:(NSUInteger)index;
- (CIFilter *)filterAtIndex:(NSUInteger)index;
@end
