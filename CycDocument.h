//
//  CycDocument.h
//  Cyclorama
//
//  Created by Iain Holmes on 31/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CycArrayController;
@class StageView;
@class VideoClipController;
@class CycFilterUIView;
@class FilterBrowserBox;
@class FilterControlBox;
@class VideoBrowserBox;
@class VideoPlayerBox;
@class SLFHorizontalLayout;

@interface CycDocument : NSDocument

@property (readwrite, strong)NSMutableArray *layers;
@property (readwrite, strong) FilterBrowserBox *filterBrowserBox;
@property (readwrite, strong) VideoBrowserBox *videoBrowserBox;
@property (readwrite, strong) VideoPlayerBox *videoPlayerBox;
@property (readwrite, strong) FilterControlBox *filterControlBox;

@property (readwrite, strong)IBOutlet CycArrayController *layerController;
@property (readwrite, strong)IBOutlet CycArrayController *filterController;

@property (readwrite, weak)IBOutlet StageView *stageView;
@property (readwrite, weak)IBOutlet NSScrollView *filterScrollView;

@property (readwrite, weak)IBOutlet SLFHorizontalLayout *topLayout;
@property (readwrite, weak)IBOutlet SLFHorizontalLayout *bottomLayout;

@end
