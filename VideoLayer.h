//
//  VideoLayer.h
//  Cyclorama
//
//  Created by Iain Holmes on 29/09/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class ActorFilter;
@class CycArrayController;

@interface VideoLayer : AVPlayerLayer

@property (readonly, strong) CycArrayController *filterController;

- (void)addFilter:(ActorFilter *)filter atIndex:(NSUInteger)index;
- (void)removeFilterAtIndex:(NSUInteger)index;
- (CIFilter *)filterInstanceAtIndex:(NSUInteger)index;
- (NSArray *)actorFilters;

@end
