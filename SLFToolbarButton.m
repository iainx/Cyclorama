//
//  SLFButton.m
//  Cyclorama
//
//  Created by iain on 14/10/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import "SLFToolbarButton.h"

@implementation SLFToolbarButton {
}

+ (void)load
{
    [NSButton setCellClass:NSClassFromString(@"SLFButtonCell")];
}

- (id)initWithTitle:(NSString *)title
             action:(SEL)action
             target:(id)target
{
    self = [super initWithFrame:NSZeroRect];
    
    [self setTitle:title];
    [self setTarget:target];
    [self setAction:action];
    
    [self setButtonType:6];
    [self setBordered:YES];
    [self setBezelStyle:NSRegularSquareBezelStyle];
  
    [self setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
                                   forOrientation:NSLayoutConstraintOrientationVertical];
    return self;
}

/*
- (NSSize)intrinsicContentSize
{
    NSSize parentSize = [super intrinsicContentSize];
    parentSize.height = 18.0;
    
    return parentSize;
}
*/
@end
