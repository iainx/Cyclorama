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

- (id)initWithContent:(id)content
{
    self = [super initWithContent:content];
    
    [self setSelectsInsertedObjects:NO];
    
    videoQuery = [[NSMetadataQuery alloc] init];
    filesForThumbnailing = [[NSMutableArray alloc] init];
    
    // We listen to any notification from the query
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(queryNotification:) 
               name:nil object:videoQuery];
    
    [videoQuery setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:(NSString *)kMDItemTitle ascending:YES]]];
    
    [videoQuery setPredicate:[NSPredicate predicateWithFormat:@"(kMDItemContentTypeTree == 'public.movie')"]];
    [videoQuery startQuery];
    
    return self;
}

- (void)dealloc
{
    [self stopIdleLoop];
    
    filesForThumbnailing = nil;
    
}

#pragma mark - Local methods

#define VIDEO_LIMIT 50

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
        int limit = 0;
        
        NSLog(@"Found %lu videos", count);

        for (NSMetadataItem *item in results) {
            NSString *path = [[item valueForAttribute:(NSString *)kMDItemPath] stringByResolvingSymlinksInPath];
            if ([path hasSuffix:@".flv"]) {
                continue;
            }
            
            NSString *title = [item valueForAttribute:(NSString *)kMDItemTitle];
            
            if (title == nil) {
                title = [[path lastPathComponent] stringByDeletingPathExtension];
            }
            
            VideoClip *clip = [[VideoClip alloc] initWithFilePath:path title:title];
            [self addObject:clip];
            
            [filesForThumbnailing addObject:clip];
            
            limit++;

#if VIDEO_LIMIT > 0
            if (limit > VIDEO_LIMIT) {
                break;
            }
#endif
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
    
    [self dequeueVideoItem];
}

- (void)startIdleLoop
{
    int activities = kCFRunLoopBeforeWaiting;
    
    CFRunLoopObserverContext ctxt = {0, (__bridge void *)(self), NULL, NULL, NULL};
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
    VideoClip *clip = filesForThumbnailing[0];
    
    [filesForThumbnailing removeObjectAtIndex:0];
    if ([filesForThumbnailing count] == 0) {
        [self stopIdleLoop];
    }

    [clip openMovie];
}

@end
