//
//  CycAppDelegate.m
//  Cyclorama
//
//  Created by Iain Holmes on 08/09/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "CycAppDelegate.h"
#import "VideoClipController.h"
#import "FilterModel.h"
#import "FilterBrowserView.h"
#import "FilterBrowserWindowController.h"

@implementation CycAppDelegate {
    FilterModel *_filterModel;
    FilterBrowserWindowController *_filterBrowserController;
}

- (id)init
{
    self = [super init];
    if (self) {
    }

    _filterModel = [[FilterModel alloc] init];

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    _filterBrowserController = [[FilterBrowserWindowController alloc] init];
    FilterBrowserView *filterBrowser = [[FilterBrowserView alloc] initWithFilterModel:_filterModel];
    
    [_filterBrowserController showWindow:self];
    [[_filterBrowserController scrollView] setDocumentView:filterBrowser];
}
@end
