//
//  VideoPlayerView.h
//  Cyclorama
//
//  Created by iain on 22/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VideoClip;
@interface VideoPlayerView : NSView

@property (readwrite, strong) VideoClip *clip;

- (void)resizeAndPositionVideoLayer;

@end
