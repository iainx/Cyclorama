//
//  VideoPlayerView.h
//  Cyclorama
//
//  Created by iain on 15/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class StageView;

@interface VideoPlayerView : NSView

@property (readwrite, weak) IBOutlet StageView *stageView;
@property (readwrite, weak) IBOutlet NSButton *previousClipButton;
@property (readwrite, weak) IBOutlet NSButton *playClipButton;
@property (readwrite, weak) IBOutlet NSButton *nextClipButton;

@end
