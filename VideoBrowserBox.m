//
//  VideoBrowserBox.m
//  Cyclorama
//
//  Created by iain on 16/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoBrowserBox.h"
#import "VideoBrowserView.h"

@implementation VideoBrowserBox {
    NSScrollView *_scrollView;
    VideoBrowserView *_videoBrowserView;
}

- (void)doInit
{
    [self setTitle:@"Video Browser"];
    [self setHasToolbar:YES];
    [self setHasCloseButton:NO];
    
    _scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [_scrollView setDrawsBackground:NO];
    [_scrollView setHasVerticalScroller:YES];
    
    [self setContentView:_scrollView];
    
    
    // FIXME: This shouldn't set the width here
    _videoBrowserView = [[VideoBrowserView alloc] initWithVideoClipController:nil
                                                                        width:[_scrollView frame].size.width];
    [_videoBrowserView setAutoresizingMask:NSViewWidthSizable];
    [_scrollView setDocumentView:_videoBrowserView];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    
    return self;
}

#pragma mark - Property accessors

- (void)setClipController:(VideoClipController *)clipController
{
    [_videoBrowserView setVideoClipController:clipController];
}

#pragma mark - Constraints

- (NSSize)intrinsicContentSize
{
    // Set a minimum height for the box.
    return NSMakeSize(NSViewNoInstrinsicMetric, 200.0);
}

@end
