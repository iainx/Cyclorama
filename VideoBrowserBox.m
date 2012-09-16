//
//  VideoBrowserBox.m
//  Cyclorama
//
//  Created by iain on 16/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "VideoBrowserBox.h"

@implementation VideoBrowserBox

- (void)doInit
{
    [self setTitle:@"Video Browser"];
    [self setHasToolbar:NO];
    [self setHasCloseButton:NO];
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
@end
