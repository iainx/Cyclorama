//
//  VideoPlayerBox.m
//  Cyclorama
//
//  Created by iain on 09/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoPlayerBox.h"

@implementation VideoPlayerBox

static void
do_init (VideoPlayerBox *box)
{
    [box setHasCloseButton:NO];
    [box setHasToolbar:YES];
    [box setTitle:@"Preview"];
    
    [box addToolbarButtonWithLabel:@"Test 1" action:@selector(testAction:) target:box];
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
