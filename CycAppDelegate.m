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
#import "VideoBrowserWindowController.h"

@implementation CycAppDelegate {
    NSMutableArray *_videoModel;
    
    FilterBrowserWindowController *_filterBrowserController;
    VideoBrowserWindowController *_videoBrowserController;
}

- (id)init
{
    self = [super init];
    if (self) {
    }

    _filterModel = [[FilterModel alloc] init];
    _videoModel = [[NSMutableArray alloc] init];
    
    _clipController = [[VideoClipController alloc] initWithContent:_videoModel];

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    /*
    _filterBrowserController = [[FilterBrowserWindowController alloc] init];
    FilterBrowserView *filterBrowser = [[FilterBrowserView alloc] initWithFilterModel:_filterModel];
    
    [_filterBrowserController showWindow:self];
    [[_filterBrowserController scrollView] setDocumentView:filterBrowser];
    
    _videoBrowserController = [[VideoBrowserWindowController alloc] init];
    [_videoBrowserController setClipController:_clipController];
    [_videoBrowserController showWindow:self];
     */
}
@end
