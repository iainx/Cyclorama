//
//  StageView.m
//  Cyclorama
//
//  Created by Iain Holmes on 31/08/2011.
//  Copyright 2011 Sleep(5). All rights reserved.
//

#import "CycArrayController.h"
#import "ActorFilter.h"
#import "StageView.h"
#import "VideoClip.h"
#import "VideoLayer.h"
#import "FilterParameter.h"

@implementation StageView {
    CALayer *parentLayer;
}

@synthesize videoClip = _videoClip;
@synthesize filterController = _filterController;
@synthesize layerController = _layerController;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    parentLayer = [CALayer layer];
    
    CGColorRef black = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
    [parentLayer setBackgroundColor:black];
    CGColorRelease(black);
    
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
                object:_filterController];
    [nc removeObserver:self
                  name:@"ObjectRemoved"
                object:_filterController];
}

- (void)addFilterNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self
           selector:@selector(objectAdded:)
               name:@"ObjectAdded"
             object:_filterController];
    [nc addObserver:self
           selector:@selector(objectRemoved:)
               name:@"ObjectRemoved"
             object:_filterController];
}

- (void)dealloc
{
    [self removeFilterNotifications];
    
}

#pragma mark - Accessors

- (void)setVideoClip:(VideoClip *)videoClip
{
    QTMovie *movie;
    
    if (videoClip == _videoClip) {
        return;
    }
    
    movie = [videoClip movie];
    
    // Stop the video otherwise it'll just keep playing on and on and on and on...
    [movie stop];
    [movie gotoBeginning];
    
    _videoClip = videoClip;
    
    movie = [videoClip movie];
    
    VideoLayer *currentLayer = [_layerController arrangedObjects][0];
    
    NSLog(@"Playing movie %p on %p", movie, currentLayer);
    [currentLayer setMovie:movie];
    [movie play];
}

- (VideoClip *)videoClip
{
    return _videoClip;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    FilterParameter *param = (FilterParameter *)object;
    ActorFilter *af = [param filter];
    
    NSLog(@"Got change for %@ of object: %@\n%@",
          keyPath, [object description], [change description]);
    
    NSString *filterKeyPath = [NSString stringWithFormat:@"filters.%@.%@", [af uniqueID], [param name]];
    
    NSLog(@"Keypath: %@", filterKeyPath);
    VideoLayer *currentLayer = [_layerController arrangedObjects][0];
    [currentLayer setValue:[param value] forKeyPath:filterKeyPath];
}

- (void)objectAdded:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    ActorFilter *af = userInfo[@"object"];
    NSNumber *index = userInfo[@"index"];
    CIFilter *filter;
    
    NSLog(@"Filter added %@", [af filterName]);
    //filter = [CIFilter filterWithName:[af filterName]];
    filter = [af filter];
    
    NSDictionary *params = [af parameters];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        FilterParameter *param = (FilterParameter *)obj;
        
        [param addObserver:self
                forKeyPath:@"value"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
    }];
    
    VideoLayer *currentLayer = [_layerController arrangedObjects][0];
    NSLog(@"Setting filter on %p", currentLayer);
    [currentLayer addFilter:filter atIndex:[index unsignedIntValue]];
}

- (void)objectRemoved:(NSNotification *)note
{
    NSNumber *index = [note userInfo][@"index"];
    ActorFilter *af = [note userInfo][@"object"];

    NSDictionary *params = [af parameters];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [obj removeObserver:self
                 forKeyPath:@"value"];
    }];
    
    VideoLayer *currentLayer = [_layerController arrangedObjects][0];
    [currentLayer removeFilterAtIndex:[index unsignedIntValue]];
}

- (void)setFilterController:(CycArrayController *)filterController
{
    if (_filterController == filterController) {
        return;
    }

    [self removeFilterNotifications];
    
    _filterController = filterController;
    
    [self addFilterNotifications];

    VideoLayer *currentLayer = [_layerController arrangedObjects][0];

    int idx = 0;
    for (ActorFilter *af in [_filterController arrangedObjects]) {
        CIFilter *filter;
        
        NSDictionary *params = [af parameters];
        
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FilterParameter *param = (FilterParameter *)obj;
            
            [param addObserver:self
                    forKeyPath:@"value"
                       options:NSKeyValueObservingOptionNew
                       context:NULL];
        }];

        //filter = [CIFilter filterWithName:[af filterName]];
        filter = [af filter];
        
        [currentLayer addFilter:filter atIndex:idx];
        idx++;
    }
}

- (CycArrayController *)filterController
{
    return _filterController;
}

- (void)setLayerController:(CycArrayController *)layerController
{
    if (layerController == _layerController) {
        return;
    }
    
    _layerController = layerController;
    
    for (VideoLayer *vl in [_layerController arrangedObjects]) {
        [parentLayer addSublayer:vl];
        [vl setFrame:NSRectToCGRect([self bounds])];
    }
}

- (CycArrayController *)layerController
{
    return _layerController;
}

- (CIFilter *)filterForCurrentLayerAt:(NSUInteger)index
{
    VideoLayer *currentLayer = [_layerController arrangedObjects][0];
    if (!currentLayer) {
        return nil;
    }
    
    return [currentLayer filterAtIndex:index];
}
@end
