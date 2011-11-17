//
//  StageView.m
//  Cyclorama
//
//  Created by Iain Holmes on 31/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "ActorFilter.h"
#import "StageView.h"
#import "VideoLayer.h"

@implementation StageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];

    // Array to store the CIFilters to be applied to the video layer.
    filters = [[NSMutableArray alloc] init];
    
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
    
    [filters release];
    [super dealloc];
}

#pragma mark - Accessors

- (void)setVideo:(QTMovie *)_video
{
    if (_video == video) {
        return;
    }
    
    // Stop the video otherwise it'll just keep playing on and on and on and on...
    [video stop];
    [video gotoBeginning];
    [video release];
    
    video = [_video retain];
//    [videoLayer setMovie:video];
    [video play];
}

- (QTMovie *)video
{
    return video;
}

- (void)objectAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    ActorFilter *af = [userInfo objectForKey:@"object"];
    NSNumber *index = [userInfo objectForKey:@"index"];
    CIFilter *filter;
    
    filter = [CIFilter filterWithName:[af filterName]];
    [filter setDefaults];
    
    [filters insertObject:filter atIndex:[index unsignedIntegerValue]];
    
    VideoLayer *currentLayer = [[layerController arrangedObjects] objectAtIndex:0];
    [currentLayer setFilters:filters];
}

- (void)objectRemoved:(NSNotification *)note
{
    NSNumber *index = [[note userInfo] objectForKey:@"index"];
    [filters removeObjectAtIndex:[index unsignedIntegerValue]];

    VideoLayer *currentLayer = [[layerController arrangedObjects] objectAtIndex:0];
    [currentLayer setFilters:filters];
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

    for (ActorFilter *af in [filterController arrangedObjects]) {
        CIFilter *filter;
        
        filter = [CIFilter filterWithName:[af filterName]];
        
        // Set defaults and then anything custom
        [filter setDefaults];
        [filter setValuesForKeysWithDictionary:[af parameters]];
        
        [filters addObject:filter];
    }
    
    VideoLayer *currentLayer = [[layerController arrangedObjects] objectAtIndex:0];
    [currentLayer setFilters:filters];
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
@end
