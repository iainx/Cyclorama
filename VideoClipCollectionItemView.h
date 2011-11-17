//
//  VideoClipCollectionItemView.h
//  Cyclorama
//
//  Created by Iain Holmes on 02/11/2011.
//  Copyright (c) 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VideoClipView;
@class VideoClip;

@interface VideoClipCollectionItemView : NSView {
@private
    VideoClipView *clipView;
}

@property (readwrite, retain) VideoClipView *clipView;

- (void)setClip:(VideoClip *)clip;
@end
