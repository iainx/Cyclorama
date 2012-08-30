//
//  FilterBrowserWindowController.h
//  Cyclorama
//
//  Created by iain on 29/08/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FilterBrowserView;
@interface FilterBrowserWindowController : NSWindowController

@property (readwrite, weak) IBOutlet NSScrollView *scrollView;
@end
