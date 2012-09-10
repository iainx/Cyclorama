//
//  VideoBrowserWindowController.h
//  Cyclorama
//
//  Created by iain on 09/09/2012.
//  Copyright (c) 2012 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXListViewDelegate.h"

@class PXListView;
@class VideoClipController;

@interface VideoBrowserWindowController : NSWindowController <PXListViewDelegate>

@property (readwrite, weak) IBOutlet PXListView *listView;
@property (readwrite, strong) VideoClipController *clipController;

@end
