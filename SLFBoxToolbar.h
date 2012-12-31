//
//  SLFBoxToolbar.h
//  Cyclorama
//
//  Created by iain on 31/12/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SLFBoxToolbar : NSView

typedef enum {
    SLFToolbarItemLayoutNone = 0x0,
    SLFToolbarItemLayoutPackEnd = 0x1
} SLFToolbarItemLayoutOptions;

- (void)addToolbarItem:(NSView *)view
           withOptions:(SLFToolbarItemLayoutOptions)options;

@end
