//
//  CycDocument.m
//  Cyclorama
//
//  Created by Iain Holmes on 31/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import <Quartz/Quartz.h>

#import "ActorFilter.h"
#import "CycAppDelegate.h"
#import "CycArrayController.h"
#import "CycDocument.h"
#import "StageView.h"
#import "VideoLayer.h"
#import "VideoClipController.h"
#import "VideoClip.h"
#import "CycFilterUIView.h"
#import "FilterModel.h"
#import "FilterBrowserBox.h"
#import "VideoBrowserBox.h"
#import "VideoPlayerBox.h"
#import "VideoPlayerView.h"
#import "SLFHorizontalLayout.h"
#import "FilterControlBox.h"
#import "FilterItem.h"

@implementation CycDocument {
    NSMutableArray *_layers;
    CycArrayController *_layerController;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    _layers = [[NSMutableArray alloc] init];
    _layerController = [[CycArrayController alloc] initWithContent:_layers];
    
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"CycDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    NSRect bottomBounds = [_bottomLayout bounds];
    NSRect topBounds = [_topLayout bounds];
    
    [super windowControllerDidLoadNib:aController];
    
    _filterBrowserBox = [[FilterBrowserBox alloc] initWithFrame:NSMakeRect(0.0, 0.0, 236.0, bottomBounds.size.height)];
    _videoBrowserBox = [[VideoBrowserBox alloc] initWithFrame:NSMakeRect(0.0, 0.0, 540.0, bottomBounds.size.height)];
    _videoPlayerBox = [[VideoPlayerBox alloc] initWithFrame:NSMakeRect(0.0, 0.0, 540.0, topBounds.size.height)];
    _filterControlBox = [[FilterControlBox alloc] initWithFrame:NSMakeRect(0.0, 0.0, 0.0, bottomBounds.size.height)];
    
    VideoPlayerView *playerView = [_videoPlayerBox playerView];
    [playerView setLayerController:_layerController];
    
    [_layerController addObject:[[VideoLayer alloc] init]];
    
    [_topLayout addChild:_videoPlayerBox withOptions:SLFHorizontalLayoutFixedWidth];
    [_topLayout addChild:_filterControlBox withOptions:SLFHorizontalLayoutNone];
    
    [_bottomLayout addChild:_videoBrowserBox withOptions:SLFHorizontalLayoutNone];
    [_bottomLayout addChild:_filterBrowserBox withOptions:SLFHorizontalLayoutFixedWidth];
    
    FilterModel *model = [[NSApp delegate] filterModel];
    [_filterBrowserBox setFilterModel:model];
    [_filterBrowserBox setViewDelegate:self];
    
    VideoClipController *clipController = [[NSApp delegate] clipController];
    [_videoBrowserBox setClipController:clipController];
    
    [clipController addObserver:self
                     forKeyPath:@"selectionIndex"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
}

- (void)addFilter:(FilterItem *)item
{
    VideoPlayerView *playerView = [_videoPlayerBox playerView];
    VideoLayer *layer = [playerView currentLayer];
    
    ActorFilter *af = [[ActorFilter alloc] initWithFilterItem:item];
    
    [layer addFilter:af atIndex:0];
    NSLog(@"Add Filter: %@", [item description]);
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == [[NSApp delegate] clipController] && [keyPath isEqualToString:@"selectionIndex"]) {
        VideoClipController *clipController = (VideoClipController *)object;
        
        NSUInteger selectedIndex = [clipController selectionIndex];
        if (selectedIndex > 100) {
            return;
        }
        VideoClip *selectedClip = [[clipController arrangedObjects] objectAtIndex:selectedIndex];
        
        VideoPlayerView *playerView = [_videoPlayerBox playerView];
        [playerView setClip:selectedClip];
        
        NSLog(@"%@: %@", keyPath, [change description]);
        return;
    }
    
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    /*
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver finishEncoding];
    
    return data;
     */
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    //NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    //NSMutableArray *newVideoList = [unarchiver decodeObjectForKey:@"videos"];
    //NSMutableArray *newFilterList = [unarchiver decodeObjectForKey:@"filters"];
    
    //[self setVideos:newVideoList];
    //[self setFilters:newFilterList];
    
    //[unarchiver finishDecoding];
    //[unarchiver release];
    
    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

#pragma mark - UI Actions
- (IBAction)playSet:(id)sender
{
    NSLog(@"play clicked");
}

- (IBAction)stopSet:(id)sender
{
    NSLog(@"Stop clicked");
}

#pragma mark - Filter table methods

@end
