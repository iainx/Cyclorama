//
//  VideoBrowserView.h
//  Cyclorama
//
//  Created by iain on 19/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VideoClipController;

@interface VideoBrowserView : NSView

@property (readwrite, nonatomic, strong) VideoClipController *videoClipController;

- (id)initWithVideoClipController:(VideoClipController *)controller width:(CGFloat)width;

@end
