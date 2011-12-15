//
//  StageView.m
//  Cyclorama
//
//  Created by Iain Holmes on 31/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "ActorFilter.h"
#import "StageView.h"
#import "VideoClip.h"
#import "VideoLayer.h"

@implementation StageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    parentLayer = [CALayer layer];
    [parentLayer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0)];
    [self setLayer:parentLayer];
    [self setWantsLayer:YES];
    
    /*
    videoLayer = [QTMovieLayer layer];
    [videoLayer setFrame:NSMakeRect(0.0, 0.0, frame.size.width, frame.size.height)];
    [parentLayer addSublayer:videoLayer];
    */
    return self;
}

- (void)removeFilterNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver:self
                  name:@"ObjectAdded"
                object:filterController];
    [nc removeObserver:self
                  name:@"ObjectRemoved"
                object:filterController];
}

- (void)addFilterNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self
           selector:@selector(objectAdded:)
               name:@"ObjectAdded"
             object:filterController];
    [nc addObserver:self
           selector:@selector(objectRemoved:)
               name:@"ObjectRemoved"
             object:filterController];
}

- (void)dealloc
{
    [self removeFilterNotifications];
    
    [super dealloc];
}

#pragma mark - Accessors

- (void)setVideoClip:(VideoClip *)_videoClip
{
    QTMovie *movie;
    
    if (_videoClip == videoClip) {
        return;
    }
    
    movie = [videoClip movie];
    
    // Stop the video otherwise it'll just keep playing on and on and on and on...
    [movie stop];
    [movie gotoBeginning];
    
    videoClip = [_videoClip retain];
    
    movie = [videoClip movie];
    
    VideoLayer *currentLayer = [[layerController arrangedObjects] objectAtIndex:0];
    
    NSLog(@"Playing movie on %p", currentLayer);
    [currentLayer setMovie:movie];
    [movie play];
}

- (VideoClip *)videoClip
{
    return videoClip;
}

- (void)objectAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    ActorFilter *af = [userInfo objectForKey:@"object"];
    NSNumber *index = [userInfo objectForKey:@"index"];
    CIFilter *filter;
    
    NSLog(@"Filter added %@", [af filterName]);
    filter = [CIFilter filterWithName:[af filterName]];
    [filter setName:[af filterName]];
    [filter setDefaults];
    [filter setValuesForKeysWithDictionary:[af parameters]];
    
    VideoLayer *currentLayer = [[layerController arrangedObjects] objectAtIndex:0];
    NSLog(@"Setting filter on %p", currentLayer);
    [currentLayer addFilter:filter atIndex:[index unsignedIntValue]];
}

- (void)objectRemoved:(NSNotification *)note
{
    NSNumber *index = [[note userInfo] objectForKey:@"index"];

    VideoLayer *currentLayer = [[layerController arrangedObjects] objectAtIndex:0];
    [currentLayer removeFilterAtIndex:[index unsignedIntValue]];
}

- (void)setFilterController:(CycArrayController *)_filterController
{
    if (_filterController == filterController) {
        return;
    }

    [self removeFilterNotifications];
    
    [filterController release];
    filterController = [_filterController retain];
    
    [self addFilterNotifications];

    VideoLayer *currentLayer = [[layerController arrangedObjects] objectAtIndex:0];

    int idx = 0;
    for (ActorFilter *af in [filterController arrangedObjects]) {
        CIFilter *filter;
        
        filter = [CIFilter filterWithName:[af filterName]];
        [filter setName:[af filterName]];
        
        // Set defaults and then anything custom
        [filter setDefaults];
        [filter setValuesForKeysWithDictionary:[af parameters]];
        
        [currentLayer addFilter:filter atIndex:idx];
        idx++;
    }
}

- (CycArrayController *)filterController
{
    return filterController;
}

- (void)setLayerController:(CycArrayController *)_layerController
{
    if (_layerController == layerController) {
        return;
    }
    
    [layerController release];
    layerController = [_layerController retain];
    
    for (VideoLayer *vl in [layerController arrangedObjects]) {
        [parentLayer addSublayer:vl];
        [vl setFrame:NSRectToCGRect([self bounds])];
    }
}

- (CycArrayController *)layerController
{
    return layerController;
}

- (CIFilter *)filterForCurrentLayerAt:(NSUInteger)index
{
    VideoLayer *currentLayer = [[layerController arrangedObjects] objectAtIndex:0];
    if (!currentLayer) {
        return nil;
    }
    
    return [currentLayer filterAtIndex:index];
}
@end
