//
//  SLFBOX.h
//  Cyclorama
//
//  Created by iain on 15/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SLFBoxDelegate.h"
#import "SLFBoxToolbar.h"

@interface SLFBox : NSView

@property (readwrite, copy) NSString *title;
@property (readwrite, strong, nonatomic) NSView *contentView;
@property (readwrite, nonatomic) BOOL hasToolbar;
@property (readwrite, nonatomic) BOOL hasCloseButton;
@property (readwrite, getter = isClosed) BOOL closed;

@property (readwrite, weak) id<SLFBoxDelegate> delegate;

- (void)addToolbarItem:(NSView *)view
           withOptions:(SLFToolbarItemLayoutOptions)options;
- (void)addToolbarButtonWithLabel:(NSString *)text
                          options:(SLFToolbarItemLayoutOptions)options
                           action:(SEL)action
                           target:(id)target;

@end