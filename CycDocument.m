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
#import "SLFHorizontalLayout.h"

@implementation CycDocument

- (id)init
{
    self = [super init];
    if (self) {
        _layers = [[NSMutableArray alloc] init];
        [_layers addObject:[[VideoLayer alloc] init]];
    }
    
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
    
    [_stageView setLayerController:_layerController];
    [_layerController setContent:_layers];
    
    _filterBrowserBox = [[FilterBrowserBox alloc] initWithFrame:NSMakeRect(0.0, 0.0, 236.0, bottomBounds.size.height)];
    _videoBrowserBox = [[VideoBrowserBox alloc] initWithFrame:NSMakeRect(0.0, 0.0, 540.0, bottomBounds.size.height)];
    _videoPlayerBox = [[VideoPlayerBox alloc] initWithFrame:NSMakeRect(0.0, 0.0, 540.0, topBounds.size.height)];
    
    [_topLayout addChild:_videoPlayerBox withOptions:SLFHorizontalLayoutFixedWidth];
    
    [_bottomLayout addChild:_videoBrowserBox withOptions:SLFHorizontalLayoutNone];
    [_bottomLayout addChild:_filterBrowserBox withOptions:SLFHorizontalLayoutFixedWidth];
    
    FilterModel *model = [[NSApp delegate] filterModel];
    [_filterBrowserBox setFilterModel:model];
    
    VideoClipController *clipController = [[NSApp delegate] clipController];
    [_videoBrowserBox setClipController:clipController];
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
    
}

- (IBAction)stopSet:(id)sender
{

}

#pragma mark - Filter table methods

@end
