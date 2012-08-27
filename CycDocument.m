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
#import "FilterItemView.h"

@implementation CycDocument {
    CycFilterUIView *_currentFilterView;
    FilterModel *_filterModel;
    FilterItemView *_itemView;
}

- (id)init
{
    self = [super init];
    if (self) {
        _videos = [[NSMutableArray alloc] init];
        _layers = [[NSMutableArray alloc] init];
        [_layers addObject:[[VideoLayer alloc] init]];
        
        _filters = [[NSMutableArray alloc] init];
        
        _filterModel = [[FilterModel alloc] init];
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
        NSArray *selectedObjects = [_videoClipController selectedObjects];
        
        if ([selectedObjects count] == 0) {
            return;
        }
        
        VideoClip *selectedClip = selectedObjects[0];
        NSLog(@"Video clip: %@", [selectedClip description]);
    
        [_stageView setVideoClip:selectedClip];
        return;
    }
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    [_stageView setLayerController:_layerController];
    [_videoClipController addObserver:self
                           forKeyPath:@"selection"
                              options:0
                              context:NULL];
    
    [_layerController setContent:_layers];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(filterSelectionDidChange:)
               name:NSTableViewSelectionDidChangeNotification
             object:_filterTableView];
    
    _itemView = [[FilterItemView alloc] initWithFilterItem:[_filterModel arrangedObjects][4]];
    [_itemView setFrameOrigin:NSMakePoint(500.0, 300.0)];
    [[_stageView superview] addSubview:_itemView];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:_videoClipController forKey:@"videos"];
    [archiver encodeObject:_filters forKey:@"filters"];
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
        [_filterController addObject:af];
        
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
                               modalForWindow:[_stageView window]
                             modalDelegate:self 
                               didEndSelector:@selector(addFilterSheetDidEnd:returnCode:contextInfo:)
                                  contextInfo:(void *)(filterBrowserPanel)];
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

#pragma mark - Filter table methods

- (void)filterSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = [notification object];
    NSInteger selectedRow = [tableView selectedRow];
    
    if (selectedRow == -1) {
        // Remove filter view
        _currentFilterView = nil;
        return;
    }
    
    if (_currentFilterView) {
        [_currentFilterView removeFromSuperview];
        _currentFilterView = nil;
    }
    ActorFilter *selectedFilter = _filters[selectedRow];
    
    NSLog(@"Filter selection did change %ld - %@", selectedRow, [selectedFilter name]);
    //CIFilter *currentFilter = [stageView filterForCurrentLayerAt:selectedRow];
    NSRect stageViewRect = [_stageView frame];
    
    _currentFilterView = [[CycFilterUIView alloc] initWithFilter:selectedFilter
                                                  forScreenWidth:stageViewRect.size.width
                                                    screenHeight:stageViewRect.size.height];

    [_filterScrollView setDocumentView:_currentFilterView];
}

- (IBAction)removeSelectedFilter:(id)sender
{
    if (_currentFilterView) {
        [_currentFilterView removeFromSuperview];
        _currentFilterView = nil;
    }
    
    NSUInteger selectedRow = [_filterController selectionIndex];
    [_filterController removeObjectAtArrangedObjectIndex:selectedRow];
}
@end
