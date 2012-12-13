//
//  FilterControlBox.m
//  Cyclorama
//
//  Created by iain on 03/11/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "FilterControlBox.h"
#import "FilterControlView.h"

@implementation FilterControlBox

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setHasToolbar:NO];
        [self setHasCloseButton:NO];
        [self setTitle:@"Filter Control"];
        
        _filterControlView = [[FilterControlView alloc] init];
        [self setContentView:_filterControlView];
    }
    
    return self;
}

@end
