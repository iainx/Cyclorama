//
//  VideoBrowserView.m
//  Cyclorama
//
//  Created by iain on 19/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoBrowserView.h"
#import "VideoClipLayer.h"
#import "VideoClipController.h"
#import "VideoClip.h"

@implementation VideoBrowserView {
    NSTrackingArea *trackingArea;
    int itemsPerRow;
}

#define BROWSER_GUTTER_SIZE 10
#define BROWSER_SPACING_SIZE 10

- (void)doVideoBrowserViewInit
{
    [self setWantsLayer:YES];
    
    CGFloat width = [self frame].size.width;
    itemsPerRow = (width - BROWSER_GUTTER_SIZE) / (150 + BROWSER_SPACING_SIZE);

    [self createTrackingArea];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self doVideoBrowserViewInit];
    
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
    
    [self doVideoBrowserViewInit];
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

- (void)layoutFromIndex:(NSUInteger)index
               forWidth:(CGFloat)width
{
    NSArray *sublayers = [[self layer] sublayers];
    NSUInteger i;
    NSUInteger row, col;

    row = index / itemsPerRow;
    col = index % itemsPerRow;
    
    float x = BROWSER_GUTTER_SIZE + (col * (150 + BROWSER_SPACING_SIZE));
    float y = BROWSER_GUTTER_SIZE + (row * (150 + BROWSER_SPACING_SIZE));

    for (i = index; i  < [sublayers count]; i++) {
        VideoClipLayer *clipLayer = sublayers[i];
        
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
    NSNumber *indexNumber = userInfo[@"index"];
    
    VideoClipLayer *clipLayer = [[VideoClipLayer alloc] initWithClip:clip];
    
    [[self layer] addSublayer:clipLayer];
    [self layoutFromIndex:[indexNumber unsignedIntegerValue]
                 forWidth:[self bounds].size.width];
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
        VideoClipLayer *clipLayer = [[VideoClipLayer alloc] initWithClip:clip];
        
        [[self layer] addSublayer:clipLayer];
    }
    [self layoutFromIndex:0 forWidth:[self bounds].size.width];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    // Relayout
    [self layoutFromIndex:0 forWidth:frameRect.size.width];
}

#pragma mark - Tracking Areas

- (void)mouseDown:(NSEvent *)theEvent
{
    
}

- (void)mouseUp:(NSEvent *)theEvent
{
    
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    
}

- (void)mouseExited:(NSEvent *)theEvent
{
    
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    
}

- (void)createTrackingArea
{
    NSLog(@"Create tracking area");
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
                                                options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |NSTrackingActiveInKeyWindow
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)updateTrackingAreas
{
    [self removeTrackingArea:trackingArea];
    [self createTrackingArea];
    
    [super updateTrackingAreas];
}
@end
