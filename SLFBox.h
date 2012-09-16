//
//  SLFBOX.h
//  Cyclorama
//
//  Created by iain on 15/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SLFBox : NSView

@property (readwrite, copy) NSString *title;
@property (readwrite, strong, nonatomic) NSView *contentView;
@property (readwrite) NSSize contentViewMargins;
@property (readwrite, nonatomic) BOOL hasToolbar;
@property (readwrite, nonatomic) BOOL hasCloseButton;

@end