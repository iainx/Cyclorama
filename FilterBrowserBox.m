//
//  FilterBrowserBox.m
//  Cyclorama
//
//  Created by iain on 16/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "FilterBrowserBox.h"
#import "FilterBrowserView.h"

@implementation FilterBrowserBox {
    NSScrollView *_scrollView;
    FilterBrowserView *_filterBrowserView;
}

- (void)doInit
{
    [self setHasToolbar:NO];
    [self setHasCloseButton:YES];
    [self setTitle:@"Filter Browser"];
    [self setSolidBackground:NO];
    
    _scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [_scrollView setDrawsBackground:NO];
    [_scrollView setHasVerticalScroller:YES];
    
    [self setContentView:_scrollView];
    
    _filterBrowserView = [[FilterBrowserView alloc] initWithFilterModel:nil];
    [_scrollView setDocumentView:_filterBrowserView];
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

- (void)setFilterModel:(FilterModel *)model
{
    [_filterBrowserView setModel:model];
}

@end
