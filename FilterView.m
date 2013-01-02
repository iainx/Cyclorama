//
//  FilterView.m
//  Cyclorama
//
//  Created by iain on 14/12/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "ActorFilter.h"
#import "FilterView.h"

@implementation FilterView

- (id)initWithFilter:(ActorFilter *)filter
{
    self = [super initWithFrame:NSZeroRect];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect innerRect = NSMakeRect(0.5, 0.5, [self bounds].size.width - 1, [self bounds].size.height - 1);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:innerRect
                                                         xRadius:5.0 yRadius:5.0];
    
    [[NSColor lightGrayColor] set];
    [path stroke];
    
    [[NSColor darkGrayColor] setFill];
    [path fill];
}

- (NSSize)intrinsicContentSize
{
    return NSMakeSize(100.0, 100.0);
}
@end
