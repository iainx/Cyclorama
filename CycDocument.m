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
        videos = [[NSMutableArray alloc] init];
        layers = [[NSMutableArray alloc] init];
        [layers addObject:[[VideoLayer alloc] init]];
        
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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"Got keypath: %@", keyPath);
    
    if ([keyPath isEqualToString:@"selection"]) {
        //VideoClip *selectedClip = [videoClipController selection];
        NSArray *selectedObjects = [videoClipController selectedObjects];
        
        if ([selectedObjects count] == 0) {
            return;
        }
        
        VideoClip *selectedClip = selectedObjects[0];
        NSLog(@"Video clip: %@", [selectedClip description]);
    
        [stageView setVideoClip:selectedClip];
        return;
    }
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    [stageView setLayerController:layerController];
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
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableData *data = [[NSMutableData alloc] init];
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
    IKFilterBrowserPanel *filterBrowserPanel = (__bridge IKFilterBrowserPanel *)contextInfo;

    // There is a bug between that was fixed in Mountain Lion (10.8)
    // where the value which the sheet returned was swapped
    // so clicking Cancel returned NSOKButton and clicking OK returned NSCancelButton
    // Swap them around if running on
    if (NSAppKitVersionNumber <= NSAppKitVersionNumber10_7_2) {
        if (code == NSOKButton) {
            code = NSCancelButton;
        } else if (code == NSCancelButton) {
            code = NSOKButton;
        }
    }
    
    if (code == NSOKButton) {
        ActorFilter *af = [[ActorFilter alloc] initWithName:nil 
                                             forFilterNamed:[filterBrowserPanel filterName]];
        [filterController addObject:af];
        
        NSDictionaryController *fc = [[NSDictionaryController alloc] initWithContent:[af parameters]];
        [fc addObserver:self
             forKeyPath:@"arrangedObjects.value"
                options:NSKeyValueObservingOptionNew
                context:NULL];
    }

    [filterBrowserPanel orderOut:self];
}

- (IBAction)openAddFilterSheet:(id)sender
{    
    [CIPlugIn loadAllPlugIns];
    
    IKFilterBrowserPanel *filterBrowserPanel = [IKFilterBrowserPanel 
                                                 filterBrowserPanelWithStyleMask:0];
    [filterBrowserPanel beginSheetWithOptions:NULL
                               modalForWindow:[stageView window]
                             modalDelegate:self 
                               didEndSelector:@selector(addFilterSheetDidEnd:returnCode:contextInfo:) contextInfo:(void *)(filterBrowserPanel)];
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
    ActorFilter *selectedFilter = filters[selectedRow];
    
    NSLog(@"Filter selection did change %ld - %@", selectedRow, [selectedFilter name]);
    //CIFilter *currentFilter = [stageView filterForCurrentLayerAt:selectedRow];
    NSRect stageViewRect = [stageView frame];
    
    currentFilterView = [[CycFilterUIView alloc] initWithFilter:selectedFilter
                                                  forScreenWidth:stageViewRect.size.width
                                                    screenHeight:stageViewRect.size.height];

    [filterScrollView setDocumentView:currentFilterView];
}

@end
