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
#import "CycFilterUIView.h"

@implementation CycDocument

@synthesize filters;
@synthesize filterController;
@synthesize filterTableView;
@synthesize filterUIBox;
@synthesize filterScrollView;
@synthesize layers;
@synthesize layerController;
@synthesize stageView;
@synthesize videos;
@synthesize videoClipController;
@synthesize videoClipCollectionView;

- (id)init
{
    self = [super init];
    if (self) {
        layers = [[NSMutableArray alloc] init];
        [layers addObject:[[[VideoLayer alloc] init] autorelease]];
        
        filters = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"CycDocument";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"keypath: %@ - %@", keyPath, [change description]);
    
    if ([keyPath isEqualToString:@"selection"]) {
        //VideoClip *selectedClip = [videoClipController selection];
        NSArray *selectedObjects = [videoClipController selectedObjects];
        
        if ([selectedObjects count] == 0) {
            return;
        }
        
        VideoClip *selectedClip = [selectedObjects objectAtIndex:0];
        NSLog(@"Video clip: %@", [selectedClip description]);
    
        [stageView setVideoClip:selectedClip];
    }
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    [stageView setLayerController:layerController];
    /*
    [stageView bind:@"videoClip"
           toObject:videoClipController
        withKeyPath:@"selection"
            options:nil];
    */
    [videoClipController addObserver:self
                          forKeyPath:@"selection"
                             options:0
                             context:NULL];
    
    [layerController setContent:layers];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(filterSelectionDidChange:)
               name:NSTableViewSelectionDidChangeNotification
             object:filterTableView];
    [nc addObserver:self
           selector:@selector(filterValueDidChange:)
               name:CycFilterValueChangedNotification
             object:nil];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:videoClipController forKey:@"videos"];
    [archiver encodeObject:filters forKey:@"filters"];
    [archiver finishEncoding];
    
    return data;
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

- (void)addFilterSheetDidEnd:(NSWindow *)sheet 
                  returnCode:(NSInteger)code
                 contextInfo:(void *)contextInfo
{
    IKFilterBrowserPanel *filterBrowserPanel = (IKFilterBrowserPanel *)contextInfo;

    // There appears to be a bug where NSCancelButton is sent when the OK button is clicked
    if (code == 0) {
        ActorFilter *af = [[ActorFilter alloc] initWithName:nil 
                                             forFilterNamed:[filterBrowserPanel filterName]];
        [filterController addObject:af];
        [af release];
    }

    [filterBrowserPanel orderOut:self];
    [filterBrowserPanel release];
}

- (IBAction)openAddFilterSheet:(id)sender
{    
    [CIPlugIn loadAllPlugIns];
    
    IKFilterBrowserPanel *filterBrowserPanel = [[IKFilterBrowserPanel 
                                                 filterBrowserPanelWithStyleMask:0] retain];
    [filterBrowserPanel beginSheetWithOptions:NULL
                               modalForWindow:[stageView window]
                             modalDelegate:self 
                               didEndSelector:@selector(addFilterSheetDidEnd:returnCode:contextInfo:) contextInfo:filterBrowserPanel];
}

- (IBAction)playSet:(id)sender
{
    
}

- (IBAction)stopSet:(id)sender
{

}

#pragma mark - VideoFileControllerDelegate methods

- (void)videoSelected:(QTMovie *)_video
{
    /*
    NSLog(@"Video selected");
    [self setVideo:_video];
     */
}

#pragma mark - Notification methods

- (void)filterSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = [notification object];
    NSInteger selectedRow = [tableView selectedRow];
    
    if (selectedRow == -1) {
        // Remove filter view
        currentFilterView = nil;
        return;
    }
    
    if (currentFilterView) {
        [currentFilterView removeFromSuperview];
        currentFilterView = nil;
    }
    ActorFilter *selectedFilter = [filters objectAtIndex:selectedRow];
    
    NSLog(@"Filter selection did change %ld - %@", selectedRow, [selectedFilter name]);
    CIFilter *currentFilter = [stageView filterForCurrentLayerAt:selectedRow];
    NSRect stageViewRect = [stageView frame];
    
    currentFilterView = [[[CycFilterUIView alloc] initWithFilter:currentFilter 
                                                  forScreenWidth:stageViewRect.size.width
                                                    screenHeight:stageViewRect.size.height] autorelease];

    [filterScrollView setDocumentView:currentFilterView];
}

- (void)filterValueDidChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *paramName = [userInfo objectForKey:@"paramName"];
    id value = [userInfo objectForKey:@"value"];
    
    NSInteger selectedRow = [filterTableView selectedRow];
    
    CIFilter *currentFilter = [stageView filterForCurrentLayerAt:selectedRow];
    NSString *filterName = [currentFilter name];
    
    NSString *keypath = [NSString stringWithFormat:@"filters.%@.%@", filterName, paramName];
    
    NSLog(@"Changing %@", keypath);
    VideoLayer *currentLayer = [layers objectAtIndex:0];
    
    [currentLayer setValue:value forKeyPath:keypath];
}
@end
