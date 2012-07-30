//
//  VideoClipView.h
//  Cyclorama
//
//  Created by Iain Holmes on 30/10/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VideoClip;

@interface VideoClipView : NSView {
@private
    NSProgressIndicator *progressIndicator;
    
    NSImage *thumbnail;
    VideoClip *clip;
    
    dispatch_queue_t thumbnail_queue;
    dispatch_queue_t main_queue;
}

@property (readwrite, strong) IBOutlet VideoClip *clip;
@property (readwrite, strong) NSImage *thumbnail;
@end
