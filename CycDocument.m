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

@implementation CycDocument

@synthesize filters;
@synthesize filterController;
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

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    [stageView setLayerController:layerController];
    
    [layerController setContent:layers];
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
@end
