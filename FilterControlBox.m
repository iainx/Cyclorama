//
//  FilterControlBox.m
//  Cyclorama
//
//  Created by iain on 03/11/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "FilterControlBox.h"
#import "FilterControlView.h"
#import "FilterView.h"

@implementation FilterControlBox {
    NSScrollView *_scrollView;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setHasToolbar:NO];
        [self setHasCloseButton:NO];
        [self setTitle:@"Filter Control"];
        
        _scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
        [_scrollView setDrawsBackground:NO];
        [_scrollView setHasVerticalScroller:YES];
        [self setContentView:_scrollView];
        
        _filterControlView = [[FilterControlView alloc] init];
        [_filterControlView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_scrollView setDocumentView:_filterControlView];

        // Need to tell the clipView how to lay out the _filterControlView
        NSView *clipView = [_scrollView contentView];
        NSDictionary *viewsDict = @{@"_filterControlView":_filterControlView};
        [clipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_filterControlView]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDict]];
    }
    
    return self;
}

- (void)dumpConstraints
{
    [[self window] visualizeConstraints:[self constraints]];
}
@end
