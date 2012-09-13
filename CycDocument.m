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
#import "FilterBrowserView.h"

@implementation CycDocument {
    FilterBrowserView *_filterBrowserView;
}

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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    [_stageView setLayerController:_layerController];
    [_layerController setContent:_layers];
    
    FilterModel *model = [[NSApp delegate] filterModel];
    _filterBrowserView = [[FilterBrowserView alloc] initWithFilterModel:model];
    [_filterScrollView setDocumentView:_filterBrowserView];
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
