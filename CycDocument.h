//
//  CycDocument.h
//  Cyclorama
//
//  Created by Iain Holmes on 31/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FilterBrowserDelegate.h"

@class FilterBrowserBox;
@class FilterControlBox;
@class VideoBrowserBox;
@class VideoPlayerBox;
@class SLFHorizontalLayout;

@interface CycDocument : NSDocument <FilterBrowserDelegate>

@property (readwrite, strong) FilterBrowserBox *filterBrowserBox;
@property (readwrite, strong) VideoBrowserBox *videoBrowserBox;
@property (readwrite, strong) VideoPlayerBox *videoPlayerBox;
@property (readwrite, strong) FilterControlBox *filterControlBox;

@property (readwrite, weak)IBOutlet SLFHorizontalLayout *topLayout;
@property (readwrite, weak)IBOutlet SLFHorizontalLayout *bottomLayout;

@end
