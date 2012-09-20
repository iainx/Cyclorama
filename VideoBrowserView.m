//
//  VideoBrowserView.m
//  Cyclorama
//
//  Created by iain on 19/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoBrowserView.h"
#import "VideoBrowserLayer.h"
#import "VideoClipController.h"
#import "VideoClip.h"

@implementation VideoBrowserView

- (void)doInit
{
    [self setWantsLayer:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self doInit];
    
    return self;
}

- (id)initWithVideoClipController:(VideoClipController *)controller
                            width:(CGFloat)width
{
    NSRect frame = NSZeroRect;
    frame.size.width = width;
    
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self doInit];
    [self setVideoClipController:controller];
    
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

#define BROWSER_GUTTER_SIZE 10
#define BROWSER_SPACING_SIZE 10

- (void)layoutForWidth:(CGFloat)width
{
    NSArray *sublayers = [[self layer] sublayers];

    float x = BROWSER_GUTTER_SIZE;
    float y = BROWSER_GUTTER_SIZE;

    for (VideoBrowserLayer *clipLayer in sublayers) {
        if (x + [clipLayer bounds].size.width >= width - BROWSER_GUTTER_SIZE) {
            x = BROWSER_GUTTER_SIZE;
            y += (BROWSER_SPACING_SIZE + [clipLayer bounds].size.height);
        }
        [clipLayer setPosition:CGPointMake(x, y)];
        x += [clipLayer bounds].size.width + BROWSER_SPACING_SIZE;
    }
    
    [self setFrameSize:NSMakeSize([self frame].size.width, y + 150 + BROWSER_GUTTER_SIZE)];
}

- (void)videoClipAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    VideoClip *clip = userInfo[@"object"];
    VideoBrowserLayer *clipLayer = [[VideoBrowserLayer alloc] initWithClip:clip];
    
    [[self layer] addSublayer:clipLayer];
    [self layoutForWidth:[self bounds].size.width];
}

- (void)videoClipRemoved:(NSNotification *)note
{
    
}

- (void)setVideoClipController:(VideoClipController *)videoClipController
{
    if (_videoClipController == videoClipController) {
        return;
    }

    NSLog(@"set video clip controller");

    _videoClipController = videoClipController;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(videoClipAdded:)
               name:@"ObjectAdded"
             object:videoClipController];
    [nc addObserver:self
           selector:@selector(videoClipRemoved:)
               name:@"ObjectRemoved"
             object:self];
    
    NSArray *clips = [videoClipController arrangedObjects];
    
    for (VideoClip *clip in clips) {
        VideoBrowserLayer *clipLayer = [[VideoBrowserLayer alloc] initWithClip:clip];
        
        [[self layer] addSublayer:clipLayer];
        [self layoutForWidth:[self bounds].size.width];
    }
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    // Relayout
    [self layoutForWidth:frameRect.size.width];
}
@end
