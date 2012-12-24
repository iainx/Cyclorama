//
//  VideoPlayerBox.m
//  Cyclorama
//
//  Created by iain on 09/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoPlayerBox.h"
#import "VideoPlayerView.h"
#import "SLFLabel.h"

@implementation VideoPlayerBox {
    NSSlider *_rateSlider;
    CGFloat _videoRate;
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
    [box->_rateSlider setAction:@selector(rateChanged:)];
    [box->_rateSlider setTarget:box];
    
    box->_videoRate = 1.0;
    [box->_rateSlider setFloatValue:box->_videoRate];
    [box->_rateSlider setMaxValue:2.0];
    [box->_rateSlider setMinValue:0.0];
    
    SLFLabel *label = [[SLFLabel alloc] initWithString:@"Rate:"];
    [box addToolbarItem:label
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

- (NSSize)intrinsicContentSize
{
    return NSMakeSize(540.0, NSViewNoInstrinsicMetric);
}

#pragma mark - Stuff

- (void)testAction:(id)sender
{
    NSLog(@"Test clicked");
}

- (void)rateChanged:(id)sender
{
    _videoRate = [_rateSlider floatValue];
    [_playerView setRate:_videoRate];
}
@end
