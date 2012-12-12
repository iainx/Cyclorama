//
//  VideoPlayerView.h
//  Cyclorama
//
//  Created by iain on 22/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VideoClip;
@class VideoLayer;
@class CycArrayController;

@interface VideoPlayerView : NSView

@property (readwrite, strong) VideoClip *clip;
@property (readwrite, strong) CycArrayController *layerController;

- (void)resizeAndPositionVideoLayer:(VideoLayer *)videoLayer;
- (void)setRate:(float)rate;
- (VideoLayer *)currentLayer;

@end
