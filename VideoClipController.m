//
//  VideoFileController.m
//  Flare
//
//  Created by iain on 31/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QTKit/QTKit.h>

#import "VideoClipController.h"
#import "VideoClipCell.h"
#import "VideoClip.h"

@implementation VideoClipController {
    NSMutableArray *filesForThumbnailing;
    CFRunLoopObserverRef observerRef;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    videoQuery = [[NSMetadataQuery alloc] init];
    filesForThumbnailing = [[NSMutableArray alloc] init];
    
    // We listen to any notification from the query
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(queryNotification:) 
               name:nil object:videoQuery];
    
    [videoQuery setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(NSString *)kMDItemTitle ascending:YES] autorelease]]];
    
    [videoQuery setPredicate:[NSPredicate predicateWithFormat:@"(kMDItemContentTypeTree == 'public.movie')"]];
    [videoQuery startQuery];
    
    return self;
}

- (void)dealloc
{
    [self stopIdleLoop];
    
    [filesForThumbnailing release];
    filesForThumbnailing = nil;
    
    [super dealloc];
}

#pragma mark - Local methods

- (void)queryNotification:(NSNotification *)note
{
    if ([[note name] isEqualToString:NSMetadataQueryDidStartGatheringNotification]) {
        NSLog(@"Started gathering information");
    } else if ([[note name] isEqualToString:NSMetadataQueryDidUpdateNotification]) {
        NSLog(@"Updated information");
    } else if ([[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification]) {
        NSLog(@"query finished");
        NSArray *results = [[note object] results];
        NSUInteger count = [results count];
        
        NSLog(@"Found %lu videos", count);

        for (NSMetadataItem *item in results) {
            NSString *path = [[item valueForAttribute:(NSString *)kMDItemPath] stringByResolvingSymlinksInPath];
            if ([path hasSuffix:@".flv"]) {
                continue;
            }
            
            NSString *title = [item valueForAttribute:(NSString *)kMDItemTitle];
            
            if (title == nil) {
                title = [path lastPathComponent];
            }
            
            VideoClip *clip = [[VideoClip alloc] initWithFilePath:path title:title];
            [self addObject:clip];
            
            [filesForThumbnailing addObject:clip];
        }
        [self startIdleLoop];
    } else if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification]) {
        NSLog(@"progress update");
    }
}

static void
dequeueAndThumbnail (CFRunLoopObserverRef ref,
                     CFRunLoopActivity activity,
                     void *info)
{
    VideoClipController *self = (__bridge VideoClipController *)info;
    
    NSLog(@"Dequeuing one");
    [self dequeueVideoItem];
}

- (void)startIdleLoop
{
    int activities = kCFRunLoopBeforeWaiting;
    
    CFRunLoopObserverContext ctxt = {0, (void *)(self), NULL, NULL, NULL};
    observerRef = CFRunLoopObserverCreate(NULL, activities, YES, 0,
                                          &dequeueAndThumbnail, &ctxt);
    CFRunLoopAddObserver(CFRunLoopGetCurrent(),
                         observerRef,
                         kCFRunLoopCommonModes);
}

- (void)stopIdleLoop
{
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(),
                            observerRef, kCFRunLoopCommonModes);
    CFRelease(observerRef);
}

- (void)dequeueVideoItem
{
    VideoClip *clip = [filesForThumbnailing objectAtIndex:0];
    
    NSLog(@"Dequeuing one");
    
    [filesForThumbnailing removeObjectAtIndex:0];
    if ([filesForThumbnailing count] == 0) {
        [self stopIdleLoop];
    }

    [clip openMovie];
}

#pragma mark - NSTableViewDelegate methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *videoTable = [notification object];
    NSInteger row = [videoTable selectedRow];
    if (row == -1) {
        return;
    }
    
    [self setSelectionIndex:row];
}

#pragma mark - NSTableViewDataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[self arrangedObjects] count];
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    VideoClip *clip = [[self arrangedObjects] objectAtIndex:row];
    return [clip title];
}

- (void)tableView:(NSTableView *)tableView 
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row
{
    VideoClip *clip = [[self arrangedObjects] objectAtIndex:row];
    VideoClipCell *vcCell = (VideoClipCell *)cell;
    
    [vcCell setImage:[clip thumbnail]];
    
    [vcCell setSubtitle:@"Duration:"];
}

#pragma mark - NSTableViewDataSource Drag methods

- (BOOL)tableView:(NSTableView *)tableView 
        writeRows:(NSArray *)rows 
     toPasteboard:(NSPasteboard *)pboard
{
    NSMutableArray *filePaths = [NSMutableArray arrayWithCapacity:[rows count]];
    NSData *data;
    
    NSLog(@"writeRows");
    for (NSNumber *number in rows) {
        NSUInteger row = [number unsignedIntValue];
        VideoClip *clip = [[self arrangedObjects] objectAtIndex:row];
        [filePaths addObject:[clip filePath]];
    }
    
    [pboard declareTypes:[NSArray arrayWithObject:FlareVideoClipArrayType] owner:nil];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:filePaths];
    [pboard setData:data forType:FlareVideoClipArrayType];
    
    return YES;
}
@end
