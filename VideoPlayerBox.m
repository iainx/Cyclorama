//
//  VideoPlayerBox.m
//  Cyclorama
//
//  Created by iain on 09/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoPlayerBox.h"
#import "VideoPlayerView.h"

@implementation VideoPlayerBox {
    NSSlider *_rateSlider;
}

@synthesize playerView = _playerView;

static void
do_init (VideoPlayerBox *box)
{
    [box setHasCloseButton:NO];
    [box setHasToolbar:YES];
    [box setTitle:@"Preview"];
    
    box->_playerView = [[VideoPlayerView alloc] init];
    [box setContentView:box->_playerView];
    
    [box addToolbarButtonWithLabel:@"Test 1"
                           options:SLFToolbarItemLayoutNone
                            action:@selector(testAction:)
                            target:box];
    
    box->_rateSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 18.0)];
    [box addToolbarItem:box->_rateSlider
            withOptions:SLFToolbarItemLayoutPackEnd];
    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    do_init(self);
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    do_init(self);
    
    return self;
}

- (void)testAction:(id)sender
{
    NSLog(@"Test clicked");
}
@end
